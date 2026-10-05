import '../util/ip_utils.dart';
import 'json_utils.dart';

/// Champs du formulaire DHCP.
enum DhcpField { gatewayIp, netmask, poolStart, poolEnd, leaseTime }

/// Erreurs de validation DHCP (traduites par l'interface).
enum DhcpValidationError {
  invalidIp,
  invalidNetmask,
  networkOrBroadcastAddress,
  outsideGatewaySubnet,
  poolStartAfterEnd,
  gatewayInsidePool,
  invalidLeaseTime,
}

/// Réglages DHCP (`getdhcpinfo` / `setdhcpinfo`).
///
/// `dhcpserver` est en lecture seule (grisé dans l'interface d'origine) :
/// il est affiché mais jamais modifié.
class DhcpInfo {
  DhcpInfo(Map<String, dynamic> raw) : raw = Map.unmodifiable(raw);

  final Map<String, dynamic> raw;

  /// Durée de bail maximale acceptée par le formulaire (en heures).
  static const int maxLeaseHours = 720;

  String get gatewayIp => jsonString(raw['gwip']).trim();
  String get netmask => jsonString(raw['netmask']).trim();

  /// Serveur DHCP actif (lecture seule).
  bool? get dhcpServerEnabled => jsonBool(raw['dhcpserver']);
  String get poolStart => jsonString(raw['ippoolstart']).trim();
  String get poolEnd => jsonString(raw['ippoolend']).trim();

  /// Durée du bail en heures.
  int? get leaseTimeHours => jsonInt(raw['leasetime']);

  DhcpInfo copyWith({
    String? gatewayIp,
    String? netmask,
    String? poolStart,
    String? poolEnd,
    int? leaseTimeHours,
  }) {
    final next = Map<String, dynamic>.of(raw);
    if (gatewayIp != null) next['gwip'] = gatewayIp.trim();
    if (netmask != null) next['netmask'] = netmask.trim();
    if (poolStart != null) next['ippoolstart'] = poolStart.trim();
    if (poolEnd != null) next['ippoolend'] = poolEnd.trim();
    if (leaseTimeHours != null) next['leasetime'] = intLike(raw['leasetime'], leaseTimeHours);
    return DhcpInfo(next);
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.of(raw);

  /// Vérifie la cohérence de l'ensemble : adresses valides, plage dans le
  /// sous-réseau de `gwip`, début ≤ fin, passerelle hors de la plage…
  /// Renvoie une erreur par champ fautif (vide si tout est correct).
  Map<DhcpField, DhcpValidationError> validate() {
    final errors = <DhcpField, DhcpValidationError>{};
    final gw = gatewayIp, mask = netmask, start = poolStart, end = poolEnd;

    if (!isValidIpv4(gw)) errors[DhcpField.gatewayIp] = DhcpValidationError.invalidIp;
    if (!isValidNetmask(mask)) errors[DhcpField.netmask] = DhcpValidationError.invalidNetmask;
    if (!isValidIpv4(start)) errors[DhcpField.poolStart] = DhcpValidationError.invalidIp;
    if (!isValidIpv4(end)) errors[DhcpField.poolEnd] = DhcpValidationError.invalidIp;

    final lease = leaseTimeHours;
    if (lease == null || lease < 1 || lease > maxLeaseHours) {
      errors[DhcpField.leaseTime] = DhcpValidationError.invalidLeaseTime;
    }
    if (errors.containsKey(DhcpField.gatewayIp) || errors.containsKey(DhcpField.netmask)) {
      return errors;
    }

    if (isNetworkOrBroadcast(gw, mask)) {
      errors[DhcpField.gatewayIp] = DhcpValidationError.networkOrBroadcastAddress;
    }
    for (final (field, ip) in [(DhcpField.poolStart, start), (DhcpField.poolEnd, end)]) {
      if (errors.containsKey(field)) continue;
      if (!sameSubnet(ip, gw, mask)) {
        errors[field] = DhcpValidationError.outsideGatewaySubnet;
      } else if (isNetworkOrBroadcast(ip, mask)) {
        errors[field] = DhcpValidationError.networkOrBroadcastAddress;
      }
    }
    if (!errors.containsKey(DhcpField.poolStart) && !errors.containsKey(DhcpField.poolEnd)) {
      final s = ipv4ToInt(start)!, e = ipv4ToInt(end)!, g = ipv4ToInt(gw)!;
      if (s > e) {
        errors[DhcpField.poolEnd] = DhcpValidationError.poolStartAfterEnd;
      } else if (g >= s && g <= e && !errors.containsKey(DhcpField.gatewayIp)) {
        errors[DhcpField.gatewayIp] = DhcpValidationError.gatewayInsidePool;
      }
    }
    return errors;
  }
}
