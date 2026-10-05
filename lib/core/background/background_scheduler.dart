import '../native/native_bridge.dart';
import '../settings/app_settings.dart';
import 'background_tasks.dart';
import 'daily_time.dart';

/// Aligne les tâches Android (vérification périodique, alarme du redémarrage
/// programmé) sur les réglages. À appeler au démarrage, après chaque
/// changement de réglage et après chaque tâche programmée.
class BackgroundScheduler {
  BackgroundScheduler({required this.bridge, required this.settings, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final NativeBridge bridge;
  final AppSettings settings;
  final DateTime Function() _clock;

  /// Alarmes du mode avion programmé (retiré), annulées si une ancienne
  /// version les a laissées.
  static const List<String> _legacyAirplaneTasks = ['scheduled_airplane_on', 'scheduled_airplane_off'];

  /// Prochain redémarrage programmé, ou `null` s'il est désactivé.
  DateTime? nextReboot([DateTime? now]) => settings.rebootScheduleEnabled
      ? nextDailyOccurrence(settings.rebootScheduleMinutes, now ?? _clock())
      : null;

  Future<void> sync() async {
    final now = _clock();
    await bridge.setPeriodicCheck(enabled: settings.backgroundChecksEnabled);

    for (final task in _legacyAirplaneTasks) {
      await bridge.cancelScheduledTask(task);
    }

    final reboot = nextReboot(now);
    if (reboot != null) {
      await bridge.scheduleTask(task: BackgroundTasks.scheduledReboot, at: reboot);
    } else {
      await bridge.cancelScheduledTask(BackgroundTasks.scheduledReboot);
    }
  }
}
