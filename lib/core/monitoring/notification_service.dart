import '../../l10n/app_localizations.dart';
import '../api/modem_exception.dart';
import '../background/background_tasks.dart';
import '../l10n/formatters.dart';
import '../mobile_data/data_cut.dart';
import '../models/status_models.dart';
import '../native/native_bridge.dart';
import '../settings/app_settings.dart';

/// Identifiants des canaux de notification Android.
abstract final class NotificationChannels {
  static const alerts = 'alerts';
  static const devices = 'devices';
  /// Données mobiles et programmations (identifiant hérité du mode avion,
  /// retiré).
  static const airplane = 'airplane';
}

/// Notifications système, avec textes traduits et réglages de l'utilisateur.
///
/// Fonctionne au premier plan comme dans les tâches d'arrière-plan.
class NotificationService {
  NotificationService({
    required this.bridge,
    required this.settings,
    required AppLocalizations Function() localizations,
  }) : _l10n = localizations;

  final NativeBridge bridge;
  final AppSettings settings;
  final AppLocalizations Function() _l10n;

  static const int _internetId = 1001;
  static const int _lowSignalId = 1002;
  static const int _airplaneId = 1003;
  static const int _rebootId = 1004;
  static const int _deviceIdBase = 2000;

  /// Crée ou renomme les canaux (à rappeler quand la langue change).
  Future<void> ensureChannels() {
    final l = _l10n();
    return bridge.ensureNotificationChannels([
      NotificationChannelSpec(
        id: NotificationChannels.alerts,
        name: l.notifChannelAlerts,
        description: l.notifChannelAlertsDescription,
        highImportance: true,
      ),
      NotificationChannelSpec(
        id: NotificationChannels.devices,
        name: l.notifChannelDevices,
        description: l.notifChannelDevicesDescription,
        highImportance: true,
      ),
      NotificationChannelSpec(
        id: NotificationChannels.airplane,
        name: l.notifChannelAirplane,
        description: l.notifChannelAirplaneDescription,
      ),
    ]);
  }

  Future<void> internetDown() async {
    if (!settings.notificationsEnabled || !settings.notifyInternetDown) return;
    final l = _l10n();
    await _show(_internetId, NotificationChannels.alerts, l.notifInternetDownTitle, l.notifInternetDownBody);
  }

  Future<void> internetRestored(Duration downtime) async {
    if (!settings.notificationsEnabled || !settings.notifyInternetUp) return;
    final l = _l10n();
    await _show(_internetId, NotificationChannels.alerts, l.notifInternetUpTitle,
        l.notifInternetUpBody(formatDuration(l, downtime)));
  }

  Future<void> lowSignal(int dbm) async {
    if (!settings.notificationsEnabled || !settings.notifyLowSignal) return;
    final l = _l10n();
    await _show(_lowSignalId, NotificationChannels.alerts, l.notifLowSignalTitle, l.notifLowSignalBody(dbm));
  }

  /// Appareil inconnu : un appui ouvre la liste des appareils, le bouton
  /// propose directement « Expulser les intrus ».
  Future<void> newDevice(ConnectedDevice device) async {
    if (!settings.notificationsEnabled || !settings.notifyNewDevice) return;
    final l = _l10n();
    final name = device.name.isEmpty ? l.unnamedDevice : device.name;
    await _show(
      _deviceIdBase + device.mac.hashCode.abs() % 1000,
      NotificationChannels.devices,
      l.notifNewDeviceTitle,
      l.notifNewDeviceBody(name, device.mac),
      route: AppRoutes.devices,
      actionLabel: l.expelTitle,
      actionRoute: AppRoutes.expelIntruders,
    );
  }

  /// Échec d'une bascule des données mobiles depuis la tuile. Toujours
  /// affichée : l'utilisateur doit le savoir.
  Future<void> mobileDataFailed({Object? error}) async {
    final l = _l10n();
    await _show(_airplaneId, NotificationChannels.airplane, l.notifMobileDataFailedTitle, _toggleFailedBody(l, error));
  }

  /// Coupure d'internet (données coupées) qui ne tient pas.
  /// Toujours affichée : internet passe alors que l'utilisateur l'a coupé.
  Future<void> dataCutNotHolding(DataCutProblem problem) async {
    final l = _l10n();
    await _show(_airplaneId, NotificationChannels.airplane, l.dataCutNotHoldingTitle, switch (problem) {
      DataCutProblem.profileLost => l.dataCutProfileLost,
      DataCutProblem.internetStillUp => l.dataCutInternetStillUp,
    });
  }

  /// Cause d'un échec de bascule, selon l'erreur (modem injoignable par défaut).
  String _toggleFailedBody(AppLocalizations l, Object? error) => switch (error) {
        DataCutFailedException() || CommandFailedException() => l.notifToggleRefusedBody,
        LoginFailedException() || SessionExpiredException() => l.notifToggleLoginFailedBody,
        _ => l.notifAirplaneFailedBody,
      };

  /// Échec du redémarrage programmé.
  Future<void> rebootFailed() async {
    final l = _l10n();
    await _show(_rebootId, NotificationChannels.airplane, l.notifRebootFailedTitle, l.notifRebootFailedBody);
  }

  /// Réparation automatique lancée (si les alertes internet sont activées).
  Future<void> autoRepairStarted() async {
    if (!settings.notificationsEnabled || !settings.notifyInternetDown) return;
    final l = _l10n();
    await _show(_internetId, NotificationChannels.alerts, l.notifAutoRepairTitle, l.notifAutoRepairStarted);
  }

  /// Résultat de la réparation automatique.
  Future<void> autoRepairFinished({required bool restored}) async {
    if (!settings.notificationsEnabled) return;
    final l = _l10n();
    await _show(_internetId, NotificationChannels.alerts, l.notifAutoRepairTitle,
        restored ? l.notifAutoRepairSucceeded : l.notifAutoRepairFailed);
  }

  Future<void> _show(
    int id,
    String channel,
    String title,
    String body, {
    String? route,
    String? actionLabel,
    String? actionRoute,
  }) async {
    await ensureChannels();
    await bridge.showNotification(
      id: id,
      channelId: channel,
      title: title,
      body: body,
      route: route,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }
}
