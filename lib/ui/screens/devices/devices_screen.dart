import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/data/app_data_store.dart';
import '../../../core/models/status_models.dart';
import '../../../core/status/status_controller.dart';
import '../../l10n_helpers.dart';
import '../../widgets/feedback.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';
import '../wifi/expel_screen.dart';

/// Appareils connectés au modem : nom (ou surnom), type, IP, MAC ; appareils
/// déjà vus ; surnoms mémorisés par adresse MAC.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  Map<String, KnownDevice> _known = {};
  DateTime? _knownFor;

  static const Duration _newFor = Duration(hours: 24);

  Future<void> _loadKnown() async {
    final list = await context.read<AppDataStore>().knownDevices();
    if (mounted) setState(() => _known = {for (final d in list) d.mac: d});
  }

  void _syncKnown(StatusSnapshot? snapshot) {
    final time = snapshot?.time;
    if (time == null || time == _knownFor) return;
    _knownFor = time;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadKnown());
  }

  Future<void> _refresh() async {
    await context.read<StatusController>().refresh();
    await _loadKnown();
  }

  Future<void> _rename(String mac, String? currentNickname) async {
    final l = context.l10n;
    final controller = TextEditingController(text: currentNickname ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.devicesRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(labelText: l.devicesNickname, helperText: l.devicesNicknameHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(l.commonSave)),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    await context.read<AppDataStore>().setNickname(mac, result);
    await _loadKnown();
  }

  void _showDetails(ConnectedDevice? device, KnownDevice? known) {
    final l = context.l10n;
    final mac = device?.mac ?? known!.mac;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_displayName(device, known), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (device != null) _detail(l.commonTypeLabel, deviceTypeLabel(l, device.type)),
              if ((device?.ip ?? known?.lastIp ?? '').isNotEmpty)
                _detail(l.devicesIp, device?.ip ?? known!.lastIp!, copy: true),
              _detail(l.devicesMac, mac, copy: true),
              if ((device?.name ?? known?.lastName ?? '').isNotEmpty)
                _detail(l.devicesAnnouncedName, device?.name ?? known!.lastName!),
              if (known != null) ...[
                _detail(l.devicesFirstSeen, formatFullDateTime(context, known.firstSeen)),
                _detail(l.devicesLastSeen, formatFullDateTime(context, known.lastSeen)),
              ],
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _rename(mac, known?.nickname);
                },
                icon: const Icon(Icons.edit_rounded),
                label: Text(l.devicesRename),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExpelIntrudersScreen()));
                },
                icon: const Icon(Icons.shield_outlined),
                label: Text(l.expelTitle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value, {bool copy = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: copy
          ? IconButton(
              tooltip: context.l10n.commonCopy,
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (mounted) showSnack(context, context.l10n.commonCopied);
              },
            )
          : null,
    );
  }

  String _displayName(ConnectedDevice? device, KnownDevice? known) {
    final nickname = known?.nickname;
    if (nickname != null && nickname.isNotEmpty) return nickname;
    final name = device?.name ?? known?.lastName ?? '';
    return name.isEmpty ? context.l10n.unnamedDevice : name;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = context.watch<StatusController>();
    final snapshot = status.snapshot;
    _syncKnown(snapshot);
    final devices = snapshot?.devices;

    final Widget body;
    if (devices == null) {
      body = status.error != null && !status.isRefreshing
          ? ErrorView(error: status.error!, onRetry: _refresh)
          : const LoadingView();
    } else {
      final counts = DeviceCounts.of(devices);
      final connectedMacs = devices.map((d) => d.mac).toSet();
      final offline = _known.values.where((k) => !connectedMacs.contains(k.mac)).toList()
        ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
      final now = DateTime.now();
      body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (status.isStale) ...[
              WarningBanner(title: l.commonDataStale, message: describeError(l, status.error!)),
              const SizedBox(height: 12),
            ],
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.devices_other_rounded, size: 40, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.deviceCount(counts.total), style: Theme.of(context).textTheme.headlineSmall),
                          Text(l.dashboardDevicesSplit(counts.wifi, counts.wired)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (devices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.devicesNoneConnected, textAlign: TextAlign.center),
              )
            else
              SectionCard(
                title: l.devicesConnected,
                icon: Icons.wifi_rounded,
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                children: [
                  for (final device in devices)
                    _DeviceTile(
                      title: _displayName(device, _known[device.mac]),
                      subtitle: [
                        if ((_known[device.mac]?.nickname ?? '').isNotEmpty && device.name.isNotEmpty) device.name,
                        device.ip,
                        device.mac,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      icon: switch (device.type) {
                        DeviceConnectionType.wifi => Icons.wifi_rounded,
                        DeviceConnectionType.wired => Icons.settings_ethernet_rounded,
                        DeviceConnectionType.unknown => Icons.device_unknown_rounded,
                      },
                      isNew: _known[device.mac] == null || now.difference(_known[device.mac]!.firstSeen) < _newFor,
                      onTap: () => _showDetails(device, _known[device.mac]),
                      onRename: () => _rename(device.mac, _known[device.mac]?.nickname),
                    ),
                ],
              ),
            if (offline.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: l.devicesSeenBefore,
                icon: Icons.history_rounded,
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                children: [
                  for (final known in offline)
                    _DeviceTile(
                      title: _displayName(null, known),
                      subtitle: '${known.mac} · ${l.devicesLastSeenShort(formatDateTime(context, known.lastSeen))}',
                      icon: Icons.devices_outlined,
                      dimmed: true,
                      onTap: () => _showDetails(null, known),
                      onRename: () => _rename(known.mac, known.nickname),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(l.devicesNoBlockingNote, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navDevices),
        actions: [
          IconButton(
            tooltip: l.expelTitle,
            icon: const Icon(Icons.shield_outlined),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExpelIntrudersScreen())),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onRename,
    this.isNew = false,
    this.dimmed = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  /// Donner un surnom : bouton visible sur chaque ligne.
  final VoidCallback onRename;
  final bool isNew;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: dimmed ? scheme.surfaceContainerHighest : scheme.primaryContainer,
        foregroundColor: dimmed ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
        child: Icon(icon),
      ),
      title: Row(
        children: [
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          if (isNew) ...[
            const SizedBox(width: 8),
            Badge(label: Text(context.l10n.devicesNewBadge), backgroundColor: scheme.tertiary),
          ],
        ],
      ),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: context.l10n.devicesRename,
        icon: const Icon(Icons.edit_rounded),
        onPressed: onRename,
      ),
    );
  }
}
