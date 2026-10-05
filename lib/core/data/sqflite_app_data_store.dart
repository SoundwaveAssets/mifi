import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/status_models.dart';
import 'app_data_store.dart';

/// Implémentation SQLite de [AppDataStore] (fichier `mifi.db`).
class SqfliteAppDataStore implements AppDataStore {
  SqfliteAppDataStore._(this._db);

  final Database _db;

  static Future<SqfliteAppDataStore>? _instance;

  /// Ouvre (une seule fois par isolate) la base de données.
  static Future<SqfliteAppDataStore> open() => _instance ??= _open();

  static Future<SqfliteAppDataStore> _open() async {
    final path = p.join(await getDatabasesPath(), 'mifi.db');
    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // L'interface et les tâches d'arrière-plan peuvent écrire en même temps.
        await db.rawQuery('PRAGMA journal_mode=WAL');
        await db.rawQuery('PRAGMA busy_timeout=5000');
      },
      onCreate: (db, version) async {
        final batch = db.batch()
          ..execute('CREATE TABLE signal_samples (ts INTEGER NOT NULL, dbm INTEGER NOT NULL, operator TEXT)')
          ..execute('CREATE INDEX idx_signal_ts ON signal_samples (ts)')
          ..execute('CREATE TABLE outages (id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'started_at INTEGER NOT NULL, ended_at INTEGER, planned INTEGER NOT NULL DEFAULT 0, operator TEXT)')
          ..execute('CREATE TABLE devices (mac TEXT PRIMARY KEY, nickname TEXT, '
              'first_seen INTEGER NOT NULL, last_seen INTEGER NOT NULL, last_name TEXT, last_ip TEXT)')
          ..execute('CREATE TABLE speed_tests (id INTEGER PRIMARY KEY AUTOINCREMENT, ts INTEGER NOT NULL, '
              'bytes INTEGER NOT NULL, duration_ms INTEGER NOT NULL, latency_ms INTEGER, url TEXT, operator TEXT)')
          ..execute('CREATE TABLE kv (key TEXT PRIMARY KEY, value TEXT)');
        await batch.commit(noResult: true);
      },
    );
    return SqfliteAppDataStore._(db);
  }

  static int _ms(DateTime t) => t.millisecondsSinceEpoch;
  static DateTime _time(Object? ms) => DateTime.fromMillisecondsSinceEpoch(ms as int);

  // ----------------------------------------------------------------- Signal

  @override
  Future<void> addSignalSample(SignalSample sample) => _db.insert(
      'signal_samples', {'ts': _ms(sample.time), 'dbm': sample.dbm, 'operator': sample.operatorCode});

  @override
  Future<List<SignalSample>> signalSamplesSince(DateTime from) async {
    final rows = await _db.query('signal_samples', where: 'ts >= ?', whereArgs: [_ms(from)], orderBy: 'ts ASC');
    return [
      for (final r in rows)
        SignalSample(time: _time(r['ts']), dbm: r['dbm'] as int, operatorCode: r['operator'] as String?),
    ];
  }

  @override
  Future<void> deleteSignalSamplesBefore(DateTime time) =>
      _db.delete('signal_samples', where: 'ts < ?', whereArgs: [_ms(time)]);

  // --------------------------------------------------------------- Coupures

  Outage _outage(Map<String, Object?> r) => Outage(
        id: r['id'] as int,
        start: _time(r['started_at']),
        end: r['ended_at'] == null ? null : _time(r['ended_at']),
        planned: (r['planned'] as int? ?? 0) != 0,
        operatorCode: r['operator'] as String?,
      );

  @override
  Future<Outage?> ongoingOutage() async {
    final rows = await _db.query('outages', where: 'ended_at IS NULL', orderBy: 'started_at DESC', limit: 1);
    return rows.isEmpty ? null : _outage(rows.first);
  }

  @override
  Future<Outage> startOutage(DateTime start, {bool planned = false, String? operatorCode}) async {
    final existing = await ongoingOutage();
    if (existing != null) return existing;
    final id = await _db.insert(
        'outages', {'started_at': _ms(start), 'planned': planned ? 1 : 0, 'operator': operatorCode});
    return Outage(id: id, start: start, planned: planned, operatorCode: operatorCode);
  }

  @override
  Future<Outage?> endOngoingOutage(DateTime end) async {
    final ongoing = await ongoingOutage();
    if (ongoing == null) return null;
    final safeEnd = end.isBefore(ongoing.start) ? ongoing.start : end;
    await _db.update('outages', {'ended_at': _ms(safeEnd)}, where: 'id = ?', whereArgs: [ongoing.id]);
    return Outage(
        id: ongoing.id, start: ongoing.start, end: safeEnd, planned: ongoing.planned, operatorCode: ongoing.operatorCode);
  }

  @override
  Future<List<Outage>> recentOutages({int limit = 200}) async {
    final rows = await _db.query('outages', orderBy: 'started_at DESC', limit: limit);
    return rows.map(_outage).toList();
  }

  @override
  Future<List<Outage>> outagesSince(DateTime from) async {
    final rows = await _db.query('outages',
        where: 'started_at >= ? OR ended_at IS NULL OR ended_at >= ?',
        whereArgs: [_ms(from), _ms(from)],
        orderBy: 'started_at DESC');
    return rows.map(_outage).toList();
  }

  @override
  Future<void> clearOutages() => _db.delete('outages');

  // -------------------------------------------------------------- Appareils

  @override
  Future<List<KnownDevice>> knownDevices() async {
    final rows = await _db.query('devices', orderBy: 'last_seen DESC');
    return [
      for (final r in rows)
        KnownDevice(
          mac: r['mac'] as String,
          nickname: r['nickname'] as String?,
          firstSeen: _time(r['first_seen']),
          lastSeen: _time(r['last_seen']),
          lastName: r['last_name'] as String?,
          lastIp: r['last_ip'] as String?,
        ),
    ];
  }

  @override
  Future<List<ConnectedDevice>> recordSeenDevices(List<ConnectedDevice> devices, DateTime time) {
    return _db.transaction((txn) async {
      final count = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM devices')) ?? 0;
      final firstRun = count == 0;
      final unknown = <ConnectedDevice>[];
      for (final device in devices) {
        if (device.mac.isEmpty) continue;
        final rows = await txn.query('devices', columns: ['mac'], where: 'mac = ?', whereArgs: [device.mac]);
        if (rows.isEmpty) {
          await txn.insert('devices', {
            'mac': device.mac,
            'first_seen': _ms(time),
            'last_seen': _ms(time),
            'last_name': device.name,
            'last_ip': device.ip,
          });
          if (!firstRun) unknown.add(device);
        } else {
          await txn.update(
            'devices',
            {'last_seen': _ms(time), 'last_name': device.name, 'last_ip': device.ip},
            where: 'mac = ?',
            whereArgs: [device.mac],
          );
        }
      }
      return unknown;
    });
  }

  @override
  Future<void> setNickname(String mac, String? nickname) async {
    final value = (nickname == null || nickname.trim().isEmpty) ? null : nickname.trim();
    final key = ConnectedDevice.normalizeMac(mac);
    final updated = await _db.update('devices', {'nickname': value}, where: 'mac = ?', whereArgs: [key]);
    if (updated == 0) {
      final now = _ms(DateTime.now());
      await _db.insert('devices', {'mac': key, 'nickname': value, 'first_seen': now, 'last_seen': now});
    }
  }

  // ---------------------------------------------------------- Tests de débit

  @override
  Future<SpeedTestResult> addSpeedTest(SpeedTestResult result) async {
    final id = await _db.insert('speed_tests', {
      'ts': _ms(result.time),
      'bytes': result.bytes,
      'duration_ms': result.duration.inMilliseconds,
      'latency_ms': result.latency?.inMilliseconds,
      'url': result.url,
      'operator': result.operatorCode,
    });
    return SpeedTestResult(
      id: id,
      time: result.time,
      bytes: result.bytes,
      duration: result.duration,
      latency: result.latency,
      url: result.url,
      operatorCode: result.operatorCode,
    );
  }

  @override
  Future<List<SpeedTestResult>> recentSpeedTests({int limit = 100}) async {
    final rows = await _db.query('speed_tests', orderBy: 'ts DESC', limit: limit);
    return [
      for (final r in rows)
        SpeedTestResult(
          id: r['id'] as int,
          time: _time(r['ts']),
          bytes: r['bytes'] as int,
          duration: Duration(milliseconds: r['duration_ms'] as int),
          latency: r['latency_ms'] == null ? null : Duration(milliseconds: r['latency_ms'] as int),
          url: r['url'] as String?,
          operatorCode: r['operator'] as String?,
        ),
    ];
  }

  @override
  Future<void> clearSpeedTests() => _db.delete('speed_tests');

  // -------------------------------------------------------------------- État

  @override
  Future<String?> readState(String key) async {
    final rows = await _db.query('kv', columns: ['value'], where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  @override
  Future<void> writeState(String key, String? value) async {
    if (value == null) {
      await _db.delete('kv', where: 'key = ?', whereArgs: [key]);
    } else {
      await _db.insert('kv', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
