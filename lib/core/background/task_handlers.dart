import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../api/modem_exception.dart';
import '../app_services.dart';
import '../mobile_data/data_cut.dart';
import '../models/status_models.dart';
import '../native/native_bridge.dart';
import 'background_tasks.dart';

/// Exécute les tâches lancées par Android (WorkManager, alarmes, tuiles,
/// widget). Sert dans le moteur principal (appli ouverte) comme dans un
/// moteur d'arrière-plan dédié.
class BackgroundTaskHandlers {
  BackgroundTaskHandlers(this.services);

  final AppServices services;

  Future<BackgroundTaskResult> run(String task, Map<String, Object?> payload) async {
    switch (task) {
      case BackgroundTasks.periodicCheck:
        return _periodicCheck();
      case BackgroundTasks.mobileDataToggle:
        return _mobileData();
      case BackgroundTasks.scheduledReboot:
        return _reboot();
      case BackgroundTasks.reschedule:
        await services.scheduler.sync();
        return const BackgroundTaskResult.ok();
    }
    return BackgroundTaskResult.failed('unknown task: $task');
  }

  Future<void> _ensureSignedIn() => services.ensureSignedIn();

  Future<BackgroundTaskResult> _periodicCheck() async {
    try {
      // Surveillance continue arrêtée par Android : la relancer.
      if (services.settings.monitorEnabled && !await services.bridge.isMonitorRunning()) {
        await services.bridge.startMonitor();
      }
      await _ensureSignedIn();
      var status = await services.api.getAllStatus();
      // L'état du modem ne suffit pas : test réel d'accès à internet.
      if (status.isInternetConnected) status = status.withInternetCheck(await services.bridge.probeInternet());
      List<ConnectedDevice>? devices;
      try {
        devices = await services.api.getConnectedDevices();
      } on ModemException {
        devices = null;
      }
      final report = await services.monitoring.process(status: status, devices: devices);
      await services.maintainDataCut(status);
      if (report.autoRepairDue) await services.runAutoRepair();
      return const BackgroundTaskResult.ok();
    } on ModemException catch (e) {
      // Téléphone hors du Wi-Fi du modem : rien à signaler.
      return BackgroundTaskResult.failed('$e');
    }
  }

  Future<BackgroundTaskResult> _mobileData() async {
    final mobileData = services.mobileData;
    try {
      await _ensureSignedIn();
      await mobileData.toggle();
      final problem = mobileData.lastError;
      if (problem is DataCutNotHoldingException) await services.notifications.dataCutNotHolding(problem.problem);
      return const BackgroundTaskResult.ok();
    } catch (e) {
      await mobileData.reportFailure(e);
      await services.notifications.mobileDataFailed(error: e);
      return BackgroundTaskResult.failed('$e');
    }
  }

  Future<BackgroundTaskResult> _reboot() async {
    try {
      await _ensureSignedIn();
      await services.api.reboot();
      services.client.dropSession();
      return const BackgroundTaskResult.ok();
    } catch (e) {
      await services.notifications.rebootFailed();
      return BackgroundTaskResult.failed('$e');
    } finally {
      await services.scheduler.sync();
    }
  }
}

/// Point d'entrée d'un moteur Flutter d'arrière-plan (appelé par
/// `backgroundMain` dans main.dart). Arguments : [tâche, charge JSON].
Future<void> runBackgroundTask(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final bridge = NativeBridge();
  BackgroundTaskResult result;
  try {
    var task = args.isNotEmpty ? args.first : '';
    var payloadJson = args.length > 1 ? args[1] : '';
    if (task.isEmpty) {
      // Arguments non transmis : les demander à Android.
      final pending = await bridge.backgroundTask();
      if (pending != null) (task, payloadJson) = pending;
    }
    final payload = <String, Object?>{};
    if (payloadJson.isNotEmpty) {
      final decoded = jsonDecode(payloadJson);
      if (decoded is Map) payload.addAll(decoded.cast<String, Object?>());
    }
    final services = await AppServices.create();
    result = await BackgroundTaskHandlers(services).run(task, payload).timeout(const Duration(minutes: 8));
  } catch (e) {
    result = BackgroundTaskResult.failed('$e');
  }
  await bridge.backgroundTaskCompleted(result);
}
