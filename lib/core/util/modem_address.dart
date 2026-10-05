import 'ip_utils.dart';

/// Adresse du modem saisie par l'utilisateur (IPv4 ou nom d'hôte, port
/// facultatif). Par défaut `192.168.100.1` ; elle change si `gwip` est modifié
/// dans les réglages DHCP.
abstract final class ModemAddress {
  static const String defaultAddress = '192.168.100.1';

  /// Normalise une saisie (`http://192.168.100.1/`, `192.168.100.1:8080`…)
  /// en `hôte` ou `hôte:port`. Renvoie `null` si invalide.
  static String? normalize(String input) {
    var text = input.trim();
    if (text.isEmpty) return null;
    text = text.replaceFirst(RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://'), '');
    final slash = text.indexOf('/');
    if (slash >= 0) text = text.substring(0, slash);
    String host = text;
    int? port;
    final colon = text.lastIndexOf(':');
    if (colon >= 0) {
      host = text.substring(0, colon);
      port = int.tryParse(text.substring(colon + 1));
      if (port == null || port < 1 || port > 65535) return null;
    }
    if (!isValidIpv4OrHostname(host)) return null;
    return port == null || port == 80 ? host : '$host:$port';
  }

  /// URL de base HTTP (en clair) d'une adresse normalisée.
  static Uri toBaseUri(String address) => Uri.parse('http://$address');

  /// Partie « hôte » d'une adresse normalisée.
  static String hostOf(String address) {
    final colon = address.lastIndexOf(':');
    return colon >= 0 ? address.substring(0, colon) : address;
  }
}
