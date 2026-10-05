import 'dart:async';

import 'package:flutter/widgets.dart';

import 'core/app_services.dart';
import 'core/app_wiring.dart';
import 'core/background/connection_monitor.dart';
import 'core/background/task_handlers.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  wireAppServices(services);
  runApp(AppScope(services: services, child: const MifiApp()));

  unawaited(services.session.start());
  unawaited(services.scheduler.sync());
  unawaited(services.notifications.ensureChannels());
  unawaited(services.mobileData.publish());
}

/// Point d'entrée des moteurs Flutter d'arrière-plan lancés par Android
/// (WorkManager, alarmes, tuile « Réglages rapides », widget).
/// Arguments : [nom de la tâche, charge JSON].
@pragma('vm:entry-point')
Future<void> backgroundMain(List<String> args) => runBackgroundTask(args);

/// Point d'entrée de la surveillance continue (service Android au premier
/// plan, appli fermée).
@pragma('vm:entry-point')
Future<void> monitorMain() => runConnectionMonitor();
