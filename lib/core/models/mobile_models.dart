import '../util/ip_utils.dart';
import 'json_utils.dart';

/// Réponse de `getsimset`.
class SimSettings {
  SimSettings(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  /// Valeur brute `simset` (sens non documenté, conservée telle quelle).
  String get simSet => jsonString(raw['simset']);

  /// Emplacement actif : 0 = SIM1, 1 = SIM2 (`null` si illisible).
  int? get currentSim => jsonInt(raw['simcurrent']);

  /// Valeur `spassw` à renvoyer dans `params1` de `setsimnum`.
  String get switchPassword => jsonString(raw['spassw']);
}

/// Profil APN (élément de `apnlist`).
///
/// Champs : `id, apnname, pdptype, apn, mmc (sic, = MCC), mnc, auth,
/// username, passw, proxy, port`. Sur le modem réel, `auth` peut valoir "-1"
/// et `pdptype` "IPV4", valeurs hors des listes documentées : à afficher
/// (« Non défini », « IPv4 ») sans planter.
class ApnProfile {
  ApnProfile(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  /// Nouveau profil pour `setnewapn`.
  factory ApnProfile.create({
    required Object id,
    required String name,
    required String apn,
    required String pdpType,
    required String mcc,
    required String mnc,
    String auth = authNone,
    String username = '',
    String password = '',
    String proxy = '',
    String port = '',
  }) {
    return ApnProfile({
      'id': id,
      'apnname': name,
      'pdptype': pdpType,
      'apn': apn,
      'mmc': mcc,
      'mnc': mnc,
      'auth': auth,
      'username': username,
      'passw': password,
      'proxy': proxy,
      'port': port,
    });
  }

  final Map<String, dynamic> raw;

  /// Types PDP proposés à la création.
  static const List<String> pdpTypes = ['IP', 'IPV6', 'IPV4V6'];

  /// Codes `auth` : aucun, PAP, CHAP, PAP/CHAP ("-1" = non défini).
  static const String authUndefined = '-1';
  static const String authNone = '0';
  static const String authPap = '1';
  static const String authChap = '2';
  static const String authPapChap = '3';
  static const List<String> authCodes = [authNone, authPap, authChap, authPapChap];

  Object? get id => raw['id'];
  String get name => jsonString(raw['apnname']);
  String get pdpType => jsonString(raw['pdptype']);
  String get apn => jsonString(raw['apn']);
  String get mcc => jsonString(raw['mmc']);
  String get mnc => jsonString(raw['mnc']);
  String get auth => jsonString(raw['auth']);
  String get username => jsonString(raw['username']);
  String get password => jsonString(raw['passw']);
  String get proxy => jsonString(raw['proxy']);
  String get port => jsonString(raw['port']);

  /// Vrai si `auth` ne correspond à aucune option connue (ex. "-1").
  bool get isAuthUndefined => !authCodes.contains(auth.trim());

  Map<String, dynamic> toJson() => Map<String, dynamic>.of(raw);
}

/// Réponse de `getapninfo`.
class ApnInfo {
  ApnInfo(Map<String, dynamic> raw)
      : raw = Map.unmodifiable(raw),
        profiles = [
          for (final item in (raw['apnlist'] is List ? raw['apnlist'] as List : const []))
            if (item is Map) ApnProfile(Map<String, dynamic>.from(item)),
        ];

  final Map<String, dynamic> raw;
  final List<ApnProfile> profiles;

  /// Index du profil actif dans [profiles], -1 si aucun.
  int get currentIndex => jsonInt(raw['apncurrent']) ?? -1;

  ApnProfile? get current =>
      currentIndex >= 0 && currentIndex < profiles.length ? profiles[currentIndex] : null;

  /// Identifiant à donner à un nouveau profil : max + 1 si les identifiants
  /// sont numériques (même type que les existants), sinon le nombre de profils.
  Object nextId() {
    final ids = profiles.map((p) => p.id).toList();
    final numeric = ids.map(jsonInt).whereType<int>().toList();
    final next = numeric.isEmpty ? profiles.length : numeric.reduce((a, b) => a > b ? a : b) + 1;
    final sample = ids.firstWhere((id) => id != null, orElse: () => null);
    return sample is int ? next : '$next';
  }
}

/// Mode réseau (`netmode`) : "0" = 4G/3G, "1" = 4G seule, "2" = 3G seule.
abstract final class NetworkModes {
  static const String auto4g3g = '0';
  static const String only4g = '1';
  static const String only3g = '2';
  static const List<String> all = [auto4g3g, only4g, only3g];
}

/// Erreurs de validation de la détection de coupure.
enum ConnectionDetectError { invalidHost, noAddressWhenEnabled }

/// Détection de coupure réseau (`getcondetect` / `setcondetect`).
///
/// Les adresses peuvent être des IPv4 ou des noms d'hôte (le modem réel
/// contient `4.2.2.2`, `8.8.8.8` et `www.google.com`).
class ConnectionDetectConfig {
  ConnectionDetectConfig(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  static const List<String> addressKeys = ['ipaddr1', 'ipaddr2', 'ipaddr3'];

  /// `state` : "0" désactivé, "1" activé.
  bool get enabled => jsonBool(raw['state']) ?? false;

  List<String> get addresses => [for (final key in addressKeys) jsonString(raw[key]).trim()];

  ConnectionDetectConfig copyWith({bool? enabled, List<String>? addresses}) {
    final next = Map<String, dynamic>.of(raw);
    if (enabled != null) next['state'] = boolLike(raw['state'] ?? '0', enabled);
    if (addresses != null) {
      for (var i = 0; i < addressKeys.length; i++) {
        next[addressKeys[i]] = i < addresses.length ? addresses[i].trim() : '';
      }
    }
    return ConnectionDetectConfig(next);
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.of(raw);

  /// Erreur pour une adresse saisie, ou `null`. Une adresse vide est
  /// acceptée (emplacement inutilisé).
  static ConnectionDetectError? validateAddress(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return isValidIpv4OrHostname(text) ? null : ConnectionDetectError.invalidHost;
  }

  /// Vérifie l'ensemble : quand la détection est activée, au moins une
  /// adresse est requise.
  ConnectionDetectError? validate() {
    for (final address in addresses) {
      final error = validateAddress(address);
      if (error != null) return error;
    }
    if (enabled && addresses.every((a) => a.isEmpty)) return ConnectionDetectError.noAddressWhenEnabled;
    return null;
  }
}
