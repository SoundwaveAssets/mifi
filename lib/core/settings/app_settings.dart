import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/modem_address.dart';

/// Réglages de l'appli (hors mot de passe, voir `CredentialsStore`),
/// mémorisés dans les préférences partagées.
class AppSettings extends ChangeNotifier {
  AppSettings(this._prefs);

  /// Charge les réglages (premier plan comme arrière-plan).
  static Future<AppSettings> load() async => AppSettings(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _kModemAddress = 'modem_address';
  static const _kLanguage = 'language_code';
  static const _kApplyLanguageToModem = 'apply_language_to_modem';
  static const _kThemeMode = 'theme_mode';
  static const _kNotifications = 'notifications_enabled';
  static const _kMonitor = 'monitor_enabled';
  static const _kMonitorAsked = 'monitor_permission_asked';
  static const _kNotifyInternetDown = 'notify_internet_down';
  static const _kNotifyInternetUp = 'notify_internet_up';
  static const _kNotifyLowSignal = 'notify_low_signal';
  static const _kNotifyNewDevice = 'notify_new_device';
  static const _kBackgroundChecks = 'background_checks_enabled';
  static const _kSpeedTestSize = 'speed_test_size_mb';
  static const _kPermissionAsked = 'notification_permission_asked';
  static const _kAutoRepair = 'auto_repair_enabled';
  static const _kRebootEnabled = 'reboot_schedule_enabled';
  static const _kRebootTime = 'reboot_schedule_time';
  static const _kAppLock = 'app_lock_enabled';

  /// Langues proposées par l'appli (codes ISO 639-1).
  static const List<String> supportedLanguages = ['fr', 'en'];

  /// Tailles proposées pour le test de débit (Mo).
  static const List<int> speedTestSizes = [5, 10, 25];

  // ------------------------------------------------------------------ Modem

  /// Adresse normalisée du modem (`192.168.100.1` par défaut).
  String get modemAddress => _prefs.getString(_kModemAddress) ?? ModemAddress.defaultAddress;

  Uri get modemBaseUri => ModemAddress.toBaseUri(modemAddress);

  /// Enregistre une adresse déjà normalisée (`ModemAddress.normalize`).
  Future<void> setModemAddress(String address) => _setString(_kModemAddress, address);

  // ----------------------------------------------------------------- Langue

  /// Code de langue choisi, `null` = langue du téléphone.
  String? get languageCode {
    final code = _prefs.getString(_kLanguage);
    return supportedLanguages.contains(code) ? code : null;
  }

  /// Locale imposée à l'appli, `null` = langue du téléphone.
  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  Future<void> setLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_kLanguage);
      notifyListeners();
    } else {
      await _setString(_kLanguage, code);
    }
  }

  /// « Appliquer aussi à l'interface web du modem » (`selectlang`).
  bool get applyLanguageToModem => _prefs.getBool(_kApplyLanguageToModem) ?? false;
  Future<void> setApplyLanguageToModem(bool value) => _setBool(_kApplyLanguageToModem, value);

  // ------------------------------------------------------------------ Thème

  ThemeMode get themeMode => switch (_prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) => _setString(_kThemeMode, mode.name);

  // --------------------------------------------------------- Notifications

  /// Interrupteur général des notifications.
  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool value) => _setBool(_kNotifications, value);

  bool get notifyInternetDown => _prefs.getBool(_kNotifyInternetDown) ?? true;
  Future<void> setNotifyInternetDown(bool value) => _setBool(_kNotifyInternetDown, value);

  bool get notifyInternetUp => _prefs.getBool(_kNotifyInternetUp) ?? true;
  Future<void> setNotifyInternetUp(bool value) => _setBool(_kNotifyInternetUp, value);

  bool get notifyLowSignal => _prefs.getBool(_kNotifyLowSignal) ?? true;
  Future<void> setNotifyLowSignal(bool value) => _setBool(_kNotifyLowSignal, value);

  bool get notifyNewDevice => _prefs.getBool(_kNotifyNewDevice) ?? true;
  Future<void> setNotifyNewDevice(bool value) => _setBool(_kNotifyNewDevice, value);

  /// Vérification périodique en arrière-plan (WorkManager, ~15 min) :
  /// notifications, journal des coupures et historique du signal.
  bool get backgroundChecksEnabled => _prefs.getBool(_kBackgroundChecks) ?? true;
  Future<void> setBackgroundChecksEnabled(bool value) => _setBool(_kBackgroundChecks, value);

  /// La demande d'autorisation des notifications (Android 13+) a été faite.
  bool get notificationPermissionAsked => _prefs.getBool(_kPermissionAsked) ?? false;
  Future<void> setNotificationPermissionAsked(bool value) => _setBool(_kPermissionAsked, value);

  /// Surveillance continue appli fermée (service Android au premier plan),
  /// activée avec l'accord de l'utilisateur.
  bool get monitorEnabled => _prefs.getBool(_kMonitor) ?? false;
  Future<void> setMonitorEnabled(bool value) => _setBool(_kMonitor, value);

  /// L'autorisation de fonctionner en arrière-plan a été demandée une fois.
  bool get monitorPermissionAsked => _prefs.getBool(_kMonitorAsked) ?? false;
  Future<void> setMonitorPermissionAsked(bool value) => _setBool(_kMonitorAsked, value);

  /// Relit les réglages modifiés par un autre moteur Flutter (l'interface,
  /// pour la surveillance continue).
  Future<void> reload() async {
    await _prefs.reload();
    notifyListeners();
  }

  // ------------------------------------------------ Réparation automatique

  /// Relancer seul la connexion quand internet est coupé alors que le
  /// signal est bon. Désactivée tant que l'utilisateur ne l'a pas choisie :
  /// elle change le profil APN du modem.
  bool get autoRepairEnabled => _prefs.getBool(_kAutoRepair) ?? false;
  Future<void> setAutoRepairEnabled(bool value) => _setBool(_kAutoRepair, value);

  // ------------------------------------------------ Redémarrage programmé

  bool get rebootScheduleEnabled => _prefs.getBool(_kRebootEnabled) ?? false;
  Future<void> setRebootScheduleEnabled(bool value) => _setBool(_kRebootEnabled, value);

  /// Heure du redémarrage quotidien, en minutes depuis minuit (4 h par défaut).
  int get rebootScheduleMinutes => _prefs.getInt(_kRebootTime) ?? 4 * 60;

  Future<void> setRebootScheduleMinutes(int minutes) async {
    await _prefs.setInt(_kRebootTime, minutes % (24 * 60));
    notifyListeners();
  }

  // ------------------------------------------------------------ Verrouillage

  /// Demander l'empreinte (ou le code du téléphone) à l'ouverture de l'appli.
  bool get appLockEnabled => _prefs.getBool(_kAppLock) ?? false;
  Future<void> setAppLockEnabled(bool value) => _setBool(_kAppLock, value);

  // ---------------------------------------------------------- Test de débit

  /// Taille du fichier de test (Mo).
  int get speedTestSizeMb {
    final value = _prefs.getInt(_kSpeedTestSize);
    return speedTestSizes.contains(value) ? value! : 10;
  }

  Future<void> setSpeedTestSizeMb(int value) async {
    await _prefs.setInt(_kSpeedTestSize, value);
    notifyListeners();
  }

  // ----------------------------------------------------------------- Outils

  Future<void> _setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    notifyListeners();
  }

  Future<void> _setString(String key, String value) async {
    await _prefs.setString(key, value);
    notifyListeners();
  }
}
