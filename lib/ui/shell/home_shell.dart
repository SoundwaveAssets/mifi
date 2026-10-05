import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/background/background_tasks.dart';
import '../../core/models/status_models.dart';
import '../../core/monitoring/monitoring_service.dart';
import '../../core/native/native_bridge.dart';
import '../../core/status/status_controller.dart';
import '../../core/util/operators.dart';
import '../l10n_helpers.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/devices/devices_screen.dart';
import '../screens/mobile/mobile_network_screen.dart';
import '../screens/settings_hub/settings_hub_screen.dart';
import '../screens/speed_test/speed_test_screen.dart';
import '../screens/wifi/expel_screen.dart';
import '../screens/wifi/wifi_qr_screen.dart';
import '../background_monitoring.dart';

/// Coque principale (connecté) : Accueil, Appareils, Réglages.
///
/// Gère aussi les alertes globales (nouvel appareil, nouvelle SIM) et les
/// écrans demandés par Android (raccourcis de l'icône, notifications).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final List<StreamSubscription<Object>> _subscriptions = [];
  bool _simDialogOpen = false;

  @override
  void initState() {
    super.initState();
    final status = context.read<StatusController>();
    final bridge = context.read<NativeBridge>();
    _subscriptions
      ..add(status.newDevices.listen(_announceNewDevices))
      ..add(status.simChanges.listen((_) => _showSimChange()))
      ..add(bridge.routes.listen(_openRoute));
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterFirstFrame());
  }

  Future<void> _afterFirstFrame() async {
    final bridge = context.read<NativeBridge>();
    final monitoring = context.read<MonitoringService>();
    final route = await bridge.takeLaunchRoute();
    if (route != null) _openRoute(route);
    // Nouvelle SIM détectée pendant une vérification en arrière-plan.
    if (await monitoring.pendingSimChange() != null) _showSimChange();
    if (!mounted) return;
    // Autorisations : notifications et surveillance continue appli fermée.
    await offerBackgroundMonitoringOnce(context);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  void _openRoute(String route) {
    if (!mounted) return;
    switch (route) {
      case AppRoutes.expelIntruders:
        _push(const ExpelIntrudersScreen());
      case AppRoutes.shareWifi:
        _push(const WifiQrScreen());
      case AppRoutes.speedTest:
        _push(const SpeedTestScreen());
      case AppRoutes.mobileNetwork:
        _push(const MobileNetworkScreen());
      case AppRoutes.devices:
        setState(() => _index = 1);
    }
  }

  /// Alerte « appareil inconnu », avec accès direct à « Expulser les intrus ».
  void _announceNewDevices(List<ConnectedDevice> devices) {
    if (!mounted || devices.isEmpty) return;
    final l = context.l10n;
    final device = devices.first;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 10),
        content: Text(l.notifNewDeviceBody(device.name.isEmpty ? l.unnamedDevice : device.name, device.mac)),
        action: SnackBarAction(label: l.expelTitle, onPressed: () => _push(const ExpelIntrudersScreen())),
      ));
  }

  /// « Nouvelle SIM détectée : opérateur », avec accès aux réglages APN.
  Future<void> _showSimChange() async {
    if (!mounted || _simDialogOpen) return;
    _simDialogOpen = true;
    final l = context.l10n;
    final monitoring = context.read<MonitoringService>();
    final status = context.read<StatusController>().snapshot?.status;
    final imsi = await monitoring.pendingSimChange();
    if (!mounted) {
      _simDialogOpen = false;
      return;
    }
    final operator = status?.serviceName ??
        resolveOperator(imsi ?? status?.imsi)?.let((info) => info.name ?? l.operatorCode(info.code)) ??
        l.operatorUnknown;
    final openApn = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.sim_card_outlined),
        title: Text(l.simChangedTitle),
        content: Text(l.simChangedBody(operator)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.simChangedLater)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l.simChangedOpenApn)),
        ],
      ),
    );
    _simDialogOpen = false;
    await monitoring.acknowledgeSimChange();
    if (openApn == true && mounted) _push(const MobileNetworkScreen());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [DashboardScreen(), DevicesScreen(), SettingsHubScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.devices_other_outlined),
            selectedIcon: const Icon(Icons.devices_other_rounded),
            label: l.navDevices,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) transform) => transform(this);
}
