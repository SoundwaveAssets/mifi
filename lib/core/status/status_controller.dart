import 'dart:async';

import 'package:flutter/widgets.dart';

import '../api/modem_api.dart';
import '../api/modem_exception.dart';
import '../models/status_models.dart';
import '../monitoring/monitoring_service.dart';
import '../util/operators.dart';

/// Dernier relevé complet de l'état du modem.
class StatusSnapshot {
  const StatusSnapshot({
    required this.time,
    required this.status,
    this.overview,
    this.sysInfo,
    this.devices,
  });

  final DateTime time;
  final AllStatus status;
  final Overview? overview;
  final SysInfo? sysInfo;
  final List<ConnectedDevice>? devices;

  /// Opérateur déduit de l'IMSI.
  OperatorInfo? get operator => resolveOperator(status.imsi.isNotEmpty ? status.imsi : overview?.imsi);

  /// Nom de service de la SIM (ex. « blue »), si le modem le fournit.
  String? get serviceName => status.serviceName;

  /// Compteurs calculés à partir de la liste (`ethnum`/`wifinum` sont faux).
  DeviceCounts? get deviceCounts => devices == null ? null : DeviceCounts.of(devices!);
}

/// Relève l'état du modem en continu (toutes les [interval]) tant que l'appli
/// est au premier plan, avec un test réel d'internet, et transmet chaque
/// relevé à la surveillance (historique, coupures, alertes). Les détails plus
/// lourds (aperçu, système, appareils) sont relus toutes les
/// [detailsInterval].
class StatusController extends ChangeNotifier {
  StatusController({
    required this.api,
    this.monitoring,
    this.autoRepair,
    this.onStatus,
    this.probeInternet,
    this.interval = const Duration(seconds: 2),
    this.detailsInterval = const Duration(seconds: 10),
  });

  final ModemApi api;
  final MonitoringService? monitoring;

  /// Lancée quand la surveillance juge une réparation automatique utile.
  final Future<void> Function()? autoRepair;

  /// Reçoit chaque relevé réussi (maintien de la coupure d'internet).
  final Future<void> Function(AllStatus status)? onStatus;

  /// Test réel d'accès à internet à travers le modem (voir
  /// [AllStatus.withInternetCheck]).
  final Future<bool?> Function()? probeInternet;
  final Duration interval;
  final Duration detailsInterval;
  DateTime? _detailsAt;
  bool _repairing = false;
  bool _inspecting = false;

  StatusSnapshot? _snapshot;
  Object? _error;
  DateTime? _internetDownSince;
  bool _refreshing = false;
  bool _running = false;
  bool _foreground = true;
  final Set<Object> _pauses = {};
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  final _newDevices = StreamController<List<ConnectedDevice>>.broadcast();
  final _simChanges = StreamController<String>.broadcast();

  StatusSnapshot? get snapshot => _snapshot;

  /// Erreur du dernier rafraîchissement (`null` s'il a réussi).
  Object? get error => _error;
  bool get isRefreshing => _refreshing;

  /// Des données existent mais le dernier rafraîchissement a échoué : elles
  /// ne reflètent peut-être plus l'état réel (ex. téléphone hors du Wi-Fi
  /// du modem).
  bool get isStale => _snapshot != null && _error != null;

  /// Depuis combien de temps internet ne passe plus (relevés à jour
  /// uniquement), `null` s'il passe.
  Duration? get internetDownFor {
    final since = _internetDownSince;
    return since == null || isStale ? null : DateTime.now().difference(since);
  }

  /// Appareils inconnus détectés (pour une alerte dans l'interface).
  Stream<List<ConnectedDevice>> get newDevices => _newDevices.stream;

  /// IMSI d'une nouvelle SIM détectée (« Nouvelle SIM détectée »).
  Stream<String> get simChanges => _simChanges.stream;

  bool get _shouldPoll => _running && _foreground && _pauses.isEmpty;

