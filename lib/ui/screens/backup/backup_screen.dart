import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/mobile_data/data_cut.dart';
import '../../../core/mobile_data/mobile_data.dart';
import '../../../core/models/dhcp_models.dart';
import '../../../core/models/mobile_models.dart';
import '../../../core/models/wifi_models.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/status/status_controller.dart';
import '../../../core/util/modem_address.dart';
import '../../../l10n/app_localizations.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/async_button.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/modem_restart_dialog.dart';
import '../../widgets/section_card.dart';

/// Sauvegarde (export JSON) et restauration des réglages du modem.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

enum _Section { networkMode, connectionDetect, apn, dhcp, wifi }

enum _StepState { pending, running, done, failed }

class _BackupScreenState extends State<BackupScreen> {
  ModemBackup? _loaded;
  final Set<_Section> _selected = {};
  final Map<_Section, _StepState> _steps = {};
  bool _restoring = false;

  BackupService get _service => BackupService(context.read<ModemApi>());

  Future<void> _export() async {
    final l = context.l10n;
    final bridge = context.read<NativeBridge>();
    final version = context.read<StatusController>().snapshot?.overview?.softwareVersion;
    final backup = await _service.collect(softwareVersion: version);
    if (backup.isEmpty) throw const BackupFormatException('empty');
    final saved = await bridge.saveDocument(
      fileName: 'mifi-sauvegarde-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.json',
      mimeType: 'application/json',
      bytes: utf8.encode(backup.encode()),
    );
    if (mounted) showSnack(context, saved ? l.backupExported : l.backupExportCancelled);
  }

