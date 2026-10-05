import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/models/status_models.dart';
import '../../../core/models/system_models.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/status/status_controller.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/async_button.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/modem_restart_dialog.dart';
import '../../widgets/section_card.dart';
import '../backup/backup_screen.dart';
import '../firmware/firmware_screen.dart';
import 'change_password_screen.dart';

/// Système : mot de passe, redémarrage, réinitialisation d'usine,
/// informations de fabrication et du modem.
class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    void push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    return Scaffold(
      appBar: AppBar(title: Text(l.hubSystemTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: l.systemAccountSection,
            icon: Icons.admin_panel_settings_outlined,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.password_rounded),
                title: Text(l.dashboardChangePassword),
                subtitle: Text(l.systemChangePasswordHint),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => push(const ChangePasswordScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _MaintenanceSection(),
          const SizedBox(height: 16),
          const _ProduceSection(),
          const SizedBox(height: 16),
          const _ModemInfoSection(),
          const SizedBox(height: 16),
          SectionCard(
            title: l.systemToolsSection,
            icon: Icons.build_outlined,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.save_alt_rounded),
                title: Text(l.hubBackupTitle),
                subtitle: Text(l.hubBackupSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => push(const BackupScreen()),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.system_update_alt_rounded),
                title: Text(l.hubFirmwareTitle),
                subtitle: Text(l.hubFirmwareSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => push(const FirmwareScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaintenanceSection extends StatelessWidget {
  const _MaintenanceSection();

  Future<void> _reboot(BuildContext context) async {
    final l = context.l10n;
    final api = context.read<ModemApi>();
    final ok = await showConfirmDialog(
      context,
      title: l.dashboardRebootTitle,
      message: l.dashboardRebootConfirm,
      confirmLabel: l.dashboardRebootAction,
      icon: Icons.power_settings_new_rounded,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await api.reboot();
    if (context.mounted) await showModemRestartDialog(context, initialDelay: const Duration(seconds: 15));
  }

  Future<void> _factoryReset(BuildContext context) async {
    final l = context.l10n;
    final api = context.read<ModemApi>();
    final session = context.read<SessionController>();
    // Première confirmation, avec proposition de sauvegarde.
    final first = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.dangerous_outlined, color: Theme.of(context).colorScheme.error),
        title: Text(l.systemResetTitle),
        content: SingleChildScrollView(child: Text(l.systemResetWarning)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop('backup'), child: Text(l.systemResetBackupFirst)),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop('continue'),
            child: Text(l.commonContinue),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (first == 'backup') {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BackupScreen()));
      return;
    }
    if (first != 'continue') return;
    // Seconde confirmation : saisir le mot demandé.
    final second = await showTypedConfirmDialog(
      context,
      title: l.systemResetTitle,
      message: l.systemResetSecond,
      confirmationWord: l.systemResetWord,
      confirmLabel: l.systemResetAction,
    );
    if (!second || !context.mounted) return;
    await api.factoryReset();
    if (!context.mounted) return;
    // Expliquer la suite AVANT de revenir à l'écran de connexion.
    await showInfoDialog(context, title: l.systemResetDoneTitle, message: l.systemResetDone, icon: Icons.info_outline);
    await session.forgetAfterFactoryReset();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SectionCard(
      title: l.systemMaintenanceSection,
      icon: Icons.restart_alt_rounded,
      children: [
        Text(l.systemRebootHint),
        const SizedBox(height: 12),
        AsyncButton(
          onPressed: () => _reboot(context),
          label: l.dashboardRebootAction,
          icon: Icons.power_settings_new_rounded,
          variant: AsyncButtonVariant.tonal,
        ),
        const Divider(height: 32),
        Text(l.systemResetHint),
        const SizedBox(height: 12),
        AsyncButton(
          onPressed: () => _factoryReset(context),
          label: l.systemResetAction,
          icon: Icons.settings_backup_restore_rounded,
          variant: AsyncButtonVariant.danger,
        ),
      ],
    );
  }
}

class _ProduceSection extends StatefulWidget {
  const _ProduceSection();

  @override
  State<_ProduceSection> createState() => _ProduceSectionState();
}

class _ProduceSectionState extends State<_ProduceSection> {
  late final Future<ProduceInfo> _future = context.read<ModemApi>().getProduceInfo();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.statusColors;
    Widget row(String label, bool? ok, String yes, String no, String raw) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            ok == true ? Icons.check_circle_rounded : Icons.help_outline_rounded,
            color: ok == true ? colors.good : (ok == false ? colors.warning : null),
          ),
          title: Text(label),
          subtitle: Text(ok == null ? (raw.isEmpty ? l.commonUnknown : raw) : (ok ? yes : no)),
        );
    return SectionCard(
      title: l.systemProduceSection,
      icon: Icons.factory_outlined,
      children: [
        FutureBuilder<ProduceInfo>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(describeError(l, snapshot.error!));
            final info = snapshot.data;
            if (info == null) return const LinearProgressIndicator();
            return Column(
              children: [
                row(l.systemCalibration, info.calibrated, l.systemCalibrated, l.systemNotCalibrated, info.calibrationRaw),
                row(l.systemWifiTest, info.wifiChecked, l.systemWifiTested, l.systemWifiNotTested, info.wifiCheckRaw),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ModemInfoSection extends StatefulWidget {
  const _ModemInfoSection();

  @override
  State<_ModemInfoSection> createState() => _ModemInfoSectionState();
}

class _ModemInfoSectionState extends State<_ModemInfoSection> {
  late final Future<ModemConfig> _future = context.read<ModemApi>().getConfig();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final Overview? overview = context.watch<StatusController>().snapshot?.overview;
    return SectionCard(
      title: l.systemModemSection,
      icon: Icons.router_outlined,
      children: [
        if ((overview?.softwareVersion ?? '').isNotEmpty)
          InfoTile(label: l.dashboardSoftwareVersion, value: overview!.softwareVersion, copyable: true),
        if ((overview?.hardwareVersion ?? '').isNotEmpty)
          InfoTile(label: l.dashboardHardwareVersion, value: overview!.hardwareVersion),
        if ((overview?.webVersion ?? '').isNotEmpty) InfoTile(label: l.dashboardWebVersion, value: overview!.webVersion),
        if ((overview?.imei ?? '').isNotEmpty) InfoTile(label: l.dashboardImei, value: overview!.imei, copyable: true),
        FutureBuilder<ModemConfig>(
          future: _future,
          builder: (context, snapshot) {
            final config = snapshot.data;
            if (config == null) return const SizedBox.shrink();
            return Column(
              children: [
                if (config.simSlots != null) InfoTile(label: l.systemSimSlots, value: '${config.simSlots}'),
                if (config.webLanguage.isNotEmpty) InfoTile(label: l.systemWebLanguage, value: config.webLanguage),
                if (config.copyrights.isNotEmpty) InfoTile(label: l.systemCopyright, value: config.copyrights),
              ],
            );
          },
        ),
      ],
    );
  }
}
