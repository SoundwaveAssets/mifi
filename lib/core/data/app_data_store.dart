import '../models/status_models.dart';

/// Mesure de signal enregistrée.
class SignalSample {
  const SignalSample({required this.time, required this.dbm, this.operatorCode});

  final DateTime time;
  final int dbm;

  /// Opérateur de la SIM au moment de la mesure (`624-05`…).
  final String? operatorCode;
}

/// Coupure d'internet (`internetState` passé à "disconnected").
class Outage {
  const Outage({required this.id, required this.start, this.end, this.planned = false, this.operatorCode});

  final int id;
  final DateTime start;

  /// `null` tant que la coupure est en cours.
  final DateTime? end;

  /// Coupure volontaire (données coupées ou connexion relancée par l'appli).
  final bool planned;

  /// Opérateur de la SIM au début de la coupure.
  final String? operatorCode;

  bool get isOngoing => end == null;

  /// Durée (jusqu'à [now] si la coupure est en cours).
  Duration duration([DateTime? now]) => (end ?? now ?? DateTime.now()).difference(start);
}

/// Appareil déjà vu sur le Wi-Fi du modem.
class KnownDevice {
  const KnownDevice({
    required this.mac,
    required this.firstSeen,
    required this.lastSeen,
    this.nickname,
    this.lastName,
    this.lastIp,
  });

  final String mac;
  final DateTime firstSeen;
  final DateTime lastSeen;

  /// Surnom donné dans l'appli (mémorisé par adresse MAC).
  final String? nickname;

  /// Dernier nom annoncé par l'appareil.
  final String? lastName;
  final String? lastIp;
}

/// Résultat d'un test de débit.
class SpeedTestResult {
  const SpeedTestResult({
    this.id,
    required this.time,
    required this.bytes,
    required this.duration,
    this.latency,
    this.url,
    this.operatorCode,
  });

  final int? id;
  final DateTime time;
  final int bytes;

  /// Durée du transfert (du premier au dernier octet).
  final Duration duration;

  /// Délai avant le premier octet (latence approximative).
  final Duration? latency;
  final String? url;

  /// Opérateur de la SIM pendant le test.
  final String? operatorCode;

  /// Débit en mégabits par seconde.
  double get megabitsPerSecond =>
      duration.inMicroseconds <= 0 ? 0 : bytes * 8 / duration.inMicroseconds;
}

/// Stockage local de l'appli (historiques, appareils, état de surveillance).
///
/// Partagé entre l'interface et les tâches d'arrière-plan (WorkManager).
abstract interface class AppDataStore {
  // Historique du signal.
  Future<void> addSignalSample(SignalSample sample);
  Future<List<SignalSample>> signalSamplesSince(DateTime from);
  Future<void> deleteSignalSamplesBefore(DateTime time);

  // Journal des coupures.
  Future<Outage?> ongoingOutage();
  Future<Outage> startOutage(DateTime start, {bool planned = false, String? operatorCode});

  /// Termine la coupure en cours et la renvoie (`null` s'il n'y en a pas).
  Future<Outage?> endOngoingOutage(DateTime end);
  Future<List<Outage>> recentOutages({int limit = 200});
  Future<List<Outage>> outagesSince(DateTime from);
  Future<void> clearOutages();

  // Appareils connus.
  Future<List<KnownDevice>> knownDevices();

  /// Enregistre les appareils vus à [time] et renvoie ceux qui n'avaient
  /// jamais été vus. Au tout premier relevé (registre vide), rien n'est
  /// signalé : les appareils présents servent de référence.
  Future<List<ConnectedDevice>> recordSeenDevices(List<ConnectedDevice> devices, DateTime time);

  /// Surnom d'un appareil (`null` ou vide pour l'effacer).
  Future<void> setNickname(String mac, String? nickname);

  // Tests de débit.
  Future<SpeedTestResult> addSpeedTest(SpeedTestResult result);
  Future<List<SpeedTestResult>> recentSpeedTests({int limit = 100});
  Future<void> clearSpeedTests();

  // État de surveillance (clé → valeur).
  Future<String?> readState(String key);
  Future<void> writeState(String key, String? value);
}

/// Clés de [AppDataStore.readState].
abstract final class MonitorStateKeys {
  /// Dernier état internet retenu : "up" ou "down".
  static const internet = 'monitor.internet';

  /// Début (millisecondes depuis l'époque) d'une perte d'internet observée
  /// mais pas encore confirmée.
  static const internetDownSince = 'monitor.internet_down_since';

  /// "1" quand une alerte « signal faible » a été envoyée.
  static const lowSignalAlerted = 'monitor.low_signal';

  /// "1" pendant la coupure brève de « Relancer la connexion » (coupure
  /// volontaire). Nom hérité du mode avion, retiré : une valeur laissée par
  /// une ancienne version est levée au démarrage.
  static const reconnectCut = 'monitor.airplane_expected';

  /// "1" quand l'appli a coupé les données mobiles (coupure volontaire).
  static const mobileDataOffExpected = 'monitor.mobile_data_off';

  /// Dernière purge de l'historique (millisecondes depuis l'époque).
  static const lastPrune = 'monitor.last_prune';

  /// Dernier IMSI vu (détection d'un changement de SIM).
  static const lastImsi = 'monitor.last_imsi';

  /// IMSI d'une nouvelle SIM pas encore signalée à l'utilisateur.
  static const pendingSimChange = 'monitor.pending_sim_change';

  /// Dernière réparation automatique (millisecondes depuis l'époque).
  static const lastAutoRepair = 'monitor.last_auto_repair';
}
