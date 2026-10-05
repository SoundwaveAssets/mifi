/// Contenu d'un QR code de connexion Wi-Fi, scannable par l'appareil photo
/// d'Android et d'iOS : `WIFI:T:WPA;S:<ssid>;P:<motdepasse>;;`.
///
/// [authCode] est la valeur `wifiauth` du modem ("0" = réseau ouvert).
/// [hidden] ajoute `H:true` quand le SSID n'est pas diffusé.
String buildWifiQrPayload({
  required String ssid,
  required String password,
  required String authCode,
  bool hidden = false,
}) {
  final open = authCode == '0';
  final buffer = StringBuffer('WIFI:')
    ..write('T:${open ? 'nopass' : 'WPA'};')
    ..write('S:${escapeWifiQrValue(ssid)};');
  if (!open) buffer.write('P:${escapeWifiQrValue(password)};');
  if (hidden) buffer.write('H:true;');
  buffer.write(';');
  return buffer.toString();
}

/// Échappe les caractères spéciaux du format `WIFI:` (`\ ; , : "`).
String escapeWifiQrValue(String value) =>
    value.replaceAllMapped(RegExp(r'[\\;,:"]'), (m) => '\\${m[0]}');
