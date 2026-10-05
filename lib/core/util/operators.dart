/// Opérateur mobile de la SIM insérée.
///
/// Le champ `carrier` du modem est toujours faux (« China Telecom » quelle
/// que soit la SIM) : l'opérateur est déduit des 5 premiers chiffres de
/// l'IMSI (MCC + MNC). `carrier` n'est jamais utilisé.
class OperatorInfo {
  const OperatorInfo({required this.mcc, required this.mnc, this.name});

  final String mcc;
  final String mnc;

  /// Nom commercial si le code est dans [knownOperators], sinon `null`
  /// (l'interface affiche alors « Opérateur 624-XX »).
  final String? name;

  /// Code lisible, ex. `624-05`.
  String get code => '$mcc-$mnc';

  @override
  bool operator ==(Object other) => other is OperatorInfo && other.mcc == mcc && other.mnc == mnc;

  @override
  int get hashCode => Object.hash(mcc, mnc);
}

/// Opérateurs connus, clé = MCC + MNC (5 chiffres).
/// Pour en ajouter un, il suffit d'ajouter une ligne.
const Map<String, String> knownOperators = {
  // Cameroun (MCC 624).
  '62401': 'MTN',
  '62402': 'Orange',
  '62404': 'Nexttel',
  '62405': 'Camtel',
};

/// Opérateur déduit de l'[imsi], ou `null` si l'IMSI est vide ou trop court
/// (pas de SIM).
OperatorInfo? resolveOperator(String? imsi) {
  final digits = (imsi ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length < 5) return null;
  final key = digits.substring(0, 5);
  return OperatorInfo(mcc: key.substring(0, 3), mnc: key.substring(3), name: knownOperators[key]);
}

/// MCC et MNC (2 chiffres) tirés de l'IMSI, pour pré-remplir un nouvel APN.
/// `null` si l'IMSI est inexploitable.
(String mcc, String mnc)? mccMncFromImsi(String? imsi) {
  final info = resolveOperator(imsi);
  return info == null ? null : (info.mcc, info.mnc);
}
