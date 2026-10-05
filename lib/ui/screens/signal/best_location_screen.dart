import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/status/status_controller.dart';
import '../../../core/util/signal.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/signal_bars.dart';

/// « Trouver le meilleur emplacement » : grande jauge du signal mise à jour
/// toutes les 2,5 s pendant qu'on déplace le modem.
class BestLocationScreen extends StatefulWidget {
  const BestLocationScreen({super.key});

  @override
  State<BestLocationScreen> createState() => _BestLocationScreenState();
}

class _BestLocationScreenState extends State<BestLocationScreen> {
  static const Duration _interval = Duration(milliseconds: 2500);

  late final StatusController _status = context.read<StatusController>();
  late final NativeBridge _bridge = context.read<NativeBridge>();
  Timer? _timer;
  bool _busy = false;
  int? _dbm;
  int? _previous;
  int? _best;
  DateTime? _bestAt;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _status.pause(this);
    _bridge.setKeepScreenOn(true);
    _poll();
    _timer = Timer.periodic(_interval, (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _status.resume(this);
    _bridge.setKeepScreenOn(false);
    super.dispose();
  }

  Future<void> _poll() async {
    if (_busy) return;
    _busy = true;
    try {
      final status = await context.read<ModemApi>().getAllStatus();
      final dbm = status.signalDbm;
      if (!mounted) return;
      setState(() {
        _error = null;
        _previous = _dbm;
        _dbm = isValidSignalDbm(dbm) ? dbm : null;
        if (_dbm != null && (_best == null || _dbm! > _best!)) {
          if (_best != null) HapticFeedback.selectionClick();
          _best = _dbm;
          _bestAt = DateTime.now();
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dbm = _dbm;
    final quality = SignalQuality.fromDbm(dbm);
    final color = switch (quality) {
      SignalQuality.excellent || SignalQuality.good => context.statusColors.good,
      SignalQuality.fair => context.statusColors.warning,
      _ => context.statusColors.bad,
    };
    final trend = dbm == null || _previous == null ? 0 : dbm.compareTo(_previous!);
    return Scaffold(
      appBar: AppBar(title: Text(l.dashboardBestLocation)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.bestLocationInstructions, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.4,
              child: CustomPaint(
                painter: _GaugePainter(
                  dbm: dbm,
                  color: color,
                  track: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dbm == null ? '—' : '$dbm',
                          style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
                        ),
                        Text(l.bestLocationUnit, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignalBars(bars: signalBarsFromDbm(dbm), size: 28, color: color),
                const SizedBox(width: 12),
                Text(signalQualityLabel(l, quality), style: theme.textTheme.titleLarge),
                const SizedBox(width: 12),
                Icon(
                  trend > 0 ? Icons.trending_up_rounded : (trend < 0 ? Icons.trending_down_rounded : Icons.trending_flat_rounded),
                  color: trend > 0 ? context.statusColors.good : (trend < 0 ? context.statusColors.bad : null),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_best != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: Text(l.bestLocationRecord(l.signalDbm(_best!))),
                  subtitle: Text(l.bestLocationRecordAt(formatTime(context, _bestAt!))),
                  trailing: TextButton(
                    onPressed: () => setState(() {
                      _best = _dbm;
                      _bestAt = _dbm == null ? null : DateTime.now();
                    }),
                    child: Text(l.bestLocationReset),
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  describeError(l, _error!),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            Text(l.bestLocationTips, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Jauge en arc de -120 à -50 dBm.
class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.dbm, required this.color, required this.track});

  final int? dbm;
  final Color color;
  final Color track;

  static const double _min = -120;
  static const double _max = -50;
  static const double _sweep = math.pi * 1.5;
  static const double _start = math.pi * 0.75;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width / 2, size.height / 1.25) - 16;
    final center = Offset(size.width / 2, size.height / 2 + radius * 0.15);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final stroke = radius * 0.16;
    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    final value = dbm;
    if (value == null) return;
    final fraction = ((value - _min) / (_max - _min)).clamp(0.0, 1.0);
    canvas.drawArc(
      rect,
      _start,
      _sweep * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.dbm != dbm || old.color != color || old.track != track;
}
