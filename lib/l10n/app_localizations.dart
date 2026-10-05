import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Nom de l'application (barre de titre, écran des tâches récentes)
  ///
  /// In fr, this message translates to:
  /// **'MiFi'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get commonApply;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié dans le presse-papiers'**
  String get commonCopied;

  /// No description provided for @commonEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get commonEnabled;

  /// No description provided for @commonDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get commonDisabled;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get commonLoading;

  /// No description provided for @commonSaved.
  ///
  /// In fr, this message translates to:
  /// **'Réglages enregistrés'**
  String get commonSaved;

  /// No description provided for @commonUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get commonUnknown;

  /// No description provided for @commonNotDefined.
  ///
  /// In fr, this message translates to:
  /// **'Non défini'**
  String get commonNotDefined;

  /// No description provided for @commonShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get commonHidePassword;

  /// No description provided for @commonRequiredField.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get commonRequiredField;

  /// No description provided for @commonInvalidIpv4.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IPv4 invalide (ex. 192.168.100.1)'**
  String get commonInvalidIpv4;

  /// No description provided for @commonInvalidHost.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP ou nom d\'hôte invalide'**
  String get commonInvalidHost;

  /// No description provided for @commonTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get commonTypeLabel;

  /// No description provided for @commonProxyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Proxy'**
  String get commonProxyLabel;

  /// No description provided for @commonUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour à {time}'**
  String commonUpdatedAt(String time);

  /// No description provided for @commonDataStale.
  ///
  /// In fr, this message translates to:
  /// **'Données non à jour'**
  String get commonDataStale;

  /// No description provided for @commonWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get commonWarning;

  /// No description provided for @commonTypeToConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Pour confirmer, saisissez « {word} »'**
  String commonTypeToConfirm(String word);

  /// Nombre d'appareils. En français, 0 et 1 sont au singulier (« 0 appareil »).
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} appareil} other{{count} appareils}}'**
  String deviceCount(int count);

  /// No description provided for @deviceTypeWifi.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi'**
  String get deviceTypeWifi;

  /// No description provided for @deviceTypeWired.
  ///
  /// In fr, this message translates to:
  /// **'Filaire'**
  String get deviceTypeWired;

  /// No description provided for @deviceTypeUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get deviceTypeUnknown;

  /// No description provided for @unnamedDevice.
  ///
  /// In fr, this message translates to:
  /// **'Appareil sans nom'**
  String get unnamedDevice;

  /// No description provided for @durationSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String durationSeconds(int seconds);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min {seconds} s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationDaysHoursMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{days} j {hours} h {minutes} min'**
  String durationDaysHoursMinutes(int days, int hours, int minutes);

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navDevices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils'**
  String get navDevices;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @splashConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au modem…'**
  String get splashConnecting;

  /// No description provided for @errorUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le modem ({address}). Vérifiez que le téléphone est connecté au Wi-Fi du modem.'**
  String errorUnreachable(String address);

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le modem ne répond pas (délai dépassé).'**
  String get errorTimeout;

  /// No description provided for @errorLoginFailed.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe refusé par le modem.'**
  String get errorLoginFailed;

  /// No description provided for @errorSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée. Veuillez vous reconnecter.'**
  String get errorSessionExpired;

  /// No description provided for @errorCommandFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le modem a refusé l\'opération (réponse : {reply}).'**
  String errorCommandFailed(String reply);

  /// No description provided for @errorUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Fonction non prise en charge par le firmware du modem.'**
  String get errorUnsupported;

  /// No description provided for @errorInvalidResponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse inattendue du modem.'**
  String get errorInvalidResponse;

  /// No description provided for @errorCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Opération annulée.'**
  String get errorCancelled;

  /// No description provided for @errorUnexpected.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inattendue : {details}'**
  String errorUnexpected(String details);

  /// No description provided for @hintWifiDisconnected.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone n\'est connecté à aucun réseau Wi-Fi.'**
  String get hintWifiDisconnected;

  /// No description provided for @hintWrongWifi.
  ///
  /// In fr, this message translates to:
  /// **'Le Wi-Fi actuel (passerelle {gateway}) ne semble pas être celui du modem ({address}).'**
  String hintWrongWifi(String gateway, String address);

  /// No description provided for @hintNoInternetIsOk.
  ///
  /// In fr, this message translates to:
  /// **'Android peut signaler le Wi-Fi du modem « sans internet » : l\'appli l\'utilise quand même.'**
  String get hintNoInternetIsOk;

  /// No description provided for @restartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion au modem'**
  String get restartTitle;

  /// No description provided for @restartWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Patientez pendant que le modem redémarre…'**
  String get restartWaiting;

  /// No description provided for @restartElapsed.
  ///
  /// In fr, this message translates to:
  /// **'Temps écoulé : {elapsed}'**
  String restartElapsed(String elapsed);

  /// No description provided for @restartHint.
  ///
  /// In fr, this message translates to:
  /// **'Si nécessaire, reconnectez le téléphone au Wi-Fi du modem.'**
  String get restartHint;

  /// No description provided for @restartSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Le modem est de nouveau joignable.'**
  String get restartSuccess;

  /// No description provided for @restartTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le modem ne répond toujours pas. Vérifiez la connexion Wi-Fi puis réessayez.'**
  String get restartTimeout;

  /// No description provided for @restartStopWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter d\'attendre'**
  String get restartStopWaiting;

  /// No description provided for @airplaneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode avion'**
  String get airplaneTitle;

  /// No description provided for @airplaneStateOn.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get airplaneStateOn;

  /// No description provided for @airplaneStateOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get airplaneStateOff;

  /// No description provided for @airplaneStateSwitching.
  ///
  /// In fr, this message translates to:
  /// **'Bascule en cours…'**
  String get airplaneStateSwitching;

  /// No description provided for @airplaneStateUnknown.
  ///
  /// In fr, this message translates to:
  /// **'État inconnu'**
  String get airplaneStateUnknown;

  /// No description provided for @airplaneStateError.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la bascule'**
  String get airplaneStateError;

  /// No description provided for @airplaneExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Coupe internet sur la SIM active, en quelques secondes et sans changer de SIM. Le Wi-Fi du modem reste actif. L\'appli vérifie la coupure et vous prévient si elle ne tient pas.'**
  String get airplaneExplanation;

  /// No description provided for @notifChannelAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de connexion'**
  String get notifChannelAlerts;

  /// No description provided for @notifChannelAlertsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Coupure et retour d\'internet, signal faible'**
  String get notifChannelAlertsDescription;

  /// No description provided for @notifChannelDevices.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux appareils'**
  String get notifChannelDevices;

  /// No description provided for @notifChannelDevicesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un appareil inconnu se connecte au Wi-Fi du modem'**
  String get notifChannelDevicesDescription;

  /// No description provided for @notifChannelAirplane.
  ///
  /// In fr, this message translates to:
  /// **'Données mobiles et programmations'**
  String get notifChannelAirplane;

  /// No description provided for @notifChannelAirplaneDescription.
  ///
  /// In fr, this message translates to:
  /// **'Résultat des changements des données mobiles et du redémarrage programmé'**
  String get notifChannelAirplaneDescription;

  /// No description provided for @notifInternetDownTitle.
  ///
  /// In fr, this message translates to:
  /// **'Internet coupé'**
  String get notifInternetDownTitle;

  /// No description provided for @notifInternetDownBody.
  ///
  /// In fr, this message translates to:
  /// **'Le modem a perdu la connexion internet.'**
  String get notifInternetDownBody;

  /// No description provided for @notifInternetUpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Internet rétabli'**
  String get notifInternetUpTitle;

  /// No description provided for @notifInternetUpBody.
  ///
  /// In fr, this message translates to:
  /// **'La connexion est revenue après {duration}.'**
  String notifInternetUpBody(String duration);

  /// No description provided for @notifLowSignalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signal faible'**
  String get notifLowSignalTitle;

  /// No description provided for @notifLowSignalBody.
  ///
  /// In fr, this message translates to:
  /// **'Signal mobile faible : {dbm} dBm.'**
  String notifLowSignalBody(int dbm);

  /// No description provided for @notifNewDeviceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel appareil connecté'**
  String get notifNewDeviceTitle;

  /// No description provided for @notifNewDeviceBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} ({mac}) vient de se connecter.'**
  String notifNewDeviceBody(String name, String mac);

  /// No description provided for @notifScheduleFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode avion programmé : échec'**
  String get notifScheduleFailedTitle;

  /// No description provided for @notifScheduleFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le modem. Le téléphone doit être connecté au Wi-Fi du modem à l\'heure prévue.'**
  String get notifScheduleFailedBody;

  /// No description provided for @notifAirplaneFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode avion : échec'**
  String get notifAirplaneFailedTitle;

  /// No description provided for @notifAirplaneFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le modem. Vérifiez la connexion Wi-Fi du téléphone.'**
  String get notifAirplaneFailedBody;

  /// No description provided for @notifToggleRefusedBody.
  ///
  /// In fr, this message translates to:
  /// **'Le modem a refusé le changement. Réessayez depuis l\'appli.'**
  String get notifToggleRefusedBody;

  /// No description provided for @notifToggleLoginFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au modem refusée : mot de passe incorrect ou absent. Reconnectez-vous dans l\'appli.'**
  String get notifToggleLoginFailedBody;

  /// No description provided for @operatorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur inconnu'**
  String get operatorUnknown;

  /// No description provided for @operatorCode.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur {code}'**
  String operatorCode(String code);

  /// No description provided for @noSim.
  ///
  /// In fr, this message translates to:
  /// **'Pas de SIM'**
  String get noSim;

  /// No description provided for @mobileDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données mobiles'**
  String get mobileDataTitle;

  /// No description provided for @mobileDataStateOn.
  ///
  /// In fr, this message translates to:
  /// **'Activées'**
  String get mobileDataStateOn;

  /// No description provided for @mobileDataStateOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivées'**
  String get mobileDataStateOff;

  /// No description provided for @mobileDataAirplaneOn.
  ///
  /// In fr, this message translates to:
  /// **'Coupées par le mode avion'**
  String get mobileDataAirplaneOn;

  /// No description provided for @mobileDataSwitching.
  ///
  /// In fr, this message translates to:
  /// **'Changement en cours…'**
  String get mobileDataSwitching;

  /// No description provided for @mobileDataSwitchFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le modem n\'a pas appliqué le changement des données mobiles.'**
  String get mobileDataSwitchFailed;

  /// No description provided for @dataCutFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le modem n\'a pas appliqué le changement. Réessayez.'**
  String get dataCutFailed;

  /// No description provided for @dataCutNotHoldingTitle.
  ///
  /// In fr, this message translates to:
  /// **'La coupure d\'internet ne tient pas'**
  String get dataCutNotHoldingTitle;

  /// No description provided for @dataCutNotHoldingShort.
  ///
  /// In fr, this message translates to:
  /// **'Coupure inefficace'**
  String get dataCutNotHoldingShort;

  /// No description provided for @dataCutProfileLost.
  ///
  /// In fr, this message translates to:
  /// **'Le modem remet sans cesse son profil APN habituel, donc internet revient. L\'appli a réactivé la coupure plusieurs fois puis a arrêté. Désactivez puis réactivez pour réessayer.'**
  String get dataCutProfileLost;

  /// No description provided for @dataCutInternetStillUp.
  ///
  /// In fr, this message translates to:
  /// **'Le profil de coupure est actif mais internet passe encore : votre opérateur semble accepter n\'importe quel APN. Avec cette SIM, l\'appli ne peut pas couper internet de cette façon.'**
  String get dataCutInternetStillUp;

  /// No description provided for @mobileDataExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Coupe internet en gardant la SIM sur le réseau (le signal reste visible). Le Wi-Fi reste actif.'**
  String get mobileDataExplanation;

  /// No description provided for @simChangedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle SIM détectée'**
  String get simChangedTitle;

  /// No description provided for @simChangedBody.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle SIM détectée : {operator}. Si internet ne fonctionne pas, vérifiez les réglages APN.'**
  String simChangedBody(String operator);

  /// No description provided for @simChangedOpenApn.
  ///
  /// In fr, this message translates to:
  /// **'Réglages APN'**
  String get simChangedOpenApn;

  /// No description provided for @simChangedLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get simChangedLater;

  /// No description provided for @expelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Expulser les intrus'**
  String get expelTitle;

  /// No description provided for @lockTitle.
  ///
  /// In fr, this message translates to:
  /// **'MiFi est verrouillée'**
  String get lockTitle;

  /// No description provided for @lockReason.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillez pour accéder aux réglages du modem'**
  String get lockReason;

  /// No description provided for @lockFailed.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillage non abouti. Réessayez.'**
  String get lockFailed;

  /// No description provided for @lockUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller'**
  String get lockUnlock;

  /// No description provided for @widgetInternetOn.
  ///
  /// In fr, this message translates to:
  /// **'Internet connecté'**
  String get widgetInternetOn;

  /// No description provided for @widgetInternetOff.
  ///
  /// In fr, this message translates to:
  /// **'Internet coupé'**
  String get widgetInternetOff;

  /// No description provided for @notifAutoRepairTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réparation automatique'**
  String get notifAutoRepairTitle;

  /// No description provided for @notifAutoRepairStarted.
  ///
  /// In fr, this message translates to:
  /// **'Internet est coupé malgré un bon signal : relance de la connexion en cours…'**
  String get notifAutoRepairStarted;

  /// No description provided for @notifAutoRepairSucceeded.
  ///
  /// In fr, this message translates to:
  /// **'Internet a été rétabli automatiquement.'**
  String get notifAutoRepairSucceeded;

  /// No description provided for @notifAutoRepairFailed.
  ///
  /// In fr, this message translates to:
  /// **'La relance automatique n\'a pas rétabli internet. Essayez de redémarrer le modem.'**
  String get notifAutoRepairFailed;

  /// No description provided for @notifRebootFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage programmé : échec'**
  String get notifRebootFailedTitle;

  /// No description provided for @notifRebootFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le modem à l\'heure prévue. Le téléphone doit être connecté au Wi-Fi du modem.'**
  String get notifRebootFailedBody;

  /// No description provided for @notifMobileDataFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données mobiles : échec'**
  String get notifMobileDataFailedTitle;

  /// No description provided for @signalDbm.
  ///
  /// In fr, this message translates to:
  /// **'{dbm} dBm'**
  String signalDbm(int dbm);

  /// No description provided for @signalQualityNone.
  ///
  /// In fr, this message translates to:
  /// **'Inexistant'**
  String get signalQualityNone;

  /// No description provided for @signalQualityPoor.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get signalQualityPoor;

  /// No description provided for @signalQualityFair.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get signalQualityFair;

  /// No description provided for @signalQualityGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get signalQualityGood;

  /// No description provided for @signalQualityExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get signalQualityExcellent;

  /// No description provided for @wifiAuthNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune (réseau ouvert)'**
  String get wifiAuthNone;

  /// No description provided for @wifiAuthWpaPsk.
  ///
  /// In fr, this message translates to:
  /// **'WPA-PSK'**
  String get wifiAuthWpaPsk;

  /// No description provided for @wifiAuthWpa2Psk.
  ///
  /// In fr, this message translates to:
  /// **'WPA2-PSK'**
  String get wifiAuthWpa2Psk;

  /// No description provided for @networkModeAuto.
  ///
  /// In fr, this message translates to:
  /// **'4G/3G (automatique)'**
  String get networkModeAuto;

  /// No description provided for @networkMode4gOnly.
  ///
  /// In fr, this message translates to:
  /// **'4G uniquement'**
  String get networkMode4gOnly;

  /// No description provided for @networkMode3gOnly.
  ///
  /// In fr, this message translates to:
  /// **'3G uniquement'**
  String get networkMode3gOnly;

  /// No description provided for @apnAuthNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get apnAuthNone;

  /// No description provided for @apnAuthPap.
  ///
  /// In fr, this message translates to:
  /// **'PAP'**
  String get apnAuthPap;

  /// No description provided for @apnAuthChap.
  ///
  /// In fr, this message translates to:
  /// **'CHAP'**
  String get apnAuthChap;

  /// No description provided for @apnAuthPapChap.
  ///
  /// In fr, this message translates to:
  /// **'PAP/CHAP'**
  String get apnAuthPapChap;

  /// No description provided for @pdpTypeIpv4.
  ///
  /// In fr, this message translates to:
  /// **'IPv4'**
  String get pdpTypeIpv4;

  /// No description provided for @pdpTypeIpv6.
  ///
  /// In fr, this message translates to:
  /// **'IPv6'**
  String get pdpTypeIpv6;

  /// No description provided for @pdpTypeIpv4v6.
  ///
  /// In fr, this message translates to:
  /// **'IPv4/IPv6'**
  String get pdpTypeIpv4v6;

  /// No description provided for @simSlot.
  ///
  /// In fr, this message translates to:
  /// **'SIM {number}'**
  String simSlot(int number);

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @hubSectionModem.
  ///
  /// In fr, this message translates to:
  /// **'Modem'**
  String get hubSectionModem;

  /// No description provided for @hubSectionTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get hubSectionTools;

  /// No description provided for @hubSectionApp.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get hubSectionApp;

  /// No description provided for @hubWifiTitle.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi'**
  String get hubWifiTitle;

  /// No description provided for @hubWifiSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom du réseau, mot de passe, canal, partage par QR code'**
  String get hubWifiSubtitle;

  /// No description provided for @hubMobileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réseau mobile'**
  String get hubMobileTitle;

  /// No description provided for @hubMobileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'SIM, APN, mode réseau, partage USB, détection de coupure'**
  String get hubMobileSubtitle;

  /// No description provided for @hubDhcpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réseau local (DHCP)'**
  String get hubDhcpTitle;

  /// No description provided for @hubDhcpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du modem et plage d\'adresses'**
  String get hubDhcpSubtitle;

  /// No description provided for @hubSystemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get hubSystemTitle;

  /// No description provided for @hubSystemSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe, redémarrage, réinitialisation, informations'**
  String get hubSystemSubtitle;

  /// No description provided for @hubSignalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique du signal'**
  String get hubSignalTitle;

  /// No description provided for @hubSignalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Graphique et recherche du meilleur emplacement'**
  String get hubSignalSubtitle;

  /// No description provided for @hubOutagesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal des coupures'**
  String get hubOutagesTitle;

  /// No description provided for @hubOutagesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des pertes de connexion internet'**
  String get hubOutagesSubtitle;

  /// No description provided for @hubSpeedTestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Test de débit'**
  String get hubSpeedTestTitle;

  /// No description provided for @hubSpeedTestSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mesurer la vitesse de téléchargement'**
  String get hubSpeedTestSubtitle;

  /// No description provided for @hubBackupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde et restauration'**
  String get hubBackupTitle;

  /// No description provided for @hubBackupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter puis réappliquer les réglages du modem'**
  String get hubBackupSubtitle;

  /// No description provided for @hubFirmwareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour du firmware'**
  String get hubFirmwareTitle;

  /// No description provided for @hubFirmwareSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Avancé : à utiliser avec précaution'**
  String get hubFirmwareSubtitle;

  /// No description provided for @hubAppSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages de l\'application'**
  String get hubAppSettingsTitle;

  /// No description provided for @hubAppSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue, thème, notifications, adresse du modem'**
  String get hubAppSettingsSubtitle;

  /// No description provided for @appSettingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get appSettingsLanguage;

  /// No description provided for @appSettingsApplyToModem.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer aussi à l\'interface web du modem'**
  String get appSettingsApplyToModem;

  /// No description provided for @appSettingsApplyToModemHint.
  ///
  /// In fr, this message translates to:
  /// **'Change aussi la langue de la page web d\'origine du modem (langues acceptées : en, fr, pl, ru, tk, zh).'**
  String get appSettingsApplyToModemHint;

  /// No description provided for @appSettingsSendNow.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la langue au modem maintenant'**
  String get appSettingsSendNow;

  /// No description provided for @appSettingsLanguageSent.
  ///
  /// In fr, this message translates to:
  /// **'Langue envoyée au modem.'**
  String get appSettingsLanguageSent;

  /// No description provided for @appSettingsLanguageNotSent.
  ///
  /// In fr, this message translates to:
  /// **'Le modem n\'a pas accepté le changement de langue.'**
  String get appSettingsLanguageNotSent;

  /// No description provided for @appSettingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get appSettingsTheme;

  /// No description provided for @appSettingsThemeAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get appSettingsThemeAuto;

  /// No description provided for @appSettingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get appSettingsThemeLight;

  /// No description provided for @appSettingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get appSettingsThemeDark;

  /// No description provided for @appSettingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get appSettingsNotifications;

  /// No description provided for @appSettingsNotificationsBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications de MiFi sont bloquées par Android.'**
  String get appSettingsNotificationsBlocked;

  /// No description provided for @appSettingsAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get appSettingsAllow;

  /// No description provided for @appSettingsNotificationsAll.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get appSettingsNotificationsAll;

  /// No description provided for @appSettingsNotifyDown.
  ///
  /// In fr, this message translates to:
  /// **'Internet coupé'**
  String get appSettingsNotifyDown;

  /// No description provided for @appSettingsNotifyUp.
  ///
  /// In fr, this message translates to:
  /// **'Internet rétabli'**
  String get appSettingsNotifyUp;

  /// No description provided for @appSettingsNotifyLowSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal faible'**
  String get appSettingsNotifyLowSignal;

  /// No description provided for @appSettingsNotifyNewDevice.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel appareil connecté'**
  String get appSettingsNotifyNewDevice;

  /// No description provided for @appSettingsBackground.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en arrière-plan'**
  String get appSettingsBackground;

  /// No description provided for @appSettingsBackgroundHint.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de secours environ toutes les 15 minutes (limite d\'Android), quand le téléphone est connecté au Wi-Fi du modem ; elle relance aussi la surveillance continue si Android l\'a arrêtée.'**
  String get appSettingsBackgroundHint;

  /// No description provided for @appSettingsMonitor.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance continue'**
  String get appSettingsMonitor;

  /// No description provided for @appSettingsMonitorHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous prévient dès qu\'internet ne passe plus, même appli fermée (notification discrète « Surveillance active »). Relevés espacés quand tout va bien, pour économiser la batterie.'**
  String get appSettingsMonitorHint;

  /// No description provided for @appSettingsMonitorRestricted.
  ///
  /// In fr, this message translates to:
  /// **'Android limite encore l\'appli en arrière-plan : la surveillance peut être interrompue. Autorisez-la à fonctionner sans restriction.'**
  String get appSettingsMonitorRestricted;

  /// No description provided for @monitorPermissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance de la connexion'**
  String get monitorPermissionTitle;

  /// No description provided for @monitorPermissionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Pour vous prévenir dès qu\'internet ne passe plus, même appli fermée, MiFi doit pouvoir fonctionner en arrière-plan. Android va vous demander deux autorisations (notifications et arrière-plan) : acceptez-les. La surveillance consomme très peu de batterie et s\'affiche par une notification discrète « Surveillance active ».'**
  String get monitorPermissionMessage;

  /// No description provided for @monitorPermissionAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get monitorPermissionAllow;

  /// No description provided for @appSettingsAutomation.
  ///
  /// In fr, this message translates to:
  /// **'Automatismes'**
  String get appSettingsAutomation;

  /// No description provided for @appSettingsAutoRepair.
  ///
  /// In fr, this message translates to:
  /// **'Réparation automatique'**
  String get appSettingsAutoRepair;

  /// No description provided for @appSettingsAutoRepairHint.
  ///
  /// In fr, this message translates to:
  /// **'Si internet est coupé depuis 3 minutes alors que le signal est bon, l\'appli relance la connexion (au plus une fois toutes les 30 minutes).'**
  String get appSettingsAutoRepairHint;

  /// No description provided for @appSettingsSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Mode avion programmé'**
  String get appSettingsSchedule;

  /// No description provided for @appSettingsScheduleHint.
  ///
  /// In fr, this message translates to:
  /// **'Coupe le réseau mobile chaque jour pendant la plage choisie.'**
  String get appSettingsScheduleHint;

  /// No description provided for @appSettingsFrom.
  ///
  /// In fr, this message translates to:
  /// **'De'**
  String get appSettingsFrom;

  /// No description provided for @appSettingsTo.
  ///
  /// In fr, this message translates to:
  /// **'À'**
  String get appSettingsTo;

  /// No description provided for @appSettingsScheduleSame.
  ///
  /// In fr, this message translates to:
  /// **'Le début et la fin doivent être différents.'**
  String get appSettingsScheduleSame;

  /// No description provided for @appSettingsScheduleNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine coupure : {start} · fin : {end}'**
  String appSettingsScheduleNext(String start, String end);

  /// No description provided for @appSettingsReboot.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage programmé du modem'**
  String get appSettingsReboot;

  /// No description provided for @appSettingsRebootHint.
  ///
  /// In fr, this message translates to:
  /// **'Redémarre le modem chaque jour à l\'heure choisie.'**
  String get appSettingsRebootHint;

  /// No description provided for @appSettingsRebootTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure du redémarrage'**
  String get appSettingsRebootTime;

  /// No description provided for @appSettingsRebootNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochain redémarrage : {time}'**
  String appSettingsRebootNext(String time);

  /// No description provided for @appSettingsAutomationNote.
  ///
  /// In fr, this message translates to:
  /// **'Au moment prévu, le téléphone doit être connecté au Wi-Fi du modem ; sinon une notification d\'échec s\'affiche. Android peut décaler l\'heure de quelques minutes.'**
  String get appSettingsAutomationNote;

  /// No description provided for @appSettingsReliabilityHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour que les programmations et la surveillance fonctionnent appli fermée sur un téléphone Xiaomi, autorisez le démarrage automatique et choisissez « Aucune restriction » dans l\'économie de batterie de l\'appli.'**
  String get appSettingsReliabilityHint;

  /// No description provided for @appSettingsExactAlarmsMissing.
  ///
  /// In fr, this message translates to:
  /// **'Les alarmes exactes ne sont pas autorisées : Android peut décaler les programmations de plusieurs minutes, voire davantage.'**
  String get appSettingsExactAlarmsMissing;

  /// No description provided for @appSettingsExactAlarmsAllow.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get appSettingsExactAlarmsAllow;

  /// No description provided for @appSettingsAutostart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrage automatique'**
  String get appSettingsAutostart;

  /// No description provided for @appSettingsBattery.
  ///
  /// In fr, this message translates to:
  /// **'Économie de batterie'**
  String get appSettingsBattery;

  /// No description provided for @appSettingsSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get appSettingsSecurity;

  /// No description provided for @appSettingsLock.
  ///
  /// In fr, this message translates to:
  /// **'Verrouiller l\'appli'**
  String get appSettingsLock;

  /// No description provided for @appSettingsLockHint.
  ///
  /// In fr, this message translates to:
  /// **'Demande l\'empreinte digitale ou le code du téléphone à l\'ouverture de MiFi.'**
  String get appSettingsLockHint;

  /// No description provided for @appSettingsLockUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Aucune empreinte ni aucun code n\'est configuré sur ce téléphone.'**
  String get appSettingsLockUnsupported;

  /// No description provided for @appSettingsAddressConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'adresse du modem ?'**
  String get appSettingsAddressConfirmTitle;

  /// No description provided for @appSettingsAddressConfirm.
  ///
  /// In fr, this message translates to:
  /// **'L\'appli contactera désormais le modem à l\'adresse {address}.'**
  String appSettingsAddressConfirm(String address);

  /// No description provided for @appSettingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get appSettingsAbout;

  /// No description provided for @appSettingsAboutText.
  ///
  /// In fr, this message translates to:
  /// **'MiFi pilote votre modem 4G HiMILink depuis le téléphone, avec n\'importe quelle SIM. L\'appli ne fonctionne que connectée au Wi-Fi du modem.'**
  String get appSettingsAboutText;

  /// No description provided for @backupExportSection.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get backupExportSection;

  /// No description provided for @backupExportHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistre dans un fichier les réglages Wi-Fi, APN, DHCP, mode réseau et détection de coupure.'**
  String get backupExportHint;

  /// No description provided for @backupPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe administrateur n\'est jamais exporté. Le fichier contient en revanche le mot de passe Wi-Fi : gardez-le en lieu sûr.'**
  String get backupPrivacy;

  /// No description provided for @backupExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les réglages'**
  String get backupExport;

  /// No description provided for @backupExported.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde enregistrée.'**
  String get backupExported;

  /// No description provided for @backupExportCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Export annulé.'**
  String get backupExportCancelled;

  /// No description provided for @backupImportSection.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get backupImportSection;

  /// No description provided for @backupImportHint.
  ///
  /// In fr, this message translates to:
  /// **'Réappliquez une sauvegarde, par exemple après une réinitialisation d\'usine.'**
  String get backupImportHint;

  /// No description provided for @backupChooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier de sauvegarde'**
  String get backupChooseFile;

  /// No description provided for @backupFileLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde MiFi (.json)'**
  String get backupFileLabel;

  /// No description provided for @backupInvalidFile.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une sauvegarde MiFi valide.'**
  String get backupInvalidFile;

  /// No description provided for @backupFileDate.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde du {date}'**
  String backupFileDate(String date);

  /// No description provided for @backupOrderNote.
  ///
  /// In fr, this message translates to:
  /// **'Ordre d\'application : mode réseau, détection, APN, puis DHCP (le modem redémarre) et enfin le Wi-Fi (le téléphone devra s\'y reconnecter).'**
  String get backupOrderNote;

  /// No description provided for @backupRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer la sélection'**
  String get backupRestore;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer ces réglages ?'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreWarning.
  ///
  /// In fr, this message translates to:
  /// **'Les réglages choisis vont remplacer ceux du modem. Le DHCP redémarre le modem, et le changement de Wi-Fi déconnecte tous les appareils.'**
  String get backupRestoreWarning;

  /// No description provided for @backupRestored.
  ///
  /// In fr, this message translates to:
  /// **'Réglages restaurés.'**
  String get backupRestored;

  /// No description provided for @backupWifiAppliedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi restauré'**
  String get backupWifiAppliedTitle;

  /// No description provided for @backupWifiApplied.
  ///
  /// In fr, this message translates to:
  /// **'Le Wi-Fi « {ssid} » a été appliqué : reconnectez le téléphone à ce réseau.'**
  String backupWifiApplied(String ssid);

  /// No description provided for @compareHubSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Signal, débit et coupures selon la SIM utilisée'**
  String get compareHubSubtitle;

  /// No description provided for @compareIntro.
  ///
  /// In fr, this message translates to:
  /// **'Mesures des 7 derniers jours, classées par signal moyen. Elles sont attribuées à l\'opérateur de la SIM utilisée à ce moment-là.'**
  String get compareIntro;

  /// No description provided for @compareEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore assez de mesures. Utilisez l\'appli quelques jours avec vos différentes SIM, et lancez des tests de débit.'**
  String get compareEmpty;

  /// No description provided for @compareSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal moyen'**
  String get compareSignal;

  /// No description provided for @compareSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Débit moyen'**
  String get compareSpeed;

  /// No description provided for @compareOutages.
  ///
  /// In fr, this message translates to:
  /// **'Coupures'**
  String get compareOutages;

  /// No description provided for @compareBestSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur débit : {value}'**
  String compareBestSpeed(String value);

  /// No description provided for @compareLastUsed.
  ///
  /// In fr, this message translates to:
  /// **'Dernière utilisation : {time}'**
  String compareLastUsed(String time);

  /// No description provided for @dashboardWifiOn.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi allumé'**
  String get dashboardWifiOn;

  /// No description provided for @dashboardWifiOff.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi éteint'**
  String get dashboardWifiOff;

  /// No description provided for @dashboardSimOk.
  ///
  /// In fr, this message translates to:
  /// **'SIM présente'**
  String get dashboardSimOk;

  /// No description provided for @dashboardLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get dashboardLanguage;

  /// No description provided for @dashboardAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get dashboardAdmin;

  /// No description provided for @dashboardChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get dashboardChangePassword;

  /// No description provided for @dashboardLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get dashboardLogout;

  /// No description provided for @dashboardLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez déconnecté du modem et le mot de passe enregistré sera oublié.'**
  String get dashboardLogoutConfirm;

  /// No description provided for @dashboardWanIp.
  ///
  /// In fr, this message translates to:
  /// **'IP WAN {ip}'**
  String dashboardWanIp(String ip);

  /// No description provided for @dashboardSignalHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get dashboardSignalHistory;

  /// No description provided for @dashboardBestLocation.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur emplacement'**
  String get dashboardBestLocation;

  /// No description provided for @dashboardUsbTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partage USB'**
  String get dashboardUsbTitle;

  /// No description provided for @dashboardTurnOn.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get dashboardTurnOn;

  /// No description provided for @dashboardTurnOff.
  ///
  /// In fr, this message translates to:
  /// **'Couper'**
  String get dashboardTurnOff;

  /// No description provided for @dashboardAirplaneConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer le mode avion ?'**
  String get dashboardAirplaneConfirmTitle;

  /// No description provided for @airplaneDisableConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le mode avion ?'**
  String get airplaneDisableConfirmTitle;

  /// No description provided for @airplaneDisableConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Internet sera rétabli avec votre profil APN habituel.'**
  String get airplaneDisableConfirmMessage;

  /// No description provided for @airplaneDisableConfirmAction.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get airplaneDisableConfirmAction;

  /// No description provided for @dashboardMobileDataConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Couper les données mobiles ?'**
  String get dashboardMobileDataConfirmTitle;

  /// No description provided for @dashboardMobileDataHow.
  ///
  /// In fr, this message translates to:
  /// **'L\'appli active pour cela un profil APN de coupure (« MiFi-OFF ») ; réactiver les données remet votre profil habituel. Fonction à confirmer sur votre modem.'**
  String get dashboardMobileDataHow;

  /// No description provided for @dashboardAirplaneWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Activation du mode avion… Le Wi-Fi reste actif.'**
  String get dashboardAirplaneWaiting;

  /// No description provided for @dashboardAirplaneWaitingOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivation du mode avion…'**
  String get dashboardAirplaneWaitingOff;

  /// No description provided for @dashboardMobileDataWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Changement des données mobiles en cours…'**
  String get dashboardMobileDataWaiting;

  /// No description provided for @dashboardTogglesInfo.
  ///
  /// In fr, this message translates to:
  /// **'Comment ça marche ?'**
  String get dashboardTogglesInfo;

  /// No description provided for @dashboardTogglesInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données mobiles et mode avion'**
  String get dashboardTogglesInfoTitle;

  /// No description provided for @dashboardReconnectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relancer la connexion'**
  String get dashboardReconnectTitle;

  /// No description provided for @dashboardReconnectHint.
  ///
  /// In fr, this message translates to:
  /// **'Internet ne passe plus ? Relancez la connexion : plus rapide qu\'un redémarrage du modem.'**
  String get dashboardReconnectHint;

  /// No description provided for @dashboardInternetUnknown.
  ///
  /// In fr, this message translates to:
  /// **'État d\'internet inconnu'**
  String get dashboardInternetUnknown;

  /// No description provided for @dashboardInternetLostTitle.
  ///
  /// In fr, this message translates to:
  /// **'Internet ne passe plus'**
  String get dashboardInternetLostTitle;

  /// No description provided for @dashboardInternetLostMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le modem n\'a plus accès à internet. Relancez la connexion pour le rétablir.'**
  String get dashboardInternetLostMessage;

  /// No description provided for @dashboardReconnectAction.
  ///
  /// In fr, this message translates to:
  /// **'Relancer la connexion'**
  String get dashboardReconnectAction;

  /// No description provided for @dashboardReconnectConfirm.
  ///
  /// In fr, this message translates to:
  /// **'L\'appli coupe la connexion du modem, comme un mode avion (il se réinscrit sur le réseau), puis la rétablit. Elle recommence jusqu\'au retour d\'internet ou jusqu\'à ce que vous touchiez « Arrêter ». Le Wi-Fi reste actif.'**
  String get dashboardReconnectConfirm;

  /// No description provided for @dashboardReconnectStepCut.
  ///
  /// In fr, this message translates to:
  /// **'Coupure de la connexion'**
  String get dashboardReconnectStepCut;

  /// No description provided for @dashboardReconnectStepRestore.
  ///
  /// In fr, this message translates to:
  /// **'Rétablissement de la connexion'**
  String get dashboardReconnectStepRestore;

  /// No description provided for @dashboardReconnectStepReregister.
  ///
  /// In fr, this message translates to:
  /// **'Réinscription du modem sur le réseau'**
  String get dashboardReconnectStepReregister;

  /// No description provided for @dashboardReconnectAttempt.
  ///
  /// In fr, this message translates to:
  /// **'Tentative {attempt}'**
  String dashboardReconnectAttempt(int attempt);

  /// No description provided for @dashboardReconnectElapsed.
  ///
  /// In fr, this message translates to:
  /// **'Temps écoulé : {time}'**
  String dashboardReconnectElapsed(String time);

  /// No description provided for @dashboardReconnectStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get dashboardReconnectStop;

  /// No description provided for @dashboardReconnectStopping.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt après cette tentative…'**
  String get dashboardReconnectStopping;

  /// No description provided for @dashboardReconnectStopped.
  ///
  /// In fr, this message translates to:
  /// **'Relance arrêtée.'**
  String get dashboardReconnectStopped;

  /// No description provided for @dashboardReconnectSuccessAfter.
  ///
  /// In fr, this message translates to:
  /// **'Connexion relancée : internet est revenu à la tentative {attempt}.'**
  String dashboardReconnectSuccessAfter(int attempt);

  /// No description provided for @dashboardReconnectStepInternet.
  ///
  /// In fr, this message translates to:
  /// **'Attente du retour d\'internet'**
  String get dashboardReconnectStepInternet;

  /// No description provided for @dashboardReconnectSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion relancée : internet est revenu.'**
  String get dashboardReconnectSuccess;

  /// No description provided for @dashboardReconnectNoInternet.
  ///
  /// In fr, this message translates to:
  /// **'Le réseau est revenu mais internet ne répond pas encore. Réessayez ou redémarrez le modem.'**
  String get dashboardReconnectNoInternet;

  /// No description provided for @dashboardRebootTitle.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrer le modem ?'**
  String get dashboardRebootTitle;

  /// No description provided for @dashboardRebootConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Le modem va redémarrer (environ 1 minute). Tous les appareils seront déconnectés pendant ce temps.'**
  String get dashboardRebootConfirm;

  /// No description provided for @dashboardRebootAction.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrer le modem'**
  String get dashboardRebootAction;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardDevicesSplit.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi : {wifi} · Filaire : {wired}'**
  String dashboardDevicesSplit(int wifi, int wired);

  /// No description provided for @dashboardModemSection.
  ///
  /// In fr, this message translates to:
  /// **'Modem'**
  String get dashboardModemSection;

  /// No description provided for @dashboardUptime.
  ///
  /// In fr, this message translates to:
  /// **'Durée de fonctionnement'**
  String get dashboardUptime;

  /// No description provided for @dashboardCpuTemp.
  ///
  /// In fr, this message translates to:
  /// **'Température du processeur'**
  String get dashboardCpuTemp;

  /// No description provided for @dashboardTemperature.
  ///
  /// In fr, this message translates to:
  /// **'{value} °C'**
  String dashboardTemperature(String value);

  /// No description provided for @dashboardSystemTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure du modem'**
  String get dashboardSystemTime;

  /// No description provided for @dashboardBsid.
  ///
  /// In fr, this message translates to:
  /// **'Station de base (BS ID)'**
  String get dashboardBsid;

  /// No description provided for @dashboardCellId.
  ///
  /// In fr, this message translates to:
  /// **'Cellule (Cell ID)'**
  String get dashboardCellId;

  /// No description provided for @dashboardSoftwareVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version logicielle'**
  String get dashboardSoftwareVersion;

  /// No description provided for @dashboardHardwareVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version matérielle'**
  String get dashboardHardwareVersion;

  /// No description provided for @dashboardWebVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version de l\'interface web'**
  String get dashboardWebVersion;

  /// No description provided for @dashboardImei.
  ///
  /// In fr, this message translates to:
  /// **'IMEI'**
  String get dashboardImei;

  /// No description provided for @dashboardIccid.
  ///
  /// In fr, this message translates to:
  /// **'ICCID'**
  String get dashboardIccid;

  /// No description provided for @dashboardImsi.
  ///
  /// In fr, this message translates to:
  /// **'IMSI'**
  String get dashboardImsi;

  /// No description provided for @dashboardSsid.
  ///
  /// In fr, this message translates to:
  /// **'Nom du Wi-Fi'**
  String get dashboardSsid;

  /// No description provided for @dashboardShortcuts.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis'**
  String get dashboardShortcuts;

  /// No description provided for @dashboardCompareOperators.
  ///
  /// In fr, this message translates to:
  /// **'Comparatif des opérateurs'**
  String get dashboardCompareOperators;

  /// No description provided for @devicesConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connectés maintenant'**
  String get devicesConnected;

  /// No description provided for @devicesNoneConnected.
  ///
  /// In fr, this message translates to:
  /// **'0 appareil connecté pour le moment.'**
  String get devicesNoneConnected;

  /// No description provided for @devicesSeenBefore.
  ///
  /// In fr, this message translates to:
  /// **'Déjà vus (déconnectés)'**
  String get devicesSeenBefore;

  /// No description provided for @devicesNewBadge.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get devicesNewBadge;

  /// No description provided for @devicesRename.
  ///
  /// In fr, this message translates to:
  /// **'Donner un surnom'**
  String get devicesRename;

  /// No description provided for @devicesRenameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Surnom de l\'appareil'**
  String get devicesRenameTitle;

  /// No description provided for @devicesNickname.
  ///
  /// In fr, this message translates to:
  /// **'Surnom'**
  String get devicesNickname;

  /// No description provided for @devicesNicknameHint.
  ///
  /// In fr, this message translates to:
  /// **'Mémorisé dans l\'appli ; laissez vide pour l\'effacer'**
  String get devicesNicknameHint;

  /// No description provided for @devicesIp.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP'**
  String get devicesIp;

  /// No description provided for @devicesMac.
  ///
  /// In fr, this message translates to:
  /// **'Adresse MAC'**
  String get devicesMac;

  /// No description provided for @devicesAnnouncedName.
  ///
  /// In fr, this message translates to:
  /// **'Nom annoncé par l\'appareil'**
  String get devicesAnnouncedName;

  /// No description provided for @devicesFirstSeen.
  ///
  /// In fr, this message translates to:
  /// **'Vu la première fois'**
  String get devicesFirstSeen;

  /// No description provided for @devicesLastSeen.
  ///
  /// In fr, this message translates to:
  /// **'Vu la dernière fois'**
  String get devicesLastSeen;

  /// No description provided for @devicesLastSeenShort.
  ///
  /// In fr, this message translates to:
  /// **'vu {time}'**
  String devicesLastSeenShort(String time);

  /// No description provided for @devicesNoBlockingNote.
  ///
  /// In fr, this message translates to:
  /// **'Le modem ne permet pas de bloquer un appareil : utilisez « Expulser les intrus » pour changer le mot de passe Wi-Fi.'**
  String get devicesNoBlockingNote;

  /// No description provided for @dhcpWarning.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer ces réglages redémarre le modem (environ 1 minute) et son adresse peut changer. Tous les appareils seront déconnectés pendant ce temps.'**
  String get dhcpWarning;

  /// No description provided for @dhcpModemSection.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du modem'**
  String get dhcpModemSection;

  /// No description provided for @dhcpGateway.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP du modem (passerelle)'**
  String get dhcpGateway;

  /// No description provided for @dhcpNetmask.
  ///
  /// In fr, this message translates to:
  /// **'Masque de sous-réseau'**
  String get dhcpNetmask;

  /// No description provided for @dhcpServerSection.
  ///
  /// In fr, this message translates to:
  /// **'Serveur DHCP'**
  String get dhcpServerSection;

  /// No description provided for @dhcpServer.
  ///
  /// In fr, this message translates to:
  /// **'Serveur DHCP'**
  String get dhcpServer;

  /// No description provided for @dhcpReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Non modifiable (comme dans l\'interface d\'origine)'**
  String get dhcpReadOnly;

  /// No description provided for @dhcpPoolStart.
  ///
  /// In fr, this message translates to:
  /// **'Début de plage'**
  String get dhcpPoolStart;

  /// No description provided for @dhcpPoolEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin de plage'**
  String get dhcpPoolEnd;

  /// No description provided for @dhcpLease.
  ///
  /// In fr, this message translates to:
  /// **'Durée du bail'**
  String get dhcpLease;

  /// No description provided for @dhcpHours.
  ///
  /// In fr, this message translates to:
  /// **'heures'**
  String get dhcpHours;

  /// No description provided for @dhcpSummary.
  ///
  /// In fr, this message translates to:
  /// **'Réseau {network}/{prefix} · {count} adresses attribuables'**
  String dhcpSummary(String network, int prefix, int count);

  /// No description provided for @dhcpErrorNetmask.
  ///
  /// In fr, this message translates to:
  /// **'Masque invalide (ex. 255.255.255.0)'**
  String get dhcpErrorNetmask;

  /// No description provided for @dhcpErrorReserved.
  ///
  /// In fr, this message translates to:
  /// **'Adresse réservée (réseau ou diffusion)'**
  String get dhcpErrorReserved;

  /// No description provided for @dhcpErrorSubnet.
  ///
  /// In fr, this message translates to:
  /// **'Hors du sous-réseau du modem'**
  String get dhcpErrorSubnet;

  /// No description provided for @dhcpErrorOrder.
  ///
  /// In fr, this message translates to:
  /// **'La fin doit être après le début'**
  String get dhcpErrorOrder;

  /// No description provided for @dhcpErrorGatewayInPool.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse du modem ne doit pas être dans la plage'**
  String get dhcpErrorGatewayInPool;

  /// No description provided for @dhcpErrorLease.
  ///
  /// In fr, this message translates to:
  /// **'Nombre d\'heures entre 1 et {max}'**
  String dhcpErrorLease(int max);

  /// No description provided for @dhcpSaveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et redémarrer ?'**
  String get dhcpSaveTitle;

  /// No description provided for @dhcpSaveWarning.
  ///
  /// In fr, this message translates to:
  /// **'Le modem va redémarrer (environ 1 minute). Le téléphone devra peut-être se reconnecter au Wi-Fi.'**
  String get dhcpSaveWarning;

  /// No description provided for @dhcpNewAddress.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse du modem devient {address} : l\'appli l\'utilisera automatiquement.'**
  String dhcpNewAddress(String address);

  /// No description provided for @dhcpNotBack.
  ///
  /// In fr, this message translates to:
  /// **'Le modem ne répond pas encore. Vérifiez le Wi-Fi du téléphone ; l\'adresse du modem peut aussi se modifier dans Réglages › Réglages de l\'application.'**
  String get dhcpNotBack;

  /// No description provided for @expelIntro.
  ///
  /// In fr, this message translates to:
  /// **'Le modem ne sait pas bloquer un appareil précis. Pour se débarrasser d\'un intrus, l\'appli change le mot de passe Wi-Fi : seuls ceux qui connaissent le nouveau pourront se reconnecter.'**
  String get expelIntro;

  /// No description provided for @expelWarning.
  ///
  /// In fr, this message translates to:
  /// **'Tous les appareils, y compris ce téléphone, seront déconnectés. Reconnectez-vous avec le nouveau mot de passe.'**
  String get expelWarning;

  /// No description provided for @expelHideSsid.
  ///
  /// In fr, this message translates to:
  /// **'Masquer aussi le nom du Wi-Fi'**
  String get expelHideSsid;

  /// No description provided for @expelHideSsidHint.
  ///
  /// In fr, this message translates to:
  /// **'Le réseau devient invisible pour les voisins ; il faudra saisir son nom pour s\'y connecter.'**
  String get expelHideSsidHint;

  /// No description provided for @expelApply.
  ///
  /// In fr, this message translates to:
  /// **'Générer un nouveau mot de passe et l\'appliquer'**
  String get expelApply;

  /// No description provided for @expelDone.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe appliqué. Scannez ce code avec vos appareils pour les reconnecter.'**
  String get expelDone;

  /// No description provided for @expelNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau Wi-Fi'**
  String get expelNetwork;

  /// No description provided for @expelNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get expelNewPassword;

  /// No description provided for @expelHiddenNote.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du réseau est masqué : il n\'apparaît plus dans la liste des Wi-Fi.'**
  String get expelHiddenNote;

  /// No description provided for @expelReconnectPhone.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecter ce téléphone'**
  String get expelReconnectPhone;

  /// No description provided for @expelWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente de la reconnexion du téléphone au Wi-Fi…'**
  String get expelWaiting;

  /// No description provided for @expelReconnected.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone reconnecté : la session a repris.'**
  String get expelReconnected;

  /// No description provided for @expelNotReconnected.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone n\'est pas encore reconnecté au Wi-Fi du modem.'**
  String get expelNotReconnected;

  /// No description provided for @firmwareDangerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservé aux utilisateurs avertis'**
  String get firmwareDangerTitle;

  /// No description provided for @firmwareDanger.
  ///
  /// In fr, this message translates to:
  /// **'Un mauvais fichier ou une coupure pendant la mise à jour peut rendre le modem inutilisable. N\'utilisez que le firmware officiel prévu pour ce modem.'**
  String get firmwareDanger;

  /// No description provided for @firmwareChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Avant de commencer'**
  String get firmwareChecklist;

  /// No description provided for @firmwareCheckBattery.
  ///
  /// In fr, this message translates to:
  /// **'La batterie du modem est chargée'**
  String get firmwareCheckBattery;

  /// No description provided for @firmwareCheckPlugged.
  ///
  /// In fr, this message translates to:
  /// **'Le modem restera branché et je ne l\'éteindrai pas'**
  String get firmwareCheckPlugged;

  /// No description provided for @firmwareCheckRisks.
  ///
  /// In fr, this message translates to:
  /// **'Je comprends les risques'**
  String get firmwareCheckRisks;

  /// No description provided for @firmwareFileSection.
  ///
  /// In fr, this message translates to:
  /// **'Fichier du firmware'**
  String get firmwareFileSection;

  /// No description provided for @firmwareFileLabel.
  ///
  /// In fr, this message translates to:
  /// **'Firmware (.zip)'**
  String get firmwareFileLabel;

  /// No description provided for @firmwareChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier .zip'**
  String get firmwareChoose;

  /// No description provided for @firmwareChooseAnother.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un autre fichier'**
  String get firmwareChooseAnother;

  /// No description provided for @firmwareNotZip.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier doit être une archive .zip.'**
  String get firmwareNotZip;

  /// No description provided for @firmwareTooBig.
  ///
  /// In fr, this message translates to:
  /// **'Fichier vide ou trop volumineux (500 Mo au maximum).'**
  String get firmwareTooBig;

  /// No description provided for @firmwareSize.
  ///
  /// In fr, this message translates to:
  /// **'{size} Mo'**
  String firmwareSize(String size);

  /// No description provided for @firmwareCrcLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code CRC'**
  String get firmwareCrcLabel;

  /// No description provided for @firmwareCrcHelper.
  ///
  /// In fr, this message translates to:
  /// **'Code de contrôle fourni avec le firmware. À défaut, l\'appli peut le calculer (format attendu par le modem à confirmer).'**
  String get firmwareCrcHelper;

  /// No description provided for @firmwareComputeMd5.
  ///
  /// In fr, this message translates to:
  /// **'Calculer le MD5'**
  String get firmwareComputeMd5;

  /// No description provided for @firmwareComputeCrc32.
  ///
  /// In fr, this message translates to:
  /// **'Calculer le CRC32'**
  String get firmwareComputeCrc32;

  /// No description provided for @firmwareStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer la mise à jour'**
  String get firmwareStart;

  /// No description provided for @firmwareConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour le firmware ?'**
  String get firmwareConfirmTitle;

  /// No description provided for @firmwareConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier « {file} » va être envoyé au modem. Ne quittez pas l\'appli et n\'éteignez pas le modem pendant toute l\'opération.'**
  String firmwareConfirmMessage(String file);

  /// No description provided for @firmwareConfirmWord.
  ///
  /// In fr, this message translates to:
  /// **'METTRE À JOUR'**
  String get firmwareConfirmWord;

  /// No description provided for @firmwarePreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de la mise à jour…'**
  String get firmwarePreparing;

  /// No description provided for @firmwareUploading.
  ///
  /// In fr, this message translates to:
  /// **'Envoi du fichier : {sent} Mo sur {total} Mo'**
  String firmwareUploading(String sent, String total);

  /// No description provided for @firmwareVerifying.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du fichier par le modem…'**
  String get firmwareVerifying;

  /// No description provided for @firmwareDoNotLeave.
  ///
  /// In fr, this message translates to:
  /// **'Ne quittez pas cet écran et n\'éteignez pas le modem.'**
  String get firmwareDoNotLeave;

  /// No description provided for @firmwareCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'envoi'**
  String get firmwareCancel;

  /// No description provided for @firmwareCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'envoi ?'**
  String get firmwareCancelTitle;

  /// No description provided for @firmwareCancelMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'envoi du firmware sera interrompu ; le modem gardera sa version actuelle.'**
  String get firmwareCancelMessage;

  /// No description provided for @firmwareRefused.
  ///
  /// In fr, this message translates to:
  /// **'Le modem a refusé la mise à jour'**
  String get firmwareRefused;

  /// No description provided for @firmwareNoAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Le modem n\'a pas confirmé la vérification du fichier.'**
  String get firmwareNoAnswer;

  /// No description provided for @firmwareInProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour en cours'**
  String get firmwareInProgressTitle;

  /// No description provided for @firmwareInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Le modem installe le nouveau firmware puis redémarrera. Cela peut prendre plusieurs minutes : ne l\'éteignez surtout pas.'**
  String get firmwareInProgress;

  /// No description provided for @firmwareWaitingRestart.
  ///
  /// In fr, this message translates to:
  /// **'Installation du firmware et redémarrage du modem (plusieurs minutes)…'**
  String get firmwareWaitingRestart;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Guide d\'utilisation'**
  String get helpTitle;

  /// No description provided for @helpHubSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment utiliser chaque fonction, et que faire en cas de problème'**
  String get helpHubSubtitle;

  /// No description provided for @helpIntro.
  ///
  /// In fr, this message translates to:
  /// **'MiFi remplace l\'interface web du modem. Touchez une rubrique pour savoir comment utiliser chaque fonction.'**
  String get helpIntro;

  /// No description provided for @helpStartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Premiers pas'**
  String get helpStartTitle;

  /// No description provided for @helpStartBody.
  ///
  /// In fr, this message translates to:
  /// **'1. Connectez le téléphone au Wi-Fi du modem (nom et mot de passe sur l\'étiquette du modem).\n2. Ouvrez MiFi et saisissez le mot de passe administrateur du modem (indiqué sur l\'étiquette s\'il n\'a jamais été changé).\n3. Laissez « Mémoriser le mot de passe » coché : la connexion sera automatique aux lancements suivants. Le mot de passe est enregistré chiffré sur le téléphone.\n\nSi Android signale « Pas d\'accès à internet » pour ce Wi-Fi (par exemple quand les données sont coupées), c\'est normal : l\'appli l\'utilise quand même pour parler au modem.'**
  String get helpStartBody;

  /// No description provided for @helpAddressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du modem'**
  String get helpAddressTitle;

  /// No description provided for @helpAddressBody.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut, le modem répond à l\'adresse 192.168.100.1.\n\nSi vous la changez dans « Réseau local (DHCP) », l\'appli suit automatiquement la nouvelle adresse. Vous pouvez aussi la modifier à la main sur l\'écran de connexion (rubrique « Adresse du modem ») ou dans Réglages › Réglages de l\'application. L\'appli propose l\'adresse de la passerelle du Wi-Fi actuel quand elle est différente.'**
  String get helpAddressBody;

  /// No description provided for @helpDashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get helpDashboardTitle;

  /// No description provided for @helpDashboardBody.
  ///
  /// In fr, this message translates to:
  /// **'En haut, comme sur l\'interface d\'origine : icônes Wi-Fi, SIM, signal et internet, nom de l\'opérateur, choix de la langue et menu administrateur (mot de passe, guide, déconnexion).\n\nEn dessous : le signal (barres, dBm, qualité), l\'état d\'internet et l\'IP WAN, des boutons rapides façon téléphone (Données mobiles, Wi-Fi, Partage USB), « Relancer la connexion », les appareils connectés, les informations et versions du modem, et des raccourcis.\n\nLes données se mettent à jour en continu (toutes les 2 secondes) ; tirez l\'écran vers le bas pour tout recharger. Les valeurs que le modem ne fournit pas sont masquées au lieu d\'afficher 0.'**
  String get helpDashboardBody;

  /// No description provided for @helpOperatorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur et changement de SIM'**
  String get helpOperatorTitle;

  /// No description provided for @helpOperatorBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'appli fonctionne avec la SIM de n\'importe quel opérateur. Elle affiche le nom de service fourni par la SIM ; sinon, elle déduit l\'opérateur du code de la SIM (MTN, Orange, Nexttel, Camtel), ou affiche « Opérateur 624-XX ».\n\nQuand vous changez de SIM, l\'appli affiche « Nouvelle SIM détectée » et propose d\'ouvrir les réglages APN. En général, le modem choisit seul le bon APN.'**
  String get helpOperatorBody;

  /// No description provided for @helpMobileDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données mobiles'**
  String get helpMobileDataTitle;

  /// No description provided for @helpMobileDataBody.
  ///
  /// In fr, this message translates to:
  /// **'Comme sur un téléphone, l\'interrupteur « Données mobiles » coupe internet tout en gardant la SIM connectée au réseau (le signal reste visible). Le Wi-Fi reste actif.\n\nLe modem n\'ayant pas de commande dédiée, l\'appli active pour cela un profil APN de coupure (« MiFi-OFF ») ; réactiver les données remet votre profil habituel. Une tuile « Données mobiles » est aussi disponible dans les Réglages rapides d\'Android.'**
  String get helpMobileDataBody;

  /// No description provided for @helpAirplaneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode avion'**
  String get helpAirplaneTitle;

  /// No description provided for @helpAirplaneBody.
  ///
  /// In fr, this message translates to:
  /// **'Comme sur un téléphone, le mode avion coupe internet sur la SIM utilisée (SIM 1 ou SIM 2), sans jamais changer de SIM. Après confirmation, il s\'active en quelques secondes. Le Wi-Fi du modem reste allumé : vos appareils restent connectés au modem (sans internet) et l\'appli peut toujours désactiver le mode avion.\n\nLe modem n\'a pas de commande pour éteindre sa radio : l\'appli coupe internet en activant un profil APN de coupure (« MiFi-OFF »). La SIM reste donc accrochée au réseau et la barre de signal reste visible. Si vous changez de SIM pendant le mode avion, la coupure s\'applique aussi à la nouvelle SIM.\n\nL\'appli vérifie que la connexion tombe. Si le modem remet de lui-même son profil APN habituel, elle réactive la coupure : à chaque relevé quand l\'appli est ouverte, sinon lors des vérifications en arrière-plan (toutes les 15 minutes au mieux, si elles sont activées). Si la coupure ne tient pas, par exemple quand l\'opérateur accepte n\'importe quel APN, un avertissement s\'affiche.\n\nPendant le mode avion, l\'interrupteur « Données mobiles » est grisé. Désactiver le mode avion remet votre profil APN habituel.'**
  String get helpAirplaneBody;

  /// No description provided for @helpReconnectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relancer la connexion et réparation automatique'**
  String get helpReconnectTitle;

  /// No description provided for @helpReconnectBody.
  ///
  /// In fr, this message translates to:
  /// **'Quand internet ne passe plus, touchez « Relancer la connexion » sur le tableau de bord : l\'appli coupe la connexion du modem, comme un mode avion (il se réinscrit sur le réseau), puis la rétablit. Elle recommence jusqu\'au retour d\'internet ou jusqu\'à ce que vous touchiez « Arrêter » ; le numéro de la tentative et le temps écoulé sont affichés. C\'est bien plus rapide qu\'un redémarrage du modem, qui reste proposé.\n\nAvec la réparation automatique (Réglages › Réglages de l\'application), l\'appli le fait seule si internet est coupé depuis 3 minutes avec un bon signal (3 tentatives au plus, une fois toutes les 30 minutes au plus).'**
  String get helpReconnectBody;

  /// No description provided for @helpTileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tuiles « Réglages rapides » et raccourcis'**
  String get helpTileTitle;

  /// No description provided for @helpTileBody.
  ///
  /// In fr, this message translates to:
  /// **'Pour activer ou désactiver les données mobiles sans ouvrir l\'appli :\n1. Faites glisser deux fois vers le bas depuis le haut de l\'écran.\n2. Touchez le crayon (Modifier).\n3. Faites glisser la tuile « Données mobiles » de MiFi parmi vos tuiles.\n\nUn appui lance le changement. Le téléphone doit être connecté au Wi-Fi du modem et le mot de passe mémorisé ; en cas d\'échec, une notification vous prévient.\n\nUn appui long sur l\'icône MiFi propose aussi des raccourcis : Partager le Wi-Fi, Test de débit.'**
  String get helpTileBody;

  /// No description provided for @helpWidgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Widgets d\'écran d\'accueil'**
  String get helpWidgetTitle;

  /// No description provided for @helpWidgetBody.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez longuement sur un espace vide de l\'écran d\'accueil, choisissez « Widgets », puis MiFi : le widget « État du modem » affiche l\'opérateur, le signal, internet et le nombre d\'appareils ; un appui ouvre l\'appli. Il se met à jour quand l\'appli est ouverte et à chaque vérification en arrière-plan.'**
  String get helpWidgetBody;

  /// No description provided for @helpScheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage programmé'**
  String get helpScheduleTitle;

  /// No description provided for @helpScheduleBody.
  ///
  /// In fr, this message translates to:
  /// **'Dans Réglages › Réglages de l\'application › Automatismes, le redémarrage programmé redémarre le modem chaque jour à l\'heure choisie.\n\nÀ l\'heure prévue, le téléphone doit être connecté au Wi-Fi du modem ; sinon, une notification d\'échec s\'affiche. Android peut décaler l\'heure de quelques minutes.'**
  String get helpScheduleBody;

  /// No description provided for @helpDevicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appareils connectés'**
  String get helpDevicesTitle;

  /// No description provided for @helpDevicesBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Appareils liste les appareils connectés : nom, type (Wi-Fi ou filaire), adresse IP et adresse MAC. Touchez un appareil pour lui donner un surnom, mémorisé d\'après son adresse MAC.\n\nUn badge « Nouveau » signale un appareil vu pour la première fois récemment, et une alerte prévient quand un appareil inconnu se connecte, avec un accès direct à « Expulser les intrus ». Les appareils déjà vus mais déconnectés sont listés à part.'**
  String get helpDevicesBody;

  /// No description provided for @helpExpelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Expulser les intrus'**
  String get helpExpelTitle;

  /// No description provided for @helpExpelBody.
  ///
  /// In fr, this message translates to:
  /// **'Le modem ne sait pas bloquer un appareil. « Expulser les intrus » génère un nouveau mot de passe Wi-Fi solide (12 caractères), l\'applique et affiche aussitôt son QR code. Vous pouvez aussi masquer le nom du Wi-Fi pour le rendre invisible aux voisins.\n\nTous les appareils, y compris ce téléphone, sont déconnectés : reconnectez-les avec le nouveau mot de passe (bouton « Reconnecter ce téléphone », QR code ou partage par message). L\'appli reprend sa session dès que le téléphone est reconnecté.'**
  String get helpExpelBody;

  /// No description provided for @helpWifiTitle.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi et partage'**
  String get helpWifiTitle;

  /// No description provided for @helpWifiBody.
  ///
  /// In fr, this message translates to:
  /// **'Réglages › Wi-Fi permet de changer le nom du réseau, le mot de passe (8 à 32 caractères), la sécurité, le canal et la diffusion du nom. Après l\'enregistrement, le Wi-Fi redémarre : reconnectez le téléphone au réseau.\n\nPour partager le Wi-Fi : QR code à scanner avec l\'appareil photo, ou envoi du nom et du mot de passe par message (WhatsApp, SMS…).\n\nAttention : « Couper le Wi-Fi » déconnecte immédiatement le téléphone et l\'appli ne pourra pas le rallumer. Il faudra le bouton du modem ou un redémarrage.'**
  String get helpWifiBody;

  /// No description provided for @helpDhcpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réseau local (DHCP)'**
  String get helpDhcpTitle;

  /// No description provided for @helpDhcpBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette page règle l\'adresse du modem, le masque, la plage d\'adresses attribuées aux appareils et la durée du bail (en heures). L\'appli vérifie que la plage est dans le même sous-réseau que le modem.\n\nL\'enregistrement redémarre le modem (environ 1 minute). Si l\'adresse du modem change, l\'appli utilise automatiquement la nouvelle. L\'état du serveur DHCP est affiché en lecture seule.'**
  String get helpDhcpBody;

  /// No description provided for @helpMobileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réseau mobile'**
  String get helpMobileTitle;

  /// No description provided for @helpMobileBody.
  ///
  /// In fr, this message translates to:
  /// **'• Carte SIM : emplacement utilisé (SIM 1 ou SIM 2) ; la bascule prend environ 20 secondes.\n• Données mobiles : même interrupteur que sur le tableau de bord.\n• APN : choisissez le profil utilisé pour internet ou créez-en un avec les paramètres de votre opérateur (MCC et MNC sont pré-remplis d\'après la SIM).\n• Mode réseau : 4G/3G automatique, 4G uniquement ou 3G uniquement.\n• Partage de connexion USB : internet par câble USB vers un ordinateur.\n• Détection de coupure : le modem vérifie la connexion en contactant ces adresses (IP ou nom, par exemple 8.8.8.8 ou www.google.com).'**
  String get helpMobileBody;

  /// No description provided for @helpSystemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get helpSystemTitle;

  /// No description provided for @helpSystemBody.
  ///
  /// In fr, this message translates to:
  /// **'• Changer le mot de passe administrateur : l\'appli se reconnecte toute seule avec le nouveau.\n• Redémarrer le modem : environ 1 minute ; l\'appli attend son retour.\n• Réinitialisation d\'usine : deux confirmations sont demandées. Le Wi-Fi et le mot de passe reviennent aux valeurs de l\'étiquette du modem : reconnectez le téléphone au Wi-Fi d\'usine puis reconnectez-vous. Faites une sauvegarde avant.\n• Informations de fabrication : calibrage et test Wi-Fi d\'usine (lecture seule).'**
  String get helpSystemBody;

  /// No description provided for @helpFirmwareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour du firmware'**
  String get helpFirmwareTitle;

  /// No description provided for @helpFirmwareBody.
  ///
  /// In fr, this message translates to:
  /// **'Réservée aux utilisateurs avertis : un mauvais fichier peut rendre le modem inutilisable.\n\nAvant de commencer : batterie chargée, modem branché et immobile, téléphone près du modem. Choisissez le fichier .zip officiel (500 Mo maximum) et saisissez le code CRC fourni avec lui. Pendant l\'envoi, ne quittez pas l\'appli et n\'éteignez pas le modem. À la fin, le modem se met à jour puis redémarre.'**
  String get helpFirmwareBody;

  /// No description provided for @helpSignalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique du signal et meilleur emplacement'**
  String get helpSignalTitle;

  /// No description provided for @helpSignalBody.
  ///
  /// In fr, this message translates to:
  /// **'Réglages › Historique du signal affiche la puissance du signal (en dBm) sur la dernière heure ou les dernières 24 heures. Plus la valeur est proche de 0, meilleur est le signal : excellent (4 barres) à partir de -80 dBm, bon (3) à partir de -90, moyen (2) à partir de -100, faible (1) à partir de -110, inexistant en dessous ; les barres sont vertes, orange ou rouges selon le niveau. Le relevé est mis à jour en continu (toutes les 2 secondes).\n\n« Trouver le meilleur emplacement » affiche une grande jauge mise à jour toutes les 2 à 3 secondes. Déplacez lentement le modem (près d\'une fenêtre, en hauteur) et attendez quelques secondes à chaque position : l\'appli retient la meilleure valeur.'**
  String get helpSignalBody;

  /// No description provided for @helpOutagesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal des coupures'**
  String get helpOutagesTitle;

  /// No description provided for @helpOutagesBody.
  ///
  /// In fr, this message translates to:
  /// **'Chaque perte d\'internet est notée avec son début, sa fin et sa durée ; les coupures dues aux données coupées ou à « Relancer la connexion » sont marquées « volontaires ». Un résumé indique le nombre et la durée des coupures sur 24 heures et 7 jours.\n\nLe bouton d\'export enregistre le journal en fichier CSV (lisible avec Excel), par exemple pour réclamer auprès de l\'opérateur.'**
  String get helpOutagesBody;

  /// No description provided for @helpSpeedTestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Test de débit et comparatif des opérateurs'**
  String get helpSpeedTestTitle;

  /// No description provided for @helpSpeedTestBody.
  ///
  /// In fr, this message translates to:
  /// **'Le test de débit télécharge un fichier (5, 10 ou 25 Mo) à travers le modem et affiche le débit en Mb/s avec sa qualité : inexistant, faible, moyen, bon ou excellent. Il consomme des données de votre forfait. Les résultats sont gardés dans un historique.\n\nLe comparatif des opérateurs (raccourci sur le tableau de bord) regroupe, pour chaque SIM utilisée ces 7 derniers jours : signal moyen, débit moyen et coupures. Pratique pour choisir la SIM qui marche le mieux chez vous.'**
  String get helpSpeedTestBody;

  /// No description provided for @helpBackupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde et restauration'**
  String get helpBackupTitle;

  /// No description provided for @helpBackupBody.
  ///
  /// In fr, this message translates to:
  /// **'« Exporter les réglages » enregistre dans un fichier les réglages Wi-Fi, APN, DHCP, mode réseau et détection de coupure. Le mot de passe administrateur n\'est jamais exporté, mais le fichier contient le mot de passe Wi-Fi : gardez-le en lieu sûr.\n\n« Restaurer » réapplique une sauvegarde, par exemple après une réinitialisation d\'usine. Vous choisissez les rubriques ; le DHCP redémarre le modem, et le Wi-Fi est appliqué en dernier car le téléphone devra s\'y reconnecter.'**
  String get helpBackupBody;

  /// No description provided for @helpNotificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get helpNotificationsTitle;

  /// No description provided for @helpNotificationsBody.
  ///
  /// In fr, this message translates to:
  /// **'MiFi peut vous prévenir quand internet est coupé ou revient, quand le signal est faible et quand un nouvel appareil se connecte. Réglez-les dans Réglages › Réglages de l\'application › Notifications, et autorisez-les quand Android le demande.\n\nAppli ouverte, la surveillance est continue. Appli fermée, la surveillance continue (Réglages de l\'application) vous prévient en quelques secondes ; sans elle, Android n\'autorise qu\'une vérification environ toutes les 15 minutes. Le téléphone doit être connecté au Wi-Fi du modem.'**
  String get helpNotificationsBody;

  /// No description provided for @helpLanguageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue, thème et verrouillage'**
  String get helpLanguageTitle;

  /// No description provided for @helpLanguageBody.
  ///
  /// In fr, this message translates to:
  /// **'Dans Réglages › Réglages de l\'application :\n• langue de l\'appli (langue du téléphone, français ou anglais) ; l\'option « Appliquer aussi à l\'interface web du modem » change aussi la langue de la page web d\'origine ;\n• thème automatique, clair ou sombre ;\n• verrouillage : MiFi demande l\'empreinte digitale ou le code du téléphone à l\'ouverture.'**
  String get helpLanguageBody;

  /// No description provided for @helpTroubleshootingTitle.
  ///
  /// In fr, this message translates to:
  /// **'En cas de problème'**
  String get helpTroubleshootingTitle;

  /// No description provided for @helpTroubleshootingBody.
  ///
  /// In fr, this message translates to:
  /// **'• « Impossible de joindre le modem » : vérifiez que le téléphone est connecté au Wi-Fi du modem, puis l\'adresse du modem (192.168.100.1 par défaut).\n• « Session expirée » : l\'appli se reconnecte seule ; si le mot de passe a été changé ailleurs, reconnectez-vous.\n• Wi-Fi coupé : rallumez-le avec le bouton du modem ou redémarrez le modem.\n• Mot de passe administrateur oublié : faites une réinitialisation d\'usine avec le bouton RESET du modem.\n• Données mobiles en échec : vérifiez le Wi-Fi puis réessayez ; en dernier recours, redémarrez le modem.'**
  String get helpTroubleshootingBody;

  /// No description provided for @helpLimitsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que le modem ne permet pas'**
  String get helpLimitsTitle;

  /// No description provided for @helpLimitsBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'API du modem ne fournit pas ces informations, et l\'appli ne les invente pas : niveau de batterie, données consommées, blocage d\'un appareil, SMS, USSD, solde ou forfait de l\'opérateur.'**
  String get helpLimitsBody;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au modem'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez le téléphone au Wi-Fi du modem, puis saisissez le mot de passe administrateur.'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe administrateur'**
  String get loginPasswordLabel;

  /// No description provided for @loginRemember.
  ///
  /// In fr, this message translates to:
  /// **'Mémoriser le mot de passe'**
  String get loginRemember;

  /// No description provided for @loginRememberHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré chiffré sur ce téléphone, pour la connexion automatique'**
  String get loginRememberHint;

  /// No description provided for @loginAction.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginAction;

  /// No description provided for @loginRetrySaved.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer avec le mot de passe enregistré'**
  String get loginRetrySaved;

  /// No description provided for @loginAddressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du modem'**
  String get loginAddressTitle;

  /// No description provided for @loginAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP du modem'**
  String get loginAddressLabel;

  /// No description provided for @loginAddressHelper.
  ///
  /// In fr, this message translates to:
  /// **'192.168.100.1 par défaut ; elle change si vous modifiez le DHCP'**
  String get loginAddressHelper;

  /// No description provided for @loginUseGateway.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser {address} (Wi-Fi actuel)'**
  String loginUseGateway(String address);

  /// No description provided for @loginResetAddress.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir {address}'**
  String loginResetAddress(String address);

  /// No description provided for @loginTestAddress.
  ///
  /// In fr, this message translates to:
  /// **'Tester'**
  String get loginTestAddress;

  /// No description provided for @loginReachable.
  ///
  /// In fr, this message translates to:
  /// **'Modem joignable à cette adresse.'**
  String get loginReachable;

  /// No description provided for @loginDefaultPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe jamais changé ? Il figure sur l\'étiquette du modem.'**
  String get loginDefaultPasswordHint;

  /// No description provided for @mobileSimSection.
  ///
  /// In fr, this message translates to:
  /// **'Carte SIM'**
  String get mobileSimSection;

  /// No description provided for @mobileSimCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement actif : {slot}'**
  String mobileSimCurrent(String slot);

  /// No description provided for @mobileSimSwitchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passer sur la SIM {number} ?'**
  String mobileSimSwitchTitle(int number);

  /// No description provided for @mobileSimSwitchWarning.
  ///
  /// In fr, this message translates to:
  /// **'La bascule prend environ 20 secondes ; internet est coupé pendant ce temps. Le Wi-Fi reste actif.'**
  String get mobileSimSwitchWarning;

  /// No description provided for @mobileSimSwitching.
  ///
  /// In fr, this message translates to:
  /// **'Bascule de SIM en cours (environ 20 s)…'**
  String get mobileSimSwitching;

  /// No description provided for @mobileApnSection.
  ///
  /// In fr, this message translates to:
  /// **'Profils APN'**
  String get mobileApnSection;

  /// No description provided for @mobileApnHint.
  ///
  /// In fr, this message translates to:
  /// **'Le modem choisit d\'habitude l\'APN selon la SIM. Ne le changez que si internet ne fonctionne pas ; demandez les paramètres à votre opérateur.'**
  String get mobileApnHint;

  /// No description provided for @mobileApnEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun profil APN sur le modem.'**
  String get mobileApnEmpty;

  /// No description provided for @mobileApnActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get mobileApnActive;

  /// No description provided for @mobileApnUse.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce profil'**
  String get mobileApnUse;

  /// No description provided for @mobileApnUseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer de profil APN ?'**
  String get mobileApnUseTitle;

  /// No description provided for @mobileApnUseMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le modem utilisera le profil « {name} » pour se connecter à internet. La connexion peut être brièvement coupée.'**
  String mobileApnUseMessage(String name);

  /// No description provided for @mobileApnNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau profil APN'**
  String get mobileApnNew;

  /// No description provided for @mobileApnNewHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez les paramètres fournis par votre opérateur. MCC et MNC sont pré-remplis d\'après la SIM insérée.'**
  String get mobileApnNewHint;

  /// No description provided for @mobileApnName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du profil'**
  String get mobileApnName;

  /// No description provided for @mobileApnApn.
  ///
  /// In fr, this message translates to:
  /// **'APN'**
  String get mobileApnApn;

  /// No description provided for @mobileApnPdpType.
  ///
  /// In fr, this message translates to:
  /// **'Type PDP'**
  String get mobileApnPdpType;

  /// No description provided for @mobileApnMcc.
  ///
  /// In fr, this message translates to:
  /// **'MCC'**
  String get mobileApnMcc;

  /// No description provided for @mobileApnMnc.
  ///
  /// In fr, this message translates to:
  /// **'MNC'**
  String get mobileApnMnc;

  /// No description provided for @mobileApnMccMnc.
  ///
  /// In fr, this message translates to:
  /// **'MCC-MNC'**
  String get mobileApnMccMnc;

  /// No description provided for @mobileApnMccInvalid.
  ///
  /// In fr, this message translates to:
  /// **'3 chiffres'**
  String get mobileApnMccInvalid;

  /// No description provided for @mobileApnMncInvalid.
  ///
  /// In fr, this message translates to:
  /// **'2 ou 3 chiffres'**
  String get mobileApnMncInvalid;

  /// No description provided for @mobileApnAuth.
  ///
  /// In fr, this message translates to:
  /// **'Authentification'**
  String get mobileApnAuth;

  /// No description provided for @mobileApnUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get mobileApnUsername;

  /// No description provided for @mobileApnPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get mobileApnPassword;

  /// No description provided for @mobileApnPort.
  ///
  /// In fr, this message translates to:
  /// **'Port'**
  String get mobileApnPort;

  /// No description provided for @mobileApnPortInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Port entre 1 et 65535'**
  String get mobileApnPortInvalid;

  /// No description provided for @mobileApnOptional.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif'**
  String get mobileApnOptional;

  /// No description provided for @mobileApnCreatedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil créé'**
  String get mobileApnCreatedTitle;

  /// No description provided for @mobileApnActivateNow.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser maintenant le profil « {name} » ?'**
  String mobileApnActivateNow(String name);

  /// No description provided for @mobileApnBlockerName.
  ///
  /// In fr, this message translates to:
  /// **'Coupure des données (MiFi)'**
  String get mobileApnBlockerName;

  /// No description provided for @mobileModeSection.
  ///
  /// In fr, this message translates to:
  /// **'Mode réseau'**
  String get mobileModeSection;

  /// No description provided for @mobileModeChangeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mode réseau ?'**
  String get mobileModeChangeTitle;

  /// No description provided for @mobileModeChangeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le modem passera en « {mode} ». La connexion peut être brièvement coupée.'**
  String mobileModeChangeMessage(String mode);

  /// No description provided for @mobileModeUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Mode actuel non reconnu : {code}'**
  String mobileModeUnknown(String code);

  /// No description provided for @mobileUsbLabel.
  ///
  /// In fr, this message translates to:
  /// **'Partager internet par câble USB'**
  String get mobileUsbLabel;

  /// No description provided for @mobileDetectSection.
  ///
  /// In fr, this message translates to:
  /// **'Détection de coupure'**
  String get mobileDetectSection;

  /// No description provided for @mobileDetectHint.
  ///
  /// In fr, this message translates to:
  /// **'Le modem vérifie la connexion internet en contactant ces adresses (IP ou nom, ex. 8.8.8.8 ou www.google.com).'**
  String get mobileDetectHint;

  /// No description provided for @mobileDetectLabel.
  ///
  /// In fr, this message translates to:
  /// **'Détection de coupure'**
  String get mobileDetectLabel;

  /// No description provided for @mobileDetectAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse {number}'**
  String mobileDetectAddress(int number);

  /// No description provided for @mobileDetectNeedAddress.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez au moins une adresse pour activer la détection.'**
  String get mobileDetectNeedAddress;

  /// No description provided for @outagesSummary.
  ///
  /// In fr, this message translates to:
  /// **'Résumé (hors coupures volontaires)'**
  String get outagesSummary;

  /// No description provided for @outagesLast24h.
  ///
  /// In fr, this message translates to:
  /// **'Dernières 24 heures'**
  String get outagesLast24h;

  /// No description provided for @outagesLast7d.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get outagesLast7d;

  /// No description provided for @outagesCountDuration.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} coupure} other{{count} coupures}} · {duration} au total'**
  String outagesCountDuration(int count, String duration);

  /// No description provided for @outagesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune coupure enregistrée.'**
  String get outagesEmpty;

  /// No description provided for @outagesOngoing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get outagesOngoing;

  /// No description provided for @outagesPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Volontaire'**
  String get outagesPlanned;

  /// No description provided for @outagesSince.
  ///
  /// In fr, this message translates to:
  /// **'Depuis {time}'**
  String outagesSince(String time);

  /// No description provided for @outagesFromTo.
  ///
  /// In fr, this message translates to:
  /// **'De {start} à {end}'**
  String outagesFromTo(String start, String end);

  /// No description provided for @outagesNote.
  ///
  /// In fr, this message translates to:
  /// **'Les coupures sont détectées en quelques secondes, appli ouverte ou avec la surveillance continue (environ toutes les 15 minutes sans elle). « Volontaire » = données coupées ou connexion relancée par l\'appli.'**
  String get outagesNote;

  /// No description provided for @outagesClearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer l\'historique'**
  String get outagesClearTitle;

  /// No description provided for @outagesClearMessage.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les coupures enregistrées seront supprimées.'**
  String get outagesClearMessage;

  /// No description provided for @outagesExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get outagesExport;

  /// No description provided for @outagesExported.
  ///
  /// In fr, this message translates to:
  /// **'Journal exporté.'**
  String get outagesExported;

  /// No description provided for @outagesExportCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Export annulé.'**
  String get outagesExportCancelled;

  /// No description provided for @outagesCsvStart.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get outagesCsvStart;

  /// No description provided for @outagesCsvEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get outagesCsvEnd;

  /// No description provided for @outagesCsvMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Durée (minutes)'**
  String get outagesCsvMinutes;

  /// No description provided for @outagesCsvPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Volontaire'**
  String get outagesCsvPlanned;

  /// No description provided for @outagesCsvOperator.
  ///
  /// In fr, this message translates to:
  /// **'Opérateur (MCC-MNC)'**
  String get outagesCsvOperator;

  /// No description provided for @signalLastHour.
  ///
  /// In fr, this message translates to:
  /// **'Dernière heure'**
  String get signalLastHour;

  /// No description provided for @signalLast24h.
  ///
  /// In fr, this message translates to:
  /// **'Dernières 24 h'**
  String get signalLast24h;

  /// No description provided for @signalEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de mesure sur cette période. Laissez l\'appli ouverte ou activez la vérification en arrière-plan.'**
  String get signalEmpty;

  /// No description provided for @signalStats.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get signalStats;

  /// No description provided for @signalCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get signalCurrent;

  /// No description provided for @signalAverage.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get signalAverage;

  /// No description provided for @signalBest.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur'**
  String get signalBest;

  /// No description provided for @signalWorst.
  ///
  /// In fr, this message translates to:
  /// **'Plus faible'**
  String get signalWorst;

  /// No description provided for @signalSamplesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} mesure} other{{count} mesures}}'**
  String signalSamplesCount(int count);

  /// No description provided for @signalHowItWorks.
  ///
  /// In fr, this message translates to:
  /// **'Plus la valeur est proche de 0, meilleur est le signal : 4 barres à partir de -95 dBm, aucune en dessous de -115 dBm. Un point toutes les 30 s, appli ouverte ou avec la surveillance continue (environ toutes les 15 min sans elle).'**
  String get signalHowItWorks;

  /// No description provided for @bestLocationInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Déplacez lentement le modem et attendez quelques secondes à chaque position.'**
  String get bestLocationInstructions;

  /// No description provided for @bestLocationUnit.
  ///
  /// In fr, this message translates to:
  /// **'dBm'**
  String get bestLocationUnit;

  /// No description provided for @bestLocationRecord.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur signal : {value}'**
  String bestLocationRecord(String value);

  /// No description provided for @bestLocationRecordAt.
  ///
  /// In fr, this message translates to:
  /// **'Atteint à {time}'**
  String bestLocationRecordAt(String time);

  /// No description provided for @bestLocationReset.
  ///
  /// In fr, this message translates to:
  /// **'Remettre à zéro'**
  String get bestLocationReset;

  /// No description provided for @bestLocationTips.
  ///
  /// In fr, this message translates to:
  /// **'Conseils : près d\'une fenêtre, en hauteur, loin des murs épais et des appareils métalliques. Le téléphone vibre à chaque nouveau record.'**
  String get bestLocationTips;

  /// No description provided for @speedTestSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du fichier de test'**
  String get speedTestSize;

  /// No description provided for @speedTestMegabytes.
  ///
  /// In fr, this message translates to:
  /// **'{size} Mo'**
  String speedTestMegabytes(int size);

  /// No description provided for @speedTestDataWarning.
  ///
  /// In fr, this message translates to:
  /// **'Le test consomme cette quantité de données sur le forfait de votre SIM.'**
  String get speedTestDataWarning;

  /// No description provided for @speedTestMbps.
  ///
  /// In fr, this message translates to:
  /// **'{value} Mb/s'**
  String speedTestMbps(String value);

  /// No description provided for @speedTestProgress.
  ///
  /// In fr, this message translates to:
  /// **'{received} Mo sur {total} Mo'**
  String speedTestProgress(String received, String total);

  /// No description provided for @speedTestDetails.
  ///
  /// In fr, this message translates to:
  /// **'{size} Mo téléchargés · latence {latency} ms'**
  String speedTestDetails(String size, String latency);

  /// No description provided for @speedTestStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le test'**
  String get speedTestStart;

  /// No description provided for @speedTestHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get speedTestHistory;

  /// No description provided for @speedTestEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun test pour le moment.'**
  String get speedTestEmpty;

  /// No description provided for @speedTestClearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer l\'historique'**
  String get speedTestClearTitle;

  /// No description provided for @speedTestClearMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tous les résultats de test seront supprimés.'**
  String get speedTestClearMessage;

  /// No description provided for @speedTestNoInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'accès à internet à travers le modem (données coupées ?).'**
  String get speedTestNoInternet;

  /// No description provided for @speedTestTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur de test ne répond pas assez vite.'**
  String get speedTestTimeout;

  /// No description provided for @speedTestServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur de test a renvoyé une erreur. Réessayez plus tard.'**
  String get speedTestServer;

  /// No description provided for @speedTestNotOnModemWifi.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone n\'est pas connecté au Wi-Fi du modem : le test mesurerait ses propres données mobiles. Connectez-le au Wi-Fi du modem puis réessayez.'**
  String get speedTestNotOnModemWifi;

  /// No description provided for @speedTestHow.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier est téléchargé depuis un serveur public à travers le modem ; le résultat dépend du réseau mobile, du signal et de l\'heure.'**
  String get speedTestHow;

  /// No description provided for @speedQualityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qualité du débit'**
  String get speedQualityTitle;

  /// No description provided for @speedQualityNone.
  ///
  /// In fr, this message translates to:
  /// **'Inexistant'**
  String get speedQualityNone;

  /// No description provided for @speedQualityPoor.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get speedQualityPoor;

  /// No description provided for @speedQualityFair.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get speedQualityFair;

  /// No description provided for @speedQualityGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get speedQualityGood;

  /// No description provided for @speedQualityExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get speedQualityExcellent;

  /// No description provided for @speedQualityNoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Internet passe à peine.'**
  String get speedQualityNoneHint;

  /// No description provided for @speedQualityPoorHint.
  ///
  /// In fr, this message translates to:
  /// **'Messages et navigation lente.'**
  String get speedQualityPoorHint;

  /// No description provided for @speedQualityFairHint.
  ///
  /// In fr, this message translates to:
  /// **'Navigation et vidéo en qualité standard.'**
  String get speedQualityFairHint;

  /// No description provided for @speedQualityGoodHint.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo HD et appels vidéo.'**
  String get speedQualityGoodHint;

  /// No description provided for @speedQualityExcellentHint.
  ///
  /// In fr, this message translates to:
  /// **'Tous les usages, même sur plusieurs appareils.'**
  String get speedQualityExcellentHint;

  /// No description provided for @speedQualityScale.
  ///
  /// In fr, this message translates to:
  /// **'Inexistant : moins de 0,5 Mb/s · Faible : moins de 2 · Moyen : moins de 8 · Bon : moins de 25 · Excellent : 25 Mb/s et plus.'**
  String get speedQualityScale;

  /// No description provided for @systemAccountSection.
  ///
  /// In fr, this message translates to:
  /// **'Compte administrateur'**
  String get systemAccountSection;

  /// No description provided for @systemChangePasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe de l\'interface d\'administration du modem'**
  String get systemChangePasswordHint;

  /// No description provided for @systemMaintenanceSection.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage et réinitialisation'**
  String get systemMaintenanceSection;

  /// No description provided for @systemRebootHint.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrer règle souvent les lenteurs. Les appareils sont déconnectés environ 1 minute.'**
  String get systemRebootHint;

  /// No description provided for @systemResetHint.
  ///
  /// In fr, this message translates to:
  /// **'La réinitialisation d\'usine efface tous les réglages du modem.'**
  String get systemResetHint;

  /// No description provided for @systemResetAction.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation d\'usine'**
  String get systemResetAction;

  /// No description provided for @systemResetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation d\'usine'**
  String get systemResetTitle;

  /// No description provided for @systemResetWarning.
  ///
  /// In fr, this message translates to:
  /// **'Tous les réglages du modem seront effacés. Le nom et le mot de passe du Wi-Fi, ainsi que le mot de passe administrateur, reviendront aux valeurs d\'usine indiquées sur l\'étiquette du modem. Il faudra reconnecter le téléphone au Wi-Fi d\'usine.\n\nConseil : faites d\'abord une sauvegarde de vos réglages.'**
  String get systemResetWarning;

  /// No description provided for @systemResetBackupFirst.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder d\'abord'**
  String get systemResetBackupFirst;

  /// No description provided for @systemResetSecond.
  ///
  /// In fr, this message translates to:
  /// **'Dernière confirmation : cette opération est irréversible.'**
  String get systemResetSecond;

  /// No description provided for @systemResetWord.
  ///
  /// In fr, this message translates to:
  /// **'RÉINITIALISER'**
  String get systemResetWord;

  /// No description provided for @systemResetDoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation lancée'**
  String get systemResetDoneTitle;

  /// No description provided for @systemResetDone.
  ///
  /// In fr, this message translates to:
  /// **'Le modem redémarre avec ses réglages d\'usine. Dans 1 à 2 minutes : connectez le téléphone au Wi-Fi d\'usine (étiquette du modem), puis reconnectez-vous avec le mot de passe d\'usine. Vous pourrez ensuite restaurer votre sauvegarde.'**
  String get systemResetDone;

  /// No description provided for @systemProduceSection.
  ///
  /// In fr, this message translates to:
  /// **'Informations de fabrication'**
  String get systemProduceSection;

  /// No description provided for @systemCalibration.
  ///
  /// In fr, this message translates to:
  /// **'Calibrage'**
  String get systemCalibration;

  /// No description provided for @systemCalibrated.
  ///
  /// In fr, this message translates to:
  /// **'Calibré'**
  String get systemCalibrated;

  /// No description provided for @systemNotCalibrated.
  ///
  /// In fr, this message translates to:
  /// **'Non calibré'**
  String get systemNotCalibrated;

  /// No description provided for @systemWifiTest.
  ///
  /// In fr, this message translates to:
  /// **'Test Wi-Fi'**
  String get systemWifiTest;

  /// No description provided for @systemWifiTested.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi testé'**
  String get systemWifiTested;

  /// No description provided for @systemWifiNotTested.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi non testé'**
  String get systemWifiNotTested;

  /// No description provided for @systemModemSection.
  ///
  /// In fr, this message translates to:
  /// **'Modem'**
  String get systemModemSection;

  /// No description provided for @systemSimSlots.
  ///
  /// In fr, this message translates to:
  /// **'Emplacements SIM'**
  String get systemSimSlots;

  /// No description provided for @systemWebLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'interface web'**
  String get systemWebLanguage;

  /// No description provided for @systemCopyright.
  ///
  /// In fr, this message translates to:
  /// **'Fabricant'**
  String get systemCopyright;

  /// No description provided for @systemToolsSection.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get systemToolsSection;

  /// No description provided for @systemPasswordIntro.
  ///
  /// In fr, this message translates to:
  /// **'Après le changement, l\'appli se reconnecte toute seule avec le nouveau mot de passe.'**
  String get systemPasswordIntro;

  /// No description provided for @systemOldPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get systemOldPassword;

  /// No description provided for @systemNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get systemNewPassword;

  /// No description provided for @systemConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get systemConfirmPassword;

  /// No description provided for @systemPasswordRules.
  ///
  /// In fr, this message translates to:
  /// **'4 à 32 caractères, sans espace ni accent'**
  String get systemPasswordRules;

  /// No description provided for @systemPasswordSame.
  ///
  /// In fr, this message translates to:
  /// **'Le nouveau mot de passe doit être différent de l\'actuel'**
  String get systemPasswordSame;

  /// No description provided for @systemPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe ne correspondent pas'**
  String get systemPasswordMismatch;

  /// No description provided for @systemPasswordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe administrateur changé.'**
  String get systemPasswordChanged;

  /// No description provided for @systemPasswordRefused.
  ///
  /// In fr, this message translates to:
  /// **'Le modem a refusé le changement : vérifiez le mot de passe actuel.'**
  String get systemPasswordRefused;

  /// No description provided for @wifiNetworkSection.
  ///
  /// In fr, this message translates to:
  /// **'Réseau Wi-Fi'**
  String get wifiNetworkSection;

  /// No description provided for @wifiSsidLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du réseau (SSID)'**
  String get wifiSsidLabel;

  /// No description provided for @wifiSsidTooLong.
  ///
  /// In fr, this message translates to:
  /// **'{max} caractères au maximum'**
  String wifiSsidTooLong(int max);

  /// No description provided for @wifiSecurityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get wifiSecurityLabel;

  /// No description provided for @wifiPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe Wi-Fi'**
  String get wifiPasswordLabel;

  /// No description provided for @wifiPasswordLength.
  ///
  /// In fr, this message translates to:
  /// **'De {min} à {max} caractères'**
  String wifiPasswordLength(int min, int max);

  /// No description provided for @wifiPasswordAscii.
  ///
  /// In fr, this message translates to:
  /// **'Lettres sans accents, chiffres et symboles courants uniquement'**
  String get wifiPasswordAscii;

  /// No description provided for @wifiOpenWarning.
  ///
  /// In fr, this message translates to:
  /// **'Réseau ouvert : n\'importe qui à proximité pourra se connecter sans mot de passe.'**
  String get wifiOpenWarning;

  /// No description provided for @wifiChannelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Canal'**
  String get wifiChannelLabel;

  /// No description provided for @wifiChannelValue.
  ///
  /// In fr, this message translates to:
  /// **'Canal {channel}'**
  String wifiChannelValue(String channel);

  /// No description provided for @wifiBroadcastLabel.
  ///
  /// In fr, this message translates to:
  /// **'Diffusion du nom (SSID)'**
  String get wifiBroadcastLabel;

  /// No description provided for @wifiBroadcastHiddenHint.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé : le réseau est invisible, il faut saisir son nom pour s\'y connecter'**
  String get wifiBroadcastHiddenHint;

  /// No description provided for @wifiSaveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les réglages Wi-Fi ?'**
  String get wifiSaveTitle;

  /// No description provided for @wifiSaveWarning.
  ///
  /// In fr, this message translates to:
  /// **'Le Wi-Fi du modem va redémarrer : tous les appareils, y compris ce téléphone, seront déconnectés quelques instants. Si vous changez le nom ou le mot de passe, reconnectez le téléphone au nouveau réseau.'**
  String get wifiSaveWarning;

  /// No description provided for @wifiReconnectMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le Wi-Fi redémarre. Reconnectez si besoin le téléphone au réseau « {ssid} ».'**
  String wifiReconnectMessage(String ssid);

  /// No description provided for @wifiShareSection.
  ///
  /// In fr, this message translates to:
  /// **'Partager le Wi-Fi'**
  String get wifiShareSection;

  /// No description provided for @wifiShareQr.
  ///
  /// In fr, this message translates to:
  /// **'Partager par QR code'**
  String get wifiShareQr;

  /// No description provided for @wifiShareQrHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos invités le scannent avec l\'appareil photo'**
  String get wifiShareQrHint;

  /// No description provided for @wifiShareMessage.
  ///
  /// In fr, this message translates to:
  /// **'Partager par message'**
  String get wifiShareMessage;

  /// No description provided for @wifiShareMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le nom et le mot de passe par WhatsApp, SMS…'**
  String get wifiShareMessageHint;

  /// No description provided for @wifiShareText.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi : {ssid}\nMot de passe : {password}'**
  String wifiShareText(String ssid, String password);

  /// No description provided for @wifiShareTextOpen.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi : {ssid} (sans mot de passe)'**
  String wifiShareTextOpen(String ssid);

  /// No description provided for @wifiExpelHint.
  ///
  /// In fr, this message translates to:
  /// **'Un appareil inconnu utilise votre Wi-Fi ? Changez le mot de passe en un geste et partagez le nouveau.'**
  String get wifiExpelHint;

  /// No description provided for @wifiApSection.
  ///
  /// In fr, this message translates to:
  /// **'Point d\'accès Wi-Fi'**
  String get wifiApSection;

  /// No description provided for @wifiApState.
  ///
  /// In fr, this message translates to:
  /// **'État du Wi-Fi'**
  String get wifiApState;

  /// No description provided for @wifiTurnOff.
  ///
  /// In fr, this message translates to:
  /// **'Couper le Wi-Fi'**
  String get wifiTurnOff;

  /// No description provided for @wifiTurnOn.
  ///
  /// In fr, this message translates to:
  /// **'Allumer le Wi-Fi'**
  String get wifiTurnOn;

  /// No description provided for @wifiTurnOffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Couper le Wi-Fi du modem ?'**
  String get wifiTurnOffTitle;

  /// No description provided for @wifiTurnOffWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention : ce téléphone perdra aussitôt la connexion avec le modem et l\'appli ne pourra PAS rallumer le Wi-Fi. Il faudra appuyer sur le bouton du modem ou le redémarrer.'**
  String get wifiTurnOffWarning;

  /// No description provided for @wifiTurnOffWord.
  ///
  /// In fr, this message translates to:
  /// **'COUPER'**
  String get wifiTurnOffWord;

  /// No description provided for @wifiTurnedOffInfo.
  ///
  /// In fr, this message translates to:
  /// **'Le Wi-Fi du modem est coupé. Pour le rallumer, appuyez sur le bouton du modem ou redémarrez-le, puis reconnectez le téléphone.'**
  String get wifiTurnedOffInfo;

  /// No description provided for @wifiQrInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ce code avec l\'appareil photo d\'un téléphone pour vous connecter au Wi-Fi.'**
  String get wifiQrInstructions;

  /// No description provided for @wifiQrHiddenNote.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du réseau est masqué : le code contient l\'information nécessaire pour s\'y connecter quand même.'**
  String get wifiQrHiddenNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
