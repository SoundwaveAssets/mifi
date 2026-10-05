import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/native/native_bridge.dart';
import '../core/settings/app_settings.dart';
import 'l10n_helpers.dart';
import 'widgets/dialogs.dart';

/// Au premier lancement après la connexion : explique la surveillance
/// continue et demande l'autorisation de fonctionner en arrière-plan. Ne
/// pose la question qu'une fois (réglable ensuite dans les réglages).
Future<void> offerBackgroundMonitoringOnce(BuildContext context) async {
  final settings = context.read<AppSettings>();
  final bridge = context.read<NativeBridge>();
  if (settings.monitorPermissionAsked) {
    if (settings.monitorEnabled) await bridge.startMonitor();
    return;
  }
  await settings.setMonitorPermissionAsked(true);
  if (!context.mounted) return;
  final l = context.l10n;
  final accepted = await showConfirmDialog(
    context,
    title: l.monitorPermissionTitle,
    message: l.monitorPermissionMessage,
    confirmLabel: l.monitorPermissionAllow,
    icon: Icons.notifications_active_outlined,
  );
  if (!context.mounted) return;
  if (accepted) {
    await enableBackgroundMonitoring(context);
  } else if (!settings.notificationPermissionAsked) {
    // Les alertes restent utiles appli ouverte.
    await settings.setNotificationPermissionAsked(true);
    await bridge.requestNotificationPermission();
  }
}

/// Active la surveillance continue : autorisation des notifications, puis
/// fonctionnement en arrière-plan sans restriction de batterie (demandes
/// système), puis démarrage du service. Renvoie `false` si Android a refusé
/// le démarrage.
Future<bool> enableBackgroundMonitoring(BuildContext context) async {
  final settings = context.read<AppSettings>();
  final bridge = context.read<NativeBridge>();
  await settings.setNotificationPermissionAsked(true);
  await bridge.requestNotificationPermission();
  if (!await bridge.isIgnoringBatteryOptimizations()) await bridge.requestIgnoreBatteryOptimizations();
  await settings.setMonitorEnabled(true);
  return bridge.startMonitor();
}

/// Désactive la surveillance continue.
Future<void> disableBackgroundMonitoring(BuildContext context) async {
  final settings = context.read<AppSettings>();
  final bridge = context.read<NativeBridge>();
  await settings.setMonitorEnabled(false);
  await bridge.stopMonitor();
}
