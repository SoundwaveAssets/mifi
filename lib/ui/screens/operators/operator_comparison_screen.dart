import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/app_data_store.dart';
import '../../../core/monitoring/monitoring_service.dart';
import '../../../core/util/signal.dart';
import '../../l10n_helpers.dart';
import '../../widgets/signal_bars.dart';

/// Statistiques d'un opérateur sur les 7 derniers jours.
class _OperatorStats {
  _OperatorStats(this.code);

  final String code;
  String? serviceName;
  final List<int> signal = [];
  final List<double> speeds = [];
  int outages = 0;
  Duration downtime = Duration.zero;
  DateTime? lastSeen;

  int? get averageDbm => signal.isEmpty ? null : (signal.reduce((a, b) => a + b) / signal.length).round();
  double? get averageMbps => speeds.isEmpty ? null : speeds.reduce((a, b) => a + b) / speeds.length;
  double? get bestMbps => speeds.isEmpty ? null : speeds.reduce((a, b) => a > b ? a : b);
}

/// Comparatif des opérateurs (selon la SIM utilisée) : signal moyen, débit
/// et coupures sur les 7 derniers jours.
class OperatorComparisonScreen extends StatefulWidget {
  const OperatorComparisonScreen({super.key});

  @override
  State<OperatorComparisonScreen> createState() => _OperatorComparisonScreenState();
}

class _OperatorComparisonScreenState extends State<OperatorComparisonScreen> {
  static const Duration _window = Duration(days: 7);
  List<_OperatorStats>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = context.read<AppDataStore>();
    final monitoring = context.read<MonitoringService>();
    final now = DateTime.now();
    final from = now.subtract(_window);
    final byCode = <String, _OperatorStats>{};
    _OperatorStats stats(String code) => byCode.putIfAbsent(code, () => _OperatorStats(code));

    for (final sample in await store.signalSamplesSince(from)) {
      final code = sample.operatorCode;
      if (code == null) continue;
      final s = stats(code)..signal.add(sample.dbm);
      if (s.lastSeen == null || sample.time.isAfter(s.lastSeen!)) s.lastSeen = sample.time;
    }
    for (final test in await store.recentSpeedTests(limit: 500)) {
      final code = test.operatorCode;
      if (code == null || test.time.isBefore(from)) continue;
      stats(code).speeds.add(test.megabitsPerSecond);
    }
    for (final outage in await store.outagesSince(from)) {
      final code = outage.operatorCode;
      if (code == null || outage.planned) continue;
      final s = stats(code);
      s.outages++;
      final start = outage.start.isBefore(from) ? from : outage.start;
      s.downtime += (outage.end ?? now).difference(start);
    }
    for (final s in byCode.values) {
      s.serviceName = await monitoring.serviceNameFor(s.code);
    }
    final list = byCode.values.toList()
      ..sort((a, b) => (b.averageDbm ?? -200).compareTo(a.averageDbm ?? -200));
    if (mounted) setState(() => _stats = list);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final stats = _stats;
    return Scaffold(
      appBar: AppBar(title: Text(l.dashboardCompareOperators)),
      body: stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l.compareIntro, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  if (stats.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(l.compareEmpty, textAlign: TextAlign.center),
                    ),
                  for (final s in stats) _OperatorCard(stats: s),
                ],
              ),
            ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  const _OperatorCard({required this.stats});

  final _OperatorStats stats;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dbm = stats.averageDbm;
    final average = stats.averageMbps;
    final best = stats.bestMbps;
    Widget metric(IconData icon, String label, String value) => Expanded(
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SignalBars(bars: signalBarsFromDbm(dbm), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operatorCodeLabel(l, stats.code, serviceName: stats.serviceName),
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(stats.code, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                metric(Icons.network_cell_rounded, l.compareSignal, dbm == null ? '—' : l.signalDbm(dbm)),
                metric(Icons.speed_rounded, l.compareSpeed,
                    average == null ? '—' : l.speedTestMbps(formatDecimal(context, average))),
                metric(Icons.signal_wifi_connected_no_internet_4_rounded, l.compareOutages,
                    '${stats.outages} · ${formatDuration(l, stats.downtime)}'),
              ],
            ),
            if (best != null || stats.lastSeen != null) ...[
              const SizedBox(height: 12),
              Text(
                [
                  if (best != null) l.compareBestSpeed(l.speedTestMbps(formatDecimal(context, best))),
                  if (stats.lastSeen != null) l.compareLastUsed(formatDateTime(context, stats.lastSeen!)),
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
