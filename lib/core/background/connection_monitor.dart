import 'dart:async';

import 'package:flutter/widgets.dart';

import '../api/modem_exception.dart';
import '../app_services.dart';
import '../app_wiring.dart';
import '../models/status_models.dart';
import '../status/status_controller.dart';
import 'task_handlers.dart';

/// Surveillance continue, appli fermée (service Android au premier plan) :
/// le même traitement que l'appli ouverte (journal des coupures, alertes,
/// maintien de la coupure des données, réparation automatique, widget),
/// avec des relevés économes :
/// - toutes les [calmInterval] quand internet passe ;
/// - toutes les [alertInterval] quand il ne passe plus, pour voir vite son
///   retour ;
/// - en pause quand l'appli est affichée (elle relève elle-même, toutes les
///   2 s) ;
/// - sans verrou d'éveil : en veille profonde, Android espace les relevés.
class ConnectionMonitor {
  ConnectionMonitor(this.services);

  final AppServices services;

  static const Duration calmInterval = Duration(seconds: 15);
  static const Duration alertInterval = Duration(seconds: 5);
  static const Duration pausedInterval = Duration(seconds: 5);

  Future<void> run() async {
    while (true) {
      await Future<void>.delayed(await _tick());
    }
  }

  /// Un passage de la boucle ; renvoie le délai avant le suivant.
  Future<Duration> _tick() async {
    try {
      if (await services.bridge.isAppVisible()) return pausedInterval;
      // Réglages modifiés depuis l'interface (autre moteur Flutter).
      await services.settings.reload();
      if (!services.settings.monitorEnabled) {
        await services.bridge.stopMonitor();
        return calmInterval;
      }
      return await check() ? calmInterval : alertInterval;
    } on SessionExpiredException {
      // Aucun mot de passe mémorisé : surveillance impossible.
      await services.bridge.stopMonitor();
      return calmInterval;
    } on ModemException {
      // Modem injoignable (téléphone hors de son Wi-Fi) : nouvel essai.
      return calmInterval;
    } catch (e) {
      debugPrint('Surveillance continue : $e');
      return calmInterval;
    }
  }

  /// Un relevé complet. Renvoie `true` si internet passe.
  Future<bool> check() async {
    await services.ensureSignedIn();
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
    publishStatusWidget(services, StatusSnapshot(time: DateTime.now(), status: status, devices: devices));
    if (report.autoRepairDue) await services.runAutoRepair();
    return status.isInternetConnected;
  }
}

/// Point d'entrée du moteur Flutter de la surveillance continue (appelé
/// par `monitorMain` dans main.dart).
Future<void> runConnectionMonitor() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  // Tâches Android (tuile, programmation…) confiées à ce moteur : une seule
  // session avec le modem.
  services.bridge.listen(taskHandler: BackgroundTaskHandlers(services).run);
  await services.notifications.ensureChannels();
  await ConnectionMonitor(services).run();
}
