import 'json_utils.dart';

/// Erreurs de validation des réglages Wi-Fi (traduites par l'interface).
enum WifiValidationError {
  ssidEmpty,
  ssidTooLong,
  passwordTooShort,
  passwordTooLong,
  passwordInvalidCharacters,
}

/// Réglages Wi-Fi (`getwifiinfo` / `setwifiinfo`).
///
/// L'objet brut est conservé : `setwifiinfo` attend « l'objet complet,
/// modifié », champs inconnus compris, avec leurs types d'origine.
class WifiInfo {
  WifiInfo(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  static const int ssidMaxLength = 64;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 32;

  /// Canaux proposés ("1" à "13").
  static const List<String> channels = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', //
  ];

  /// Codes `wifiauth` : aucun, WPA-PSK, WPA2-PSK.
  static const String authNone = '0';
  static const String authWpaPsk = '1';
  static const String authWpa2Psk = '4';
  static const List<String> authCodes = [authNone, authWpaPsk, authWpa2Psk];

  /// État du Wi-Fi (`wifistate` : "open"/"close").
  bool get isEnabled => jsonBool(raw['wifistate']) ?? true;
  String get ssid => jsonString(raw['wifissid']);
  String get password => jsonString(raw['wifipass']);
  String get channel => jsonString(raw['wifichan']);
  String get authCode => jsonString(raw['wifiauth']);
  bool get isOpenNetwork => authCode == authNone;

  /// Diffusion du SSID (`wifibrocast`).
  bool get broadcastSsid => jsonBool(raw['wifibrocast']) ?? true;

  WifiInfo copyWith({
    String? ssid,
    String? password,
    String? channel,
    String? authCode,
    bool? broadcastSsid,
  }) {
    final next = Map<String, dynamic>.of(raw);
    if (ssid != null) next['wifissid'] = ssid;
    if (password != null) next['wifipass'] = password;
    if (channel != null) next['wifichan'] = stringLike(raw['wifichan'], channel);
    if (authCode != null) next['wifiauth'] = stringLike(raw['wifiauth'], authCode);
    if (broadcastSsid != null) next['wifibrocast'] = boolLike(raw['wifibrocast'], broadcastSsid);
    return WifiInfo(next);
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.of(raw);

  /// SSID : 1 à [ssidMaxLength] caractères.
  static WifiValidationError? validateSsid(String ssid) {
    if (ssid.trim().isEmpty) return WifiValidationError.ssidEmpty;
    if (ssid.length > ssidMaxLength) return WifiValidationError.ssidTooLong;
    return null;
  }

  /// Mot de passe : 8 à 32 caractères ASCII imprimables (norme WPA), sauf
  /// pour un réseau ouvert.
  static WifiValidationError? validatePassword(String password, {required String authCode}) {
    if (authCode == authNone) return null;
    if (password.length < passwordMinLength) return WifiValidationError.passwordTooShort;
    if (password.length > passwordMaxLength) return WifiValidationError.passwordTooLong;
    if (password.codeUnits.any((c) => c < 0x20 || c > 0x7E)) {
      return WifiValidationError.passwordInvalidCharacters;
    }
    return null;
  }
}
