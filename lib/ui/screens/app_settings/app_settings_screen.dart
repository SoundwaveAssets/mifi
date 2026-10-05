import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../core/app_services.dart';
import '../../../core/app_wiring.dart';
import '../../../core/background/background_scheduler.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/settings/app_settings.dart';
import '../../background_monitoring.dart';
import '../../l10n_helpers.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/section_card.dart';
import '../help/help_screen.dart';
import '../login/modem_address_editor.dart';

/// Réglages de l'appli : langue, thème, notifications, automatismes
/// (réparation, redémarrage programmé), verrouillage,
/// adresse du modem, compte.
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.hubAppSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LanguageSection(),
          SizedBox(height: 16),
          _ThemeSection(),
          SizedBox(height: 16),
          _NotificationsSection(),
          SizedBox(height: 16),
          _AutomationSection(),
          SizedBox(height: 16),
          _SecuritySection(),
          SizedBox(height: 16),
          _ModemSection(),
          SizedBox(height: 16),
          _AboutSection(),
        ],
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    return SectionCard(
      title: l.appSettingsLanguage,
      icon: Icons.translate_rounded,
      children: [
        RadioGroup<String>(
          groupValue: settings.languageCode ?? 'system',
          onChanged: (code) => settings.setLanguageCode(code == null || code == 'system' ? null : code),
          child: Column(
            children: [
              for (final code in ['system', ...AppSettings.supportedLanguages])
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: code,
                  title: Text(languageLabel(l, code == 'system' ? null : code)),
                ),
            ],
          ),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsApplyToModem),
          subtitle: Text(l.appSettingsApplyToModemHint),
          value: settings.applyLanguageToModem,
          onChanged: settings.setApplyLanguageToModem,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final ok = await applyLanguageToModem(context.read<AppServices>());
              if (context.mounted) {
                showSnack(context, ok ? l.appSettingsLanguageSent : l.appSettingsLanguageNotSent, error: !ok);
              }
            },
            icon: const Icon(Icons.send_rounded),
            label: Text(l.appSettingsSendNow),
          ),
        ),
      ],
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    return SectionCard(
      title: l.appSettingsTheme,
      icon: Icons.palette_outlined,
      children: [
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(value: ThemeMode.system, label: Text(l.appSettingsThemeAuto), icon: const Icon(Icons.brightness_auto_rounded)),
            ButtonSegment(value: ThemeMode.light, label: Text(l.appSettingsThemeLight), icon: const Icon(Icons.light_mode_rounded)),
            ButtonSegment(value: ThemeMode.dark, label: Text(l.appSettingsThemeDark), icon: const Icon(Icons.dark_mode_rounded)),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (selection) => settings.setThemeMode(selection.first),
        ),
      ],
    );
  }
}

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final allowed = await context.read<NativeBridge>().notificationsAllowed();
    if (mounted) setState(() => _allowed = allowed);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    final enabled = settings.notificationsEnabled;
    Widget toggle(String title, bool value, Future<void> Function(bool) onChanged) => SwitchListTile(
          contentPadding: const EdgeInsets.only(left: 16),
          title: Text(title),
          value: enabled && value,
          onChanged: enabled ? onChanged : null,
        );
    return SectionCard(
      title: l.appSettingsNotifications,
      icon: Icons.notifications_outlined,
      children: [
        if (_allowed == false && enabled) ...[
          WarningBanner(message: l.appSettingsNotificationsBlocked, severity: BannerSeverity.warning),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                await context.read<NativeBridge>().requestNotificationPermission();
                await _check();
              },
              child: Text(l.appSettingsAllow),
            ),
          ),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsNotificationsAll),
          value: enabled,
          onChanged: settings.setNotificationsEnabled,
        ),
        toggle(l.appSettingsNotifyDown, settings.notifyInternetDown, settings.setNotifyInternetDown),
        toggle(l.appSettingsNotifyUp, settings.notifyInternetUp, settings.setNotifyInternetUp),
        toggle(l.appSettingsNotifyLowSignal, settings.notifyLowSignal, settings.setNotifyLowSignal),
        toggle(l.appSettingsNotifyNewDevice, settings.notifyNewDevice, settings.setNotifyNewDevice),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsBackground),
          subtitle: Text(l.appSettingsBackgroundHint),
          value: settings.backgroundChecksEnabled,
          onChanged: settings.setBackgroundChecksEnabled,
        ),
        const Divider(),
        const _MonitorTile(),
      ],
    );
  }
}

/// Surveillance continue appli fermée, avec l'état de l'autorisation de
/// fonctionner en arrière-plan.
class _MonitorTile extends StatefulWidget {
  const _MonitorTile();

  @override
  State<_MonitorTile> createState() => _MonitorTileState();
}

class _MonitorTileState extends State<_MonitorTile> {
  bool _unrestricted = true;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Relu au retour des réglages Android.
    _lifecycle = AppLifecycleListener(onResume: _check);
    _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final unrestricted = await context.read<NativeBridge>().isIgnoringBatteryOptimizations();
    if (mounted && unrestricted != _unrestricted) setState(() => _unrestricted = unrestricted);
  }

  Future<void> _set(bool value) async {
    if (value) {
      await enableBackgroundMonitoring(context);
    } else {
      await disableBackgroundMonitoring(context);
    }
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsMonitor),
          subtitle: Text(l.appSettingsMonitorHint),
          value: settings.monitorEnabled,
          onChanged: _set,
        ),
        if (settings.monitorEnabled && !_unrestricted)
          WarningBanner(
            message: l.appSettingsMonitorRestricted,
            action: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: context.read<NativeBridge>().requestIgnoreBatteryOptimizations,
                child: Text(l.appSettingsExactAlarmsAllow),
              ),
            ),
          ),
      ],
    );
  }
}