  Future<void> _pick() async {
    final l = context.l10n;
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(
        label: l.backupFileLabel,
        extensions: const ['json'],
        mimeTypes: const ['application/json', 'text/plain', 'application/octet-stream'],
      ),
    ]);
    if (file == null) return;
    try {
      final backup = ModemBackup.parse(await file.readAsString());
      if (!mounted) return;
      setState(() {
        _loaded = backup;
        _steps.clear();
        _selected
          ..clear()
          ..addAll(_available(backup));
      });
    } on BackupFormatException {
      if (mounted) showSnack(context, l.backupInvalidFile, error: true);
    }
  }

  List<_Section> _available(ModemBackup b) => [
        if (b.networkMode != null) _Section.networkMode,
        if (b.connectionDetect != null) _Section.connectionDetect,
        if (b.apnCurrent != null) _Section.apn,
        if (b.dhcp != null) _Section.dhcp,
        if (b.wifi != null) _Section.wifi,
      ];

  String _title(AppLocalizations l, _Section s) => switch (s) {
        _Section.networkMode => l.mobileModeSection,
        _Section.connectionDetect => l.mobileDetectSection,
        _Section.apn => l.mobileApnSection,
        _Section.dhcp => l.hubDhcpTitle,
        _Section.wifi => l.hubWifiTitle,
      };

  String _summary(AppLocalizations l, ModemBackup b, _Section s) => switch (s) {
        _Section.networkMode => networkModeLabel(l, b.networkMode!),
        _Section.connectionDetect =>
          ConnectionDetectConfig(b.connectionDetect!).enabled ? l.commonEnabled : l.commonDisabled,
        _Section.apn => '${ApnProfile(b.apnCurrent!).name} (${ApnProfile(b.apnCurrent!).apn})',
        _Section.dhcp => '${DhcpInfo(b.dhcp!).gatewayIp} · ${DhcpInfo(b.dhcp!).poolStart} – ${DhcpInfo(b.dhcp!).poolEnd}',
        _Section.wifi => WifiInfo(b.wifi!).ssid,
      };

  Future<void> _restore() async {
    final backup = _loaded;
    if (backup == null || _selected.isEmpty) return;
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.backupRestoreTitle,
      message: l.backupRestoreWarning,
      confirmLabel: l.backupRestore,
      icon: Icons.restore_rounded,
    );
    if (!ok || !mounted) return;
    final session = context.read<SessionController>();
    final bridge = context.read<NativeBridge>();
    final dataCut = context.read<ApnDataCut>();
    final mobileData = context.read<MobileDataController>();
    final service = _service;
    final order = _Section.values.where(_selected.contains).toList();
    setState(() {
      _restoring = true;
      _steps
        ..clear()
        ..addEntries(order.map((s) => MapEntry(s, _StepState.pending)));
    });
    WifiInfo? appliedWifi;
    for (final section in order) {
      setState(() => _steps[section] = _StepState.running);
      try {
        switch (section) {
          case _Section.networkMode:
            await service.applyNetworkMode(backup.networkMode!);
          case _Section.connectionDetect:
            await service.applyConnectionDetect(backup.connectionDetect!);
          case _Section.apn:
            await service.applyApn(backup.apnCurrent!);
            // Profil choisi par l'utilisateur : les coupures en cours sont levées.
            await dataCut.forget();
            unawaited(mobileData.refresh());
          case _Section.dhcp:
            final newGateway = await service.applyDhcp(backup.dhcp!);
            if (newGateway != null) {
              await session.setModemAddress(ModemAddress.normalize(newGateway) ?? newGateway);
            }
            if (!mounted) return;
            final back = await showModemRestartDialog(context, initialDelay: const Duration(seconds: 20));
            if (!back) throw const BackupFormatException('modem not back');
          case _Section.wifi:
            appliedWifi = await service.applyWifi(backup.wifi!);
        }
        if (mounted) setState(() => _steps[section] = _StepState.done);
      } catch (e) {
        if (!mounted) return;
        setState(() => _steps[section] = _StepState.failed);
        showErrorSnack(context, e is BackupFormatException ? l.restartTimeout : e);
        if (section == _Section.dhcp) break;
      }
    }
    if (!mounted) return;
    setState(() => _restoring = false);
    final wifi = appliedWifi;
    if (wifi != null) {
      final reconnect = await showConfirmDialog(
        context,
        title: l.backupWifiAppliedTitle,
        message: l.backupWifiApplied(wifi.ssid),
        confirmLabel: l.expelReconnectPhone,
        icon: Icons.wifi_rounded,
      );
      if (reconnect) {
        await bridge.suggestWifiNetwork(ssid: wifi.ssid, password: wifi.password, hidden: !wifi.broadcastSsid);
      }
    } else {
      showSnack(context, l.backupRestored);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final backup = _loaded;
    return Scaffold(
      appBar: AppBar(title: Text(l.hubBackupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: l.backupExportSection,
            icon: Icons.upload_file_rounded,
            children: [
              Text(l.backupExportHint),
              const SizedBox(height: 8),
              WarningBanner(message: l.backupPrivacy, severity: BannerSeverity.info),
              const SizedBox(height: 12),
              AsyncButton(onPressed: _export, label: l.backupExport, icon: Icons.save_alt_rounded),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l.backupImportSection,
            icon: Icons.restore_rounded,
            children: [
              Text(l.backupImportHint),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _restoring ? null : _pick,
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(l.backupChooseFile),
              ),
              if (backup != null) ...[
                const SizedBox(height: 12),
                Text(l.backupFileDate(formatFullDateTime(context, backup.createdAt)), style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                for (final section in _available(backup))
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selected.contains(section),
                    onChanged: _restoring
                        ? null
                        : (value) => setState(() => value == true ? _selected.add(section) : _selected.remove(section)),
                    title: Text(_title(l, section)),
                    subtitle: Text(_summary(l, backup, section)),
                    secondary: switch (_steps[section]) {
                      _StepState.running =>
                        const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
                      _StepState.done => Icon(Icons.check_circle_rounded, color: context.statusColors.good),
                      _StepState.failed => Icon(Icons.error_rounded, color: theme.colorScheme.error),
                      _ => null,
                    },
                  ),
                const SizedBox(height: 8),
                Text(l.backupOrderNote, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _restoring || _selected.isEmpty ? null : _restore,
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(l.backupRestore),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
