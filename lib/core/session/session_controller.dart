import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/modem_api.dart';
import '../api/modem_client.dart';
import '../api/modem_exception.dart';
import '../native/native_bridge.dart';
import '../settings/app_settings.dart';
import '../settings/credentials_store.dart';
import '../util/modem_address.dart';

enum SessionStatus {
  /// Démarrage : lecture du mot de passe et connexion automatique.
  starting,

  /// Non connecté : écran de connexion.
  signedOut,

  /// Connexion en cours depuis l'écran de connexion.
  signingIn,

  /// Connecté.
  signedIn,
}

/// Session de l'appli avec le modem : connexion (automatique au démarrage si
/// un mot de passe est enregistré), déconnexion, changement de mot de passe,
/// adresse du modem et attente après un redémarrage.
///
/// La reconnexion sur `SessionOut` est gérée par `ModemClient` ; ce
/// contrôleur réagit seulement quand elle devient impossible.
class SessionController extends ChangeNotifier {
  SessionController({
    required this.client,
    required this.api,
    required this.settings,
    required this.credentials,
    required this.bridge,
  }) {
    client.transport.baseUri = settings.modemBaseUri;
    _sessionLostSub = client.sessionLost.listen(_onSessionLost);
  }

  final ModemClient client;
  final ModemApi api;
  final AppSettings settings;
  final CredentialsStore credentials;
  final NativeBridge bridge;

  late final StreamSubscription<ModemException> _sessionLostSub;

  SessionStatus _status = SessionStatus.starting;
  Object? _lastError;
  bool _hasSavedPassword = false;

  SessionStatus get status => _status;
  bool get isSignedIn => _status == SessionStatus.signedIn;

  /// Erreur de la dernière connexion (affichée sur l'écran de connexion).
  Object? get lastError => _lastError;

  /// Un mot de passe est enregistré (connexion automatique possible).
  bool get hasSavedPassword => _hasSavedPassword;

  String get modemAddress => settings.modemAddress;

  /// Démarrage de l'appli : force le Wi-Fi, puis connexion automatique si un
  /// mot de passe est enregistré.
  Future<void> start() async {
    _setStatus(SessionStatus.starting);
    await bridge.bindToWifi();
    client.transport.baseUri = settings.modemBaseUri;
    final saved = await credentials.readPassword();
    _hasSavedPassword = saved != null;
    if (saved == null) {
      _setStatus(SessionStatus.signedOut);
      return;
    }
    await _login(saved, remember: true, initial: true);
  }

  /// Connexion depuis l'écran de connexion. Renvoie `true` si réussie.
  Future<bool> signIn(String password, {required bool remember}) async {
    _setStatus(SessionStatus.signingIn);
    await bridge.bindToWifi();
    return _login(password, remember: remember);
  }

  /// Nouvel essai avec le mot de passe enregistré (après une erreur réseau).
  Future<bool> retrySavedPassword() async {
    final saved = await credentials.readPassword();
    if (saved == null) return false;
    _setStatus(SessionStatus.signingIn);
    await bridge.bindToWifi();
    return _login(saved, remember: true);
  }

  Future<bool> _login(String password, {required bool remember, bool initial = false}) async {
    try {
      await client.login(ModemCredentials(password: password));
      if (remember) {
        await credentials.savePassword(password);
        _hasSavedPassword = true;
      } else if (!initial) {
        await credentials.clearPassword();
        _hasSavedPassword = false;
      }
      _lastError = null;
      _setStatus(SessionStatus.signedIn);
      return true;
    } catch (e) {
      _lastError = e;
      _setStatus(SessionStatus.signedOut);
      return false;
    }
  }

  /// Déconnexion (menu administrateur) : oublie aussi le mot de passe
  /// enregistré, sinon la connexion automatique l'annulerait.
  Future<void> signOut() async {
    await client.logout();
    await credentials.clearPassword();
    _hasSavedPassword = false;
    _lastError = null;
    _setStatus(SessionStatus.signedOut);
  }

  /// Change le mot de passe admin puis se reconnecte avec le nouveau (la
  /// session se termine côté modem). Met à jour le mot de passe enregistré.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await api.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    client.updatePassword(newPassword);
    client.dropSession();
    if (_hasSavedPassword) await credentials.savePassword(newPassword);
    try {
      await client.login(ModemCredentials(password: newPassword));
    } on ModemException {
      // La prochaine requête se reconnectera d'elle-même.
    }
  }

  /// Nouvelle adresse du modem (déjà normalisée par [ModemAddress.normalize]).
  Future<void> setModemAddress(String address) async {
    await settings.setModemAddress(address);
    client.transport.baseUri = ModemAddress.toBaseUri(address);
    client.dropSession();
    notifyListeners();
  }

  /// Après un redémarrage (DHCP, redémarrage, bascule…) : attend que le
  /// modem réponde à nouveau puis rouvre la session. Renvoie `true` si le
  /// modem est revenu avant [timeout].
  ///
  /// [isCancelled] permet d'abandonner ; [onTick] reçoit le temps écoulé.
  Future<bool> waitForModem({
    Duration timeout = const Duration(minutes: 3),
    Duration initialDelay = const Duration(seconds: 5),
    Duration interval = const Duration(seconds: 3),
    bool Function()? isCancelled,
    void Function(Duration elapsed)? onTick,
  }) async {
    final started = DateTime.now();
    Duration elapsed() => DateTime.now().difference(started);
    client.dropSession();
    await Future<void>.delayed(initialDelay);
    while (elapsed() < timeout) {
      if (isCancelled?.call() ?? false) return false;
      onTick?.call(elapsed());
      await bridge.bindToWifi();
      try {
        await api.getConfig(timeout: const Duration(seconds: 4));
        final creds = client.credentials;
        if (creds != null) await client.login(creds);
        return true;
      } on LoginFailedException catch (e) {
        // Mot de passe réinitialisé (ex. réinitialisation d'usine).
        _onSessionLost(e);
        return true;
      } on ModemException {
        await Future<void>.delayed(interval);
      }
    }
    return false;
  }

  /// Après une réinitialisation d'usine : le mot de passe revient à sa valeur
  /// d'usine, celui enregistré n'est plus valable.
  Future<void> forgetAfterFactoryReset() async {
    client.dropSession();
    await client.logout();
    await credentials.clearPassword();
    _hasSavedPassword = false;
    _lastError = null;
    _setStatus(SessionStatus.signedOut);
  }

  void _onSessionLost(ModemException error) {
    if (_status != SessionStatus.signedIn) return;
    _lastError = error;
    _setStatus(SessionStatus.signedOut);
  }

  void _setStatus(SessionStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionLostSub.cancel();
    super.dispose();
  }
}
