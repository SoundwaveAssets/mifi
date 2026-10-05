import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../l10n_helpers.dart';
import '../../widgets/app_logo.dart';

/// Guide d'utilisation : une rubrique dépliable par fonction de l'appli.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static List<_HelpTopic> _topics(AppLocalizations l) => [
        _HelpTopic(Icons.login_rounded, l.helpStartTitle, l.helpStartBody),
        _HelpTopic(Icons.router_outlined, l.helpAddressTitle, l.helpAddressBody),
        _HelpTopic(Icons.dashboard_outlined, l.helpDashboardTitle, l.helpDashboardBody),
        _HelpTopic(Icons.sim_card_outlined, l.helpOperatorTitle, l.helpOperatorBody),
        _HelpTopic(Icons.swap_vert_rounded, l.helpMobileDataTitle, l.helpMobileDataBody),
        _HelpTopic(Icons.restart_alt_rounded, l.helpReconnectTitle, l.helpReconnectBody),
        _HelpTopic(Icons.view_compact_outlined, l.helpTileTitle, l.helpTileBody),
        _HelpTopic(Icons.widgets_outlined, l.helpWidgetTitle, l.helpWidgetBody),
        _HelpTopic(Icons.schedule_rounded, l.helpScheduleTitle, l.helpScheduleBody),
        _HelpTopic(Icons.devices_other_outlined, l.helpDevicesTitle, l.helpDevicesBody),
        _HelpTopic(Icons.shield_outlined, l.helpExpelTitle, l.helpExpelBody),
        _HelpTopic(Icons.wifi_rounded, l.helpWifiTitle, l.helpWifiBody),
        _HelpTopic(Icons.lan_outlined, l.helpDhcpTitle, l.helpDhcpBody),
        _HelpTopic(Icons.cell_tower_rounded, l.helpMobileTitle, l.helpMobileBody),
        _HelpTopic(Icons.settings_suggest_outlined, l.helpSystemTitle, l.helpSystemBody),
        _HelpTopic(Icons.system_update_alt_rounded, l.helpFirmwareTitle, l.helpFirmwareBody),
        _HelpTopic(Icons.show_chart_rounded, l.helpSignalTitle, l.helpSignalBody),
        _HelpTopic(Icons.history_rounded, l.helpOutagesTitle, l.helpOutagesBody),
        _HelpTopic(Icons.speed_rounded, l.helpSpeedTestTitle, l.helpSpeedTestBody),
        _HelpTopic(Icons.save_alt_rounded, l.helpBackupTitle, l.helpBackupBody),
        _HelpTopic(Icons.notifications_outlined, l.helpNotificationsTitle, l.helpNotificationsBody),
        _HelpTopic(Icons.translate_rounded, l.helpLanguageTitle, l.helpLanguageBody),
        _HelpTopic(Icons.build_circle_outlined, l.helpTroubleshootingTitle, l.helpTroubleshootingBody),
        _HelpTopic(Icons.block_rounded, l.helpLimitsTitle, l.helpLimitsBody),
      ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final topics = _topics(l);
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const AppLogo(size: 56),
                const SizedBox(width: 16),
                Expanded(child: Text(l.helpIntro, style: theme.textTheme.bodyLarge)),
              ],
            ),
          ),
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ExpansionTile(
                  leading: Icon(topic.icon, color: theme.colorScheme.primary),
                  title: Text(topic.title, style: theme.textTheme.titleMedium),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(topic.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpTopic {
  const _HelpTopic(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}
