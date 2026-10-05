/// Qualité d'une connexion d'après son débit descendant : inexistant,
/// faible, moyen, bon, excellent.
enum SpeedQuality {
  none,
  poor,
  fair,
  good,
  excellent;

  /// Seuils en Mb/s :
  /// - moins de 0,5 : inexistant (internet passe à peine) ;
  /// - moins de 2 : faible (messages, navigation lente) ;
  /// - moins de 8 : moyen (navigation, vidéo en qualité standard) ;
  /// - moins de 25 : bon (vidéo HD, appels vidéo) ;
  /// - sinon : excellent.
  static SpeedQuality fromMbps(double mbps) {
    if (mbps < 0.5) return SpeedQuality.none;
    if (mbps < 2) return SpeedQuality.poor;
    if (mbps < 8) return SpeedQuality.fair;
    if (mbps < 25) return SpeedQuality.good;
    return SpeedQuality.excellent;
  }
}
