import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/data/app_data_store.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/status/status_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/section_card.dart';

/// Journal des coupures d'internet, avec résumé 24 h / 7 jours et export CSV.
class OutageLogScreen extends StatefulWidget {
  const OutageLogScreen({super.key});

  @override
  State<OutageLogScreen> createState() => _OutageLogScreenState();
}

class _OutageLogScreenState extends State<OutageLogScreen> {
  List<Outage>? _outages;
  Timer? _ticker;
  DateTime? _lastSnapshot;

  @override
  void initState() {
    super.initState();
    _load();
    // Durée des coupures en cours, mise à jour chaque seconde.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (_outages?.any((o) => o.isOngoing) ?? false)) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final outages = await context.read<AppDataStore>().recentOutages(limit: 500);
    if (mounted) setState(() => _outages = outages);
  }

  Future<void> _clear() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.outagesClearTitle,
      message: l.outagesClearMessage,
      confirmLabel: l.commonDelete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<AppDataStore>().clearOutages();
    await _load();
  }

  Future<void> _exportCsv() async {
    final l = context.l10n;
    final outages = _outages ?? const <Outage>[];
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final now = DateTime.now();
    final buffer = StringBuffer()
      ..writeln([l.outagesCsvStart, l.outagesCsvEnd, l.outagesCsvMinutes, l.outagesCsvPlanned, l.outagesCsvOperator]
          .map(_csv)
          .join(';'));
    for (final outage in outages.reversed) {
      buffer.writeln([
        format.format(outage.start),
        outage.end == null ? l.outagesOngoing : format.format(outage.end!),
        (outage.duration(now).inSeconds / 60).toStringAsFixed(1),
        outage.planned ? l.commonYes : l.commonNo,
        outage.operatorCode ?? '',
      ].map(_csv).join(';'));
    }
    // BOM UTF-8 : Excel affiche correctement les accents.
    final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(buffer.toString())]);
    final saved = await context.read<NativeBridge>().saveDocument(
          fileName: 'mifi-coupures-${DateFormat('yyyyMMdd-HHmm').format(now)}.csv',
          mimeType: 'text/csv',
          bytes: bytes,
        );
    if (mounted) showSnack(context, saved ? l.outagesExported : l.outagesExportCancelled);
  }

  static String _csv(String value) =>
      value.contains(RegExp('[;"\n]')) ? '"${value.replaceAll('"', '""')}"' : value;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Recharger quand un nouveau relevé arrive.
    final snapshotTime = context.select<StatusController, DateTime?>((s) => s.snapshot?.time);
    if (snapshotTime != null && snapshotTime != _lastSnapshot) {
      _lastSnapshot = snapshotTime;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
    final outages = _outages;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.hubOutagesTitle),
        actions: [
          IconButton(
            tooltip: l.outagesExport,
            icon: const Icon(Icons.file_download_outlined),
            onPressed: outages == null || outages.isEmpty ? null : _exportCsv,
          ),
          IconButton(
            tooltip: l.outagesClearTitle,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: outages == null || outages.isEmpty ? null : _clear,
          ),
        ],
      ),
      body: outages == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Summary(outages: outages),
                  const SizedBox(height: 16),
                  if (outages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(l.outagesEmpty, textAlign: TextAlign.center),
                    )
                  else
                    ..._grouped(context, l, outages),
                  const SizedBox(height: 12),
                  Text(l.outagesNote, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
    );
  }

  List<Widget> _grouped(BuildContext context, AppLocalizations l, List<Outage> outages) {
    final dayFormat = DateFormat.yMMMMEEEEd(l.localeName);
    final widgets = <Widget>[];
    DateTime? currentDay;
    for (final outage in outages) {
      final day = DateTime(outage.start.year, outage.start.month, outage.start.day);
      if (day != currentDay) {
        currentDay = day;
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(dayFormat.format(day), style: Theme.of(context).textTheme.titleSmall),
        ));
      }
      widgets.add(_OutageTile(outage: outage));
    }
    return widgets;
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.outages});

  final List<Outage> outages;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    (int, Duration) stats(Duration window) {
      final from = now.subtract(window);
      var count = 0;
      var total = Duration.zero;
      for (final o in outages.where((o) => !o.planned)) {
        final end = o.end ?? now;
        if (end.isBefore(from)) continue;
        final start = o.start.isBefore(from) ? from : o.start;
        count++;
        total += end.difference(start);
      }
      return (count, total);
    }

    final day = stats(const Duration(hours: 24));
    final week = stats(const Duration(days: 7));
    return SectionCard(
      title: l.outagesSummary,
      icon: Icons.insights_rounded,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.outagesLast24h),
          subtitle: Text(l.outagesCountDuration(day.$1, formatDuration(l, day.$2))),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.outagesLast7d),
          subtitle: Text(l.outagesCountDuration(week.$1, formatDuration(l, week.$2))),
        ),
      ],
    );
  }
}

class _OutageTile extends StatelessWidget {
  const _OutageTile({required this.outage});

  final Outage outage;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final ongoing = outage.isOngoing;
    final color = outage.planned
        ? theme.colorScheme.onSurfaceVariant
        : (ongoing ? context.statusColors.bad : context.statusColors.warning);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(outage.planned ? Icons.mobiledata_off_rounded : Icons.signal_wifi_connected_no_internet_4_rounded, color: color),
        title: Text(formatDuration(l, outage.duration())),
        subtitle: Text(ongoing
            ? l.outagesSince(formatTime(context, outage.start))
            : l.outagesFromTo(formatTime(context, outage.start), formatTime(context, outage.end!))),
        trailing: outage.planned
            ? Chip(label: Text(l.outagesPlanned), visualDensity: VisualDensity.compact)
            : (ongoing ? Chip(label: Text(l.outagesOngoing), visualDensity: VisualDensity.compact) : null),
      ),
    );
  }
}
