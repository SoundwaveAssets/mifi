import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/app_data_store.dart';
import '../../../core/util/signal.dart';
import '../../l10n_helpers.dart';
import '../../widgets/section_card.dart';
import 'best_location_screen.dart';
import 'signal_chart.dart';

/// Historique du signal : dernière heure ou dernières 24 h.
class SignalHistoryScreen extends StatefulWidget {
  const SignalHistoryScreen({super.key});

  @override
  State<SignalHistoryScreen> createState() => _SignalHistoryScreenState();
}

class _SignalHistoryScreenState extends State<SignalHistoryScreen> {
  Duration _range = const Duration(hours: 1);
  List<SignalSample> _samples = const [];
  DateTime _now = DateTime.now();
  Timer? _timer;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    // Les mesures arrivent toutes les 10 s pendant que l'appli est ouverte.
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final samples = await context.read<AppDataStore>().signalSamplesSince(now.subtract(_range));
    if (!mounted) return;
    setState(() {
      _now = now;
      _samples = samples;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final values = _samples.map((s) => s.dbm).toList();
    final current = values.isEmpty ? null : values.last;
    final minimum = values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b);
    final maximum = values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b);
    final average = values.isEmpty ? null : (values.reduce((a, b) => a + b) / values.length).round();
    return Scaffold(
      appBar: AppBar(title: Text(l.hubSignalTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<Duration>(
            segments: [
              ButtonSegment(value: const Duration(hours: 1), label: Text(l.signalLastHour)),
              ButtonSegment(value: const Duration(hours: 24), label: Text(l.signalLast24h)),
            ],
            selected: {_range},
            onSelectionChanged: (selection) {
              setState(() => _range = selection.first);
              _load();
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
              child: !_loaded
                  ? const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
                  : values.isEmpty
                      ? SizedBox(
                          height: 220,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(l.signalEmpty, textAlign: TextAlign.center),
                            ),
                          ),
                        )
                      : SignalChart(
                          samples: _samples,
                          from: _now.subtract(_range),
                          to: _now,
                          locale: l.localeName,
                        ),
            ),
          ),
          const SizedBox(height: 16),
          if (current != null)
            SectionCard(
              title: l.signalStats,
              icon: Icons.insights_rounded,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(label: l.signalCurrent, value: l.signalDbm(current), hint: signalQualityLabel(l, SignalQuality.fromDbm(current))),
                    _Stat(label: l.signalAverage, value: l.signalDbm(average!)),
                    _Stat(label: l.signalBest, value: l.signalDbm(maximum!)),
                    _Stat(label: l.signalWorst, value: l.signalDbm(minimum!)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l.signalSamplesCount(values.length), style: theme.textTheme.bodySmall),
              ],
            ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BestLocationScreen())),
            icon: const Icon(Icons.explore_outlined),
            label: Text(l.dashboardBestLocation),
          ),
          const SizedBox(height: 12),
          Text(l.signalHowItWorks, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge),
          if (hint != null) Text(hint!, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
