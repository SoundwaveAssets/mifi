// Validation et calculs d'adresses IPv4 et de noms d'hôte.

final RegExp _ipv4Pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');

/// Vrai si [value] est une adresse IPv4 décimale pointée valide.
bool isValidIpv4(String value) => ipv4ToInt(value) != null;

/// Adresse IPv4 → entier 32 bits, ou `null` si invalide.
/// Refuse les zéros non significatifs ("192.168.001.1").
int? ipv4ToInt(String value) {
  final match = _ipv4Pattern.firstMatch(value.trim());
  if (match == null) return null;
  var result = 0;
  for (var i = 1; i <= 4; i++) {
    final part = match.group(i)!;
    if (part.length > 1 && part.startsWith('0')) return null;
    final octet = int.parse(part);
    if (octet > 255) return null;
    result = (result << 8) | octet;
  }
  return result;
}

/// Entier 32 bits → adresse IPv4.
String intToIpv4(int value) =>
    [24, 16, 8, 0].map((shift) => (value >> shift) & 0xFF).join('.');

/// Vrai si [mask] est un masque de sous-réseau valide (bits à 1 contigus),
/// entre /8 et /30.
bool isValidNetmask(String mask) {
  final value = ipv4ToInt(mask);
  if (value == null) return false;
  final prefix = netmaskPrefixLength(mask);
  return prefix != null && prefix >= 8 && prefix <= 30;
}

/// Longueur de préfixe d'un masque (ex. 24), ou `null` si non contigu.
int? netmaskPrefixLength(String mask) {
  final value = ipv4ToInt(mask);
  if (value == null) return null;
  var prefix = 0;
  var seenZero = false;
  for (var bit = 31; bit >= 0; bit--) {
    final isOne = (value >> bit) & 1 == 1;
    if (isOne) {
      if (seenZero) return null;
      prefix++;
    } else {
      seenZero = true;
    }
  }
  return prefix;
}

/// Vrai si [a] et [b] sont dans le même sous-réseau pour le masque [mask].
bool sameSubnet(String a, String b, String mask) {
  final ia = ipv4ToInt(a), ib = ipv4ToInt(b), im = ipv4ToInt(mask);
  if (ia == null || ib == null || im == null) return false;
  return (ia & im) == (ib & im);
}

/// Adresse de réseau (ex. 192.168.100.0), ou `null`.
String? networkAddress(String ip, String mask) {
  final i = ipv4ToInt(ip), m = ipv4ToInt(mask);
  if (i == null || m == null) return null;
  return intToIpv4(i & m);
}

/// Adresse de diffusion (ex. 192.168.100.255), ou `null`.
String? broadcastAddress(String ip, String mask) {
  final i = ipv4ToInt(ip), m = ipv4ToInt(mask);
  if (i == null || m == null) return null;
  return intToIpv4((i & m) | (~m & 0xFFFFFFFF));
}

/// Vrai si [ip] est l'adresse de réseau ou de diffusion de son sous-réseau.
bool isNetworkOrBroadcast(String ip, String mask) =>
    ip.trim() == networkAddress(ip, mask) || ip.trim() == broadcastAddress(ip, mask);

final RegExp _hostLabel = RegExp(r'^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$');

/// Vrai si [value] est un nom d'hôte valide (RFC 1123), ex. `www.google.com`.
bool isValidHostname(String value) {
  final host = value.trim();
  if (host.isEmpty || host.length > 253) return false;
  final labels = host.endsWith('.') ? host.substring(0, host.length - 1).split('.') : host.split('.');
  if (labels.any((label) => !_hostLabel.hasMatch(label))) return false;
  // Un nom entièrement numérique doit être une IPv4 valide.
  if (labels.every((label) => RegExp(r'^\d+$').hasMatch(label))) return isValidIpv4(host);
  return true;
}

/// Vrai si [value] est une IPv4 valide ou un nom d'hôte valide.
bool isValidIpv4OrHostname(String value) => isValidIpv4(value) || isValidHostname(value);
