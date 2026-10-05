import '../data/app_data_store.dart';
import '../models/status_models.dart';
import '../settings/app_settings.dart';
import '../util/signal.dart';
import 'notification_service.dart';

/// Ce qu'un relevé a changé (pour l'interface).
class MonitoringReport {
  const MonitoringReport({
    this.newDevices = const [],
    this.outageStarted,
    this.outageEnded,
    this.simChanged = false,
    this.autoRepairDue = false,
  });

  /// Appareils jamais vus jusqu'ici (MAC inconnue).
  final List<ConnectedDevice> newDevices;
  final Outage? outageStarted;
  final Outage? outageEnded;

  /// Une autre SIM que la précédente vient d'être détectée.
  final bool simChanged;

  /// Internet est coupé depuis un moment alors que le signal est bon : il
  /// faut lancer « Relancer la connexion » (réparation automatique).
  final bool autoRepairDue;
}

/// Surveillance commune au premier plan (rafraîchissement toutes les 10 s) et
/// à l'arrière-plan (WorkManager, ~15 min) :
/// - historique du signal (avec l'opérateur, pour le comparatif) ;
/// - journal des coupures (passages de `internetState` à "disconnected" et
///   retours) ;
/// - alerte « signal faible » (avec hystérésis) ;
/// - détection des appareils inconnus et des changements de SIM ;
/// - décision de réparation automatique.
class MonitoringService {
  MonitoringService({
    required this.store,
    required this.notifications,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDataStore store;
  final NotificationService notifications;
  final AppSettings settings;
  final DateTime Function() _clock;

  /// Durée de conservation de l'historique du signal (comparatif sur 7 jours).
  static const Duration signalRetention = Duration(days: 7);

  /// Un point d'historique du signal au plus toutes les 30 s (les relevés,
  /// eux, sont bien plus fréquents).
  static const Duration signalSampleInterval = Duration(seconds: 30);

  /// Une perte d'internet n'est retenue (journal, alerte) qu'après ce délai
  /// sans internet : un test raté isolé ne déclenche pas de fausse alerte.
  static const Duration outageConfirmDelay = Duration(seconds: 5);

  DateTime? _lastSignalSample;

  /// Réparation automatique : coupure minimale avant d'agir…
  static const Duration autoRepairAfter = Duration(minutes: 3);

  /// … et délai minimal entre deux tentatives.
  static const Duration autoRepairCooldown = Duration(minutes: 30);

  /// Préfixe des clés mémorisant le nom de service vu pour un opérateur.
  static const String operatorNameKeyPrefix = 'operator.name.';

  Future<MonitoringReport> process({required AllStatus status, List<ConnectedDevice>? devices}) async {
    final now = _clock();
    // Coupure volontaire (données coupées ou « Relancer la connexion »).
    final cutExpected = await store.readState(MonitorStateKeys.reconnectCut) == '1' ||
        await store.readState(MonitorStateKeys.mobileDataOffExpected) == '1';
    final operatorCode = status.hasSim ? status.operator?.code : null;

    // Nom de service vu pour cet opérateur (affiché dans le comparatif).
    final serviceName = status.serviceName;
    if (operatorCode != null && serviceName != null) {
      final key = '$operatorNameKeyPrefix$operatorCode';
      if (await store.readState(key) != serviceName) await store.writeState(key, serviceName);
    }

    // 1. Historique du signal.
    final dbm = status.signalDbm;
    final lastSample = _lastSignalSample;
    if (status.hasSim &&
        isValidSignalDbm(dbm) &&
        (lastSample == null || now.difference(lastSample) >= signalSampleInterval)) {
      _lastSignalSample = now;
      await store.addSignalSample(SignalSample(time: now, dbm: dbm!, operatorCode: operatorCode));
    }
    await _pruneIfNeeded(now);

    // 2. Coupures d'internet, datées du premier relevé sans internet.
    Outage? started;
    Outage? ended;
    final previous = await store.readState(MonitorStateKeys.internet);
    if (status.isInternetConnected) {
      await store.writeState(MonitorStateKeys.internetDownSince, null);
      if (previous != 'up') {
        await store.writeState(MonitorStateKeys.internet, 'up');
        ended = await store.endOngoingOutage(now);
        if (previous != null && ended != null && !ended.planned) {
          await notifications.internetRestored(ended.duration(now));
        }
      }
    } else if (previous != 'down') {
      final since = int.tryParse(await store.readState(MonitorStateKeys.internetDownSince) ?? '');
      if (since == null) await store.writeState(MonitorStateKeys.internetDownSince, '${now.millisecondsSinceEpoch}');
      final downSince = since == null ? now : DateTime.fromMillisecondsSinceEpoch(since);
      // Confirmée après le délai ; tout de suite pour une coupure volontaire
      // ou au tout premier relevé (sans alerte dans ces deux cas).
      if (cutExpected || previous == null || now.difference(downSince) >= outageConfirmDelay) {
        await store.writeState(MonitorStateKeys.internet, 'down');
        await store.writeState(MonitorStateKeys.internetDownSince, null);
        started = await store.startOutage(downSince, planned: cutExpected, operatorCode: operatorCode);
        if (previous != null && !started.planned) await notifications.internetDown();
      }
    }

    // 3. Signal faible (une alerte, puis silence jusqu'au retour à 3 barres).
    final alerted = await store.readState(MonitorStateKeys.lowSignalAlerted) == '1';
    final bars = status.signalBars;
    if (status.hasSim && !cutExpected && isValidSignalDbm(dbm) && bars <= lowSignalMaxBars) {
      if (!alerted) {
        await store.writeState(MonitorStateKeys.lowSignalAlerted, '1');
        await notifications.lowSignal(dbm!);
      }
    } else if (alerted && bars >= lowSignalRecoveryBars) {
      await store.writeState(MonitorStateKeys.lowSignalAlerted, null);
    }

    // 4. Appareils inconnus.
    var newDevices = const <ConnectedDevice>[];
    if (devices != null) {
      newDevices = await store.recordSeenDevices(devices, now);
      for (final device in newDevices) {
        await notifications.newDevice(device);
      }
    }

    // 5. Changement de SIM (IMSI différent de celui vu la dernière fois).
    var simChanged = false;
    final imsi = status.imsi;
    if (status.hasSim && imsi.length >= 5) {
      final lastImsi = await store.readState(MonitorStateKeys.lastImsi);
      if (lastImsi != imsi) {
        await store.writeState(MonitorStateKeys.lastImsi, imsi);
        if (lastImsi != null) {
          await store.writeState(MonitorStateKeys.pendingSimChange, imsi);
          simChanged = true;
        }
      }
    }

    // 6. Réparation automatique.
    final autoRepairDue = await _isAutoRepairDue(status, cutExpected, now);

    return MonitoringReport(
      newDevices: newDevices,
      outageStarted: started,
      outageEnded: ended,
      simChanged: simChanged,
      autoRepairDue: autoRepairDue,
    );
  }

  Future<bool> _isAutoRepairDue(AllStatus status, bool cutExpected, DateTime now) async {
    if (!settings.autoRepairEnabled || cutExpected) return false;
    if (status.isInternetConnected || !status.hasSim) return false;
    // Signal correct : la coupure vient du réseau mobile, pas de l'emplacement.
    if (status.signalBars < 2) return false;
    final outage = await store.ongoingOutage();
    if (outage == null || outage.planned || outage.duration(now) < autoRepairAfter) return false;
    final last = int.tryParse(await store.readState(MonitorStateKeys.lastAutoRepair) ?? '');
    if (last != null && now.millisecondsSinceEpoch - last < autoRepairCooldown.inMilliseconds) return false;
    await store.writeState(MonitorStateKeys.lastAutoRepair, '${now.millisecondsSinceEpoch}');
    return true;
  }

  /// Nouvelle SIM détectée mais pas encore signalée (par exemple pendant une
  /// vérification en arrière-plan) : son IMSI, sinon `null`.
  Future<String?> pendingSimChange() => store.readState(MonitorStateKeys.pendingSimChange);

  /// L'utilisateur a vu l'information « Nouvelle SIM détectée ».
  Future<void> acknowledgeSimChange() => store.writeState(MonitorStateKeys.pendingSimChange, null);

  /// Nom de service mémorisé pour un opérateur (ex. « blue » pour 624-05).
  Future<String?> serviceNameFor(String operatorCode) =>
      store.readState('$operatorNameKeyPrefix$operatorCode');

  Future<void> _pruneIfNeeded(DateTime now) async {
    final last = int.tryParse(await store.readState(MonitorStateKeys.lastPrune) ?? '');
    if (last != null && now.millisecondsSinceEpoch - last < const Duration(hours: 1).inMilliseconds) return;
    await store.deleteSignalSamplesBefore(now.subtract(signalRetention));
    await store.writeState(MonitorStateKeys.lastPrune, '${now.millisecondsSinceEpoch}');
  }
}
