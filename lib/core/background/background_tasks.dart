/// Noms des tâches exécutées hors de l'interface (WorkManager / AlarmManager),
/// partagés avec le code Kotlin.
abstract final class BackgroundTasks {
  /// Vérification périodique (~15 min) : notifications, journal des
  /// coupures, historique du signal, réparation automatique.
  static const periodicCheck = 'periodic_check';

  /// Bascule des données mobiles depuis leur tuile « Réglages rapides ».
  static const mobileDataToggle = 'mobile_data_toggle';

  /// Redémarrage programmé du modem.
  static const scheduledReboot = 'scheduled_reboot';

  /// Reprogrammation complète (après redémarrage du téléphone ou mise à jour).
  static const reschedule = 'reschedule';
}

/// Écrans que l'on peut ouvrir directement depuis Android (raccourcis de
/// l'icône, actions de notification, widgets).
abstract final class AppRoutes {
  static const expelIntruders = 'expel';
  static const shareWifi = 'share_wifi';
  static const speedTest = 'speed_test';
  static const mobileNetwork = 'mobile_network';
  static const devices = 'devices';
}
