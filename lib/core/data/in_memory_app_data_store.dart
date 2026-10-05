import '../models/status_models.dart';
import 'app_data_store.dart';

/// [AppDataStore] en mémoire, pour les tests (et en secours si SQLite est
/// indisponible).
class InMemoryAppDataStore implements AppDataStore {
  final List<SignalSample> _samples = [];
  final List<Outage> _outages = [];
  final Map<String, KnownDevice> _devices = {};
  final List<SpeedTestResult> _speedTests = [];
  final Map<String, String> _state = {};
  int _nextId = 1;

  @override
  Future<void> addSignalSample(SignalSample sample) async => _samples.add(sample);

  @override
  Future<List<SignalSample>> signalSamplesSince(DateTime from) async =>
      _samples.where((s) => !s.time.isBefore(from)).toList()..sort((a, b) => a.time.compareTo(b.time));

  @override
  Future<void> deleteSignalSamplesBefore(DateTime time) async => _samples.removeWhere((s) => s.time.isBefore(time));

  @override
  Future<Outage?> ongoingOutage() async {
    for (final outage in _outages.reversed) {
      if (outage.isOngoing) return outage;
    }
    return null;
  }

  @override
  Future<Outage> startOutage(DateTime start, {bool planned = false, String? operatorCode}) async {
    final existing = await ongoingOutage();
    if (existing != null) return existing;
    final outage = Outage(id: _nextId++, start: start, planned: planned, operatorCode: operatorCode);
    _outages.add(outage);
    return outage;
  }

  @override
  Future<Outage?> endOngoingOutage(DateTime end) async {
    final ongoing = await ongoingOutage();
    if (ongoing == null) return null;
    final safeEnd = end.isBefore(ongoing.start) ? ongoing.start : end;
    final ended = Outage(
        id: ongoing.id, start: ongoing.start, end: safeEnd, planned: ongoing.planned, operatorCode: ongoing.operatorCode);
    _outages[_outages.indexOf(ongoing)] = ended;
    return ended;
  }

  @override
  Future<List<Outage>> recentOutages({int limit = 200}) async =>
      (_outages.toList()..sort((a, b) => b.start.compareTo(a.start))).take(limit).toList();

  @override
  Future<List<Outage>> outagesSince(DateTime from) async => (_outages
          .where((o) => !o.start.isBefore(from) || o.end == null || !o.end!.isBefore(from))
          .toList()
        ..sort((a, b) => b.start.compareTo(a.start)));

  @override
  Future<void> clearOutages() async => _outages.clear();

  @override
  Future<List<KnownDevice>> knownDevices() async =>
      _devices.values.toList()..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

  @override
  Future<List<ConnectedDevice>> recordSeenDevices(List<ConnectedDevice> devices, DateTime time) async {
    final firstRun = _devices.isEmpty;
    final unknown = <ConnectedDevice>[];
    for (final device in devices) {
      if (device.mac.isEmpty) continue;
      final known = _devices[device.mac];
      _devices[device.mac] = KnownDevice(
        mac: device.mac,
        nickname: known?.nickname,
        firstSeen: known?.firstSeen ?? time,
        lastSeen: time,
        lastName: device.name,
        lastIp: device.ip,
      );
      if (known == null && !firstRun) unknown.add(device);
    }
    return unknown;
  }

  @override
  Future<void> setNickname(String mac, String? nickname) async {
    final key = ConnectedDevice.normalizeMac(mac);
    final value = (nickname == null || nickname.trim().isEmpty) ? null : nickname.trim();
    final known = _devices[key];
    final now = DateTime.now();
    _devices[key] = KnownDevice(
      mac: key,
      nickname: value,
      firstSeen: known?.firstSeen ?? now,
      lastSeen: known?.lastSeen ?? now,
      lastName: known?.lastName,
      lastIp: known?.lastIp,
    );
  }

  @override
  Future<SpeedTestResult> addSpeedTest(SpeedTestResult result) async {
    final stored = SpeedTestResult(
      id: _nextId++,
      time: result.time,
      bytes: result.bytes,
      duration: result.duration,
      latency: result.latency,
      url: result.url,
      operatorCode: result.operatorCode,
    );
    _speedTests.add(stored);
    return stored;
  }

  @override
  Future<List<SpeedTestResult>> recentSpeedTests({int limit = 100}) async =>
      (_speedTests.toList()..sort((a, b) => b.time.compareTo(a.time))).take(limit).toList();

  @override
  Future<void> clearSpeedTests() async => _speedTests.clear();

  @override
  Future<String?> readState(String key) async => _state[key];

  @override
  Future<void> writeState(String key, String? value) async {
    if (value == null) {
      _state.remove(key);
    } else {
      _state[key] = value;
    }
  }
}
