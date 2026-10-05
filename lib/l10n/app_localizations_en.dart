// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MiFi';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOk => 'OK';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied to clipboard';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSaved => 'Settings saved';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonNotDefined => 'Not set';

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String get commonRequiredField => 'Required field';

  @override
  String get commonInvalidIpv4 => 'Invalid IPv4 address (e.g. 192.168.100.1)';

  @override
  String get commonInvalidHost => 'Invalid IP address or host name';

  @override
  String get commonTypeLabel => 'Type';

  @override
  String get commonProxyLabel => 'Proxy';

  @override
  String commonUpdatedAt(String time) {
    return 'Updated at $time';
  }

  @override
  String get commonDataStale => 'Data not up to date';

  @override
  String get commonWarning => 'Warning';

  @override
  String commonTypeToConfirm(String word) {
    return 'To confirm, type “$word”';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '$count device',
    );
    return '$_temp0';
  }

  @override
  String get deviceTypeWifi => 'Wi-Fi';

  @override
  String get deviceTypeWired => 'Wired';

  @override
  String get deviceTypeUnknown => 'Unknown';

  @override
  String get unnamedDevice => 'Unnamed device';

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
    return '$days d $hours h $minutes min';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navDevices => 'Devices';

  @override
  String get navSettings => 'Settings';

  @override
  String get splashConnecting => 'Connecting to the modem…';

  @override
  String errorUnreachable(String address) {
    return 'Cannot reach the modem ($address). Make sure the phone is connected to the modem\'s Wi-Fi.';
  }

  @override
  String get errorTimeout => 'The modem is not responding (timeout).';

  @override
  String get errorLoginFailed => 'Password rejected by the modem.';

  @override
  String get errorSessionExpired => 'Session expired. Please sign in again.';

  @override
  String errorCommandFailed(String reply) {
    return 'The modem rejected the operation (reply: $reply).';
  }

  @override
  String get errorUnsupported =>
      'This feature is not supported by the modem firmware.';

  @override
  String get errorInvalidResponse => 'Unexpected response from the modem.';

  @override
  String get errorCancelled => 'Operation cancelled.';

  @override
  String errorUnexpected(String details) {
    return 'Unexpected error: $details';
  }

  @override
  String get hintWifiDisconnected =>
      'The phone is not connected to any Wi-Fi network.';

  @override
  String hintWrongWifi(String gateway, String address) {
    return 'The current Wi-Fi (gateway $gateway) does not look like the modem\'s network ($address).';
  }

  @override
  String get hintNoInternetIsOk =>
      'Android may flag the modem\'s Wi-Fi as “no internet”: the app still uses it.';

  @override
  String get restartTitle => 'Reconnecting to the modem';

  @override
  String get restartWaiting => 'Please wait while the modem restarts…';

  @override
  String restartElapsed(String elapsed) {
    return 'Elapsed time: $elapsed';
  }

  @override
  String get restartHint =>
      'If needed, reconnect the phone to the modem\'s Wi-Fi.';

  @override
  String get restartSuccess => 'The modem is reachable again.';

  @override
  String get restartTimeout =>
      'The modem is still not responding. Check the Wi-Fi connection and try again.';

  @override
  String get restartStopWaiting => 'Stop waiting';

  @override
  String get airplaneTitle => 'Airplane mode';

  @override
  String get airplaneStateOn => 'On';

  @override
  String get airplaneStateOff => 'Off';

  @override
  String get airplaneStateSwitching => 'Switching…';

  @override
  String get airplaneStateUnknown => 'Unknown state';

  @override
  String get airplaneStateError => 'Switch failed';

  @override
  String get airplaneExplanation =>
      'Cuts the internet on the active SIM, in a few seconds and without changing SIM. The modem\'s Wi-Fi stays on. The app checks the cut and warns you if it doesn\'t hold.';

  @override
  String get notifChannelAlerts => 'Connection alerts';

  @override
  String get notifChannelAlertsDescription =>
      'Internet lost and restored, weak signal';

  @override
  String get notifChannelDevices => 'New devices';

  @override
  String get notifChannelDevicesDescription =>
      'An unknown device joins the modem\'s Wi-Fi';

  @override
  String get notifChannelAirplane => 'Mobile data and schedules';

  @override
  String get notifChannelAirplaneDescription =>
      'Result of mobile data changes and of the scheduled restart';

  @override
  String get notifInternetDownTitle => 'Internet lost';

  @override
  String get notifInternetDownBody => 'The modem lost its internet connection.';

  @override
  String get notifInternetUpTitle => 'Internet restored';

  @override
  String notifInternetUpBody(String duration) {
    return 'The connection came back after $duration.';
  }

  @override
  String get notifLowSignalTitle => 'Weak signal';

  @override
  String notifLowSignalBody(int dbm) {
    return 'Weak mobile signal: $dbm dBm.';
  }

  @override
  String get notifNewDeviceTitle => 'New device connected';

  @override
  String notifNewDeviceBody(String name, String mac) {
    return '$name ($mac) just connected.';
  }

  @override
  String get notifScheduleFailedTitle => 'Scheduled airplane mode failed';

  @override
  String get notifScheduleFailedBody =>
      'Cannot reach the modem. The phone must be connected to the modem\'s Wi-Fi at the scheduled time.';

  @override
  String get notifAirplaneFailedTitle => 'Airplane mode failed';

  @override
  String get notifAirplaneFailedBody =>
      'Cannot reach the modem. Check the phone\'s Wi-Fi connection.';

  @override
  String get notifToggleRefusedBody =>
      'The modem refused the change. Try again from the app.';

  @override
  String get notifToggleLoginFailedBody =>
      'Sign-in to the modem refused: wrong or missing password. Sign in again in the app.';

  @override
  String get operatorUnknown => 'Unknown operator';

  @override
  String operatorCode(String code) {
    return 'Operator $code';
  }

  @override
  String get noSim => 'No SIM';

  @override
  String get mobileDataTitle => 'Mobile data';

  @override
  String get mobileDataStateOn => 'On';

  @override
  String get mobileDataStateOff => 'Off';

  @override
  String get mobileDataAirplaneOn => 'Off (airplane mode)';

  @override
  String get mobileDataSwitching => 'Switching…';

  @override
  String get mobileDataSwitchFailed =>
      'The modem did not apply the mobile data change.';

  @override
  String get dataCutFailed => 'The modem did not apply the change. Try again.';

  @override
  String get dataCutNotHoldingTitle => 'The internet cut isn\'t holding';

  @override
  String get dataCutNotHoldingShort => 'Cut not holding';

  @override
  String get dataCutProfileLost =>
      'The modem keeps switching back to its usual APN profile, so the internet comes back. The app re-applied the cut several times, then stopped. Turn it off and on again to retry.';

  @override
  String get dataCutInternetStillUp =>
      'The blocking profile is active but the internet still works: your carrier seems to accept any APN. With this SIM, the app can\'t cut the internet this way.';

  @override
  String get mobileDataExplanation =>
      'Cuts the internet while keeping the SIM on the network (the signal stays visible). Wi-Fi stays on.';

  @override
  String get simChangedTitle => 'New SIM detected';

  @override
  String simChangedBody(String operator) {
    return 'New SIM detected: $operator. If the internet does not work, check the APN settings.';
  }

  @override
  String get simChangedOpenApn => 'APN settings';

  @override
  String get simChangedLater => 'Later';

  @override
  String get expelTitle => 'Kick out intruders';

  @override
  String get lockTitle => 'MiFi is locked';

  @override
  String get lockReason => 'Unlock to access the modem settings';

  @override
  String get lockFailed => 'Unlock failed. Try again.';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get widgetInternetOn => 'Internet connected';

  @override
  String get widgetInternetOff => 'Internet down';

  @override
  String get notifAutoRepairTitle => 'Automatic repair';

  @override
  String get notifAutoRepairStarted =>
      'The internet is down despite a good signal: restarting the connection…';

  @override
  String get notifAutoRepairSucceeded =>
      'The internet was restored automatically.';

  @override
  String get notifAutoRepairFailed =>
      'The automatic restart did not restore the internet. Try restarting the modem.';

  @override
  String get notifRebootFailedTitle => 'Scheduled restart failed';

  @override
  String get notifRebootFailedBody =>
      'Cannot reach the modem at the scheduled time. The phone must be connected to the modem\'s Wi-Fi.';

  @override
  String get notifMobileDataFailedTitle => 'Mobile data failed';

  @override
  String signalDbm(int dbm) {
    return '$dbm dBm';
  }

  @override
  String get signalQualityNone => 'None';

  @override
  String get signalQualityPoor => 'Weak';

  @override
  String get signalQualityFair => 'Fair';

  @override
  String get signalQualityGood => 'Good';

  @override
  String get signalQualityExcellent => 'Excellent';

  @override
  String get wifiAuthNone => 'None (open network)';

  @override
  String get wifiAuthWpaPsk => 'WPA-PSK';

  @override
  String get wifiAuthWpa2Psk => 'WPA2-PSK';

  @override
  String get networkModeAuto => '4G/3G (automatic)';

  @override
  String get networkMode4gOnly => '4G only';

  @override
  String get networkMode3gOnly => '3G only';

  @override
  String get apnAuthNone => 'None';

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
  String get languageSystem => 'Phone language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get hubSectionModem => 'Modem';

  @override
  String get hubSectionTools => 'Tools';

  @override
  String get hubSectionApp => 'App';

  @override
  String get hubWifiTitle => 'Wi-Fi';

  @override
  String get hubWifiSubtitle =>
      'Network name, password, channel, QR code sharing';

  @override
  String get hubMobileTitle => 'Mobile network';

  @override
  String get hubMobileSubtitle =>
      'SIM, APN, network mode, USB sharing, outage detection';

  @override
  String get hubDhcpTitle => 'Local network (DHCP)';

  @override
  String get hubDhcpSubtitle => 'Modem address and address range';

  @override
  String get hubSystemTitle => 'System';

  @override
  String get hubSystemSubtitle =>
      'Password, restart, factory reset, information';

  @override
  String get hubSignalTitle => 'Signal history';

  @override
  String get hubSignalSubtitle => 'Chart and best-location finder';

  @override
  String get hubOutagesTitle => 'Outage log';

  @override
  String get hubOutagesSubtitle => 'History of internet connection losses';

  @override
  String get hubSpeedTestTitle => 'Speed test';

  @override
  String get hubSpeedTestSubtitle => 'Measure the download speed';

  @override
  String get hubBackupTitle => 'Backup and restore';

  @override
  String get hubBackupSubtitle => 'Export and re-apply the modem settings';

  @override
  String get hubFirmwareTitle => 'Firmware update';

  @override
  String get hubFirmwareSubtitle => 'Advanced: use with care';

  @override
  String get hubAppSettingsTitle => 'App settings';

  @override
  String get hubAppSettingsSubtitle =>
      'Language, theme, notifications, modem address';

  @override
  String get appSettingsLanguage => 'Language';

  @override
  String get appSettingsApplyToModem =>
      'Also apply to the modem\'s web interface';

  @override
  String get appSettingsApplyToModemHint =>
      'Also changes the language of the modem\'s original web page (accepted languages: en, fr, pl, ru, tk, zh).';

  @override
  String get appSettingsSendNow => 'Send the language to the modem now';

  @override
  String get appSettingsLanguageSent => 'Language sent to the modem.';

  @override
  String get appSettingsLanguageNotSent =>
      'The modem did not accept the language change.';

  @override
  String get appSettingsTheme => 'Theme';

  @override
  String get appSettingsThemeAuto => 'Automatic';

  @override
  String get appSettingsThemeLight => 'Light';

  @override
  String get appSettingsThemeDark => 'Dark';

  @override
  String get appSettingsNotifications => 'Notifications';

  @override
  String get appSettingsNotificationsBlocked =>
      'MiFi notifications are blocked by Android.';

  @override
  String get appSettingsAllow => 'Allow';

  @override
  String get appSettingsNotificationsAll => 'Enable notifications';

  @override
  String get appSettingsNotifyDown => 'Internet lost';

  @override
  String get appSettingsNotifyUp => 'Internet restored';

  @override
  String get appSettingsNotifyLowSignal => 'Weak signal';

  @override
  String get appSettingsNotifyNewDevice => 'New device connected';

  @override
  String get appSettingsBackground => 'Background check';

  @override
  String get appSettingsBackgroundHint =>
      'Backup check about every 15 minutes (Android limit), while the phone is connected to the modem\'s Wi-Fi; it also restarts continuous monitoring if Android stopped it.';

  @override
  String get appSettingsMonitor => 'Continuous monitoring';

  @override
  String get appSettingsMonitorHint =>
      'Alerts you as soon as the internet stops working, even when the app is closed (discreet “Monitoring active” notification). Readings are spaced out while all is well, to save battery.';

  @override
  String get appSettingsMonitorRestricted =>
      'Android still restricts the app in the background: monitoring may be interrupted. Allow it to run without restrictions.';

  @override
  String get monitorPermissionTitle => 'Connection monitoring';

  @override
  String get monitorPermissionMessage =>
      'To alert you as soon as the internet stops working, even when the app is closed, MiFi must be able to run in the background. Android will ask you for two permissions (notifications and background): accept them. Monitoring uses very little battery and shows a discreet “Monitoring active” notification.';

  @override
  String get monitorPermissionAllow => 'Allow';

  @override
  String get appSettingsAutomation => 'Automation';

  @override
  String get appSettingsAutoRepair => 'Automatic repair';

  @override
  String get appSettingsAutoRepairHint =>
      'If the internet has been down for 3 minutes while the signal is good, the app restarts the connection (at most once every 30 minutes).';

  @override
  String get appSettingsSchedule => 'Scheduled airplane mode';

  @override
  String get appSettingsScheduleHint =>
      'Cuts the mobile network every day during the chosen range.';

  @override
  String get appSettingsFrom => 'From';

  @override
  String get appSettingsTo => 'To';

  @override
  String get appSettingsScheduleSame => 'Start and end must be different.';

  @override
  String appSettingsScheduleNext(String start, String end) {
    return 'Next cut: $start · ends: $end';
  }

  @override
  String get appSettingsReboot => 'Scheduled modem restart';

  @override
  String get appSettingsRebootHint =>
      'Restarts the modem every day at the chosen time.';

  @override
  String get appSettingsRebootTime => 'Restart time';

  @override
  String appSettingsRebootNext(String time) {
    return 'Next restart: $time';
  }

  @override
  String get appSettingsAutomationNote =>
      'At the scheduled time, the phone must be connected to the modem\'s Wi-Fi; otherwise a failure notification is shown. Android may shift the time by a few minutes.';

  @override
  String get appSettingsReliabilityHint =>
      'For schedules and monitoring to work while the app is closed on a Xiaomi phone, allow autostart and choose “No restrictions” in the app\'s battery saver.';

  @override
  String get appSettingsExactAlarmsMissing =>
      'Exact alarms aren\'t allowed: Android may delay schedules by several minutes or more.';

  @override
  String get appSettingsExactAlarmsAllow => 'Allow';

  @override
  String get appSettingsAutostart => 'Autostart';

  @override
  String get appSettingsBattery => 'Battery saver';

  @override
  String get appSettingsSecurity => 'Security';

  @override
  String get appSettingsLock => 'Lock the app';

  @override
  String get appSettingsLockHint =>
      'Asks for the fingerprint or the phone\'s code when MiFi opens.';

  @override
  String get appSettingsLockUnsupported =>
      'No fingerprint or code is set up on this phone.';

  @override
  String get appSettingsAddressConfirmTitle => 'Change the modem address?';

  @override
  String appSettingsAddressConfirm(String address) {
    return 'The app will now contact the modem at $address.';
  }

  @override
  String get appSettingsAbout => 'About';

  @override
  String get appSettingsAboutText =>
      'MiFi controls your HiMILink 4G modem from your phone, with any SIM. The app only works while connected to the modem\'s Wi-Fi.';

  @override
  String get backupExportSection => 'Back up';

  @override
  String get backupExportHint =>
      'Saves the Wi-Fi, APN, DHCP, network mode and outage detection settings to a file.';

  @override
  String get backupPrivacy =>
      'The admin password is never exported. The file does contain the Wi-Fi password: keep it safe.';

  @override
  String get backupExport => 'Export the settings';

  @override
  String get backupExported => 'Backup saved.';

  @override
  String get backupExportCancelled => 'Export cancelled.';

  @override
  String get backupImportSection => 'Restore';

  @override
  String get backupImportHint =>
      'Re-apply a backup, for example after a factory reset.';

  @override
  String get backupChooseFile => 'Choose a backup file';

  @override
  String get backupFileLabel => 'MiFi backup (.json)';

  @override
  String get backupInvalidFile => 'This file is not a valid MiFi backup.';

  @override
  String backupFileDate(String date) {
    return 'Backup from $date';
  }

  @override
  String get backupOrderNote =>
      'Order: network mode, detection, APN, then DHCP (the modem restarts) and finally Wi-Fi (the phone will have to reconnect).';

  @override
  String get backupRestore => 'Restore the selection';

  @override
  String get backupRestoreTitle => 'Restore these settings?';

  @override
  String get backupRestoreWarning =>
      'The chosen settings will replace the modem\'s. DHCP restarts the modem, and changing the Wi-Fi disconnects all devices.';

  @override
  String get backupRestored => 'Settings restored.';

  @override
  String get backupWifiAppliedTitle => 'Wi-Fi restored';

  @override
  String backupWifiApplied(String ssid) {
    return 'The “$ssid” Wi-Fi has been applied: reconnect the phone to this network.';
  }

  @override
  String get compareHubSubtitle => 'Signal, speed and outages by SIM used';

  @override
  String get compareIntro =>
      'Readings from the last 7 days, ranked by average signal. They are attributed to the operator of the SIM in use at the time.';

  @override
  String get compareEmpty =>
      'Not enough readings yet. Use the app for a few days with your different SIMs, and run speed tests.';

  @override
  String get compareSignal => 'Average signal';

  @override
  String get compareSpeed => 'Average speed';

  @override
  String get compareOutages => 'Outages';

  @override
  String compareBestSpeed(String value) {
    return 'Best speed: $value';
  }

  @override
  String compareLastUsed(String time) {
    return 'Last used: $time';
  }

  @override
  String get dashboardWifiOn => 'Wi-Fi on';

  @override
  String get dashboardWifiOff => 'Wi-Fi off';

  @override
  String get dashboardSimOk => 'SIM present';

  @override
  String get dashboardLanguage => 'Language';

  @override
  String get dashboardAdmin => 'Administrator';

  @override
  String get dashboardChangePassword => 'Change password';

  @override
  String get dashboardLogout => 'Sign out';

  @override
  String get dashboardLogoutConfirm =>
      'You will be signed out of the modem and the saved password will be forgotten.';

  @override
  String dashboardWanIp(String ip) {
    return 'WAN IP $ip';
  }

  @override
  String get dashboardSignalHistory => 'History';

  @override
  String get dashboardBestLocation => 'Best location';

  @override
  String get dashboardUsbTitle => 'USB sharing';

  @override
  String get dashboardTurnOn => 'Turn on';

  @override
  String get dashboardTurnOff => 'Turn off';

  @override
  String get dashboardAirplaneConfirmTitle => 'Turn on airplane mode?';

  @override
  String get airplaneDisableConfirmTitle => 'Turn off airplane mode?';

  @override
  String get airplaneDisableConfirmMessage =>
      'The internet will be restored with your usual APN profile.';

  @override
  String get airplaneDisableConfirmAction => 'Turn off';

  @override
  String get dashboardMobileDataConfirmTitle => 'Turn off mobile data?';

  @override
  String get dashboardMobileDataHow =>
      'To do so, the app activates a blocking APN profile (“MiFi-OFF”); turning data back on restores your usual profile. To be confirmed on your modem.';

  @override
  String get dashboardAirplaneWaiting =>
      'Turning airplane mode on… Wi-Fi stays on.';

  @override
  String get dashboardAirplaneWaitingOff => 'Turning airplane mode off…';

  @override
  String get dashboardMobileDataWaiting => 'Changing mobile data…';

  @override
  String get dashboardTogglesInfo => 'How does it work?';

  @override
  String get dashboardTogglesInfoTitle => 'Mobile data and airplane mode';

  @override
  String get dashboardReconnectTitle => 'Restart the connection';

  @override
  String get dashboardReconnectHint =>
      'No internet? Restart the connection: faster than restarting the modem.';

  @override
  String get dashboardInternetUnknown => 'Internet status unknown';

  @override
  String get dashboardInternetLostTitle => 'The internet is down';

  @override
  String get dashboardInternetLostMessage =>
      'The modem has lost internet access. Restart the connection to bring it back.';

  @override
  String get dashboardReconnectAction => 'Restart the connection';

  @override
  String get dashboardReconnectConfirm =>
      'The app cuts the modem\'s connection, like airplane mode (it registers on the network again), then restores it. It tries again until the internet is back or until you tap “Stop”. Wi-Fi stays on.';

  @override
  String get dashboardReconnectStepCut => 'Cutting the connection';

  @override
  String get dashboardReconnectStepRestore => 'Restoring the connection';

  @override
  String get dashboardReconnectStepReregister =>
      'Modem registering on the network again';

  @override
  String dashboardReconnectAttempt(int attempt) {
    return 'Attempt $attempt';
  }

  @override
  String dashboardReconnectElapsed(String time) {
    return 'Elapsed: $time';
  }

  @override
  String get dashboardReconnectStop => 'Stop';

  @override
  String get dashboardReconnectStopping => 'Stopping after this attempt…';

  @override
  String get dashboardReconnectStopped => 'Reconnection stopped.';

  @override
  String dashboardReconnectSuccessAfter(int attempt) {
    return 'Connection restarted: the internet came back on attempt $attempt.';
  }

  @override
  String get dashboardReconnectStepInternet => 'Waiting for the internet';

  @override
  String get dashboardReconnectSuccess =>
      'Connection restarted: the internet is back.';

  @override
  String get dashboardReconnectNoInternet =>
      'The network is back but the internet is not responding yet. Try again or restart the modem.';

  @override
  String get dashboardRebootTitle => 'Restart the modem?';

  @override
  String get dashboardRebootConfirm =>
      'The modem will restart (about 1 minute). All devices will be disconnected meanwhile.';

  @override
  String get dashboardRebootAction => 'Restart the modem';

  @override
  String get dashboardSeeAll => 'View';

  @override
  String dashboardDevicesSplit(int wifi, int wired) {
    return 'Wi-Fi: $wifi · Wired: $wired';
  }

  @override
  String get dashboardModemSection => 'Modem';

  @override
  String get dashboardUptime => 'Uptime';

  @override
  String get dashboardCpuTemp => 'CPU temperature';

  @override
  String dashboardTemperature(String value) {
    return '$value °C';
  }

  @override
  String get dashboardSystemTime => 'Modem time';

  @override
  String get dashboardBsid => 'Base station (BS ID)';

  @override
  String get dashboardCellId => 'Cell (Cell ID)';

  @override
  String get dashboardSoftwareVersion => 'Software version';

  @override
  String get dashboardHardwareVersion => 'Hardware version';

  @override
  String get dashboardWebVersion => 'Web interface version';

  @override
  String get dashboardImei => 'IMEI';

  @override
  String get dashboardIccid => 'ICCID';

  @override
  String get dashboardImsi => 'IMSI';

  @override
  String get dashboardSsid => 'Wi-Fi name';

  @override
  String get dashboardShortcuts => 'Shortcuts';

  @override
  String get dashboardCompareOperators => 'Operator comparison';

  @override
  String get devicesConnected => 'Connected now';

  @override
  String get devicesNoneConnected => 'No device connected at the moment.';

  @override
  String get devicesSeenBefore => 'Seen before (disconnected)';

  @override
  String get devicesNewBadge => 'New';

  @override
  String get devicesRename => 'Give a nickname';

  @override
  String get devicesRenameTitle => 'Device nickname';

  @override
  String get devicesNickname => 'Nickname';

  @override
  String get devicesNicknameHint =>
      'Stored in the app; leave empty to clear it';

  @override
  String get devicesIp => 'IP address';

  @override
  String get devicesMac => 'MAC address';

  @override
  String get devicesAnnouncedName => 'Name announced by the device';

  @override
  String get devicesFirstSeen => 'First seen';

  @override
  String get devicesLastSeen => 'Last seen';

  @override
  String devicesLastSeenShort(String time) {
    return 'seen $time';
  }

  @override
  String get devicesNoBlockingNote =>
      'The modem cannot block a device: use “Kick out intruders” to change the Wi-Fi password.';

  @override
  String get dhcpWarning =>
      'Saving these settings restarts the modem (about 1 minute) and its address may change. All devices will be disconnected meanwhile.';

  @override
  String get dhcpModemSection => 'Modem address';

  @override
  String get dhcpGateway => 'Modem IP address (gateway)';

  @override
  String get dhcpNetmask => 'Subnet mask';

  @override
  String get dhcpServerSection => 'DHCP server';

  @override
  String get dhcpServer => 'DHCP server';

  @override
  String get dhcpReadOnly => 'Read-only (as in the original interface)';

  @override
  String get dhcpPoolStart => 'Range start';

  @override
  String get dhcpPoolEnd => 'Range end';

  @override
  String get dhcpLease => 'Lease time';

  @override
  String get dhcpHours => 'hours';

  @override
  String dhcpSummary(String network, int prefix, int count) {
    return 'Network $network/$prefix · $count assignable addresses';
  }

  @override
  String get dhcpErrorNetmask => 'Invalid mask (e.g. 255.255.255.0)';

  @override
  String get dhcpErrorReserved => 'Reserved address (network or broadcast)';

  @override
  String get dhcpErrorSubnet => 'Outside the modem\'s subnet';

  @override
  String get dhcpErrorOrder => 'The end must come after the start';

  @override
  String get dhcpErrorGatewayInPool =>
      'The modem address must not be in the range';

  @override
  String dhcpErrorLease(int max) {
    return 'Number of hours between 1 and $max';
  }

  @override
  String get dhcpSaveTitle => 'Save and restart?';

  @override
  String get dhcpSaveWarning =>
      'The modem will restart (about 1 minute). The phone may need to reconnect to the Wi-Fi.';

  @override
  String dhcpNewAddress(String address) {
    return 'The modem address becomes $address: the app will use it automatically.';
  }

  @override
  String get dhcpNotBack =>
      'The modem is not responding yet. Check the phone\'s Wi-Fi; the modem address can also be changed in Settings › App settings.';

  @override
  String get expelIntro =>
      'The modem cannot block a specific device. To get rid of an intruder, the app changes the Wi-Fi password: only those who know the new one can reconnect.';

  @override
  String get expelWarning =>
      'All devices, including this phone, will be disconnected. Reconnect with the new password.';

  @override
  String get expelHideSsid => 'Also hide the Wi-Fi name';

  @override
  String get expelHideSsidHint =>
      'The network becomes invisible to neighbours; its name will have to be typed to connect.';

  @override
  String get expelApply => 'Generate a new password and apply it';

  @override
  String get expelDone =>
      'New password applied. Scan this code with your devices to reconnect them.';

  @override
  String get expelNetwork => 'Wi-Fi network';

  @override
  String get expelNewPassword => 'New password';

  @override
  String get expelHiddenNote =>
      'The network name is hidden: it no longer appears in the Wi-Fi list.';

  @override
  String get expelReconnectPhone => 'Reconnect this phone';

  @override
  String get expelWaiting => 'Waiting for the phone to reconnect to the Wi-Fi…';

  @override
  String get expelReconnected => 'Phone reconnected: the session has resumed.';

  @override
  String get expelNotReconnected =>
      'The phone is not reconnected to the modem\'s Wi-Fi yet.';

  @override
  String get firmwareDangerTitle => 'For advanced users only';

  @override
  String get firmwareDanger =>
      'A wrong file or an interruption during the update can make the modem unusable. Only use the official firmware made for this modem.';

  @override
  String get firmwareChecklist => 'Before you start';

  @override
  String get firmwareCheckBattery => 'The modem battery is charged';

  @override
  String get firmwareCheckPlugged =>
      'The modem will stay plugged in and I will not turn it off';

  @override
  String get firmwareCheckRisks => 'I understand the risks';

  @override
  String get firmwareFileSection => 'Firmware file';

  @override
  String get firmwareFileLabel => 'Firmware (.zip)';

  @override
  String get firmwareChoose => 'Choose the .zip file';

  @override
  String get firmwareChooseAnother => 'Choose another file';

  @override
  String get firmwareNotZip => 'The file must be a .zip archive.';

  @override
  String get firmwareTooBig => 'Empty or too large file (500 MB maximum).';

  @override
  String firmwareSize(String size) {
    return '$size MB';
  }

  @override
  String get firmwareCrcLabel => 'CRC code';

  @override
  String get firmwareCrcHelper =>
      'Check code provided with the firmware. Otherwise the app can compute it (format expected by the modem to be confirmed).';

  @override
  String get firmwareComputeMd5 => 'Compute MD5';

  @override
  String get firmwareComputeCrc32 => 'Compute CRC32';

  @override
  String get firmwareStart => 'Start the update';

  @override
  String get firmwareConfirmTitle => 'Update the firmware?';

  @override
  String firmwareConfirmMessage(String file) {
    return 'The file “$file” will be sent to the modem. Do not leave the app or turn the modem off during the whole operation.';
  }

  @override
  String get firmwareConfirmWord => 'UPDATE';

  @override
  String get firmwarePreparing => 'Preparing the update…';

  @override
  String firmwareUploading(String sent, String total) {
    return 'Sending the file: $sent MB of $total MB';
  }

  @override
  String get firmwareVerifying => 'The modem is checking the file…';

  @override
  String get firmwareDoNotLeave =>
      'Do not leave this screen or turn the modem off.';

  @override
  String get firmwareCancel => 'Cancel the upload';

  @override
  String get firmwareCancelTitle => 'Cancel the upload?';

  @override
  String get firmwareCancelMessage =>
      'The firmware upload will be interrupted; the modem keeps its current version.';

  @override
  String get firmwareRefused => 'The modem refused the update';

  @override
  String get firmwareNoAnswer => 'The modem did not confirm the file check.';

  @override
  String get firmwareInProgressTitle => 'Update in progress';

  @override
  String get firmwareInProgress =>
      'The modem is installing the new firmware and will then restart. This can take several minutes: do not turn it off.';

  @override
  String get firmwareWaitingRestart =>
      'Installing the firmware and restarting the modem (several minutes)…';

  @override
  String get helpTitle => 'User guide';

  @override
  String get helpHubSubtitle =>
      'How to use every feature, and what to do if something goes wrong';

  @override
  String get helpIntro =>
      'MiFi replaces the modem\'s web interface. Tap a topic to learn how to use each feature.';

  @override
  String get helpStartTitle => 'Getting started';

  @override
  String get helpStartBody =>
      '1. Connect the phone to the modem\'s Wi-Fi (name and password are on the modem\'s label).\n2. Open MiFi and enter the modem\'s admin password (printed on the label if it was never changed).\n3. Keep “Remember password” checked: you will be signed in automatically next time. The password is stored encrypted on the phone.\n\nIf Android says this Wi-Fi has “No internet access” (for example when data is off), that is normal: the app still uses it to talk to the modem.';

  @override
  String get helpAddressTitle => 'Modem address';

  @override
  String get helpAddressBody =>
      'By default, the modem answers at 192.168.100.1.\n\nIf you change it under “Local network (DHCP)”, the app automatically follows the new address. You can also change it by hand on the sign-in screen (“Modem address”) or in Settings › App settings. The app suggests the current Wi-Fi gateway address when it differs.';

  @override
  String get helpDashboardTitle => 'Dashboard';

  @override
  String get helpDashboardBody =>
      'At the top, as in the original interface: Wi-Fi, SIM, signal and internet icons, the operator name, the language picker and the admin menu (password, guide, sign out).\n\nBelow: the signal (bars, dBm, quality), the internet state and WAN IP, phone-style quick toggles (Mobile data, Wi-Fi, USB sharing), “Restart the connection”, connected devices, modem information and versions, and shortcuts.\n\nData refreshes continuously (every 2 seconds); pull down to reload everything. Values the modem does not provide are hidden instead of showing 0.';

  @override
  String get helpOperatorTitle => 'Operator and SIM change';

  @override
  String get helpOperatorBody =>
      'The app works with any operator\'s SIM. It shows the service name provided by the SIM; otherwise it derives the operator from the SIM code (MTN, Orange, Nexttel, Camtel), or shows “Operator 624-XX”.\n\nWhen you change SIM, the app shows “New SIM detected” and offers to open the APN settings. The modem usually picks the right APN by itself.';

  @override
  String get helpMobileDataTitle => 'Mobile data';

  @override
  String get helpMobileDataBody =>
      'As on a phone, the “Mobile data” toggle cuts the internet while keeping the SIM on the network (the signal stays visible). Wi-Fi stays on.\n\nSince the modem has no dedicated command, the app activates a blocking APN profile (“MiFi-OFF”); turning data back on restores your usual profile. A “Mobile data” tile is also available in Android Quick Settings.';

  @override
  String get helpAirplaneTitle => 'Airplane mode';

  @override
  String get helpAirplaneBody =>
      'As on a phone, airplane mode cuts the internet on the SIM in use (SIM 1 or SIM 2), without ever changing SIM. After confirmation, it turns on in a few seconds. The modem\'s Wi-Fi stays on: your devices stay connected to the modem (without internet) and the app can always turn airplane mode off.\n\nThe modem has no command to turn its radio off: the app cuts the internet by activating a blocking APN profile (“MiFi-OFF”). The SIM therefore stays on the network and the signal bars stay visible. If you change SIM during airplane mode, the cut also applies to the new SIM.\n\nThe app checks that the connection drops. If the modem switches back to its usual APN profile by itself, the app re-applies the cut: at every refresh while the app is open, otherwise during background checks (every 15 minutes at best, if they are enabled). If the cut doesn\'t hold, for example when the carrier accepts any APN, a warning is shown.\n\nDuring airplane mode, the “Mobile data” toggle is greyed out. Turning airplane mode off restores your usual APN profile.';

  @override
  String get helpReconnectTitle =>
      'Restart the connection and automatic repair';

  @override
  String get helpReconnectBody =>
      'When the internet stops working, tap “Restart the connection” on the dashboard: the app cuts the modem\'s connection, like airplane mode (it registers on the network again), then restores it. It tries again until the internet is back or until you tap “Stop”; the attempt number and elapsed time are shown. It is much faster than restarting the modem, which is still offered.\n\nWith automatic repair (Settings › App settings), the app does it by itself if the internet has been down for 3 minutes with a good signal (3 attempts at most, at most once every 30 minutes).';

  @override
  String get helpTileTitle => 'Quick Settings tiles and shortcuts';

  @override
  String get helpTileBody =>
      'To turn mobile data on or off without opening the app:\n1. Swipe down twice from the top of the screen.\n2. Tap the pencil (Edit).\n3. Drag MiFi\'s “Mobile data” tile among your tiles.\n\nA tap starts the change. The phone must be connected to the modem\'s Wi-Fi and the password remembered; if it fails, a notification tells you.\n\nA long press on the MiFi icon also offers shortcuts: Share Wi-Fi, Speed test.';

  @override
  String get helpWidgetTitle => 'Home screen widgets';

  @override
  String get helpWidgetBody =>
      'Long-press an empty spot of the home screen, choose “Widgets”, then MiFi: the “Modem status” widget shows the operator, signal, internet and number of devices; a tap opens the app. It updates while the app is open and at each background check.';

  @override
  String get helpScheduleTitle => 'Scheduled restart';

  @override
  String get helpScheduleBody =>
      'In Settings › App settings › Automation, the scheduled restart restarts the modem every day at the chosen time.\n\nAt the scheduled time, the phone must be connected to the modem\'s Wi-Fi; otherwise a failure notification is shown. Android may shift the time by a few minutes.';

  @override
  String get helpDevicesTitle => 'Connected devices';

  @override
  String get helpDevicesBody =>
      'The Devices tab lists connected devices: name, type (Wi-Fi or wired), IP address and MAC address. Tap a device to give it a nickname, remembered by its MAC address.\n\nA “New” badge marks a device seen for the first time recently, and an alert warns you when an unknown device connects, with direct access to “Kick out intruders”. Devices seen before but disconnected are listed separately.';

  @override
  String get helpExpelTitle => 'Kick out intruders';

  @override
  String get helpExpelBody =>
      'The modem cannot block a device. “Kick out intruders” generates a strong new Wi-Fi password (12 characters), applies it and immediately shows its QR code. You can also hide the Wi-Fi name to make it invisible to neighbours.\n\nAll devices, including this phone, are disconnected: reconnect them with the new password (“Reconnect this phone” button, QR code or share by message). The app resumes its session as soon as the phone is reconnected.';

  @override
  String get helpWifiTitle => 'Wi-Fi and sharing';

  @override
  String get helpWifiBody =>
      'Settings › Wi-Fi lets you change the network name, the password (8 to 32 characters), the security, the channel and whether the name is broadcast. After saving, the Wi-Fi restarts: reconnect the phone to the network.\n\nTo share the Wi-Fi: a QR code to scan with the camera, or send the name and password by message (WhatsApp, SMS…).\n\nWarning: “Turn off Wi-Fi” disconnects the phone immediately and the app will not be able to turn it back on. You will need the modem\'s button or a restart.';

  @override
  String get helpDhcpTitle => 'Local network (DHCP)';

  @override
  String get helpDhcpBody =>
      'This page sets the modem address, the netmask, the range of addresses given to devices and the lease time (in hours). The app checks that the range is in the same subnet as the modem.\n\nSaving restarts the modem (about 1 minute). If the modem address changes, the app automatically uses the new one. The DHCP server state is shown read-only.';

  @override
  String get helpMobileTitle => 'Mobile network';

  @override
  String get helpMobileBody =>
      '• SIM card: slot in use (SIM 1 or SIM 2); switching takes about 20 seconds.\n• Mobile data: same toggle as on the dashboard.\n• APN: choose the profile used for the internet or create one with your operator\'s settings (MCC and MNC are pre-filled from the SIM).\n• Network mode: automatic 4G/3G, 4G only or 3G only.\n• USB tethering: internet over a USB cable to a computer.\n• Outage detection: the modem checks the connection by contacting these addresses (IP or name, for example 8.8.8.8 or www.google.com).';

  @override
  String get helpSystemTitle => 'System';

  @override
  String get helpSystemBody =>
      '• Change the admin password: the app signs in again by itself with the new one.\n• Restart the modem: about 1 minute; the app waits for it to come back.\n• Factory reset: two confirmations are required. Wi-Fi and password go back to the values on the modem\'s label: reconnect the phone to the factory Wi-Fi, then sign in again. Make a backup first.\n• Manufacturing information: factory calibration and Wi-Fi test (read-only).';

  @override
  String get helpFirmwareTitle => 'Firmware update';

  @override
  String get helpFirmwareBody =>
      'For advanced users only: a wrong file can make the modem unusable.\n\nBefore starting: battery charged, modem plugged in and not moving, phone close to the modem. Choose the official .zip file (500 MB maximum) and enter the CRC code provided with it. During the upload, do not leave the app and do not turn the modem off. At the end, the modem updates and restarts.';

  @override
  String get helpSignalTitle => 'Signal history and best location';

  @override
  String get helpSignalBody =>
      'Settings › Signal history shows the signal strength (in dBm) over the last hour or the last 24 hours. The closer to 0, the better: excellent (4 bars) from -80 dBm, good (3) from -90, fair (2) from -100, poor (1) from -110, none below; bars are green, orange or red depending on the level. The reading is updated continuously (every 2 seconds).\n\n“Find the best location” shows a large gauge updated every 2 to 3 seconds. Move the modem slowly (near a window, up high) and wait a few seconds at each spot: the app remembers the best value.';

  @override
  String get helpOutagesTitle => 'Outage log';

  @override
  String get helpOutagesBody =>
      'Each internet loss is recorded with its start, end and duration; outages caused by data turned off or by “Restart the connection” are marked “planned”. A summary shows the number and duration of outages over 24 hours and 7 days.\n\nThe export button saves the log as a CSV file (readable with Excel), for example to complain to the operator.';

  @override
  String get helpSpeedTestTitle => 'Speed test and operator comparison';

  @override
  String get helpSpeedTestBody =>
      'The speed test downloads a file (5, 10 or 25 MB) through the modem and shows the speed in Mb/s with its quality: none, poor, fair, good or excellent. It uses data from your plan. Results are kept in a history.\n\nThe operator comparison (shortcut on the dashboard) groups, for each SIM used over the last 7 days: average signal, average speed and outages. Handy to choose the SIM that works best where you are.';

  @override
  String get helpBackupTitle => 'Backup and restore';

  @override
  String get helpBackupBody =>
      '“Export the settings” saves the Wi-Fi, APN, DHCP, network mode and outage detection settings to a file. The admin password is never exported, but the file contains the Wi-Fi password: keep it safe.\n\n“Restore” re-applies a backup, for example after a factory reset. You choose the sections; DHCP restarts the modem, and Wi-Fi is applied last because the phone will have to reconnect to it.';

  @override
  String get helpNotificationsTitle => 'Notifications';

  @override
  String get helpNotificationsBody =>
      'MiFi can warn you when the internet goes down or comes back, when the signal is weak and when a new device connects. Set them up in Settings › App settings › Notifications, and allow them when Android asks.\n\nWhile the app is open, monitoring is continuous. When it is closed, continuous monitoring (App settings) alerts you within seconds; without it, Android only allows a check about every 15 minutes. The phone must be connected to the modem\'s Wi-Fi.';

  @override
  String get helpLanguageTitle => 'Language, theme and lock';

  @override
  String get helpLanguageBody =>
      'In Settings › App settings:\n• app language (phone language, French or English); the “Also apply to the modem\'s web interface” option also changes the language of the original web page;\n• automatic, light or dark theme;\n• lock: MiFi asks for the fingerprint or the phone\'s code when it opens.';

  @override
  String get helpTroubleshootingTitle => 'Troubleshooting';

  @override
  String get helpTroubleshootingBody =>
      '• “Cannot reach the modem”: check that the phone is connected to the modem\'s Wi-Fi, then the modem address (192.168.100.1 by default).\n• “Session expired”: the app signs in again by itself; if the password was changed elsewhere, sign in again.\n• Wi-Fi turned off: turn it back on with the modem\'s button or restart the modem.\n• Forgotten admin password: do a factory reset with the modem\'s RESET button.\n• Mobile data failed: check the Wi-Fi and try again; as a last resort, restart the modem.';

  @override
  String get helpLimitsTitle => 'What the modem cannot do';

  @override
  String get helpLimitsBody =>
      'The modem\'s API does not provide this information, and the app does not make it up: battery level, data used, blocking a device, SMS, USSD, operator balance or plan.';

  @override
  String get loginTitle => 'Sign in to the modem';

  @override
  String get loginSubtitle =>
      'Connect the phone to the modem\'s Wi-Fi, then enter the admin password.';

  @override
  String get loginPasswordLabel => 'Admin password';

  @override
  String get loginRemember => 'Remember password';

  @override
  String get loginRememberHint =>
      'Stored encrypted on this phone, for automatic sign-in';

  @override
  String get loginAction => 'Sign in';

  @override
  String get loginRetrySaved => 'Retry with the saved password';

  @override
  String get loginAddressTitle => 'Modem address';

  @override
  String get loginAddressLabel => 'Modem IP address';

  @override
  String get loginAddressHelper =>
      '192.168.100.1 by default; it changes if you edit DHCP';

  @override
  String loginUseGateway(String address) {
    return 'Use $address (current Wi-Fi)';
  }

  @override
  String loginResetAddress(String address) {
    return 'Restore $address';
  }

  @override
  String get loginTestAddress => 'Test';

  @override
  String get loginReachable => 'The modem answers at this address.';

  @override
  String get loginDefaultPasswordHint =>
      'Never changed the password? It is printed on the modem\'s label.';

  @override
  String get mobileSimSection => 'SIM card';

  @override
  String mobileSimCurrent(String slot) {
    return 'Active slot: $slot';
  }

  @override
  String mobileSimSwitchTitle(int number) {
    return 'Switch to SIM $number?';
  }

  @override
  String get mobileSimSwitchWarning =>
      'Switching takes about 20 seconds; the internet is cut meanwhile. Wi-Fi stays on.';

  @override
  String get mobileSimSwitching => 'Switching SIM (about 20 s)…';

  @override
  String get mobileApnSection => 'APN profiles';

  @override
  String get mobileApnHint =>
      'The modem usually picks the APN from the SIM. Only change it if the internet does not work; ask your operator for the settings.';

  @override
  String get mobileApnEmpty => 'No APN profile on the modem.';

  @override
  String get mobileApnActive => 'Active';

  @override
  String get mobileApnUse => 'Use this profile';

  @override
  String get mobileApnUseTitle => 'Change APN profile?';

  @override
  String mobileApnUseMessage(String name) {
    return 'The modem will use the “$name” profile to connect to the internet. The connection may drop briefly.';
  }

  @override
  String get mobileApnNew => 'New APN profile';

  @override
  String get mobileApnNewHint =>
      'Enter the settings provided by your operator. MCC and MNC are pre-filled from the inserted SIM.';

  @override
  String get mobileApnName => 'Profile name';

  @override
  String get mobileApnApn => 'APN';

  @override
  String get mobileApnPdpType => 'PDP type';

  @override
  String get mobileApnMcc => 'MCC';

  @override
  String get mobileApnMnc => 'MNC';

  @override
  String get mobileApnMccMnc => 'MCC-MNC';

  @override
  String get mobileApnMccInvalid => '3 digits';

  @override
  String get mobileApnMncInvalid => '2 or 3 digits';

  @override
  String get mobileApnAuth => 'Authentication';

  @override
  String get mobileApnUsername => 'Username';

  @override
  String get mobileApnPassword => 'Password';

  @override
  String get mobileApnPort => 'Port';

  @override
  String get mobileApnPortInvalid => 'Port between 1 and 65535';

  @override
  String get mobileApnOptional => 'Optional';

  @override
  String get mobileApnCreatedTitle => 'Profile created';

  @override
  String mobileApnActivateNow(String name) {
    return 'Use the “$name” profile now?';
  }

  @override
  String get mobileApnBlockerName => 'Data cut-off (MiFi)';

  @override
  String get mobileModeSection => 'Network mode';

  @override
  String get mobileModeChangeTitle => 'Change the network mode?';

  @override
  String mobileModeChangeMessage(String mode) {
    return 'The modem will switch to “$mode”. The connection may drop briefly.';
  }

  @override
  String mobileModeUnknown(String code) {
    return 'Unrecognised current mode: $code';
  }

  @override
  String get mobileUsbLabel => 'Share the internet over USB';

  @override
  String get mobileDetectSection => 'Outage detection';

  @override
  String get mobileDetectHint =>
      'The modem checks the internet connection by contacting these addresses (IP or name, e.g. 8.8.8.8 or www.google.com).';

  @override
  String get mobileDetectLabel => 'Outage detection';

  @override
  String mobileDetectAddress(int number) {
    return 'Address $number';
  }

  @override
  String get mobileDetectNeedAddress =>
      'Enter at least one address to enable detection.';

  @override
  String get outagesSummary => 'Summary (excluding planned outages)';

  @override
  String get outagesLast24h => 'Last 24 hours';

  @override
  String get outagesLast7d => 'Last 7 days';

  @override
  String outagesCountDuration(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outages',
      one: '$count outage',
    );
    return '$_temp0 · $duration in total';
  }

  @override
  String get outagesEmpty => 'No outage recorded.';

  @override
  String get outagesOngoing => 'Ongoing';

  @override
  String get outagesPlanned => 'Planned';

  @override
  String outagesSince(String time) {
    return 'Since $time';
  }

  @override
  String outagesFromTo(String start, String end) {
    return 'From $start to $end';
  }

  @override
  String get outagesNote =>
      'Outages are detected within seconds, with the app open or with continuous monitoring (about every 15 minutes without it). “Planned” = data turned off or connection restarted by the app.';

  @override
  String get outagesClearTitle => 'Clear history';

  @override
  String get outagesClearMessage => 'All recorded outages will be deleted.';

  @override
  String get outagesExport => 'Export as CSV';

  @override
  String get outagesExported => 'Log exported.';

  @override
  String get outagesExportCancelled => 'Export cancelled.';

  @override
  String get outagesCsvStart => 'Start';

  @override
  String get outagesCsvEnd => 'End';

  @override
  String get outagesCsvMinutes => 'Duration (minutes)';

  @override
  String get outagesCsvPlanned => 'Planned';

  @override
  String get outagesCsvOperator => 'Operator (MCC-MNC)';

  @override
  String get signalLastHour => 'Last hour';

  @override
  String get signalLast24h => 'Last 24 h';

  @override
  String get signalEmpty =>
      'No reading for this period yet. Keep the app open or enable the background check.';

  @override
  String get signalStats => 'Statistics';

  @override
  String get signalCurrent => 'Current';

  @override
  String get signalAverage => 'Average';

  @override
  String get signalBest => 'Best';

  @override
  String get signalWorst => 'Weakest';

  @override
  String signalSamplesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '$count reading',
    );
    return '$_temp0';
  }

  @override
  String get signalHowItWorks =>
      'The closer to 0, the better the signal: 4 bars from -95 dBm, none below -115 dBm. One point every 30 s, with the app open or with continuous monitoring (about every 15 min without it).';

  @override
  String get bestLocationInstructions =>
      'Move the modem slowly and wait a few seconds at each spot.';

  @override
  String get bestLocationUnit => 'dBm';

  @override
  String bestLocationRecord(String value) {
    return 'Best signal: $value';
  }

  @override
  String bestLocationRecordAt(String time) {
    return 'Reached at $time';
  }

  @override
  String get bestLocationReset => 'Reset';

  @override
  String get bestLocationTips =>
      'Tips: near a window, up high, away from thick walls and metal objects. The phone vibrates at every new record.';

  @override
  String get speedTestSize => 'Test file size';

  @override
  String speedTestMegabytes(int size) {
    return '$size MB';
  }

  @override
  String get speedTestDataWarning =>
      'The test uses this amount of data from your SIM plan.';

  @override
  String speedTestMbps(String value) {
    return '$value Mb/s';
  }

  @override
  String speedTestProgress(String received, String total) {
    return '$received MB of $total MB';
  }

  @override
  String speedTestDetails(String size, String latency) {
    return '$size MB downloaded · latency $latency ms';
  }

  @override
  String get speedTestStart => 'Start the test';

  @override
  String get speedTestHistory => 'History';

  @override
  String get speedTestEmpty => 'No test yet.';

  @override
  String get speedTestClearTitle => 'Clear history';

  @override
  String get speedTestClearMessage => 'All test results will be deleted.';

  @override
  String get speedTestNoInternet =>
      'No internet access through the modem (data off?).';

  @override
  String get speedTestTimeout =>
      'The test server is not responding fast enough.';

  @override
  String get speedTestServer =>
      'The test server returned an error. Try again later.';

  @override
  String get speedTestNotOnModemWifi =>
      'The phone is not connected to the modem\'s Wi-Fi: the test would measure its own mobile data. Connect it to the modem\'s Wi-Fi and try again.';

  @override
  String get speedTestHow =>
      'The file is downloaded from a public server through the modem; the result depends on the mobile network, the signal and the time of day.';

  @override
  String get speedQualityTitle => 'Speed quality';

  @override
  String get speedQualityNone => 'None';

  @override
  String get speedQualityPoor => 'Poor';

  @override
  String get speedQualityFair => 'Fair';

  @override
  String get speedQualityGood => 'Good';

  @override
  String get speedQualityExcellent => 'Excellent';

  @override
  String get speedQualityNoneHint => 'The internet barely works.';

  @override
  String get speedQualityPoorHint => 'Messaging and slow browsing.';

  @override
  String get speedQualityFairHint => 'Browsing and standard-quality video.';

  @override
  String get speedQualityGoodHint => 'HD video and video calls.';

  @override
  String get speedQualityExcellentHint => 'Any use, even on several devices.';

  @override
  String get speedQualityScale =>
      'None: under 0.5 Mb/s · Poor: under 2 · Fair: under 8 · Good: under 25 · Excellent: 25 Mb/s or more.';

  @override
  String get systemAccountSection => 'Admin account';

  @override
  String get systemChangePasswordHint =>
      'Password of the modem\'s admin interface';

  @override
  String get systemMaintenanceSection => 'Restart and reset';

  @override
  String get systemRebootHint =>
      'Restarting often fixes slowness. Devices are disconnected for about 1 minute.';

  @override
  String get systemResetHint =>
      'A factory reset erases all the modem settings.';

  @override
  String get systemResetAction => 'Factory reset';

  @override
  String get systemResetTitle => 'Factory reset';

  @override
  String get systemResetWarning =>
      'All the modem settings will be erased. The Wi-Fi name and password, as well as the admin password, will go back to the factory values printed on the modem\'s label. You will have to reconnect the phone to the factory Wi-Fi.\n\nTip: back up your settings first.';

  @override
  String get systemResetBackupFirst => 'Back up first';

  @override
  String get systemResetSecond => 'Last confirmation: this cannot be undone.';

  @override
  String get systemResetWord => 'RESET';

  @override
  String get systemResetDoneTitle => 'Reset started';

  @override
  String get systemResetDone =>
      'The modem restarts with its factory settings. In 1 to 2 minutes: connect the phone to the factory Wi-Fi (modem label), then sign in again with the factory password. You can then restore your backup.';

  @override
  String get systemProduceSection => 'Manufacturing information';

  @override
  String get systemCalibration => 'Calibration';

  @override
  String get systemCalibrated => 'Calibrated';

  @override
  String get systemNotCalibrated => 'Not calibrated';

  @override
  String get systemWifiTest => 'Wi-Fi test';

  @override
  String get systemWifiTested => 'Wi-Fi tested';

  @override
  String get systemWifiNotTested => 'Wi-Fi not tested';

  @override
  String get systemModemSection => 'Modem';

  @override
  String get systemSimSlots => 'SIM slots';

  @override
  String get systemWebLanguage => 'Web interface language';

  @override
  String get systemCopyright => 'Manufacturer';

  @override
  String get systemToolsSection => 'Tools';

  @override
  String get systemPasswordIntro =>
      'After the change, the app signs in again by itself with the new password.';

  @override
  String get systemOldPassword => 'Current password';

  @override
  String get systemNewPassword => 'New password';

  @override
  String get systemConfirmPassword => 'Confirm the new password';

  @override
  String get systemPasswordRules => '4 to 32 characters, no spaces or accents';

  @override
  String get systemPasswordSame =>
      'The new password must differ from the current one';

  @override
  String get systemPasswordMismatch => 'The two passwords do not match';

  @override
  String get systemPasswordChanged => 'Admin password changed.';

  @override
  String get systemPasswordRefused =>
      'The modem refused the change: check the current password.';

  @override
  String get wifiNetworkSection => 'Wi-Fi network';

  @override
  String get wifiSsidLabel => 'Network name (SSID)';

  @override
  String wifiSsidTooLong(int max) {
    return '$max characters maximum';
  }

  @override
  String get wifiSecurityLabel => 'Security';

  @override
  String get wifiPasswordLabel => 'Wi-Fi password';

  @override
  String wifiPasswordLength(int min, int max) {
    return '$min to $max characters';
  }

  @override
  String get wifiPasswordAscii =>
      'Unaccented letters, digits and common symbols only';

  @override
  String get wifiOpenWarning =>
      'Open network: anyone nearby can connect without a password.';

  @override
  String get wifiChannelLabel => 'Channel';

  @override
  String wifiChannelValue(String channel) {
    return 'Channel $channel';
  }

  @override
  String get wifiBroadcastLabel => 'Broadcast the name (SSID)';

  @override
  String get wifiBroadcastHiddenHint =>
      'Off: the network is invisible, its name must be typed to connect';

  @override
  String get wifiSaveTitle => 'Save the Wi-Fi settings?';

  @override
  String get wifiSaveWarning =>
      'The modem\'s Wi-Fi will restart: all devices, including this phone, will be disconnected for a moment. If you change the name or password, reconnect the phone to the new network.';

  @override
  String wifiReconnectMessage(String ssid) {
    return 'The Wi-Fi is restarting. If needed, reconnect the phone to the “$ssid” network.';
  }

  @override
  String get wifiShareSection => 'Share the Wi-Fi';

  @override
  String get wifiShareQr => 'Share with a QR code';

  @override
  String get wifiShareQrHint => 'Your guests scan it with their camera';

  @override
  String get wifiShareMessage => 'Share by message';

  @override
  String get wifiShareMessageHint =>
      'Send the name and password via WhatsApp, SMS…';

  @override
  String wifiShareText(String ssid, String password) {
    return 'Wi-Fi: $ssid\nPassword: $password';
  }

  @override
  String wifiShareTextOpen(String ssid) {
    return 'Wi-Fi: $ssid (no password)';
  }

  @override
  String get wifiExpelHint =>
      'An unknown device is using your Wi-Fi? Change the password in one tap and share the new one.';

  @override
  String get wifiApSection => 'Wi-Fi access point';

  @override
  String get wifiApState => 'Wi-Fi state';

  @override
  String get wifiTurnOff => 'Turn off Wi-Fi';

  @override
  String get wifiTurnOn => 'Turn on Wi-Fi';

  @override
  String get wifiTurnOffTitle => 'Turn off the modem\'s Wi-Fi?';

  @override
  String get wifiTurnOffWarning =>
      'Warning: this phone will immediately lose its connection to the modem and the app will NOT be able to turn the Wi-Fi back on. You will need to press the modem\'s button or restart it.';

  @override
  String get wifiTurnOffWord => 'OFF';

  @override
  String get wifiTurnedOffInfo =>
      'The modem\'s Wi-Fi is off. To turn it back on, press the modem\'s button or restart it, then reconnect the phone.';

  @override
  String get wifiQrInstructions =>
      'Scan this code with a phone camera to join the Wi-Fi.';

  @override
  String get wifiQrHiddenNote =>
      'The network name is hidden: the code still contains what is needed to join it.';
}
