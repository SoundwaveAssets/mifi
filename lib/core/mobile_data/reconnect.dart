import 'package:flutter/foundation.dart';

import '../api/modem_api.dart';
import '../api/modem_exception.dart';
import '../data/app_data_store.dart';
import '../models/mobile_models.dart';
import '../native/native_bridge.dart';
import 'data_cut.dart';

/// Étapes d'une tentative de « Relancer la connexion ».
enum ReconnectStep { cuttingNetwork, reregistering, restoringNetwork, waitingForInternet }

/// « Relancer la connexion » : comme un mode avion activé puis désactivé,
/// recommencé jusqu'au retour d'internet ou jusqu'à « Arrêter » (certaines
/// SIM ne retrouvent la connexion qu'après plusieurs coupures).
///
/// Chaque tentative coupe la connexion, pas seulement les données : profil
/// APN de coupure et réinscription du modem sur le réseau (mode réseau
/// provisoire, puis mode d'origine, toujours remis), au plus près d'un vrai
/// mode avion ; puis rétablit la connexion et attend internet.
class ReconnectController extends ChangeNotifier {
  ReconnectController({
    required this.cut,
    required this.api,
    required this.bridge,
    required this.store,
    Future<void> Function(Duration)? delay,
    DateTime Function()? clock,
  })  : _delay = delay ?? Future<void>.delayed,
        _now = clock ?? DateTime.now;

  final ApnDataCut cut;
  final ModemApi api;
  final NativeBridge bridge;
  final AppDataStore store;
  final Future<void> Function(Duration) _delay;
  final DateTime Function() _now;

  /// Réinscription au réseau dès cette tentative (toutes, par défaut).
  static const int reregisterFromAttempt = 1;

  /// Tentatives de la réparation automatique (en arrière-plan, personne ne
  /// peut l'arrêter).
  static const int autoRepairAttempts = 3;

  /// Durée de la coupure, pour que le modem décroche vraiment.
  static const Duration cutHold = Duration(seconds: 4);

  /// Durée du mode réseau provisoire pendant la réinscription.
  static const Duration reregisterHold = Duration(seconds: 6);

  /// Attente d'internet après une tentative (plus longue après une
  /// réinscription, le temps que le modem retrouve le réseau).
  static const Duration internetWait = Duration(seconds: 30);
  static const Duration internetWaitAfterReregister = Duration(seconds: 60);
  static const Duration _pollInterval = Duration(seconds: 3);

  /// Mode réseau d'origine, mémorisé pendant une réinscription.
  static const String _pendingModeKey = 'reconnect.network_mode';

  ReconnectStep? _step;
  int _attempt = 0;
  DateTime? _startedAt;
  bool _stopRequested = false;

  /// Étape en cours, `null` hors relance.
  ReconnectStep? get step => _step;
  bool get isBusy => _step != null;

  /// Tentative en cours (ou dernière tentative de la relance terminée).
  int get attempt => _attempt;
  DateTime? get startedAt => _startedAt;

  /// L'utilisateur a demandé l'arrêt (reste vrai après la relance).
  bool get stopRequested => _stopRequested;

  /// Arrête après la tentative en cours : internet y est toujours rétabli.
  void stop() {
    if (!isBusy || _stopRequested) return;
    _stopRequested = true;
    notifyListeners();
  }

  /// Recommence jusqu'au retour d'internet ou jusqu'à [stop] (au plus
  /// [maxAttempts] tentatives si précisé). Renvoie `true` si internet est
  /// revenu. Relance l'erreur si le modem refuse la coupure ou le
  /// rétablissement.
  Future<bool> reconnect({int? maxAttempts}) async {
    if (isBusy) return false;
    _stopRequested = false;
    _startedAt = _now();
    _attempt = 0;
    var cutApplied = false;
    String? originalMode;
    try {
      while (!_stopRequested && (maxAttempts == null || _attempt < maxAttempts)) {
        _attempt++;
        final reregister = _attempt >= reregisterFromAttempt;
        _setStep(ReconnectStep.cuttingNetwork);
        await cut.request(DataCutReason.reconnect);
        cutApplied = true;
        if (reregister) originalMode ??= await _readNetworkMode();
        if (reregister && originalMode != null) {
          _setStep(ReconnectStep.reregistering);
          await _reregister(originalMode);
        } else {
          await _delay(cutHold);
        }
        _setStep(ReconnectStep.restoringNetwork);
        await cut.release(DataCutReason.reconnect);
        cutApplied = false;
        _setStep(ReconnectStep.waitingForInternet);
        if (await _waitForInternet(reregister ? internetWaitAfterReregister : internetWait)) return true;
      }
      return false;
    } catch (_) {
      if (cutApplied) {
        // Internet n'a pas pu être rétabli : ne pas laisser une coupure que
        // l'utilisateur n'a pas demandée (elle serait maintenue).
        try {
          await cut.withdraw(DataCutReason.reconnect);
        } catch (_) {
          // Levée au prochain démarrage (voir ApnDataCut.releaseLeftover).
        }
      }
      rethrow;
    } finally {
      await restoreNetworkMode();
      _step = null;
      _startedAt = null;
      notifyListeners();
    }
  }

  /// Remet le mode réseau d'origine si une réinscription l'a changé (aussi
  /// au démarrage, si l'appli a été interrompue). Renvoie `false` si le
  /// modem reste injoignable : nouvel essai plus tard.
  Future<bool> restoreNetworkMode() async {
    final original = await store.readState(_pendingModeKey);
    if (original == null) return true;
    for (var i = 0; i < 3; i++) {
      try {
        await api.setNetworkMode(original);
        await store.writeState(_pendingModeKey, null);
        return true;
      } on ModemException {
        await _delay(const Duration(seconds: 2));
      }
    }
    return false;
  }

  /// Réinscription au réseau : le modem décroche (mode réseau provisoire)
  /// puis se réinscrit avec son mode d'origine.
  Future<void> _reregister(String original) async {
    await store.writeState(_pendingModeKey, original);
    try {
      await api.setNetworkMode(original == NetworkModes.only3g ? NetworkModes.auto4g3g : NetworkModes.only3g);
      await _delay(reregisterHold);
    } on ModemException {
      // Réinscription refusée : la tentative continue comme une coupure simple.
      await _delay(cutHold);
    } finally {
      await restoreNetworkMode();
    }
  }

  Future<String?> _readNetworkMode() async {
    try {
      final mode = await api.getNetworkMode();
      return NetworkModes.all.contains(mode) ? mode : null;
    } on ModemException {
      return null;
    }
  }

  /// Attend internet (test réel : l'état du modem ne suffit pas), au plus
  /// [timeout], ou jusqu'à la demande d'arrêt.
  Future<bool> _waitForInternet(Duration timeout) async {
    final deadline = _now().add(timeout);
    while (true) {
      try {
        if ((await api.getAllStatus()).isInternetConnected && await bridge.probeInternet() != false) return true;
      } on ModemException {
        // Modem encore occupé (réinscription en cours).
      }
      if (_stopRequested || !_now().isBefore(deadline)) return false;
      await _delay(_pollInterval);
    }
  }

  void _setStep(ReconnectStep step) {
    _step = step;
    notifyListeners();
  }
}
