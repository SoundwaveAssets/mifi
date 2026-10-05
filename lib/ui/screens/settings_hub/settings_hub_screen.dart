import 'package:flutter/material.dart';

import '../../l10n_helpers.dart';
import '../../widgets/section_card.dart';
import '../app_settings/app_settings_screen.dart';
import '../backup/backup_screen.dart';
import '../dhcp/dhcp_screen.dart';
import '../firmware/firmware_screen.dart';
import '../help/help_screen.dart';
import '../mobile/mobile_network_screen.dart';
import '../operators/operator_comparison_screen.dart';
import '../outages/outage_log_screen.dart';
import '../signal/signal_history_screen.dart';
import '../speed_test/speed_test_screen.dart';
import '../system/system_screen.dart';
import '../wifi/wifi_screen.dart';

/// Onglet « Réglages » : accès à tous les écrans de réglage et outils.
class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _HubTile(
            icon: Icons.menu_book_rounded,
            title: l.helpTitle,
            subtitle: l.helpHubSubtitle,
            builder: (_) => const HelpScreen(),
          ),
          ListSectionHeader(l.hubSectionModem),
          _HubTile(
            icon: Icons.wifi_rounded,
            title: l.hubWifiTitle,
            subtitle: l.hubWifiSubtitle,
            builder: (_) => const WifiScreen(),
          ),
          _HubTile(
            icon: Icons.cell_tower_rounded,
            title: l.hubMobileTitle,
            subtitle: l.hubMobileSubtitle,
            builder: (_) => const MobileNetworkScreen(),
          ),
          _HubTile(
            icon: Icons.lan_outlined,
            title: l.hubDhcpTitle,
            subtitle: l.hubDhcpSubtitle,
            builder: (_) => const DhcpScreen(),
          ),
          _HubTile(
            icon: Icons.settings_suggest_outlined,
            title: l.hubSystemTitle,
            subtitle: l.hubSystemSubtitle,
            builder: (_) => const SystemScreen(),
          ),
          ListSectionHeader(l.hubSectionTools),
          _HubTile(
            icon: Icons.show_chart_rounded,
            title: l.hubSignalTitle,
            subtitle: l.hubSignalSubtitle,
            builder: (_) => const SignalHistoryScreen(),
          ),
          _HubTile(
            icon: Icons.history_rounded,
            title: l.hubOutagesTitle,
            subtitle: l.hubOutagesSubtitle,
            builder: (_) => const OutageLogScreen(),
          ),
          _HubTile(
            icon: Icons.speed_rounded,
            title: l.hubSpeedTestTitle,
            subtitle: l.hubSpeedTestSubtitle,
            builder: (_) => const SpeedTestScreen(),
          ),
          _HubTile(
            icon: Icons.compare_arrows_rounded,
            title: l.dashboardCompareOperators,
            subtitle: l.compareHubSubtitle,
            builder: (_) => const OperatorComparisonScreen(),
          ),
          _HubTile(
            icon: Icons.save_alt_rounded,
            title: l.hubBackupTitle,
            subtitle: l.hubBackupSubtitle,
            builder: (_) => const BackupScreen(),
          ),
          _HubTile(
            icon: Icons.system_update_alt_rounded,
            title: l.hubFirmwareTitle,
            subtitle: l.hubFirmwareSubtitle,
            builder: (_) => const FirmwareScreen(),
          ),
          ListSectionHeader(l.hubSectionApp),
          _HubTile(
            icon: Icons.tune_rounded,
            title: l.hubAppSettingsTitle,
            subtitle: l.hubAppSettingsSubtitle,
            builder: (_) => const AppSettingsScreen(),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({required this.icon, required this.title, required this.subtitle, required this.builder});

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: builder)),
    );
  }
}
