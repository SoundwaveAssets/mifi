/// Nombre de barres de signal (0 à 4) pour une puissance en dBm, selon les
/// paliers de référence de la 4G (puissance reçue RSRP), un niveau par
/// barre :
/// - ≥ -80 : 4 barres (excellent) ;
/// - -81 à -90 : 3 (bon) ;
/// - -91 à -100 : 2 (moyen) ;
/// - -101 à -110 : 1 (faible) ;
/// - en dessous, ou sans mesure exploitable : aucune (inexistant).
int signalBarsFromDbm(int? dbm) {
  if (dbm == null || !isValidSignalDbm(dbm)) return 0;
  if (dbm >= -80) return 4;
  if (dbm >= -90) return 3;
  if (dbm >= -100) return 2;
  if (dbm >= -110) return 1;
  return 0;
}

/// Vrai si [dbm] est une mesure exploitable (dans la plage -120…-44 dBm).
bool isValidSignalDbm(int? dbm) => dbm != null && dbm <= -44 && dbm >= -120;

/// Qualité du signal déduite du nombre de barres : inexistant, faible,
/// moyen, bon, excellent.
enum SignalQuality {
  none,
  poor,
  fair,
  good,
  excellent;

  static SignalQuality fromBars(int bars) => switch (bars) {
        <= 0 => SignalQuality.none,
        1 => SignalQuality.poor,
        2 => SignalQuality.fair,
        3 => SignalQuality.good,
        _ => SignalQuality.excellent,
      };

  static SignalQuality fromDbm(int? dbm) => fromBars(signalBarsFromDbm(dbm));
}

/// Seuil de l'alerte « signal faible » : 1 barre ou moins.
const int lowSignalMaxBars = 1;

/// Le signal redevient « correct » (fin d'alerte) à partir de 3 barres, pour
/// éviter des alertes en rafale autour du seuil.
const int lowSignalRecoveryBars = 3;
