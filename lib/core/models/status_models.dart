import '../util/operators.dart';
import '../util/signal.dart';
import 'json_utils.dart';

/// Réponse de `getconfig` (sans session ; champs à la racine).
class ModemConfig {
  ModemConfig(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  /// Nombre d'emplacements SIM (2 sur ce modem).
  int? get simSlots => jsonInt(raw['simnum']);
  bool? get simHasPassword => jsonBool(raw['simhaspwd']);

  /// Langue actuelle de l'interface web (code : "en", "fr"…).
  String get webLanguage => jsonString(raw['langindex']);
  bool? get isVpn => jsonBool(raw['isvpn']);
  bool? get hasSdCard => jsonBool(raw['issdcard']);
  String get copyrights => jsonString(raw['copyrights']);
}

/// Réponse de `getallstatus`.
class AllStatus {
  AllStatus(Map<String, dynamic> raw, {this.internetReachable}) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  /// Résultat d'un test réel d'accès à internet à travers le Wi-Fi du modem
  /// (`null` si le test n'a pas eu lieu).
  final bool? internetReachable;

  /// Même relevé, complété par le test réel d'accès à internet.
  AllStatus withInternetCheck(bool? reachable) => AllStatus(raw, internetReachable: reachable);

  String get simCardState => jsonString(raw['simCardState']);

  /// "invalid" = pas de carte SIM.
  bool get hasSim => simCardState.trim().toLowerCase() != 'invalid';

  String get imsi => jsonString(raw['imsi']).trim();

  /// Valeur brute `carrier` du modem.
  String get carrier => jsonString(raw['carrier']);

  /// Nom de service annoncé par la SIM (ex. « blue »), affiché dans l'en-tête
  /// de l'interface d'origine. `null` s'il est vide, numérique, ou s'il
  /// s'agit du faux « China Telecom » que certains firmwares renvoient.
  String? get serviceName {
    final name = carrier.trim();
    if (name.isEmpty || RegExp(r'^\d+$').hasMatch(name)) return null;
    if (_bogusCarriers.contains(name.toLowerCase())) return null;
    return name;
  }

  static const _bogusCarriers = {
    'china telecom', 'china mobile', 'china unicom', '中国电信', '中国移动', '中国联通', //
  };

  /// Opérateur déduit de l'IMSI (table MCC/MNC).
  OperatorInfo? get operator => resolveOperator(imsi);

  String get internetState => jsonString(raw['internetState']);

  /// Internet connecté. Le modem renvoie un état autre que "disconnected" dès
  /// qu'il a une connexion au réseau de l'opérateur, même quand internet ne
  /// passe pas (SIM sans forfait, portail de l'opérateur) : le test réel,
  /// s'il a eu lieu, fait foi.
  bool get isInternetConnected {
    final state = internetState.trim().toLowerCase();
    if (state.isEmpty || state == 'disconnected') return false;
    return internetReachable ?? true;
  }

  /// Puissance du signal en dBm (`null` si absente).
  int? get signalDbm => jsonInt(raw['signalStrength']);

  /// Barres de signal (aucune sans carte SIM).
  int get signalBars => hasSim ? signalBarsFromDbm(signalDbm) : 0;

  /// Point d'accès Wi-Fi allumé ("on"/"off").
  bool get isWifiApOn => jsonBool(raw['wifiapstatus']) ?? true;
}

/// Réponse de `getoverview`.
class Overview {
  Overview(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  String get ssid => jsonString(raw['SSID']);
  String get imei => jsonString(raw['IMEI']);
  String get iccid => jsonString(raw['ICCID']);
  String get imsi => jsonString(raw['IMSI']);
  String get signal => jsonString(raw['SIGNAL']);
  String get wanIp => jsonString(raw['WANIP']);
  String get hardwareVersion => jsonString(raw['HWVER']);

  /// Version logicielle telle que renvoyée par l'API (ex.
  /// `HMIFI_X4S1U1W1_CM_V03_0401…`), pas la valeur codée en dur dans la page.
  String get softwareVersion => jsonString(raw['SYSVER']);
  String get webVersion => jsonString(raw['WEBVER']);
}

/// Réponse de `getsysinfo`.
///
/// Les champs à 0 sur le modem réel renvoient `null` (à masquer). Les
/// compteurs `ethnum`/`wifinum` sont faux : compter à partir de
/// `getconnectedsta` (voir [DeviceCounts]).
class SysInfo {
  SysInfo(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  String? get baseStationId => nonZeroString(raw['bsid']);
  String? get cellId => nonZeroString(raw['cellid']);

  /// Température CPU en °C, `null` si absente ou nulle.
  double? get cpuTemperature {
    final value = jsonDouble(raw['cputemp']);
    return value == null || value == 0 ? null : value;
  }

  /// Heure système brute du modem, `null` si vide ou nulle.
  String? get systemTime => nonZeroString(raw['systime']);

  /// Durée de fonctionnement, `null` si absente ou nulle.
  Duration? get uptime {
    final seconds = jsonInt(raw['sysruntime']);
    return seconds == null || seconds <= 0 ? null : Duration(seconds: seconds);
  }
}

/// Type de connexion d'un appareil (`devtype` : 0 = Wi-Fi, 1 = filaire).
enum DeviceConnectionType { wifi, wired, unknown }

/// Un appareil de `getconnectedsta`.
class ConnectedDevice {
  const ConnectedDevice({
    required this.name,
    required this.type,
    required this.ip,
    required this.mac,
  });

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      name: jsonString(json['devname']).trim(),
      type: switch (jsonInt(json['devtype'])) {
        0 => DeviceConnectionType.wifi,
        1 => DeviceConnectionType.wired,
        _ => DeviceConnectionType.unknown,
      },
      ip: jsonString(json['devip']).trim(),
      mac: normalizeMac(jsonString(json['devmac'])),
    );
  }

  /// Nom annoncé par l'appareil (peut être vide).
  final String name;
  final DeviceConnectionType type;
  final String ip;

  /// Adresse MAC normalisée (majuscules, séparateur « : »).
  final String mac;

  /// Normalise une adresse MAC : `aa-bb-cc…` → `AA:BB:CC…`.
  static String normalizeMac(String mac) => mac.trim().toUpperCase().replaceAll('-', ':');
}

/// Compteurs d'appareils calculés à partir de la liste `getconnectedsta`.
class DeviceCounts {
  const DeviceCounts({required this.wifi, required this.wired, required this.total});

  factory DeviceCounts.of(List<ConnectedDevice> devices) {
    final wifi = devices.where((d) => d.type == DeviceConnectionType.wifi).length;
    final wired = devices.where((d) => d.type == DeviceConnectionType.wired).length;
    return DeviceCounts(wifi: wifi, wired: wired, total: devices.length);
  }

  final int wifi;
  final int wired;
  final int total;
}
