import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../api/modem_exception.dart';
import '../native/native_bridge.dart';
import 'data_cut.dart';

/// Façon de couper les données mobiles en gardant la SIM sur le réseau.
/// L'API n'a pas de commande dédiée.
///
/// Pour changer d'approche, écrire une autre implémentation et la fournir
/// dans `createMobileDataStrategy`.
abstract interface class MobileDataStrategy {
  /// `true` = données actives, `null` = état inconnu.
  Future<bool?> isEnabled();

  Future<void> setEnabled(bool enabled);

  /// Erreur à signaler sur l'état actuel (ex. coupure qui ne tient pas),
  /// `null` sinon.
  Future<Object?> problem();
}

MobileDataStrategy createMobileDataStrategy(ApnDataCut cut) => ApnMobileData(cut);

/// Données mobiles par le profil APN de coupure : le modem ne peut plus se
/// connecter à internet, le Wi-Fi reste actif.
class ApnMobileData implements MobileDataStrategy {
  ApnMobileData(this.cut);

  final ApnDataCut cut;

  @override
  Future<bool?> isEnabled() async {
    if (await cut.isRequested(DataCutReason.mobileDataOff)) return false;
    final blocked = await cut.isBlocked();
    if (blocked == null) return null;
    if (!blocked) return true;
    // Coupure brève de « Relancer la connexion » : les données restent
    // activées. Sinon (profil de coupure choisi ailleurs), elles sont coupées.
    return cut.isRequested(DataCutReason.reconnect);
  }

  @override
  Future<void> setEnabled(bool enabled) =>
      enabled ? cut.release(DataCutReason.mobileDataOff) : cut.request(DataCutReason.mobileDataOff);

  @override
  Future<Object?> problem() async {
    final problem = await cut.problemFor(DataCutReason.mobileDataOff);
    return problem == null ? null : DataCutNotHoldingException(problem);
  }
}

/// État des données mobiles, partagé par le tableau de bord, l'écran Réseau
/// mobile et la tuile « Réglages rapides ».
class MobileDataController extends ChangeNotifier {
  MobileDataController({
    required this.strategy,
    required this.bridge,
    required AppLocalizations Function() localizations,
  }) : _l10n = localizations;

  final MobileDataStrategy strategy;
  final NativeBridge bridge;
  final AppLocalizations Function() _l10n;

  bool? _enabled;
  bool _busy = false;
  Object? _lastError;

  /// `true` = données actives, `null` = inconnu.
  bool? get enabled => _enabled;
  bool get isBusy => _busy;
  Object? get lastError => _lastError;

  /// Internet est coupé par l'appli (données désactivées) : les barres de
  /// signal s'affichent alors vides.
  bool get connectionCut => _enabled == false;

  ToggleDisplayState get displayState {
    if (_busy) return ToggleDisplayState.switching;
    if (_lastError != null) return ToggleDisplayState.error;
    return switch (_enabled) {
      true => ToggleDisplayState.on,
      false => ToggleDisplayState.off,
      null => ToggleDisplayState.unknown,
    };
  }

  Future<void> refresh() async {
    if (_busy) return;
    try {
      _enabled = await strategy.isEnabled();
      _lastError = await strategy.problem();
    } on ModemException {
      // Modem injoignable : on garde la dernière valeur connue.
    }
    notifyListeners();
    await publish();
  }

  Future<void> toggle() async {
    final current = _enabled ?? await strategy.isEnabled() ?? true;
    await setEnabled(!current);
  }

  /// Active ou coupe les données. Relance l'erreur en cas d'échec.
  Future<void> setEnabled(bool value) async {
    if (_busy) return;
    _busy = true;
    _lastError = null;
    notifyListeners();
    await publish();
    try {
      await strategy.setEnabled(value);
      _enabled = value;
      _lastError = await strategy.problem();
    } catch (e) {
      _lastError = e;
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
      await publish();
    }
  }

  /// Signale un échec survenu avant la bascule (tâche d'arrière-plan).
  Future<void> reportFailure(Object error) {
    _lastError = error;
    notifyListeners();
    return publish();
  }

  /// Publie l'état et ses textes traduits vers la tuile Android.
  Future<void> publish() {
    final l = _l10n();
    final state = displayState;
    return bridge.publishToggleState(
      toggle: QuickToggle.mobileData,
      state: state,
      label: l.mobileDataTitle,
      stateText: switch (state) {
        ToggleDisplayState.on => l.mobileDataStateOn,
        ToggleDisplayState.off => l.mobileDataStateOff,
        ToggleDisplayState.switching => l.mobileDataSwitching,
        ToggleDisplayState.error when _lastError is DataCutNotHoldingException => l.dataCutNotHoldingShort,
        ToggleDisplayState.error => l.mobileDataSwitchFailed,
        ToggleDisplayState.unknown => l.airplaneStateUnknown,
      },
      switchingText: l.mobileDataSwitching,
    );
  }

}
