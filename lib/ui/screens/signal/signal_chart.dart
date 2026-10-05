import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/data/app_data_store.dart';

/// Graphique du signal (dBm) dans le temps, dessiné sans dépendance :
/// bandes de qualité (seuils des barres), courbe, points isolés quand deux
/// mesures sont éloignées de plus de 2 minutes.
class SignalChart extends StatelessWidget {
  const SignalChart({super.key, required this.samples, required this.from, required this.to, required this.locale});

  final List<SignalSample> samples;
  final DateTime from;
  final DateTime to;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: const Size(double.infinity, 220),
      painter: _SignalChartPainter(
        samples: samples,
        from: from,
        to: to,
        lineColor: theme.colorScheme.primary,
        gridColor: theme.colorScheme.outlineVariant,
        labelStyle: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
        bandColors: [
          const Color(0xFF2E7D32).withValues(alpha: 0.10),
          const Color(0xFF9E9D24).withValues(alpha: 0.10),
          const Color(0xFFEF6C00).withValues(alpha: 0.10),
          const Color(0xFFC62828).withValues(alpha: 0.10),
        ],
        timeFormat: DateFormat.Hm(locale),
      ),
    );
  }
}

class _SignalChartPainter extends CustomPainter {
  _SignalChartPainter({
    required this.samples,
    required this.from,
    required this.to,
    required this.lineColor,
    required this.gridColor,
    required this.labelStyle,
    required this.bandColors,
    required this.timeFormat,
  });

  final List<SignalSample> samples;
  final DateTime from;
  final DateTime to;
  final Color lineColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final List<Color> bandColors;
  final DateFormat timeFormat;

  static const double _minDbm = -120;
  static const double _maxDbm = -50;
  static const double _left = 38;
  static const double _bottom = 22;
  static const Duration _gap = Duration(minutes: 2);

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(_left, 6, size.width - 6, size.height - _bottom);
    double y(num dbm) => chart.bottom - (dbm.clamp(_minDbm, _maxDbm) - _minDbm) / (_maxDbm - _minDbm) * chart.height;
    final span = to.difference(from).inMilliseconds.toDouble();
    double x(DateTime t) => chart.left + (t.difference(from).inMilliseconds / span).clamp(0, 1) * chart.width;

    // Bandes de qualité : ≥ -85 (4 barres), ≥ -95, ≥ -105, < -105.
    final bands = [(-85.0, _maxDbm), (-95.0, -85.0), (-105.0, -95.0), (_minDbm, -105.0)];
    for (var i = 0; i < bands.length; i++) {
      canvas.drawRect(
        Rect.fromLTRB(chart.left, y(bands[i].$2), chart.right, y(bands[i].$1)),
        Paint()..color = bandColors[i],
      );
    }

    // Graduations horizontales (dBm).
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final dbm in [-60, -80, -100, -120]) {
      canvas.drawLine(Offset(chart.left, y(dbm)), Offset(chart.right, y(dbm)), grid);
      _text(canvas, '$dbm', Offset(0, y(dbm) - 7), width: _left - 4, align: TextAlign.right);
    }

    // Graduations du temps (5 repères).
    for (var i = 0; i <= 4; i++) {
      final t = from.add(Duration(milliseconds: (span * i / 4).round()));
      final px = x(t);
      canvas.drawLine(Offset(px, chart.bottom), Offset(px, chart.bottom + 4), grid);
      _text(canvas, timeFormat.format(t), Offset(px - 24, chart.bottom + 6), width: 48, align: TextAlign.center);
    }

    if (samples.isEmpty) return;
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = lineColor;
    Path? path;
    SignalSample? previous;
    for (final s in samples) {
      final point = Offset(x(s.time), y(s.dbm));
      final connected = previous != null && s.time.difference(previous.time) <= _gap;
      if (connected) {
        path!.lineTo(point.dx, point.dy);
      } else {
        if (path != null) canvas.drawPath(path, line);
        path = Path()..moveTo(point.dx, point.dy);
        canvas.drawCircle(point, 2.6, dot);
      }
      previous = s;
    }
    if (path != null) canvas.drawPath(path, line);
    // Dernière mesure mise en évidence.
    final last = samples.last;
    canvas.drawCircle(Offset(x(last.time), y(last.dbm)), 4.5, dot);
  }

  void _text(Canvas canvas, String text, Offset offset, {required double width, required TextAlign align}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: width, maxWidth: math.max(width, 1));
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_SignalChartPainter old) =>
      old.samples != samples || old.from != from || old.to != to || old.lineColor != lineColor;
}
