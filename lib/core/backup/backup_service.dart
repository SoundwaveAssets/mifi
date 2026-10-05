import 'dart:convert';

import '../api/modem_api.dart';
import '../api/modem_exception.dart';
import '../mobile_data/data_cut.dart';
import '../models/dhcp_models.dart';
import '../models/json_utils.dart';
import '../models/mobile_models.dart';
import '../models/wifi_models.dart';

/// Fichier de sauvegarde illisible ou d'un autre format.
class BackupFormatException implements Exception {
  const BackupFormatException(this.details);

  final String details;

  @override
  String toString() => 'BackupFormatException($details)';
}

/// Sauvegarde des réglages du modem. Ne contient JAMAIS le mot de passe
/// administrateur (le mot de passe Wi-Fi, lui, en fait partie).
class ModemBackup {
  const ModemBackup({
    required this.createdAt,
    this.softwareVersion,
    this.wifi,
    this.apnCurrent,
    this.apnProfiles = const [],
    this.dhcp,
    this.networkMode,
    this.connectionDetect,
  });

  static const String formatName = 'mifi-backup';
  static const int formatVersion = 1;

  final DateTime createdAt;
  final String? softwareVersion;
  final Map<String, dynamic>? wifi;
  final Map<String, dynamic>? apnCurrent;
  final List<Map<String, dynamic>> apnProfiles;
  final Map<String, dynamic>? dhcp;
  final String? networkMode;
  final Map<String, dynamic>? connectionDetect;

  bool get isEmpty =>
      wifi == null && apnCurrent == null && dhcp == null && networkMode == null && connectionDetect == null;

  Map<String, Object?> toJson() => {
        'format': formatName,
        'version': formatVersion,
        'createdAt': createdAt.toIso8601String(),
        'modem': {'softwareVersion': ?softwareVersion},
        'wifi': ?wifi,
        'apn': {'current': apnCurrent, 'profiles': apnProfiles},
        'dhcp': ?dhcp,
        'networkMode': ?networkMode,
        'connectionDetect': ?connectionDetect,
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  static ModemBackup parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (e) {
      throw BackupFormatException(e.message);
    }
    if (decoded is! Map) throw const BackupFormatException('not an object');
    if (decoded['format'] != formatName) throw const BackupFormatException('format');
    final version = jsonInt(decoded['version']);
    if (version == null || version > formatVersion) throw const BackupFormatException('version');
    Map<String, dynamic>? object(Object? value) => value is Map ? Map<String, dynamic>.from(value) : null;
    final apn = object(decoded['apn']);
    return ModemBackup(
      createdAt: DateTime.tryParse('${decoded['createdAt']}') ?? DateTime.fromMillisecondsSinceEpoch(0),
      softwareVersion: object(decoded['modem'])?['softwareVersion'] as String?,
      wifi: object(decoded['wifi']),
      apnCurrent: object(apn?['current']),
      apnProfiles: [
        for (final p in (apn?['profiles'] is List ? apn!['profiles'] as List : const [])) ?object(p),
      ],
      dhcp: object(decoded['dhcp']),
      networkMode: decoded['networkMode'] == null ? null : '${decoded['networkMode']}',
      connectionDetect: object(decoded['connectionDetect']),
    );
  }
}

/// Collecte et réapplication des réglages. Les valeurs sauvegardées sont
/// toujours fusionnées sur l'objet ACTUEL du modem (jamais renvoyées
/// telles quelles), pour garder les champs propres à ce firmware.
class BackupService {
  BackupService(this.api);

  final ModemApi api;

  Future<T?> _optional<T>(Future<T> Function() load) async {
    try {
      return await load();
    } on ModemException {
      return null;
    }
  }