  /// Démarre le rafraîchissement automatique (après la connexion).
  void start() {
    _lifecycle ??= AppLifecycleListener(
      onResume: () => _setForeground(true),
      onHide: () => _setForeground(false),
    );
    if (_running) return;
    _running = true;
    _reschedule(immediate: true);
  }

  /// Arrête le rafraîchissement (déconnexion).
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Suspend le rafraîchissement automatique tant que [owner] le demande
  /// (ex. jauge « meilleur emplacement », envoi du firmware).
  void pause(Object owner) {
    _pauses.add(owner);
    _timer?.cancel();
  }

  void resume(Object owner) {
    if (_pauses.remove(owner)) _reschedule(immediate: true);
  }

  void _setForeground(bool value) {
    _foreground = value;
    if (value) {
      _reschedule(immediate: true);
    } else {
      _timer?.cancel();
    }
  }

  void _reschedule({bool immediate = false}) {
    _timer?.cancel();
    if (!_shouldPoll) return;
    _timer = Timer(immediate ? Duration.zero : interval, () async {
      await refresh(details: false);
      _reschedule();
    });
  }

  /// Relevé immédiat, détails compris sauf si [details] vaut `false` (ils
  /// sont alors relus seulement s'ils datent de plus de [detailsInterval]).
  /// Sans effet si un relevé est déjà en cours.
  Future<void> refresh({bool details = true}) async {
    if (_refreshing) return;
    _refreshing = true;
    notifyListeners();
    try {
      var status = await api.getAllStatus();
      // Test réel en parallèle des autres relevés : l'état du modem ne suffit pas.
      final probe = status.isInternetConnected ? probeInternet?.call() : null;
      final previous = _snapshot;
      var overview = previous?.overview;
      var sysInfo = previous?.sysInfo;
      var devices = previous?.devices;
      final detailsAt = _detailsAt;
      final fetchDetails = details || detailsAt == null || DateTime.now().difference(detailsAt) >= detailsInterval;
      if (fetchDetails) {
        _detailsAt = DateTime.now();
        // Facultatifs : une erreur garde l'ancienne valeur.
        overview = await _optional(api.getOverview) ?? overview;
        sysInfo = await _optional(api.getSysInfo) ?? sysInfo;
        devices = await _optional(api.getConnectedDevices) ?? devices;
      }
      if (probe != null) status = status.withInternetCheck(await probe);
      _internetDownSince = status.isInternetConnected ? null : (_internetDownSince ?? DateTime.now());
      _snapshot = StatusSnapshot(
        time: DateTime.now(),
        status: status,
        overview: overview,
        sysInfo: sysInfo,
        devices: devices,
      );
      _error = null;
      try {
        final report = await monitoring?.process(status: status, devices: fetchDetails ? devices : null);
        if (report != null && report.newDevices.isNotEmpty) _newDevices.add(report.newDevices);
        if (report != null && report.simChanged) _simChanges.add(status.imsi);
        if (report != null && report.autoRepairDue) unawaited(_runAutoRepair());
      } catch (e) {
        // La surveillance ne doit jamais bloquer l'affichage.
        debugPrint('Surveillance : $e');
      }
      unawaited(_inspect(status));
    } catch (e) {
      _error = e;
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<void> _runAutoRepair() async {
    final repair = autoRepair;
    if (repair == null || _repairing) return;
    _repairing = true;
    try {
      await repair();
    } catch (e) {
      debugPrint('Réparation automatique : $e');
    } finally {
      _repairing = false;
    }
  }

  Future<void> _inspect(AllStatus status) async {
    final inspect = onStatus;
    if (inspect == null || _inspecting) return;
    _inspecting = true;
    try {
      await inspect(status);
    } catch (e) {
      debugPrint('Relevé : $e');
    } finally {
      _inspecting = false;
    }
  }

  Future<T?> _optional<T>(Future<T> Function() load) async {
    try {
      return await load();
    } on UnsupportedCommandException {
      return null;
    } on InvalidResponseException {
      return null;
    }
  }

  @override
  void dispose() {
    stop();
    _lifecycle?.dispose();
    _newDevices.close();
    _simChanges.close();
    super.dispose();
  }
}
