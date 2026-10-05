import 'json_utils.dart';

/// Informations de fabrication (`getproduceinfo`), en lecture seule.
class ProduceInfo {
  ProduceInfo(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  /// Valeur brute de `calstatus`.
  String get calibrationRaw => jsonString(raw['calstatus']);

  /// Calibré ? (`null` si la valeur n'est pas interprétable).
  bool? get calibrated => jsonBool(raw['calstatus']);

  /// Valeur brute de `wificheckstatus`.
  String get wifiCheckRaw => jsonString(raw['wificheckstatus']);

  /// Wi-Fi testé en usine ? ("0"/"1").
  bool? get wifiChecked => jsonBool(raw['wificheckstatus']);
}

/// Langues acceptées par l'interface web du modem (`selectlang`).
abstract final class ModemWebLanguages {
  static const List<String> supported = ['en', 'fr', 'pl', 'ru', 'tk', 'zh'];

  /// Code à envoyer pour une langue d'appli ; anglais par défaut.
  static String forAppLanguage(String languageCode) =>
      supported.contains(languageCode) ? languageCode : 'en';
}

/// Objet de contrôle de la mise à jour du firmware
/// (`putcrcsystem` / `getcrcsystem`).
class FirmwareCheck {
  FirmwareCheck(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  factory FirmwareCheck.create({required String crcCode, required String fileName}) =>
      FirmwareCheck({'syscrccode': crcCode, 'fileurl': fileName, 'status': ''});

  final Map<String, dynamic> raw;

  /// Taille maximale du fichier `.zip` (500 Mo).
  static const int maxFileBytes = 500 * 1024 * 1024;

  String get crcCode => jsonString(raw['syscrccode']);
  String get fileName => jsonString(raw['fileurl']);

  /// "ok" = mise à jour en cours ; sinon message d'erreur du modem.
  String get status => jsonString(raw['status']).trim();
  bool get isOk => status.toLowerCase() == 'ok';
  bool get isPending => status.isEmpty;

  Map<String, dynamic> toJson() => Map<String, dynamic>.of(raw);
}
