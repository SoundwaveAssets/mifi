import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/app_data_store.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/status/status_controller.dart';
import '../../../core/util/speed.dart';
import '../../../l10n/app_localizations.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/section_card.dart';
import 'speed_tester.dart';

/// Test de débit à travers le modem, avec historique.
class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final _tester = SpeedTester();
  bool _running = false;
  int _received = 0;
  int _target = 0;
  Duration _elapsed = Duration.zero;
  SpeedTestResult? _last;
  List<SpeedTestResult> _history = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _tester.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await context.read<AppDataStore>().recentSpeedTests();
    if (mounted) setState(() => _history = history);
  }

  Future<void> _start() async {
    final l = context.l10n;
    final settings = context.read<AppSettings>();
    final store = context.read<AppDataStore>();
    final operatorCode = context.read<StatusController>().snapshot?.operator?.code;
    // Hors du Wi-Fi du modem, le test mesurerait les données du téléphone.
    final wifi = await context.read<NativeBridge>().bindToWifi();
    if (!mounted) return;
    if (wifi.supported && !wifi.bound) {
      showSnack(context, l.speedTestNotOnModemWifi, error: true);
      return;
    }
    final bytes = settings.speedTestSizeMb * 1000 * 1000;
    setState(() {
      _running = true;
      _received = 0;
      _target = bytes;
      _elapsed = Duration.zero;
    });
    try {
      final result = await _tester.run(
        bytes: bytes,
        operatorCode: operatorCode,
        onProgress: (received, elapsed) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _elapsed = elapsed;
          });
        },
      );
      final stored = await store.addSpeedTest(result);
      if (!mounted) return;
      setState(() => _last = stored);
      await _loadHistory();
    } on SpeedTestException catch (e) {
      if (mounted && e.kind != SpeedTestFailure.cancelled) showSnack(context, _failure(l, e.kind), error: true);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  String _failure(AppLocalizations l, SpeedTestFailure kind) => switch (kind) {
        SpeedTestFailure.noInternet => l.speedTestNoInternet,
        SpeedTestFailure.timeout => l.speedTestTimeout,
        SpeedTestFailure.server => l.speedTestServer,
        SpeedTestFailure.cancelled => l.errorCancelled,
      };

  Future<void> _clear() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.speedTestClearTitle,
      message: l.speedTestClearMessage,
      confirmLabel: l.commonDelete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<AppDataStore>().clearSpeedTests();
    setState(() => _last = null);
    await _loadHistory();
  }

  String _mbps(double value) => formatDecimal(context, value);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final settings = context.watch<AppSettings>();
    // Les premiers paquets arrivent en rafale : pas de débit affiché avant
    // une demi-seconde de transfert (sinon un pic trompeur).
    final liveMbps = _elapsed >= const Duration(milliseconds: 500) ? _received * 8 / _elapsed.inMicroseconds : null;
    final shownMbps = _running ? liveMbps : _last?.megabitsPerSecond;
    final quality = shownMbps == null ? null : SpeedQuality.fromMbps(shownMbps);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.hubSpeedTestTitle),
        actions: [
          IconButton(
            tooltip: l.speedTestClearTitle,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _history.isEmpty || _running ? null : _clear,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: l.speedTestSize,
            icon: Icons.data_usage_rounded,
            children: [
              SegmentedButton<int>(
                segments: [
                  for (final size in AppSettings.speedTestSizes)
                    ButtonSegment(value: size, label: Text(l.speedTestMegabytes(size))),
                ],
                selected: {settings.speedTestSizeMb},
                onSelectionChanged: _running ? null : (s) => settings.setSpeedTestSizeMb(s.first),
              ),
              const SizedBox(height: 8),
              Text(l.speedTestDataWarning, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    _running
                        ? (liveMbps == null ? '…' : l.speedTestMbps(_mbps(liveMbps)))
                        : (_last == null ? '—' : l.speedTestMbps(_mbps(_last!.megabitsPerSecond))),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (quality != null) ...[
                    const SizedBox(height: 12),
                    _SpeedQualityView(quality: quality),
                  ],
                  const SizedBox(height: 8),
                  if (_running) ...[
                    LinearProgressIndicator(value: _target == 0 ? null : (_received / _target).clamp(0.0, 1.0)),
                    const SizedBox(height: 8),
                    Text(l.speedTestProgress(_mbps(_received / 1e6), '${_target ~/ 1000000}')),
                  ] else if (_last != null)
                    Text(
                      l.speedTestDetails(
                        _mbps(_last!.bytes / 1e6),
                        '${_last!.latency?.inMilliseconds ?? 0}',
                      ),
                      style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  const SizedBox(height: 16),
                  _running
                      ? OutlinedButton.icon(
                          onPressed: _tester.cancel,
                          icon: const Icon(Icons.stop_rounded),
                          label: Text(l.commonCancel),
                        )
                      : FilledButton.icon(
                          onPressed: _start,
                          icon: const Icon(Icons.speed_rounded),
                          label: Text(l.speedTestStart),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l.speedTestHistory,
            icon: Icons.history_rounded,
            children: [
              if (_history.isEmpty) Text(l.speedTestEmpty),
              for (final test in _history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.speed_rounded,
                    color: speedQualityColor(context, SpeedQuality.fromMbps(test.megabitsPerSecond)),
                  ),
                  title: Text([
                    l.speedTestMbps(_mbps(test.megabitsPerSecond)),
                    speedQualityLabel(l, SpeedQuality.fromMbps(test.megabitsPerSecond)),
                  ].join(' · ')),
                  subtitle: Text([
                    formatDateTime(context, test.time),
                    l.speedTestMegabytes((test.bytes / 1e6).round()),
                    if (test.operatorCode != null) operatorCodeLabel(l, test.operatorCode!),
                  ].join(' · ')),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l.speedTestHow, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(l.speedQualityScale, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Couleur d'une qualité de débit : vert (bon, excellent), orange (moyen),
/// rouge (faible, inexistant).
Color speedQualityColor(BuildContext context, SpeedQuality quality) {
  final colors = context.statusColors;
  return switch (quality) {
    SpeedQuality.good || SpeedQuality.excellent => colors.good,
    SpeedQuality.fair => colors.warning,
    SpeedQuality.poor || SpeedQuality.none => colors.bad,
  };
}

/// Qualité du débit : jauge à 4 segments (comme les barres de signal),
/// niveau et usages possibles.
class _SpeedQualityView extends StatelessWidget {
  const _SpeedQualityView({required this.quality});

  final SpeedQuality quality;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimaryContainer;
    final color = speedQualityColor(context, quality);
    return Semantics(
      label: '${l.speedQualityTitle}, ${speedQualityLabel(l, quality)}',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 4; i++) ...[
                if (i > 1) const SizedBox(width: 6),
                Container(
                  width: 36,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i <= quality.index ? color : onCard.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(l.speedQualityTitle, style: theme.textTheme.labelMedium?.copyWith(color: onCard)),
          Text(
            speedQualityLabel(l, quality),
            style: theme.textTheme.titleLarge?.copyWith(color: onCard, fontWeight: FontWeight.w700),
          ),
          Text(
            speedQualityHint(l, quality),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
          ),
        ],
      ),
    );
  }
}