class _AutomationSection extends StatelessWidget {
  const _AutomationSection();

  Future<int?> _pickTime(BuildContext context, int minutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    return picked == null ? null : picked.hour * 60 + picked.minute;
  }

  String _time(BuildContext context, int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    final scheduler = context.read<BackgroundScheduler>();
    final reboot = scheduler.nextReboot(DateTime.now());
    return SectionCard(
      title: l.appSettingsAutomation,
      icon: Icons.auto_mode_rounded,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsAutoRepair),
          subtitle: Text(l.appSettingsAutoRepairHint),
          value: settings.autoRepairEnabled,
          onChanged: settings.setAutoRepairEnabled,
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsReboot),
          subtitle: Text(l.appSettingsRebootHint),
          value: settings.rebootScheduleEnabled,
          onChanged: settings.setRebootScheduleEnabled,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsRebootTime),
          subtitle: Text(_time(context, settings.rebootScheduleMinutes)),
          trailing: const Icon(Icons.schedule_rounded),
          onTap: () async {
            final value = await _pickTime(context, settings.rebootScheduleMinutes);
            if (value != null) await settings.setRebootScheduleMinutes(value);
          },
        ),
        if (reboot != null)
          Text(l.appSettingsRebootNext(formatDateTime(context, reboot)), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(l.appSettingsAutomationNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        _ReliabilityBlock(scheduled: settings.rebootScheduleEnabled),
      ],
    );
  }
}

/// Réglages Android dont dépendent les programmations et la surveillance
/// appli fermée : alarmes exactes, démarrage automatique (Xiaomi), batterie.
class _ReliabilityBlock extends StatefulWidget {
  const _ReliabilityBlock({required this.scheduled});

  /// Le redémarrage programmé est actif.
  final bool scheduled;

  @override
  State<_ReliabilityBlock> createState() => _ReliabilityBlockState();
}

class _ReliabilityBlockState extends State<_ReliabilityBlock> {
  bool _exactAlarms = true;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Relu au retour des réglages Android.
    _lifecycle = AppLifecycleListener(onResume: _check);
    _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final allowed = await context.read<NativeBridge>().canScheduleExactAlarms();
    if (mounted && allowed != _exactAlarms) setState(() => _exactAlarms = allowed);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bridge = context.read<NativeBridge>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.scheduled && !_exactAlarms) ...[
          WarningBanner(message: l.appSettingsExactAlarmsMissing),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: bridge.openExactAlarmSettings, child: Text(l.appSettingsExactAlarmsAllow)),
          ),
        ],
        Text(l.appSettingsReliabilityHint, style: Theme.of(context).textTheme.bodySmall),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: bridge.openAutostartSettings,
              icon: const Icon(Icons.rocket_launch_outlined),
              label: Text(l.appSettingsAutostart),
            ),
            TextButton.icon(
              onPressed: bridge.openAppSettings,
              icon: const Icon(Icons.battery_saver_outlined),
              label: Text(l.appSettingsBattery),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  Future<void> _setLock(BuildContext context, bool value) async {
    final l = context.l10n;
    final settings = context.read<AppSettings>();
    if (!value) {
      await settings.setAppLockEnabled(false);
      return;
    }
    final auth = LocalAuthentication();
    try {
      if (!await auth.isDeviceSupported()) {
        if (context.mounted) showSnack(context, l.appSettingsLockUnsupported, error: true);
        return;
      }
      final ok = await auth.authenticate(localizedReason: l.lockReason);
      if (ok) await settings.setAppLockEnabled(true);
    } catch (_) {
      if (context.mounted) showSnack(context, l.appSettingsLockUnsupported, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    return SectionCard(
      title: l.appSettingsSecurity,
      icon: Icons.fingerprint_rounded,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.appSettingsLock),
          subtitle: Text(l.appSettingsLockHint),
          value: settings.appLockEnabled,
          onChanged: (value) => _setLock(context, value),
        ),
      ],
    );
  }
}

class _ModemSection extends StatelessWidget {
  const _ModemSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SectionCard(
      title: l.loginAddressTitle,
      icon: Icons.router_outlined,
      children: [
        ModemAddressEditor(
          confirmChange: (address) => showConfirmDialog(
            context,
            title: l.appSettingsAddressConfirmTitle,
            message: l.appSettingsAddressConfirm(address),
          ),
        ),
        const Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout_rounded),
          title: Text(l.dashboardLogout),
          subtitle: Text(l.dashboardLogoutConfirm),
          onTap: () async {
            final ok = await showConfirmDialog(
              context,
              title: l.dashboardLogout,
              message: l.dashboardLogoutConfirm,
              confirmLabel: l.dashboardLogout,
            );
            if (ok && context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              await context.read<SessionController>().signOut();
            }
          },
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SectionCard(
      title: l.appSettingsAbout,
      icon: Icons.info_outline_rounded,
      children: [
        Text(l.appSettingsAboutText),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HelpScreen())),
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(l.helpTitle),
          ),
        ),
      ],
    );
  }
}
