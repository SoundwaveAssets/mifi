// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MiFi';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonOk => 'OK';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonApply => 'Appliquer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonCopied => 'Copié dans le presse-papiers';

  @override
  String get commonEnabled => 'Activé';

  @override
  String get commonDisabled => 'Désactivé';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonSaved => 'Réglages enregistrés';

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get commonNotDefined => 'Non défini';

  @override
  String get commonShowPassword => 'Afficher le mot de passe';

  @override
  String get commonHidePassword => 'Masquer le mot de passe';

  @override
  String get commonRequiredField => 'Champ obligatoire';

  @override
  String get commonInvalidIpv4 => 'Adresse IPv4 invalide (ex. 192.168.100.1)';

  @override
  String get commonInvalidHost => 'Adresse IP ou nom d\'hôte invalide';

  @override
  String get commonTypeLabel => 'Type';

  @override
  String get commonProxyLabel => 'Proxy';

  @override
  String commonUpdatedAt(String time) {
    return 'Mis à jour à $time';
  }

  @override
  String get commonDataStale => 'Données non à jour';

  @override
  String get commonWarning => 'Attention';

  @override
  String commonTypeToConfirm(String word) {
    return 'Pour confirmer, saisissez « $word »';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils',
      one: '$count appareil',
    );
    return '$_temp0';
  }

  @override
  String get deviceTypeWifi => 'Wi-Fi';

  @override
  String get deviceTypeWired => 'Filaire';

  @override
  String get deviceTypeUnknown => 'Inconnu';

  @override
  String get unnamedDevice => 'Appareil sans nom';

  @override
  String durationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationDaysHoursMinutes(int days, int hours, int minutes) {
    return '$days j $hours h $minutes min';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navDevices => 'Appareils';

  @override
  String get navSettings => 'Réglages';

  @override
  String get splashConnecting => 'Connexion au modem…';

  @override
  String errorUnreachable(String address) {
    return 'Impossible de joindre le modem ($address). Vérifiez que le téléphone est connecté au Wi-Fi du modem.';
  }

  @override
  String get errorTimeout => 'Le modem ne répond pas (délai dépassé).';

  @override
  String get errorLoginFailed => 'Mot de passe refusé par le modem.';

  @override
  String get errorSessionExpired =>
      'Session expirée. Veuillez vous reconnecter.';

  @override
  String errorCommandFailed(String reply) {
    return 'Le modem a refusé l\'opération (réponse : $reply).';
  }

  @override
  String get errorUnsupported =>
      'Fonction non prise en charge par le firmware du modem.';

  @override
  String get errorInvalidResponse => 'Réponse inattendue du modem.';

  @override
  String get errorCancelled => 'Opération annulée.';

  @override
  String errorUnexpected(String details) {
    return 'Erreur inattendue : $details';
  }

  @override
  String get hintWifiDisconnected =>
      'Le téléphone n\'est connecté à aucun réseau Wi-Fi.';

  @override
  String hintWrongWifi(String gateway, String address) {
    return 'Le Wi-Fi actuel (passerelle $gateway) ne semble pas être celui du modem ($address).';
  }

  @override
  String get hintNoInternetIsOk =>
      'Android peut signaler le Wi-Fi du modem « sans internet » : l\'appli l\'utilise quand même.';

  @override
  String get restartTitle => 'Reconnexion au modem';

  @override
  String get restartWaiting => 'Patientez pendant que le modem redémarre…';

  @override
  String restartElapsed(String elapsed) {
    return 'Temps écoulé : $elapsed';
  }

  @override
  String get restartHint =>
      'Si nécessaire, reconnectez le téléphone au Wi-Fi du modem.';

  @override
  String get restartSuccess => 'Le modem est de nouveau joignable.';

  @override
  String get restartTimeout =>
      'Le modem ne répond toujours pas. Vérifiez la connexion Wi-Fi puis réessayez.';

  @override
  String get restartStopWaiting => 'Arrêter d\'attendre';

  @override
  String get airplaneTitle => 'Mode avion';

  @override
  String get airplaneStateOn => 'Activé';

  @override
  String get airplaneStateOff => 'Désactivé';

  @override
  String get airplaneStateSwitching => 'Bascule en cours…';

  @override
  String get airplaneStateUnknown => 'État inconnu';

  @override
  String get airplaneStateError => 'Échec de la bascule';

  @override
  String get airplaneExplanation =>
      'Coupe internet sur la SIM active, en quelques secondes et sans changer de SIM. Le Wi-Fi du modem reste actif. L\'appli vérifie la coupure et vous prévient si elle ne tient pas.';

  @override
  String get notifChannelAlerts => 'Alertes de connexion';

  @override
  String get notifChannelAlertsDescription =>
      'Coupure et retour d\'internet, signal faible';

  @override
  String get notifChannelDevices => 'Nouveaux appareils';

  @override
  String get notifChannelDevicesDescription =>
      'Un appareil inconnu se connecte au Wi-Fi du modem';

  @override
  String get notifChannelAirplane => 'Données mobiles et programmations';

  @override
  String get notifChannelAirplaneDescription =>
      'Résultat des changements des données mobiles et du redémarrage programmé';

  @override
  String get notifInternetDownTitle => 'Internet coupé';

  @override
  String get notifInternetDownBody => 'Le modem a perdu la connexion internet.';

  @override
  String get notifInternetUpTitle => 'Internet rétabli';

  @override
  String notifInternetUpBody(String duration) {
    return 'La connexion est revenue après $duration.';
  }

  @override
  String get notifLowSignalTitle => 'Signal faible';

  @override
  String notifLowSignalBody(int dbm) {
    return 'Signal mobile faible : $dbm dBm.';
  }

  @override
  String get notifNewDeviceTitle => 'Nouvel appareil connecté';

  @override
  String notifNewDeviceBody(String name, String mac) {
    return '$name ($mac) vient de se connecter.';
  }

  @override
  String get notifScheduleFailedTitle => 'Mode avion programmé : échec';

  @override
  String get notifScheduleFailedBody =>
      'Impossible de joindre le modem. Le téléphone doit être connecté au Wi-Fi du modem à l\'heure prévue.';

  @override
  String get notifAirplaneFailedTitle => 'Mode avion : échec';

  @override
  String get notifAirplaneFailedBody =>
      'Impossible de joindre le modem. Vérifiez la connexion Wi-Fi du téléphone.';

  @override
  String get notifToggleRefusedBody =>
      'Le modem a refusé le changement. Réessayez depuis l\'appli.';

  @override
  String get notifToggleLoginFailedBody =>
      'Connexion au modem refusée : mot de passe incorrect ou absent. Reconnectez-vous dans l\'appli.';

  @override
  String get operatorUnknown => 'Opérateur inconnu';

  @override
  String operatorCode(String code) {
    return 'Opérateur $code';
  }

  @override
  String get noSim => 'Pas de SIM';

  @override
  String get mobileDataTitle => 'Données mobiles';

  @override
  String get mobileDataStateOn => 'Activées';

  @override
  String get mobileDataStateOff => 'Désactivées';

  @override
  String get mobileDataAirplaneOn => 'Coupées par le mode avion';

  @override
  String get mobileDataSwitching => 'Changement en cours…';

  @override
  String get mobileDataSwitchFailed =>
      'Le modem n\'a pas appliqué le changement des données mobiles.';

  @override
  String get dataCutFailed =>
      'Le modem n\'a pas appliqué le changement. Réessayez.';

  @override
  String get dataCutNotHoldingTitle => 'La coupure d\'internet ne tient pas';

  @override
  String get dataCutNotHoldingShort => 'Coupure inefficace';

  @override
  String get dataCutProfileLost =>
      'Le modem remet sans cesse son profil APN habituel, donc internet revient. L\'appli a réactivé la coupure plusieurs fois puis a arrêté. Désactivez puis réactivez pour réessayer.';

  @override
  String get dataCutInternetStillUp =>
      'Le profil de coupure est actif mais internet passe encore : votre opérateur semble accepter n\'importe quel APN. Avec cette SIM, l\'appli ne peut pas couper internet de cette façon.';

  @override
  String get mobileDataExplanation =>
      'Coupe internet en gardant la SIM sur le réseau (le signal reste visible). Le Wi-Fi reste actif.';

  @override
  String get simChangedTitle => 'Nouvelle SIM détectée';

  @override
  String simChangedBody(String operator) {
    return 'Nouvelle SIM détectée : $operator. Si internet ne fonctionne pas, vérifiez les réglages APN.';
  }

  @override
  String get simChangedOpenApn => 'Réglages APN';

  @override
  String get simChangedLater => 'Plus tard';

  @override
  String get expelTitle => 'Expulser les intrus';

  @override
  String get lockTitle => 'MiFi est verrouillée';

  @override
  String get lockReason => 'Déverrouillez pour accéder aux réglages du modem';

  @override
  String get lockFailed => 'Déverrouillage non abouti. Réessayez.';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get widgetInternetOn => 'Internet connecté';

  @override
  String get widgetInternetOff => 'Internet coupé';

  @override
  String get notifAutoRepairTitle => 'Réparation automatique';

  @override
  String get notifAutoRepairStarted =>
      'Internet est coupé malgré un bon signal : relance de la connexion en cours…';

  @override
  String get notifAutoRepairSucceeded =>
      'Internet a été rétabli automatiquement.';

  @override
  String get notifAutoRepairFailed =>
      'La relance automatique n\'a pas rétabli internet. Essayez de redémarrer le modem.';

  @override
  String get notifRebootFailedTitle => 'Redémarrage programmé : échec';

  @override
  String get notifRebootFailedBody =>
      'Impossible de joindre le modem à l\'heure prévue. Le téléphone doit être connecté au Wi-Fi du modem.';

  @override
  String get notifMobileDataFailedTitle => 'Données mobiles : échec';

  @override
  String signalDbm(int dbm) {
    return '$dbm dBm';
  }

  @override
  String get signalQualityNone => 'Inexistant';

  @override
  String get signalQualityPoor => 'Faible';

  @override
  String get signalQualityFair => 'Moyen';

  @override
  String get signalQualityGood => 'Bon';

  @override
  String get signalQualityExcellent => 'Excellent';

  @override
  String get wifiAuthNone => 'Aucune (réseau ouvert)';

  @override
  String get wifiAuthWpaPsk => 'WPA-PSK';

  @override
  String get wifiAuthWpa2Psk => 'WPA2-PSK';

  @override
  String get networkModeAuto => '4G/3G (automatique)';

  @override
  String get networkMode4gOnly => '4G uniquement';

  @override
  String get networkMode3gOnly => '3G uniquement';

  @override
  String get apnAuthNone => 'Aucune';

  @override
  String get apnAuthPap => 'PAP';

  @override
  String get apnAuthChap => 'CHAP';

  @override
  String get apnAuthPapChap => 'PAP/CHAP';

  @override
  String get pdpTypeIpv4 => 'IPv4';

  @override
  String get pdpTypeIpv6 => 'IPv6';

  @override
  String get pdpTypeIpv4v6 => 'IPv4/IPv6';

  @override
  String simSlot(int number) {
    return 'SIM $number';
  }

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get hubSectionModem => 'Modem';

  @override
  String get hubSectionTools => 'Outils';

  @override
  String get hubSectionApp => 'Application';

  @override
  String get hubWifiTitle => 'Wi-Fi';

  @override
  String get hubWifiSubtitle =>
      'Nom du réseau, mot de passe, canal, partage par QR code';

  @override
  String get hubMobileTitle => 'Réseau mobile';

  @override
  String get hubMobileSubtitle =>
      'SIM, APN, mode réseau, partage USB, détection de coupure';

  @override
  String get hubDhcpTitle => 'Réseau local (DHCP)';

  @override
  String get hubDhcpSubtitle => 'Adresse du modem et plage d\'adresses';

  @override
  String get hubSystemTitle => 'Système';

  @override
  String get hubSystemSubtitle =>
      'Mot de passe, redémarrage, réinitialisation, informations';

  @override
  String get hubSignalTitle => 'Historique du signal';

  @override
  String get hubSignalSubtitle =>
      'Graphique et recherche du meilleur emplacement';

  @override
  String get hubOutagesTitle => 'Journal des coupures';

  @override
  String get hubOutagesSubtitle =>
      'Historique des pertes de connexion internet';

  @override
  String get hubSpeedTestTitle => 'Test de débit';

  @override
  String get hubSpeedTestSubtitle => 'Mesurer la vitesse de téléchargement';

  @override
  String get hubBackupTitle => 'Sauvegarde et restauration';

  @override
  String get hubBackupSubtitle =>
      'Exporter puis réappliquer les réglages du modem';

  @override
  String get hubFirmwareTitle => 'Mise à jour du firmware';

  @override
  String get hubFirmwareSubtitle => 'Avancé : à utiliser avec précaution';

  @override
  String get hubAppSettingsTitle => 'Réglages de l\'application';

  @override
  String get hubAppSettingsSubtitle =>
      'Langue, thème, notifications, adresse du modem';

  @override
  String get appSettingsLanguage => 'Langue';

  @override
  String get appSettingsApplyToModem =>
      'Appliquer aussi à l\'interface web du modem';

  @override
  String get appSettingsApplyToModemHint =>
      'Change aussi la langue de la page web d\'origine du modem (langues acceptées : en, fr, pl, ru, tk, zh).';

  @override
  String get appSettingsSendNow => 'Envoyer la langue au modem maintenant';

  @override
  String get appSettingsLanguageSent => 'Langue envoyée au modem.';

  @override
  String get appSettingsLanguageNotSent =>
      'Le modem n\'a pas accepté le changement de langue.';

  @override
  String get appSettingsTheme => 'Thème';

  @override
  String get appSettingsThemeAuto => 'Automatique';

  @override
  String get appSettingsThemeLight => 'Clair';

  @override
  String get appSettingsThemeDark => 'Sombre';

  @override
  String get appSettingsNotifications => 'Notifications';

  @override
  String get appSettingsNotificationsBlocked =>
      'Les notifications de MiFi sont bloquées par Android.';

  @override
  String get appSettingsAllow => 'Autoriser';

  @override
  String get appSettingsNotificationsAll => 'Activer les notifications';

  @override
  String get appSettingsNotifyDown => 'Internet coupé';

  @override
  String get appSettingsNotifyUp => 'Internet rétabli';

  @override
  String get appSettingsNotifyLowSignal => 'Signal faible';

  @override
  String get appSettingsNotifyNewDevice => 'Nouvel appareil connecté';

  @override
  String get appSettingsBackground => 'Vérification en arrière-plan';

  @override
  String get appSettingsBackgroundHint =>
      'Vérification de secours environ toutes les 15 minutes (limite d\'Android), quand le téléphone est connecté au Wi-Fi du modem ; elle relance aussi la surveillance continue si Android l\'a arrêtée.';

  @override
  String get appSettingsMonitor => 'Surveillance continue';

  @override
  String get appSettingsMonitorHint =>
      'Vous prévient dès qu\'internet ne passe plus, même appli fermée (notification discrète « Surveillance active »). Relevés espacés quand tout va bien, pour économiser la batterie.';

  @override
  String get appSettingsMonitorRestricted =>
      'Android limite encore l\'appli en arrière-plan : la surveillance peut être interrompue. Autorisez-la à fonctionner sans restriction.';

  @override
  String get monitorPermissionTitle => 'Surveillance de la connexion';

  @override
  String get monitorPermissionMessage =>
      'Pour vous prévenir dès qu\'internet ne passe plus, même appli fermée, MiFi doit pouvoir fonctionner en arrière-plan. Android va vous demander deux autorisations (notifications et arrière-plan) : acceptez-les. La surveillance consomme très peu de batterie et s\'affiche par une notification discrète « Surveillance active ».';

  @override
  String get monitorPermissionAllow => 'Autoriser';

  @override
  String get appSettingsAutomation => 'Automatismes';

  @override
  String get appSettingsAutoRepair => 'Réparation automatique';

  @override
  String get appSettingsAutoRepairHint =>
      'Si internet est coupé depuis 3 minutes alors que le signal est bon, l\'appli relance la connexion (au plus une fois toutes les 30 minutes).';

  @override
  String get appSettingsSchedule => 'Mode avion programmé';

  @override
  String get appSettingsScheduleHint =>
      'Coupe le réseau mobile chaque jour pendant la plage choisie.';

  @override
  String get appSettingsFrom => 'De';

  @override
  String get appSettingsTo => 'À';

  @override
  String get appSettingsScheduleSame =>
      'Le début et la fin doivent être différents.';

  @override
  String appSettingsScheduleNext(String start, String end) {
    return 'Prochaine coupure : $start · fin : $end';
  }

  @override
  String get appSettingsReboot => 'Redémarrage programmé du modem';

  @override
  String get appSettingsRebootHint =>
      'Redémarre le modem chaque jour à l\'heure choisie.';

  @override
  String get appSettingsRebootTime => 'Heure du redémarrage';

  @override
  String appSettingsRebootNext(String time) {
    return 'Prochain redémarrage : $time';
  }

  @override
  String get appSettingsAutomationNote =>
      'Au moment prévu, le téléphone doit être connecté au Wi-Fi du modem ; sinon une notification d\'échec s\'affiche. Android peut décaler l\'heure de quelques minutes.';

  @override
  String get appSettingsReliabilityHint =>
      'Pour que les programmations et la surveillance fonctionnent appli fermée sur un téléphone Xiaomi, autorisez le démarrage automatique et choisissez « Aucune restriction » dans l\'économie de batterie de l\'appli.';

  @override
  String get appSettingsExactAlarmsMissing =>
      'Les alarmes exactes ne sont pas autorisées : Android peut décaler les programmations de plusieurs minutes, voire davantage.';

  @override
  String get appSettingsExactAlarmsAllow => 'Autoriser';

  @override
  String get appSettingsAutostart => 'Démarrage automatique';

  @override
  String get appSettingsBattery => 'Économie de batterie';

  @override
  String get appSettingsSecurity => 'Sécurité';

  @override
  String get appSettingsLock => 'Verrouiller l\'appli';

  @override
  String get appSettingsLockHint =>
      'Demande l\'empreinte digitale ou le code du téléphone à l\'ouverture de MiFi.';

  @override
  String get appSettingsLockUnsupported =>
      'Aucune empreinte ni aucun code n\'est configuré sur ce téléphone.';

  @override
  String get appSettingsAddressConfirmTitle => 'Changer l\'adresse du modem ?';

  @override
  String appSettingsAddressConfirm(String address) {
    return 'L\'appli contactera désormais le modem à l\'adresse $address.';
  }

  @override
  String get appSettingsAbout => 'À propos';

  @override
  String get appSettingsAboutText =>
      'MiFi pilote votre modem 4G HiMILink depuis le téléphone, avec n\'importe quelle SIM. L\'appli ne fonctionne que connectée au Wi-Fi du modem.';

  @override
  String get backupExportSection => 'Sauvegarder';

  @override
  String get backupExportHint =>
      'Enregistre dans un fichier les réglages Wi-Fi, APN, DHCP, mode réseau et détection de coupure.';

  @override
  String get backupPrivacy =>
      'Le mot de passe administrateur n\'est jamais exporté. Le fichier contient en revanche le mot de passe Wi-Fi : gardez-le en lieu sûr.';

  @override
  String get backupExport => 'Exporter les réglages';

  @override
  String get backupExported => 'Sauvegarde enregistrée.';

  @override
  String get backupExportCancelled => 'Export annulé.';

  @override
  String get backupImportSection => 'Restaurer';

  @override
  String get backupImportHint =>
      'Réappliquez une sauvegarde, par exemple après une réinitialisation d\'usine.';

  @override
  String get backupChooseFile => 'Choisir un fichier de sauvegarde';

  @override
  String get backupFileLabel => 'Sauvegarde MiFi (.json)';

  @override
  String get backupInvalidFile =>
      'Ce fichier n\'est pas une sauvegarde MiFi valide.';

  @override
  String backupFileDate(String date) {
    return 'Sauvegarde du $date';
  }

  @override
  String get backupOrderNote =>
      'Ordre d\'application : mode réseau, détection, APN, puis DHCP (le modem redémarre) et enfin le Wi-Fi (le téléphone devra s\'y reconnecter).';

  @override
  String get backupRestore => 'Restaurer la sélection';

  @override
  String get backupRestoreTitle => 'Restaurer ces réglages ?';

  @override
  String get backupRestoreWarning =>
      'Les réglages choisis vont remplacer ceux du modem. Le DHCP redémarre le modem, et le changement de Wi-Fi déconnecte tous les appareils.';

  @override
  String get backupRestored => 'Réglages restaurés.';

  @override
  String get backupWifiAppliedTitle => 'Wi-Fi restauré';

  @override
  String backupWifiApplied(String ssid) {
    return 'Le Wi-Fi « $ssid » a été appliqué : reconnectez le téléphone à ce réseau.';
  }

  @override
  String get compareHubSubtitle =>
      'Signal, débit et coupures selon la SIM utilisée';

  @override
  String get compareIntro =>
      'Mesures des 7 derniers jours, classées par signal moyen. Elles sont attribuées à l\'opérateur de la SIM utilisée à ce moment-là.';

  @override
  String get compareEmpty =>
      'Pas encore assez de mesures. Utilisez l\'appli quelques jours avec vos différentes SIM, et lancez des tests de débit.';

  @override
  String get compareSignal => 'Signal moyen';

  @override
  String get compareSpeed => 'Débit moyen';

  @override
  String get compareOutages => 'Coupures';

  @override
  String compareBestSpeed(String value) {
    return 'Meilleur débit : $value';
  }

  @override
  String compareLastUsed(String time) {
    return 'Dernière utilisation : $time';
  }

  @override
  String get dashboardWifiOn => 'Wi-Fi allumé';

  @override
  String get dashboardWifiOff => 'Wi-Fi éteint';

  @override
  String get dashboardSimOk => 'SIM présente';

  @override
  String get dashboardLanguage => 'Langue';

  @override
  String get dashboardAdmin => 'Administrateur';

  @override
  String get dashboardChangePassword => 'Changer le mot de passe';

  @override
  String get dashboardLogout => 'Se déconnecter';

  @override
  String get dashboardLogoutConfirm =>
      'Vous serez déconnecté du modem et le mot de passe enregistré sera oublié.';

  @override
  String dashboardWanIp(String ip) {
    return 'IP WAN $ip';
  }

  @override
  String get dashboardSignalHistory => 'Historique';

  @override
  String get dashboardBestLocation => 'Meilleur emplacement';

  @override
  String get dashboardUsbTitle => 'Partage USB';

  @override
  String get dashboardTurnOn => 'Activer';

  @override
  String get dashboardTurnOff => 'Couper';

  @override
  String get dashboardAirplaneConfirmTitle => 'Activer le mode avion ?';

  @override
  String get airplaneDisableConfirmTitle => 'Désactiver le mode avion ?';

  @override
  String get airplaneDisableConfirmMessage =>
      'Internet sera rétabli avec votre profil APN habituel.';

  @override
  String get airplaneDisableConfirmAction => 'Désactiver';

  @override
  String get dashboardMobileDataConfirmTitle => 'Couper les données mobiles ?';

  @override
  String get dashboardMobileDataHow =>
      'L\'appli active pour cela un profil APN de coupure (« MiFi-OFF ») ; réactiver les données remet votre profil habituel. Fonction à confirmer sur votre modem.';

  @override
  String get dashboardAirplaneWaiting =>
      'Activation du mode avion… Le Wi-Fi reste actif.';

  @override
  String get dashboardAirplaneWaitingOff => 'Désactivation du mode avion…';

  @override
  String get dashboardMobileDataWaiting =>
      'Changement des données mobiles en cours…';

  @override
  String get dashboardTogglesInfo => 'Comment ça marche ?';

  @override
  String get dashboardTogglesInfoTitle => 'Données mobiles et mode avion';

  @override
  String get dashboardReconnectTitle => 'Relancer la connexion';

  @override
  String get dashboardReconnectHint =>
      'Internet ne passe plus ? Relancez la connexion : plus rapide qu\'un redémarrage du modem.';

  @override
  String get dashboardInternetUnknown => 'État d\'internet inconnu';

  @override
  String get dashboardInternetLostTitle => 'Internet ne passe plus';

  @override
  String get dashboardInternetLostMessage =>
      'Le modem n\'a plus accès à internet. Relancez la connexion pour le rétablir.';

  @override
  String get dashboardReconnectAction => 'Relancer la connexion';

  @override
  String get dashboardReconnectConfirm =>
      'L\'appli coupe la connexion du modem, comme un mode avion (il se réinscrit sur le réseau), puis la rétablit. Elle recommence jusqu\'au retour d\'internet ou jusqu\'à ce que vous touchiez « Arrêter ». Le Wi-Fi reste actif.';

  @override
  String get dashboardReconnectStepCut => 'Coupure de la connexion';

  @override
  String get dashboardReconnectStepRestore => 'Rétablissement de la connexion';

  @override
  String get dashboardReconnectStepReregister =>
      'Réinscription du modem sur le réseau';

  @override
  String dashboardReconnectAttempt(int attempt) {
    return 'Tentative $attempt';
  }

  @override
  String dashboardReconnectElapsed(String time) {
    return 'Temps écoulé : $time';
  }

  @override
  String get dashboardReconnectStop => 'Arrêter';

  @override
  String get dashboardReconnectStopping => 'Arrêt après cette tentative…';

  @override
  String get dashboardReconnectStopped => 'Relance arrêtée.';

  @override
  String dashboardReconnectSuccessAfter(int attempt) {
    return 'Connexion relancée : internet est revenu à la tentative $attempt.';
  }

  @override
  String get dashboardReconnectStepInternet => 'Attente du retour d\'internet';

  @override
  String get dashboardReconnectSuccess =>
      'Connexion relancée : internet est revenu.';

  @override
  String get dashboardReconnectNoInternet =>
      'Le réseau est revenu mais internet ne répond pas encore. Réessayez ou redémarrez le modem.';

  @override
  String get dashboardRebootTitle => 'Redémarrer le modem ?';

  @override
  String get dashboardRebootConfirm =>
      'Le modem va redémarrer (environ 1 minute). Tous les appareils seront déconnectés pendant ce temps.';

  @override
  String get dashboardRebootAction => 'Redémarrer le modem';

  @override
  String get dashboardSeeAll => 'Voir';

  @override
  String dashboardDevicesSplit(int wifi, int wired) {
    return 'Wi-Fi : $wifi · Filaire : $wired';
  }

  @override
  String get dashboardModemSection => 'Modem';

  @override
  String get dashboardUptime => 'Durée de fonctionnement';

  @override
  String get dashboardCpuTemp => 'Température du processeur';

  @override
  String dashboardTemperature(String value) {
    return '$value °C';
  }

  @override
  String get dashboardSystemTime => 'Heure du modem';

  @override
  String get dashboardBsid => 'Station de base (BS ID)';

  @override
  String get dashboardCellId => 'Cellule (Cell ID)';

  @override
  String get dashboardSoftwareVersion => 'Version logicielle';

  @override
  String get dashboardHardwareVersion => 'Version matérielle';

  @override
  String get dashboardWebVersion => 'Version de l\'interface web';

  @override
  String get dashboardImei => 'IMEI';

  @override
  String get dashboardIccid => 'ICCID';

  @override
  String get dashboardImsi => 'IMSI';

  @override
  String get dashboardSsid => 'Nom du Wi-Fi';

  @override
  String get dashboardShortcuts => 'Raccourcis';

  @override
  String get dashboardCompareOperators => 'Comparatif des opérateurs';

  @override
  String get devicesConnected => 'Connectés maintenant';

  @override
  String get devicesNoneConnected => '0 appareil connecté pour le moment.';

  @override
  String get devicesSeenBefore => 'Déjà vus (déconnectés)';

  @override
  String get devicesNewBadge => 'Nouveau';

  @override
  String get devicesRename => 'Donner un surnom';

  @override
  String get devicesRenameTitle => 'Surnom de l\'appareil';

  @override
  String get devicesNickname => 'Surnom';

  @override
  String get devicesNicknameHint =>
      'Mémorisé dans l\'appli ; laissez vide pour l\'effacer';

  @override
  String get devicesIp => 'Adresse IP';

  @override
  String get devicesMac => 'Adresse MAC';

  @override
  String get devicesAnnouncedName => 'Nom annoncé par l\'appareil';

  @override
  String get devicesFirstSeen => 'Vu la première fois';

  @override
  String get devicesLastSeen => 'Vu la dernière fois';

  @override
  String devicesLastSeenShort(String time) {
    return 'vu $time';
  }

  @override
  String get devicesNoBlockingNote =>
      'Le modem ne permet pas de bloquer un appareil : utilisez « Expulser les intrus » pour changer le mot de passe Wi-Fi.';

  @override
  String get dhcpWarning =>
      'Enregistrer ces réglages redémarre le modem (environ 1 minute) et son adresse peut changer. Tous les appareils seront déconnectés pendant ce temps.';

  @override
  String get dhcpModemSection => 'Adresse du modem';

  @override
  String get dhcpGateway => 'Adresse IP du modem (passerelle)';

  @override
  String get dhcpNetmask => 'Masque de sous-réseau';

  @override
  String get dhcpServerSection => 'Serveur DHCP';

  @override
  String get dhcpServer => 'Serveur DHCP';

  @override
  String get dhcpReadOnly =>
      'Non modifiable (comme dans l\'interface d\'origine)';

  @override
  String get dhcpPoolStart => 'Début de plage';

  @override
  String get dhcpPoolEnd => 'Fin de plage';

  @override
  String get dhcpLease => 'Durée du bail';

  @override
  String get dhcpHours => 'heures';

  @override
  String dhcpSummary(String network, int prefix, int count) {
    return 'Réseau $network/$prefix · $count adresses attribuables';
  }

  @override
  String get dhcpErrorNetmask => 'Masque invalide (ex. 255.255.255.0)';

  @override
  String get dhcpErrorReserved => 'Adresse réservée (réseau ou diffusion)';

  @override
  String get dhcpErrorSubnet => 'Hors du sous-réseau du modem';

  @override
  String get dhcpErrorOrder => 'La fin doit être après le début';

  @override
  String get dhcpErrorGatewayInPool =>
      'L\'adresse du modem ne doit pas être dans la plage';

  @override
  String dhcpErrorLease(int max) {
    return 'Nombre d\'heures entre 1 et $max';
  }

  @override
  String get dhcpSaveTitle => 'Enregistrer et redémarrer ?';

  @override
  String get dhcpSaveWarning =>
      'Le modem va redémarrer (environ 1 minute). Le téléphone devra peut-être se reconnecter au Wi-Fi.';

  @override
  String dhcpNewAddress(String address) {
    return 'L\'adresse du modem devient $address : l\'appli l\'utilisera automatiquement.';
  }

  @override
  String get dhcpNotBack =>
      'Le modem ne répond pas encore. Vérifiez le Wi-Fi du téléphone ; l\'adresse du modem peut aussi se modifier dans Réglages › Réglages de l\'application.';

  @override
  String get expelIntro =>
      'Le modem ne sait pas bloquer un appareil précis. Pour se débarrasser d\'un intrus, l\'appli change le mot de passe Wi-Fi : seuls ceux qui connaissent le nouveau pourront se reconnecter.';

  @override
  String get expelWarning =>
      'Tous les appareils, y compris ce téléphone, seront déconnectés. Reconnectez-vous avec le nouveau mot de passe.';

  @override
  String get expelHideSsid => 'Masquer aussi le nom du Wi-Fi';

  @override
  String get expelHideSsidHint =>
      'Le réseau devient invisible pour les voisins ; il faudra saisir son nom pour s\'y connecter.';

  @override
  String get expelApply => 'Générer un nouveau mot de passe et l\'appliquer';

  @override
  String get expelDone =>
      'Nouveau mot de passe appliqué. Scannez ce code avec vos appareils pour les reconnecter.';

  @override
  String get expelNetwork => 'Réseau Wi-Fi';

  @override
  String get expelNewPassword => 'Nouveau mot de passe';

  @override
  String get expelHiddenNote =>
      'Le nom du réseau est masqué : il n\'apparaît plus dans la liste des Wi-Fi.';

  @override
  String get expelReconnectPhone => 'Reconnecter ce téléphone';

  @override
  String get expelWaiting =>
      'En attente de la reconnexion du téléphone au Wi-Fi…';

  @override
  String get expelReconnected => 'Téléphone reconnecté : la session a repris.';

  @override
  String get expelNotReconnected =>
      'Le téléphone n\'est pas encore reconnecté au Wi-Fi du modem.';

  @override
  String get firmwareDangerTitle => 'Réservé aux utilisateurs avertis';

  @override
  String get firmwareDanger =>
      'Un mauvais fichier ou une coupure pendant la mise à jour peut rendre le modem inutilisable. N\'utilisez que le firmware officiel prévu pour ce modem.';

  @override
  String get firmwareChecklist => 'Avant de commencer';

  @override
  String get firmwareCheckBattery => 'La batterie du modem est chargée';

  @override
  String get firmwareCheckPlugged =>
      'Le modem restera branché et je ne l\'éteindrai pas';

  @override
  String get firmwareCheckRisks => 'Je comprends les risques';

  @override
  String get firmwareFileSection => 'Fichier du firmware';

  @override
  String get firmwareFileLabel => 'Firmware (.zip)';

  @override
  String get firmwareChoose => 'Choisir le fichier .zip';

  @override
  String get firmwareChooseAnother => 'Choisir un autre fichier';

  @override
  String get firmwareNotZip => 'Le fichier doit être une archive .zip.';

  @override
  String get firmwareTooBig =>
      'Fichier vide ou trop volumineux (500 Mo au maximum).';

  @override
  String firmwareSize(String size) {
    return '$size Mo';
  }

  @override
  String get firmwareCrcLabel => 'Code CRC';

  @override
  String get firmwareCrcHelper =>
      'Code de contrôle fourni avec le firmware. À défaut, l\'appli peut le calculer (format attendu par le modem à confirmer).';

  @override
  String get firmwareComputeMd5 => 'Calculer le MD5';

  @override
  String get firmwareComputeCrc32 => 'Calculer le CRC32';

  @override
  String get firmwareStart => 'Lancer la mise à jour';

  @override
  String get firmwareConfirmTitle => 'Mettre à jour le firmware ?';

  @override
  String firmwareConfirmMessage(String file) {
    return 'Le fichier « $file » va être envoyé au modem. Ne quittez pas l\'appli et n\'éteignez pas le modem pendant toute l\'opération.';
  }

  @override
  String get firmwareConfirmWord => 'METTRE À JOUR';

  @override
  String get firmwarePreparing => 'Préparation de la mise à jour…';

  @override
  String firmwareUploading(String sent, String total) {
    return 'Envoi du fichier : $sent Mo sur $total Mo';
  }

  @override
  String get firmwareVerifying => 'Vérification du fichier par le modem…';

  @override
  String get firmwareDoNotLeave =>
      'Ne quittez pas cet écran et n\'éteignez pas le modem.';

  @override
  String get firmwareCancel => 'Annuler l\'envoi';

  @override
  String get firmwareCancelTitle => 'Annuler l\'envoi ?';

  @override
  String get firmwareCancelMessage =>
      'L\'envoi du firmware sera interrompu ; le modem gardera sa version actuelle.';

  @override
  String get firmwareRefused => 'Le modem a refusé la mise à jour';

  @override
  String get firmwareNoAnswer =>
      'Le modem n\'a pas confirmé la vérification du fichier.';

  @override
  String get firmwareInProgressTitle => 'Mise à jour en cours';

  @override
  String get firmwareInProgress =>
      'Le modem installe le nouveau firmware puis redémarrera. Cela peut prendre plusieurs minutes : ne l\'éteignez surtout pas.';

  @override
  String get firmwareWaitingRestart =>
      'Installation du firmware et redémarrage du modem (plusieurs minutes)…';

  @override
  String get helpTitle => 'Guide d\'utilisation';

  @override
  String get helpHubSubtitle =>
      'Comment utiliser chaque fonction, et que faire en cas de problème';

  @override
  String get helpIntro =>
      'MiFi remplace l\'interface web du modem. Touchez une rubrique pour savoir comment utiliser chaque fonction.';

  @override
  String get helpStartTitle => 'Premiers pas';

  @override
  String get helpStartBody =>
      '1. Connectez le téléphone au Wi-Fi du modem (nom et mot de passe sur l\'étiquette du modem).\n2. Ouvrez MiFi et saisissez le mot de passe administrateur du modem (indiqué sur l\'étiquette s\'il n\'a jamais été changé).\n3. Laissez « Mémoriser le mot de passe » coché : la connexion sera automatique aux lancements suivants. Le mot de passe est enregistré chiffré sur le téléphone.\n\nSi Android signale « Pas d\'accès à internet » pour ce Wi-Fi (par exemple quand les données sont coupées), c\'est normal : l\'appli l\'utilise quand même pour parler au modem.';

  @override
  String get helpAddressTitle => 'Adresse du modem';

  @override
  String get helpAddressBody =>
      'Par défaut, le modem répond à l\'adresse 192.168.100.1.\n\nSi vous la changez dans « Réseau local (DHCP) », l\'appli suit automatiquement la nouvelle adresse. Vous pouvez aussi la modifier à la main sur l\'écran de connexion (rubrique « Adresse du modem ») ou dans Réglages › Réglages de l\'application. L\'appli propose l\'adresse de la passerelle du Wi-Fi actuel quand elle est différente.';

  @override
  String get helpDashboardTitle => 'Tableau de bord';

  @override
  String get helpDashboardBody =>
      'En haut, comme sur l\'interface d\'origine : icônes Wi-Fi, SIM, signal et internet, nom de l\'opérateur, choix de la langue et menu administrateur (mot de passe, guide, déconnexion).\n\nEn dessous : le signal (barres, dBm, qualité), l\'état d\'internet et l\'IP WAN, des boutons rapides façon téléphone (Données mobiles, Wi-Fi, Partage USB), « Relancer la connexion », les appareils connectés, les informations et versions du modem, et des raccourcis.\n\nLes données se mettent à jour en continu (toutes les 2 secondes) ; tirez l\'écran vers le bas pour tout recharger. Les valeurs que le modem ne fournit pas sont masquées au lieu d\'afficher 0.';

  @override
  String get helpOperatorTitle => 'Opérateur et changement de SIM';

  @override
  String get helpOperatorBody =>
      'L\'appli fonctionne avec la SIM de n\'importe quel opérateur. Elle affiche le nom de service fourni par la SIM ; sinon, elle déduit l\'opérateur du code de la SIM (MTN, Orange, Nexttel, Camtel), ou affiche « Opérateur 624-XX ».\n\nQuand vous changez de SIM, l\'appli affiche « Nouvelle SIM détectée » et propose d\'ouvrir les réglages APN. En général, le modem choisit seul le bon APN.';

  @override
  String get helpMobileDataTitle => 'Données mobiles';

  @override
  String get helpMobileDataBody =>
      'Comme sur un téléphone, l\'interrupteur « Données mobiles » coupe internet tout en gardant la SIM connectée au réseau (le signal reste visible). Le Wi-Fi reste actif.\n\nLe modem n\'ayant pas de commande dédiée, l\'appli active pour cela un profil APN de coupure (« MiFi-OFF ») ; réactiver les données remet votre profil habituel. Une tuile « Données mobiles » est aussi disponible dans les Réglages rapides d\'Android.';

  @override
  String get helpAirplaneTitle => 'Mode avion';

  @override
  String get helpAirplaneBody =>
      'Comme sur un téléphone, le mode avion coupe internet sur la SIM utilisée (SIM 1 ou SIM 2), sans jamais changer de SIM. Après confirmation, il s\'active en quelques secondes. Le Wi-Fi du modem reste allumé : vos appareils restent connectés au modem (sans internet) et l\'appli peut toujours désactiver le mode avion.\n\nLe modem n\'a pas de commande pour éteindre sa radio : l\'appli coupe internet en activant un profil APN de coupure (« MiFi-OFF »). La SIM reste donc accrochée au réseau et la barre de signal reste visible. Si vous changez de SIM pendant le mode avion, la coupure s\'applique aussi à la nouvelle SIM.\n\nL\'appli vérifie que la connexion tombe. Si le modem remet de lui-même son profil APN habituel, elle réactive la coupure : à chaque relevé quand l\'appli est ouverte, sinon lors des vérifications en arrière-plan (toutes les 15 minutes au mieux, si elles sont activées). Si la coupure ne tient pas, par exemple quand l\'opérateur accepte n\'importe quel APN, un avertissement s\'affiche.\n\nPendant le mode avion, l\'interrupteur « Données mobiles » est grisé. Désactiver le mode avion remet votre profil APN habituel.';

  @override
  String get helpReconnectTitle =>
      'Relancer la connexion et réparation automatique';

  @override
  String get helpReconnectBody =>
      'Quand internet ne passe plus, touchez « Relancer la connexion » sur le tableau de bord : l\'appli coupe la connexion du modem, comme un mode avion (il se réinscrit sur le réseau), puis la rétablit. Elle recommence jusqu\'au retour d\'internet ou jusqu\'à ce que vous touchiez « Arrêter » ; le numéro de la tentative et le temps écoulé sont affichés. C\'est bien plus rapide qu\'un redémarrage du modem, qui reste proposé.\n\nAvec la réparation automatique (Réglages › Réglages de l\'application), l\'appli le fait seule si internet est coupé depuis 3 minutes avec un bon signal (3 tentatives au plus, une fois toutes les 30 minutes au plus).';

  @override
  String get helpTileTitle => 'Tuiles « Réglages rapides » et raccourcis';

  @override
  String get helpTileBody =>
      'Pour activer ou désactiver les données mobiles sans ouvrir l\'appli :\n1. Faites glisser deux fois vers le bas depuis le haut de l\'écran.\n2. Touchez le crayon (Modifier).\n3. Faites glisser la tuile « Données mobiles » de MiFi parmi vos tuiles.\n\nUn appui lance le changement. Le téléphone doit être connecté au Wi-Fi du modem et le mot de passe mémorisé ; en cas d\'échec, une notification vous prévient.\n\nUn appui long sur l\'icône MiFi propose aussi des raccourcis : Partager le Wi-Fi, Test de débit.';

  @override
  String get helpWidgetTitle => 'Widgets d\'écran d\'accueil';

  @override
  String get helpWidgetBody =>
      'Appuyez longuement sur un espace vide de l\'écran d\'accueil, choisissez « Widgets », puis MiFi : le widget « État du modem » affiche l\'opérateur, le signal, internet et le nombre d\'appareils ; un appui ouvre l\'appli. Il se met à jour quand l\'appli est ouverte et à chaque vérification en arrière-plan.';

  @override
  String get helpScheduleTitle => 'Redémarrage programmé';

  @override
  String get helpScheduleBody =>
      'Dans Réglages › Réglages de l\'application › Automatismes, le redémarrage programmé redémarre le modem chaque jour à l\'heure choisie.\n\nÀ l\'heure prévue, le téléphone doit être connecté au Wi-Fi du modem ; sinon, une notification d\'échec s\'affiche. Android peut décaler l\'heure de quelques minutes.';

  @override
  String get helpDevicesTitle => 'Appareils connectés';

  @override
  String get helpDevicesBody =>
      'L\'onglet Appareils liste les appareils connectés : nom, type (Wi-Fi ou filaire), adresse IP et adresse MAC. Touchez un appareil pour lui donner un surnom, mémorisé d\'après son adresse MAC.\n\nUn badge « Nouveau » signale un appareil vu pour la première fois récemment, et une alerte prévient quand un appareil inconnu se connecte, avec un accès direct à « Expulser les intrus ». Les appareils déjà vus mais déconnectés sont listés à part.';

  @override
  String get helpExpelTitle => 'Expulser les intrus';

  @override
  String get helpExpelBody =>
      'Le modem ne sait pas bloquer un appareil. « Expulser les intrus » génère un nouveau mot de passe Wi-Fi solide (12 caractères), l\'applique et affiche aussitôt son QR code. Vous pouvez aussi masquer le nom du Wi-Fi pour le rendre invisible aux voisins.\n\nTous les appareils, y compris ce téléphone, sont déconnectés : reconnectez-les avec le nouveau mot de passe (bouton « Reconnecter ce téléphone », QR code ou partage par message). L\'appli reprend sa session dès que le téléphone est reconnecté.';

  @override
  String get helpWifiTitle => 'Wi-Fi et partage';

  @override
  String get helpWifiBody =>
      'Réglages › Wi-Fi permet de changer le nom du réseau, le mot de passe (8 à 32 caractères), la sécurité, le canal et la diffusion du nom. Après l\'enregistrement, le Wi-Fi redémarre : reconnectez le téléphone au réseau.\n\nPour partager le Wi-Fi : QR code à scanner avec l\'appareil photo, ou envoi du nom et du mot de passe par message (WhatsApp, SMS…).\n\nAttention : « Couper le Wi-Fi » déconnecte immédiatement le téléphone et l\'appli ne pourra pas le rallumer. Il faudra le bouton du modem ou un redémarrage.';

  @override
  String get helpDhcpTitle => 'Réseau local (DHCP)';

  @override
  String get helpDhcpBody =>
      'Cette page règle l\'adresse du modem, le masque, la plage d\'adresses attribuées aux appareils et la durée du bail (en heures). L\'appli vérifie que la plage est dans le même sous-réseau que le modem.\n\nL\'enregistrement redémarre le modem (environ 1 minute). Si l\'adresse du modem change, l\'appli utilise automatiquement la nouvelle. L\'état du serveur DHCP est affiché en lecture seule.';

  @override
  String get helpMobileTitle => 'Réseau mobile';

  @override
  String get helpMobileBody =>
      '• Carte SIM : emplacement utilisé (SIM 1 ou SIM 2) ; la bascule prend environ 20 secondes.\n• Données mobiles : même interrupteur que sur le tableau de bord.\n• APN : choisissez le profil utilisé pour internet ou créez-en un avec les paramètres de votre opérateur (MCC et MNC sont pré-remplis d\'après la SIM).\n• Mode réseau : 4G/3G automatique, 4G uniquement ou 3G uniquement.\n• Partage de connexion USB : internet par câble USB vers un ordinateur.\n• Détection de coupure : le modem vérifie la connexion en contactant ces adresses (IP ou nom, par exemple 8.8.8.8 ou www.google.com).';

  @override
  String get helpSystemTitle => 'Système';

  @override
  String get helpSystemBody =>
      '• Changer le mot de passe administrateur : l\'appli se reconnecte toute seule avec le nouveau.\n• Redémarrer le modem : environ 1 minute ; l\'appli attend son retour.\n• Réinitialisation d\'usine : deux confirmations sont demandées. Le Wi-Fi et le mot de passe reviennent aux valeurs de l\'étiquette du modem : reconnectez le téléphone au Wi-Fi d\'usine puis reconnectez-vous. Faites une sauvegarde avant.\n• Informations de fabrication : calibrage et test Wi-Fi d\'usine (lecture seule).';

  @override
  String get helpFirmwareTitle => 'Mise à jour du firmware';

  @override
  String get helpFirmwareBody =>
      'Réservée aux utilisateurs avertis : un mauvais fichier peut rendre le modem inutilisable.\n\nAvant de commencer : batterie chargée, modem branché et immobile, téléphone près du modem. Choisissez le fichier .zip officiel (500 Mo maximum) et saisissez le code CRC fourni avec lui. Pendant l\'envoi, ne quittez pas l\'appli et n\'éteignez pas le modem. À la fin, le modem se met à jour puis redémarre.';

  @override
  String get helpSignalTitle => 'Historique du signal et meilleur emplacement';

  @override
  String get helpSignalBody =>
      'Réglages › Historique du signal affiche la puissance du signal (en dBm) sur la dernière heure ou les dernières 24 heures. Plus la valeur est proche de 0, meilleur est le signal : excellent (4 barres) à partir de -80 dBm, bon (3) à partir de -90, moyen (2) à partir de -100, faible (1) à partir de -110, inexistant en dessous ; les barres sont vertes, orange ou rouges selon le niveau. Le relevé est mis à jour en continu (toutes les 2 secondes).\n\n« Trouver le meilleur emplacement » affiche une grande jauge mise à jour toutes les 2 à 3 secondes. Déplacez lentement le modem (près d\'une fenêtre, en hauteur) et attendez quelques secondes à chaque position : l\'appli retient la meilleure valeur.';

  @override
  String get helpOutagesTitle => 'Journal des coupures';

  @override
  String get helpOutagesBody =>
      'Chaque perte d\'internet est notée avec son début, sa fin et sa durée ; les coupures dues aux données coupées ou à « Relancer la connexion » sont marquées « volontaires ». Un résumé indique le nombre et la durée des coupures sur 24 heures et 7 jours.\n\nLe bouton d\'export enregistre le journal en fichier CSV (lisible avec Excel), par exemple pour réclamer auprès de l\'opérateur.';

  @override
  String get helpSpeedTestTitle => 'Test de débit et comparatif des opérateurs';

  @override
  String get helpSpeedTestBody =>
      'Le test de débit télécharge un fichier (5, 10 ou 25 Mo) à travers le modem et affiche le débit en Mb/s avec sa qualité : inexistant, faible, moyen, bon ou excellent. Il consomme des données de votre forfait. Les résultats sont gardés dans un historique.\n\nLe comparatif des opérateurs (raccourci sur le tableau de bord) regroupe, pour chaque SIM utilisée ces 7 derniers jours : signal moyen, débit moyen et coupures. Pratique pour choisir la SIM qui marche le mieux chez vous.';

  @override
  String get helpBackupTitle => 'Sauvegarde et restauration';

  @override
  String get helpBackupBody =>
      '« Exporter les réglages » enregistre dans un fichier les réglages Wi-Fi, APN, DHCP, mode réseau et détection de coupure. Le mot de passe administrateur n\'est jamais exporté, mais le fichier contient le mot de passe Wi-Fi : gardez-le en lieu sûr.\n\n« Restaurer » réapplique une sauvegarde, par exemple après une réinitialisation d\'usine. Vous choisissez les rubriques ; le DHCP redémarre le modem, et le Wi-Fi est appliqué en dernier car le téléphone devra s\'y reconnecter.';

  @override
  String get helpNotificationsTitle => 'Notifications';

  @override
  String get helpNotificationsBody =>
      'MiFi peut vous prévenir quand internet est coupé ou revient, quand le signal est faible et quand un nouvel appareil se connecte. Réglez-les dans Réglages › Réglages de l\'application › Notifications, et autorisez-les quand Android le demande.\n\nAppli ouverte, la surveillance est continue. Appli fermée, la surveillance continue (Réglages de l\'application) vous prévient en quelques secondes ; sans elle, Android n\'autorise qu\'une vérification environ toutes les 15 minutes. Le téléphone doit être connecté au Wi-Fi du modem.';

  @override
  String get helpLanguageTitle => 'Langue, thème et verrouillage';

  @override
  String get helpLanguageBody =>
      'Dans Réglages › Réglages de l\'application :\n• langue de l\'appli (langue du téléphone, français ou anglais) ; l\'option « Appliquer aussi à l\'interface web du modem » change aussi la langue de la page web d\'origine ;\n• thème automatique, clair ou sombre ;\n• verrouillage : MiFi demande l\'empreinte digitale ou le code du téléphone à l\'ouverture.';

  @override
  String get helpTroubleshootingTitle => 'En cas de problème';

  @override
  String get helpTroubleshootingBody =>
      '• « Impossible de joindre le modem » : vérifiez que le téléphone est connecté au Wi-Fi du modem, puis l\'adresse du modem (192.168.100.1 par défaut).\n• « Session expirée » : l\'appli se reconnecte seule ; si le mot de passe a été changé ailleurs, reconnectez-vous.\n• Wi-Fi coupé : rallumez-le avec le bouton du modem ou redémarrez le modem.\n• Mot de passe administrateur oublié : faites une réinitialisation d\'usine avec le bouton RESET du modem.\n• Données mobiles en échec : vérifiez le Wi-Fi puis réessayez ; en dernier recours, redémarrez le modem.';

  @override
  String get helpLimitsTitle => 'Ce que le modem ne permet pas';

  @override
  String get helpLimitsBody =>
      'L\'API du modem ne fournit pas ces informations, et l\'appli ne les invente pas : niveau de batterie, données consommées, blocage d\'un appareil, SMS, USSD, solde ou forfait de l\'opérateur.';

  @override
  String get loginTitle => 'Connexion au modem';

  @override
  String get loginSubtitle =>
      'Connectez le téléphone au Wi-Fi du modem, puis saisissez le mot de passe administrateur.';

  @override
  String get loginPasswordLabel => 'Mot de passe administrateur';

  @override
  String get loginRemember => 'Mémoriser le mot de passe';

  @override
  String get loginRememberHint =>
      'Enregistré chiffré sur ce téléphone, pour la connexion automatique';

  @override
  String get loginAction => 'Se connecter';

  @override
  String get loginRetrySaved => 'Réessayer avec le mot de passe enregistré';

  @override
  String get loginAddressTitle => 'Adresse du modem';

  @override
  String get loginAddressLabel => 'Adresse IP du modem';

  @override
  String get loginAddressHelper =>
      '192.168.100.1 par défaut ; elle change si vous modifiez le DHCP';

  @override
  String loginUseGateway(String address) {
    return 'Utiliser $address (Wi-Fi actuel)';
  }

  @override
  String loginResetAddress(String address) {
    return 'Rétablir $address';
  }

  @override
  String get loginTestAddress => 'Tester';

  @override
  String get loginReachable => 'Modem joignable à cette adresse.';

  @override
  String get loginDefaultPasswordHint =>
      'Mot de passe jamais changé ? Il figure sur l\'étiquette du modem.';

  @override
  String get mobileSimSection => 'Carte SIM';

  @override
  String mobileSimCurrent(String slot) {
    return 'Emplacement actif : $slot';
  }

  @override
  String mobileSimSwitchTitle(int number) {
    return 'Passer sur la SIM $number ?';
  }

  @override
  String get mobileSimSwitchWarning =>
      'La bascule prend environ 20 secondes ; internet est coupé pendant ce temps. Le Wi-Fi reste actif.';

  @override
  String get mobileSimSwitching => 'Bascule de SIM en cours (environ 20 s)…';

  @override
  String get mobileApnSection => 'Profils APN';

  @override
  String get mobileApnHint =>
      'Le modem choisit d\'habitude l\'APN selon la SIM. Ne le changez que si internet ne fonctionne pas ; demandez les paramètres à votre opérateur.';

  @override
  String get mobileApnEmpty => 'Aucun profil APN sur le modem.';

  @override
  String get mobileApnActive => 'Actif';

  @override
  String get mobileApnUse => 'Utiliser ce profil';

  @override
  String get mobileApnUseTitle => 'Changer de profil APN ?';

  @override
  String mobileApnUseMessage(String name) {
    return 'Le modem utilisera le profil « $name » pour se connecter à internet. La connexion peut être brièvement coupée.';
  }

  @override
  String get mobileApnNew => 'Nouveau profil APN';

  @override
  String get mobileApnNewHint =>
      'Saisissez les paramètres fournis par votre opérateur. MCC et MNC sont pré-remplis d\'après la SIM insérée.';

  @override
  String get mobileApnName => 'Nom du profil';

  @override
  String get mobileApnApn => 'APN';

  @override
  String get mobileApnPdpType => 'Type PDP';

  @override
  String get mobileApnMcc => 'MCC';

  @override
  String get mobileApnMnc => 'MNC';

  @override
  String get mobileApnMccMnc => 'MCC-MNC';

  @override
  String get mobileApnMccInvalid => '3 chiffres';

  @override
  String get mobileApnMncInvalid => '2 ou 3 chiffres';

  @override
  String get mobileApnAuth => 'Authentification';

  @override
  String get mobileApnUsername => 'Identifiant';

  @override
  String get mobileApnPassword => 'Mot de passe';

  @override
  String get mobileApnPort => 'Port';

  @override
  String get mobileApnPortInvalid => 'Port entre 1 et 65535';

  @override
  String get mobileApnOptional => 'Facultatif';

  @override
  String get mobileApnCreatedTitle => 'Profil créé';

  @override
  String mobileApnActivateNow(String name) {
    return 'Utiliser maintenant le profil « $name » ?';
  }

  @override
  String get mobileApnBlockerName => 'Coupure des données (MiFi)';

  @override
  String get mobileModeSection => 'Mode réseau';

  @override
  String get mobileModeChangeTitle => 'Changer le mode réseau ?';

  @override
  String mobileModeChangeMessage(String mode) {
    return 'Le modem passera en « $mode ». La connexion peut être brièvement coupée.';
  }

  @override
  String mobileModeUnknown(String code) {
    return 'Mode actuel non reconnu : $code';
  }

  @override
  String get mobileUsbLabel => 'Partager internet par câble USB';

  @override
  String get mobileDetectSection => 'Détection de coupure';

  @override
  String get mobileDetectHint =>
      'Le modem vérifie la connexion internet en contactant ces adresses (IP ou nom, ex. 8.8.8.8 ou www.google.com).';

  @override
  String get mobileDetectLabel => 'Détection de coupure';

  @override
  String mobileDetectAddress(int number) {
    return 'Adresse $number';
  }

  @override
  String get mobileDetectNeedAddress =>
      'Indiquez au moins une adresse pour activer la détection.';

  @override
  String get outagesSummary => 'Résumé (hors coupures volontaires)';

  @override
  String get outagesLast24h => 'Dernières 24 heures';

  @override
  String get outagesLast7d => '7 derniers jours';

  @override
  String outagesCountDuration(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coupures',
      one: '$count coupure',
    );
    return '$_temp0 · $duration au total';
  }

  @override
  String get outagesEmpty => 'Aucune coupure enregistrée.';

  @override
  String get outagesOngoing => 'En cours';

  @override
  String get outagesPlanned => 'Volontaire';

  @override
  String outagesSince(String time) {
    return 'Depuis $time';
  }

  @override
  String outagesFromTo(String start, String end) {
    return 'De $start à $end';
  }

  @override
  String get outagesNote =>
      'Les coupures sont détectées en quelques secondes, appli ouverte ou avec la surveillance continue (environ toutes les 15 minutes sans elle). « Volontaire » = données coupées ou connexion relancée par l\'appli.';

  @override
  String get outagesClearTitle => 'Effacer l\'historique';

  @override
  String get outagesClearMessage =>
      'Toutes les coupures enregistrées seront supprimées.';

  @override
  String get outagesExport => 'Exporter en CSV';

  @override
  String get outagesExported => 'Journal exporté.';

  @override
  String get outagesExportCancelled => 'Export annulé.';

  @override
  String get outagesCsvStart => 'Début';

  @override
  String get outagesCsvEnd => 'Fin';

  @override
  String get outagesCsvMinutes => 'Durée (minutes)';

  @override
  String get outagesCsvPlanned => 'Volontaire';

  @override
  String get outagesCsvOperator => 'Opérateur (MCC-MNC)';

  @override
  String get signalLastHour => 'Dernière heure';

  @override
  String get signalLast24h => 'Dernières 24 h';

  @override
  String get signalEmpty =>
      'Pas encore de mesure sur cette période. Laissez l\'appli ouverte ou activez la vérification en arrière-plan.';

  @override
  String get signalStats => 'Statistiques';

  @override
  String get signalCurrent => 'Actuel';

  @override
  String get signalAverage => 'Moyenne';

  @override
  String get signalBest => 'Meilleur';

  @override
  String get signalWorst => 'Plus faible';

  @override
  String signalSamplesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesures',
      one: '$count mesure',
    );
    return '$_temp0';
  }

  @override
  String get signalHowItWorks =>
      'Plus la valeur est proche de 0, meilleur est le signal : 4 barres à partir de -95 dBm, aucune en dessous de -115 dBm. Un point toutes les 30 s, appli ouverte ou avec la surveillance continue (environ toutes les 15 min sans elle).';

  @override
  String get bestLocationInstructions =>
      'Déplacez lentement le modem et attendez quelques secondes à chaque position.';

  @override
  String get bestLocationUnit => 'dBm';

  @override
  String bestLocationRecord(String value) {
    return 'Meilleur signal : $value';
  }

  @override
  String bestLocationRecordAt(String time) {
    return 'Atteint à $time';
  }

  @override
  String get bestLocationReset => 'Remettre à zéro';

  @override
  String get bestLocationTips =>
      'Conseils : près d\'une fenêtre, en hauteur, loin des murs épais et des appareils métalliques. Le téléphone vibre à chaque nouveau record.';

  @override
  String get speedTestSize => 'Taille du fichier de test';

  @override
  String speedTestMegabytes(int size) {
    return '$size Mo';
  }

  @override
  String get speedTestDataWarning =>
      'Le test consomme cette quantité de données sur le forfait de votre SIM.';

  @override
  String speedTestMbps(String value) {
    return '$value Mb/s';
  }

  @override
  String speedTestProgress(String received, String total) {
    return '$received Mo sur $total Mo';
  }

  @override
  String speedTestDetails(String size, String latency) {
    return '$size Mo téléchargés · latence $latency ms';
  }

  @override
  String get speedTestStart => 'Lancer le test';

  @override
  String get speedTestHistory => 'Historique';

  @override
  String get speedTestEmpty => 'Aucun test pour le moment.';

  @override
  String get speedTestClearTitle => 'Effacer l\'historique';

  @override
  String get speedTestClearMessage =>
      'Tous les résultats de test seront supprimés.';

  @override
  String get speedTestNoInternet =>
      'Pas d\'accès à internet à travers le modem (données coupées ?).';

  @override
  String get speedTestTimeout => 'Le serveur de test ne répond pas assez vite.';

  @override
  String get speedTestServer =>
      'Le serveur de test a renvoyé une erreur. Réessayez plus tard.';

  @override
  String get speedTestNotOnModemWifi =>
      'Le téléphone n\'est pas connecté au Wi-Fi du modem : le test mesurerait ses propres données mobiles. Connectez-le au Wi-Fi du modem puis réessayez.';

  @override
  String get speedTestHow =>
      'Le fichier est téléchargé depuis un serveur public à travers le modem ; le résultat dépend du réseau mobile, du signal et de l\'heure.';

  @override
  String get speedQualityTitle => 'Qualité du débit';

  @override
  String get speedQualityNone => 'Inexistant';

  @override
  String get speedQualityPoor => 'Faible';

  @override
  String get speedQualityFair => 'Moyen';

  @override
  String get speedQualityGood => 'Bon';

  @override
  String get speedQualityExcellent => 'Excellent';

  @override
  String get speedQualityNoneHint => 'Internet passe à peine.';

  @override
  String get speedQualityPoorHint => 'Messages et navigation lente.';

  @override
  String get speedQualityFairHint => 'Navigation et vidéo en qualité standard.';

  @override
  String get speedQualityGoodHint => 'Vidéo HD et appels vidéo.';

  @override
  String get speedQualityExcellentHint =>
      'Tous les usages, même sur plusieurs appareils.';

  @override
  String get speedQualityScale =>
      'Inexistant : moins de 0,5 Mb/s · Faible : moins de 2 · Moyen : moins de 8 · Bon : moins de 25 · Excellent : 25 Mb/s et plus.';

  @override
  String get systemAccountSection => 'Compte administrateur';

  @override
  String get systemChangePasswordHint =>
      'Mot de passe de l\'interface d\'administration du modem';

  @override
  String get systemMaintenanceSection => 'Redémarrage et réinitialisation';

  @override
  String get systemRebootHint =>
      'Redémarrer règle souvent les lenteurs. Les appareils sont déconnectés environ 1 minute.';

  @override
  String get systemResetHint =>
      'La réinitialisation d\'usine efface tous les réglages du modem.';

  @override
  String get systemResetAction => 'Réinitialisation d\'usine';

  @override
  String get systemResetTitle => 'Réinitialisation d\'usine';

  @override
  String get systemResetWarning =>
      'Tous les réglages du modem seront effacés. Le nom et le mot de passe du Wi-Fi, ainsi que le mot de passe administrateur, reviendront aux valeurs d\'usine indiquées sur l\'étiquette du modem. Il faudra reconnecter le téléphone au Wi-Fi d\'usine.\n\nConseil : faites d\'abord une sauvegarde de vos réglages.';

  @override
  String get systemResetBackupFirst => 'Sauvegarder d\'abord';

  @override
  String get systemResetSecond =>
      'Dernière confirmation : cette opération est irréversible.';

  @override
  String get systemResetWord => 'RÉINITIALISER';

  @override
  String get systemResetDoneTitle => 'Réinitialisation lancée';

  @override
  String get systemResetDone =>
      'Le modem redémarre avec ses réglages d\'usine. Dans 1 à 2 minutes : connectez le téléphone au Wi-Fi d\'usine (étiquette du modem), puis reconnectez-vous avec le mot de passe d\'usine. Vous pourrez ensuite restaurer votre sauvegarde.';

  @override
  String get systemProduceSection => 'Informations de fabrication';

  @override
  String get systemCalibration => 'Calibrage';

  @override
  String get systemCalibrated => 'Calibré';

  @override
  String get systemNotCalibrated => 'Non calibré';

  @override
  String get systemWifiTest => 'Test Wi-Fi';

  @override
  String get systemWifiTested => 'Wi-Fi testé';

  @override
  String get systemWifiNotTested => 'Wi-Fi non testé';

  @override
  String get systemModemSection => 'Modem';

  @override
  String get systemSimSlots => 'Emplacements SIM';

  @override
  String get systemWebLanguage => 'Langue de l\'interface web';

  @override
  String get systemCopyright => 'Fabricant';

  @override
  String get systemToolsSection => 'Outils';

  @override
  String get systemPasswordIntro =>
      'Après le changement, l\'appli se reconnecte toute seule avec le nouveau mot de passe.';

  @override
  String get systemOldPassword => 'Mot de passe actuel';

  @override
  String get systemNewPassword => 'Nouveau mot de passe';

  @override
  String get systemConfirmPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get systemPasswordRules => '4 à 32 caractères, sans espace ni accent';

  @override
  String get systemPasswordSame =>
      'Le nouveau mot de passe doit être différent de l\'actuel';

  @override
  String get systemPasswordMismatch =>
      'Les deux mots de passe ne correspondent pas';

  @override
  String get systemPasswordChanged => 'Mot de passe administrateur changé.';

  @override
  String get systemPasswordRefused =>
      'Le modem a refusé le changement : vérifiez le mot de passe actuel.';

  @override
  String get wifiNetworkSection => 'Réseau Wi-Fi';

  @override
  String get wifiSsidLabel => 'Nom du réseau (SSID)';

  @override
  String wifiSsidTooLong(int max) {
    return '$max caractères au maximum';
  }

  @override
  String get wifiSecurityLabel => 'Sécurité';

  @override
  String get wifiPasswordLabel => 'Mot de passe Wi-Fi';

  @override
  String wifiPasswordLength(int min, int max) {
    return 'De $min à $max caractères';
  }

  @override
  String get wifiPasswordAscii =>
      'Lettres sans accents, chiffres et symboles courants uniquement';

  @override
  String get wifiOpenWarning =>
      'Réseau ouvert : n\'importe qui à proximité pourra se connecter sans mot de passe.';

  @override
  String get wifiChannelLabel => 'Canal';

  @override
  String wifiChannelValue(String channel) {
    return 'Canal $channel';
  }

  @override
  String get wifiBroadcastLabel => 'Diffusion du nom (SSID)';

  @override
  String get wifiBroadcastHiddenHint =>
      'Désactivé : le réseau est invisible, il faut saisir son nom pour s\'y connecter';

  @override
  String get wifiSaveTitle => 'Enregistrer les réglages Wi-Fi ?';

  @override
  String get wifiSaveWarning =>
      'Le Wi-Fi du modem va redémarrer : tous les appareils, y compris ce téléphone, seront déconnectés quelques instants. Si vous changez le nom ou le mot de passe, reconnectez le téléphone au nouveau réseau.';

  @override
  String wifiReconnectMessage(String ssid) {
    return 'Le Wi-Fi redémarre. Reconnectez si besoin le téléphone au réseau « $ssid ».';
  }

  @override
  String get wifiShareSection => 'Partager le Wi-Fi';

  @override
  String get wifiShareQr => 'Partager par QR code';

  @override
  String get wifiShareQrHint =>
      'Vos invités le scannent avec l\'appareil photo';

  @override
  String get wifiShareMessage => 'Partager par message';

  @override
  String get wifiShareMessageHint =>
      'Envoyer le nom et le mot de passe par WhatsApp, SMS…';

  @override
  String wifiShareText(String ssid, String password) {
    return 'Wi-Fi : $ssid\nMot de passe : $password';
  }

  @override
  String wifiShareTextOpen(String ssid) {
    return 'Wi-Fi : $ssid (sans mot de passe)';
  }

  @override
  String get wifiExpelHint =>
      'Un appareil inconnu utilise votre Wi-Fi ? Changez le mot de passe en un geste et partagez le nouveau.';

  @override
  String get wifiApSection => 'Point d\'accès Wi-Fi';

  @override
  String get wifiApState => 'État du Wi-Fi';

  @override
  String get wifiTurnOff => 'Couper le Wi-Fi';

  @override
  String get wifiTurnOn => 'Allumer le Wi-Fi';

  @override
  String get wifiTurnOffTitle => 'Couper le Wi-Fi du modem ?';

  @override
  String get wifiTurnOffWarning =>
      'Attention : ce téléphone perdra aussitôt la connexion avec le modem et l\'appli ne pourra PAS rallumer le Wi-Fi. Il faudra appuyer sur le bouton du modem ou le redémarrer.';

  @override
  String get wifiTurnOffWord => 'COUPER';

  @override
  String get wifiTurnedOffInfo =>
      'Le Wi-Fi du modem est coupé. Pour le rallumer, appuyez sur le bouton du modem ou redémarrez-le, puis reconnectez le téléphone.';

  @override
  String get wifiQrInstructions =>
      'Scannez ce code avec l\'appareil photo d\'un téléphone pour vous connecter au Wi-Fi.';

  @override
  String get wifiQrHiddenNote =>
      'Le nom du réseau est masqué : le code contient l\'information nécessaire pour s\'y connecter quand même.';
}