  Future<ModemBackup> collect({String? softwareVersion}) async {
    final wifi = await _optional(api.getWifiInfo);
    final apn = await _optional(api.getApnInfo);
    final dhcp = await _optional(api.getDhcpInfo);
    final mode = await _optional(api.getNetworkMode);
    final detect = await _optional(api.getConnectionDetect);
    final current = apn?.current;
    return ModemBackup(
      createdAt: DateTime.now(),
      softwareVersion: softwareVersion,
      wifi: wifi?.toJson(),
      // Le profil de coupure des données n'est jamais sauvegardé comme profil actif.
      apnCurrent: current == null || ApnDataCut.isBlocker(current) ? null : current.toJson(),
      apnProfiles: [
        for (final p in apn?.profiles ?? const <ApnProfile>[])
          if (!ApnDataCut.isBlocker(p)) p.toJson(),
      ],
      dhcp: dhcp?.toJson(),
      networkMode: mode,
      connectionDetect: detect?.toJson(),
    );
  }

  Future<void> applyNetworkMode(String mode) => api.setNetworkMode(mode);

  Future<void> applyConnectionDetect(Map<String, dynamic> saved) async {
    final current = await api.getConnectionDetect();
    final source = ConnectionDetectConfig(saved);
    await api.setConnectionDetect(current.copyWith(enabled: source.enabled, addresses: source.addresses));
  }

  /// Réactive le profil APN sauvegardé (créé s'il n'existe plus).
  Future<void> applyApn(Map<String, dynamic> saved) async {
    final wanted = ApnProfile(saved);
    bool same(ApnProfile p) =>
        p.apn == wanted.apn && p.name == wanted.name && p.mcc == wanted.mcc && p.mnc == wanted.mnc;
    var info = await api.getApnInfo();
    var existing = info.profiles.where(same).firstOrNull;
    if (existing == null) {
      await api.addApn(ApnProfile.create(
        id: info.nextId(),
        name: wanted.name,
        apn: wanted.apn,
        pdpType: ApnProfile.pdpTypes.contains(wanted.pdpType) ? wanted.pdpType : 'IP',
        mcc: wanted.mcc,
        mnc: wanted.mnc,
        auth: ApnProfile.authCodes.contains(wanted.auth) ? wanted.auth : ApnProfile.authNone,
        username: wanted.username,
        password: wanted.password,
        proxy: wanted.proxy,
        port: wanted.port,
      ));
      info = await api.getApnInfo();
      existing = info.profiles.where(same).lastOrNull;
      if (existing == null) throw const CommandFailedException('setnewapn', 'not found');
    }
    if (info.current == null || !same(info.current!)) await api.setCurrentApn(existing);
  }

  /// Applique le DHCP sauvegardé (le modem redémarre). Renvoie la nouvelle
  /// passerelle si elle change, sinon `null`.
  Future<String?> applyDhcp(Map<String, dynamic> saved) async {
    final current = await api.getDhcpInfo();
    final source = DhcpInfo(saved);
    final merged = current.copyWith(
      gatewayIp: source.gatewayIp,
      netmask: source.netmask,
      poolStart: source.poolStart,
      poolEnd: source.poolEnd,
      leaseTimeHours: source.leaseTimeHours,
    );
    if (merged.validate().isNotEmpty) throw const CommandFailedException('setdhcpinfo', 'invalid backup');
    await api.setDhcpInfo(merged);
    return merged.gatewayIp == current.gatewayIp ? null : merged.gatewayIp;
  }

  /// Applique le Wi-Fi sauvegardé (le Wi-Fi redémarre). Renvoie les
  /// réglages envoyés (nom et mot de passe pour se reconnecter).
  Future<WifiInfo> applyWifi(Map<String, dynamic> saved) async {
    final current = await api.getWifiInfo();
    final source = WifiInfo(saved);
    final merged = current.copyWith(
      ssid: source.ssid,
      password: source.password,
      channel: source.channel,
      authCode: source.authCode,
      broadcastSsid: source.broadcastSsid,
    );
    await api.setWifiInfo(merged);
    return merged;
  }
}
