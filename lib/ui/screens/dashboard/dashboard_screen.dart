import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/api/modem_exception.dart';
import '../../../core/mobile_data/data_cut.dart';
import '../../../core/mobile_data/mobile_data.dart';
import '../../../core/mobile_data/reconnect.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/status/status_controller.dart';
import '../../../core/util/signal.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/modem_restart_dialog.dart';
import '../../widgets/section_card.dart';
import '../../widgets/signal_bars.dart';
import '../../widgets/state_views.dart';
import '../devices/devices_screen.dart';
import '../help/help_screen.dart';
import '../operators/operator_comparison_screen.dart';
import '../outages/outage_log_screen.dart';
import '../signal/best_location_screen.dart';
import '../signal/signal_history_screen.dart';
import '../speed_test/speed_test_screen.dart';
import '../system/change_password_screen.dart';
import '../wifi/wifi_qr_screen.dart';
import '../wifi/wifi_screen.dart';

/// Tableau de bord : en-tête d'état (comme l'interface d'origine), signal,
/// interrupteurs rapides façon téléphone, « Relancer la connexion »,
/// appareils, informations et versions du modem.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool? _usbTether;
  bool _usbBusy = false;

  @override
  void initState() {
    super.initState();
    _loadUsb();
  }

  Future<void> _loadUsb() async {
    try {
      final value = await context.read<ModemApi>().getUsbTether();
      if (mounted) setState(() => _usbTether = value);
    } on ModemException {
      // Valeur inconnue : la tuile l'indique.
    }
  }

  void _push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _toggleMobileData(MobileDataController mobileData) async {
    final l = context.l10n;
    final enable = mobileData.enabled == false;
    if (!enable) {
      final ok = await showConfirmDialog(
        context,
        title: l.dashboardMobileDataConfirmTitle,
        message: '${l.mobileDataExplanation}\n\n${l.dashboardMobileDataHow}',
        confirmLabel: l.dashboardTurnOff,
        icon: Icons.swap_vert_rounded,
      );
      if (!ok || !mounted) return;
    }
    try {
      await mobileData.setEnabled(enable);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
    if (mounted) unawaited(context.read<StatusController>().refresh());
  }

  Future<void> _toggleUsb() async {
    final api = context.read<ModemApi>();
    final next = !(_usbTether ?? false);
    setState(() => _usbBusy = true);
    try {
      await api.setUsbTether(next);
      if (mounted) setState(() => _usbTether = next);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _usbBusy = false);
    }
  }

  Future<void> _reconnect() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.dashboardReconnectTitle,
      message: l.dashboardReconnectConfirm,
      confirmLabel: l.dashboardReconnectAction,
      icon: Icons.restart_alt_rounded,
    );
    if (!ok || !mounted) return;
    final reconnect = context.read<ReconnectController>();
    final result = await showDialog<Object?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ReconnectDialog(controller: reconnect),
    );
    if (!mounted) return;
    if (result == true) {
      showSnack(context, reconnect.attempt > 1 ? l.dashboardReconnectSuccessAfter(reconnect.attempt) : l.dashboardReconnectSuccess);
    } else if (result == false) {
      showSnack(context, reconnect.stopRequested ? l.dashboardReconnectStopped : l.dashboardReconnectNoInternet,
          error: !reconnect.stopRequested);
    } else if (result != null) {
      showErrorSnack(context, result);
    }
    unawaited(context.read<StatusController>().refresh());
  }

  Future<void> _reboot() async {
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
    if (!ok || !mounted) return;
    try {
      await api.reboot();
      if (mounted) await showModemRestartDialog(context, initialDelay: const Duration(seconds: 15));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = context.watch<StatusController>();
    final reconnect = context.watch<ReconnectController>();
    final mobileData = context.watch<MobileDataController>();
    final snapshot = status.snapshot;
    // Coupure demandée qui ne tient pas : internet passe encore.
    final notHolding = mobileData.lastError is DataCutNotHoldingException ? mobileData.lastError : null;

    final Widget body;
    if (snapshot == null) {
      body = status.error != null && !status.isRefreshing
          ? ErrorView(error: status.error!, onRetry: status.refresh)
          : const LoadingView();
    } else {
      body = RefreshIndicator(
        onRefresh: status.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (status.isStale) ...[
              WarningBanner(
                title: l.commonDataStale,
                message: describeError(l, status.error!),
                severity: BannerSeverity.warning,
              ),
              const SizedBox(height: 12),
            ],
            if (notHolding != null && !mobileData.isBusy) ...[
              WarningBanner(
                title: l.dataCutNotHoldingTitle,
                message: describeError(l, notHolding),
                severity: BannerSeverity.danger,
              ),
              const SizedBox(height: 12),
            ],
            // Internet ne passe plus (sans coupure voulue) : alerte et relance
            // à portée de main. Après 4 s, pour ne pas réagir à un test raté isolé.
            if (!mobileData.connectionCut &&
                !reconnect.isBusy &&
                (status.internetDownFor ?? Duration.zero) >= const Duration(seconds: 4)) ...[
              WarningBanner(
                title: l.dashboardInternetLostTitle,
                message: l.dashboardInternetLostMessage,
                severity: BannerSeverity.danger,
                icon: Icons.public_off_rounded,
                action: FilledButton.icon(
                  onPressed: mobileData.isBusy ? null : _reconnect,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(l.dashboardReconnectAction),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _ConnectionCard(
              snapshot: snapshot,
              stale: status.isStale,
              // Connexion coupée par l'appli : barres vides et raison de la coupure.
              cutLabel: mobileData.connectionCut ? '${l.mobileDataTitle} : ${l.mobileDataStateOff}' : null,
              onHistory: () => _push(const SignalHistoryScreen()),
              onBestLocation: () => _push(const BestLocationScreen()),
            ),
            const SizedBox(height: 16),
            _QuickToggles(
              snapshot: snapshot,
              reconnect: reconnect,
              mobileData: mobileData,
              usbTether: _usbTether,
              usbBusy: _usbBusy,
              onMobileData: () => _toggleMobileData(mobileData),
              onWifi: () => _push(const WifiScreen()),
              onUsb: _toggleUsb,
            ),
            if (mobileData.isBusy) ...[
              const SizedBox(height: 12),
              const _SwitchingProgress(),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: l.dashboardReconnectTitle,
              icon: Icons.restart_alt_rounded,
              children: [
                Text(l.dashboardReconnectHint),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      // Internet coupé volontairement : rien à relancer.
                      onPressed: reconnect.isBusy || mobileData.isBusy || mobileData.enabled == false ? null : _reconnect,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(l.dashboardReconnectAction),
                    ),
                    TextButton.icon(
                      onPressed: _reboot,
                      icon: const Icon(Icons.power_settings_new_rounded),
                      label: Text(l.dashboardRebootAction),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DevicesCard(snapshot: snapshot, onOpen: () => _push(const DevicesScreen())),
            const SizedBox(height: 16),
            _ModemInfoCard(snapshot: snapshot),
            const SizedBox(height: 16),
            _ShortcutsCard(push: _push),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: _StatusHeader(snapshot: snapshot, connectionCut: mobileData.connectionCut, stale: status.isStale),
        actions: [
          const _LanguageMenu(),
          _AdminMenu(push: _push),
        ],
      ),
      body: body,
    );
  }
}

// ------------------------------------------------------------------ En-tête

/// Les 4 icônes d'état de l'interface d'origine, puis le nom du service.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.snapshot, required this.connectionCut, required this.stale});

  final StatusSnapshot? snapshot;

  /// Connexion coupée par l'appli : barres vides.
  final bool connectionCut;

  /// Relevé périmé (modem injoignable) : état d'internet inconnu.
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = snapshot?.status;
    final colors = context.statusColors;
    final unknown = Theme.of(context).colorScheme.outline;
    Color tone(bool? ok) => ok == null ? unknown : (ok ? colors.good : colors.bad);
    final wifiOn = status?.isWifiApOn;
    final hasSim = status?.hasSim;
    final internet = stale ? null : status?.isInternetConnected;
    return Row(
      children: [
        Tooltip(
          message: wifiOn == false ? l.dashboardWifiOff : l.dashboardWifiOn,
          child: Icon(wifiOn == false ? Icons.wifi_off_rounded : Icons.wifi_rounded, size: 20, color: tone(wifiOn)),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: hasSim == false ? l.noSim : l.dashboardSimOk,
          child: Icon(hasSim == false ? Icons.no_sim_outlined : Icons.sim_card_outlined, size: 20, color: tone(hasSim)),
        ),
        const SizedBox(width: 10),
        SignalBars(
          bars: connectionCut ? 0 : status?.signalBars ?? 0,
          size: 18,
          semanticLabel: signalQualityLabel(l, SignalQuality.fromBars(connectionCut ? 0 : status?.signalBars ?? 0)),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: switch (internet) {
            true => l.widgetInternetOn,
            false => l.widgetInternetOff,
            null => l.dashboardInternetUnknown,
          },
          child: Icon(internet == false ? Icons.public_off_rounded : Icons.public_rounded, size: 20, color: tone(internet)),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            operatorLabel(l, status),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    return PopupMenuButton<String>(
      tooltip: l.dashboardLanguage,
      icon: const Icon(Icons.translate_rounded),
      onSelected: (code) => settings.setLanguageCode(code == 'system' ? null : code),
      itemBuilder: (context) => [
        for (final code in ['system', ...AppSettings.supportedLanguages])
          CheckedPopupMenuItem(
            value: code,
            checked: (settings.languageCode ?? 'system') == code,
            child: Text(languageLabel(l, code == 'system' ? null : code)),
          ),
      ],
    );
  }
}

/// Menu « administrateur » : mot de passe, guide, déconnexion.
class _AdminMenu extends StatelessWidget {
  const _AdminMenu({required this.push});

  final void Function(Widget) push;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopupMenuButton<String>(
      tooltip: l.dashboardAdmin,
      icon: const Icon(Icons.admin_panel_settings_outlined),
      onSelected: (value) async {
        switch (value) {
          case 'password':
            push(const ChangePasswordScreen());
          case 'help':
            push(const HelpScreen());
          case 'logout':
            final ok = await showConfirmDialog(
              context,
              title: l.dashboardLogout,
              message: l.dashboardLogoutConfirm,
              confirmLabel: l.dashboardLogout,
              icon: Icons.logout_rounded,
            );
            if (ok && context.mounted) await context.read<SessionController>().signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'password',
          child: ListTile(leading: const Icon(Icons.password_rounded), title: Text(l.dashboardChangePassword)),
        ),
        PopupMenuItem(
          value: 'help',
          child: ListTile(leading: const Icon(Icons.menu_book_rounded), title: Text(l.helpTitle)),
        ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(leading: const Icon(Icons.logout_rounded), title: Text(l.dashboardLogout)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Signal

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.snapshot,
    required this.stale,
    required this.cutLabel,
    required this.onHistory,
    required this.onBestLocation,
  });

  final StatusSnapshot snapshot;

  /// Relevé périmé (modem injoignable) : état d'internet inconnu.
  final bool stale;

  /// Raison de la coupure quand l'appli a coupé la connexion, sinon `null`.
  final String? cutLabel;
  final VoidCallback onHistory;
  final VoidCallback onBestLocation;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final colors = context.statusColors;
    final status = snapshot.status;
    final dbm = status.signalDbm;
    final quality = SignalQuality.fromDbm(dbm);
    final bool? internet = stale ? null : status.isInternetConnected;
    final wanIp = snapshot.overview?.wanIp ?? '';
    final operator = snapshot.operator;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SignalBars(
                  bars: cutLabel != null ? 0 : status.signalBars,
                  size: 56,
                  inactiveColor: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cutLabel != null)
                        Text(
                          cutLabel!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else ...[
                        Text(
                          // Sans mesure : la qualité « Inexistant » s'affiche dessous.
                          isValidSignalDbm(dbm) ? l.signalDbm(dbm!) : '—',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          signalQualityLabel(l, quality),
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    switch (internet) {
                      true => Icons.check_circle_rounded,
                      false => Icons.cancel_rounded,
                      null => Icons.help_outline_rounded,
                    },
                    color: switch (internet) {
                      true => colors.good,
                      false => colors.bad,
                      null => theme.colorScheme.outline,
                    },
                    size: 18,
                  ),
                  label: Text(switch (internet) {
                    true => l.widgetInternetOn,
                    false => l.widgetInternetOff,
                    null => l.dashboardInternetUnknown,
                  }),
                ),
                if (status.hasSim)
                  Chip(
                    avatar: const Icon(Icons.sim_card_outlined, size: 18),
                    label: Text(operatorLabel(l, status) +
                        (operator != null && status.serviceName != null ? ' · ${operator.code}' : '')),
                  )
                else
                  Chip(avatar: Icon(Icons.no_sim_outlined, size: 18, color: colors.bad), label: Text(l.noSim)),
                if (wanIp.isNotEmpty && wanIp != '0.0.0.0')
                  Chip(avatar: const Icon(Icons.public_rounded, size: 18), label: Text(l.dashboardWanIp(wanIp))),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onHistory,
                  icon: const Icon(Icons.show_chart_rounded),
                  label: Text(l.dashboardSignalHistory),
                ),
                TextButton.icon(
                  onPressed: onBestLocation,
                  icon: const Icon(Icons.explore_outlined),
                  label: Text(l.dashboardBestLocation),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------- Interrupteurs rapides

class _QuickToggles extends StatelessWidget {
  const _QuickToggles({
    required this.snapshot,
    required this.reconnect,
    required this.mobileData,
    required this.usbTether,
    required this.usbBusy,
    required this.onMobileData,
    required this.onWifi,
    required this.onUsb,
  });

  final StatusSnapshot snapshot;
  final ReconnectController reconnect;
  final MobileDataController mobileData;
  final bool? usbTether;
  final bool usbBusy;
  final VoidCallback onMobileData;
  final VoidCallback onWifi;
  final VoidCallback onUsb;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wifiOn = snapshot.status.isWifiApOn;
    String onOff(bool? value) => value == null ? l.commonUnknown : (value ? l.commonEnabled : l.commonDisabled);
    final data = _QuickTile(
      icon: Icons.swap_vert_rounded,
      label: l.mobileDataTitle,
      state: switch (mobileData.enabled) {
        _ when mobileData.isBusy => l.mobileDataSwitching,
        _ when mobileData.lastError is DataCutNotHoldingException => l.dataCutNotHoldingShort,
        true => l.mobileDataStateOn,
        false => l.mobileDataStateOff,
        null => l.commonUnknown,
      },
      active: mobileData.enabled == true,
      busy: mobileData.isBusy,
      onTap: mobileData.isBusy || reconnect.isBusy ? null : onMobileData,
    );
    final wifi = _QuickTile(
      icon: wifiOn ? Icons.wifi_rounded : Icons.wifi_off_rounded,
      label: l.hubWifiTitle,
      state: onOff(wifiOn),
      active: wifiOn,
      onTap: onWifi,
    );
    final usb = _QuickTile(
      icon: Icons.usb_rounded,
      label: l.dashboardUsbTitle,
      state: onOff(usbTether),
      active: usbTether == true,
      busy: usbBusy,
      onTap: usbBusy || usbTether == null ? null : onUsb,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        data,
        const SizedBox(height: 12),
        Row(children: [Expanded(child: wifi), const SizedBox(width: 12), Expanded(child: usb)]),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => showInfoDialog(
              context,
              title: l.mobileDataTitle,
              message: '${l.mobileDataExplanation}\n\n${l.dashboardMobileDataHow}',
              icon: Icons.info_outline_rounded,
            ),
            icon: const Icon(Icons.info_outline_rounded, size: 18),
            label: Text(l.dashboardTogglesInfo),
          ),
        ),
      ],
    );
  }
}

/// Tuile à la manière des réglages rapides d'un téléphone.
class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.state,
    required this.active,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final String state;
  final bool active;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = active ? scheme.primary : scheme.surfaceContainerHighest;
    final foreground = active ? scheme.onPrimary : scheme.onSurface;
    return Semantics(
      button: true,
      toggled: active,
      label: '$label, $state',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 26,
                  child: busy
                      ? CircularProgressIndicator(strokeWidth: 2.5, color: foreground)
                      : Icon(icon, color: foreground),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: foreground),
                      ),
                      Text(
                        state,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barre d'attente pendant le changement des données mobiles.
class _SwitchingProgress extends StatelessWidget {
  const _SwitchingProgress();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.dashboardMobileDataWaiting),
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Progression de « Relancer la connexion » (tentatives, étapes, temps
/// écoulé) jusqu'au retour d'internet ou à « Arrêter » ; renvoie
/// `true`/`false` (internet revenu ou relance arrêtée) ou l'erreur.
class _ReconnectDialog extends StatefulWidget {
  const _ReconnectDialog({required this.controller});

  final ReconnectController controller;

  @override
  State<_ReconnectDialog> createState() => _ReconnectDialogState();
}

class _ReconnectDialogState extends State<_ReconnectDialog> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    // Temps écoulé mis à jour chaque seconde.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _changed());
    _run();
  }

  Future<void> _run() async {
    Object? result;
    try {
      result = await widget.controller.reconnect();
    } catch (e) {
      result = e;
    }
    if (mounted) Navigator.of(context).pop(result);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final controller = widget.controller;
    final attempt = controller.attempt < 1 ? 1 : controller.attempt;
    final steps = [
      (ReconnectStep.cuttingNetwork, l.dashboardReconnectStepCut),
      if (attempt >= ReconnectController.reregisterFromAttempt)
        (ReconnectStep.reregistering, l.dashboardReconnectStepReregister),
      (ReconnectStep.restoringNetwork, l.dashboardReconnectStepRestore),
      (ReconnectStep.waitingForInternet, l.dashboardReconnectStepInternet),
    ];
    final step = controller.step;
    final currentIndex = step == null ? -1 : steps.indexWhere((s) => s.$1 == step);
    final started = controller.startedAt;
    final elapsed = started == null ? Duration.zero : DateTime.now().difference(started);
    final clock = '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l.dashboardReconnectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.dashboardReconnectAttempt(attempt), style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            for (var i = 0; i < steps.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: i < currentIndex
                    ? Icon(Icons.check_circle_rounded, color: context.statusColors.good)
                    : i == currentIndex
                        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : const Icon(Icons.radio_button_unchecked_rounded),
                title: Text(steps[i].$2),
              ),
            const SizedBox(height: 4),
            Text(l.dashboardReconnectElapsed(clock), style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: controller.stopRequested ? null : controller.stop,
            child: Text(controller.stopRequested ? l.dashboardReconnectStopping : l.dashboardReconnectStop),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Cartes

class _DevicesCard extends StatelessWidget {
  const _DevicesCard({required this.snapshot, required this.onOpen});

  final StatusSnapshot snapshot;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final counts = snapshot.deviceCounts;
    return SectionCard(
      title: l.navDevices,
      icon: Icons.devices_other_rounded,
      trailing: TextButton(onPressed: onOpen, child: Text(l.dashboardSeeAll)),
      children: [
        Text(
          l.deviceCount(counts?.total ?? 0),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (counts != null && counts.total > 0)
          Text(l.dashboardDevicesSplit(counts.wifi, counts.wired)),
      ],
    );
  }
}

class _ModemInfoCard extends StatelessWidget {
  const _ModemInfoCard({required this.snapshot});

  final StatusSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sys = snapshot.sysInfo;
    final overview = snapshot.overview;
    final rows = <Widget>[
      if (sys?.uptime != null) InfoTile(label: l.dashboardUptime, value: formatDuration(l, sys!.uptime!)),
      if (sys?.cpuTemperature != null)
        InfoTile(label: l.dashboardCpuTemp, value: l.dashboardTemperature(formatDecimal(context, sys!.cpuTemperature!))),
      if (sys?.systemTime != null) InfoTile(label: l.dashboardSystemTime, value: sys!.systemTime!),
      if (sys?.baseStationId != null) InfoTile(label: l.dashboardBsid, value: sys!.baseStationId!),
      if (sys?.cellId != null) InfoTile(label: l.dashboardCellId, value: sys!.cellId!),
      if ((overview?.softwareVersion ?? '').isNotEmpty)
        InfoTile(label: l.dashboardSoftwareVersion, value: overview!.softwareVersion, copyable: true),
      if ((overview?.hardwareVersion ?? '').isNotEmpty)
        InfoTile(label: l.dashboardHardwareVersion, value: overview!.hardwareVersion, copyable: true),
      if ((overview?.webVersion ?? '').isNotEmpty)
        InfoTile(label: l.dashboardWebVersion, value: overview!.webVersion, copyable: true),
      if ((overview?.imei ?? '').isNotEmpty) InfoTile(label: l.dashboardImei, value: overview!.imei, copyable: true),
      if ((overview?.iccid ?? '').isNotEmpty) InfoTile(label: l.dashboardIccid, value: overview!.iccid, copyable: true),
      if (snapshot.status.imsi.isNotEmpty) InfoTile(label: l.dashboardImsi, value: snapshot.status.imsi, copyable: true),
      if ((overview?.ssid ?? '').isNotEmpty) InfoTile(label: l.dashboardSsid, value: overview!.ssid),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return SectionCard(title: l.dashboardModemSection, icon: Icons.router_outlined, children: rows);
  }
}

class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard({required this.push});

  final void Function(Widget) push;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget tile(IconData icon, String title, Widget screen) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => push(screen),
        );
    return SectionCard(
      title: l.dashboardShortcuts,
      icon: Icons.bolt_rounded,
      children: [
        tile(Icons.qr_code_2_rounded, l.wifiShareQr, const WifiQrScreen()),
        tile(Icons.speed_rounded, l.hubSpeedTestTitle, const SpeedTestScreen()),
        tile(Icons.history_rounded, l.hubOutagesTitle, const OutageLogScreen()),
        tile(Icons.compare_arrows_rounded, l.dashboardCompareOperators, const OperatorComparisonScreen()),
      ],
    );
  }
}
