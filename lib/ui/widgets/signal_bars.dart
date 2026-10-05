import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Couleur des barres selon le niveau : vert (bon, excellent), orange
/// (moyen), rouge (faible ou inexistant).
Color signalLevelColor(BuildContext context, int bars) {
  final colors = context.statusColors;
  return switch (bars) {
    >= 3 => colors.good,
    2 => colors.warning,
    _ => colors.bad,
  };
}

/// Barres de signal (0 à 4), comme dans la barre d'état d'un téléphone,
/// colorées selon le niveau (sauf couleur imposée).
class SignalBars extends StatelessWidget {
  const SignalBars({
    super.key,
    required this.bars,
    this.size = 20,
    this.color,
    this.inactiveColor,
    this.semanticLabel,
  });

  final int bars;
  final double size;
  final Color? color;
  final Color? inactiveColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final level = bars.clamp(0, 4);
    return Semantics(
      label: semanticLabel,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _SignalBarsPainter(
            bars: level,
            active: color ?? signalLevelColor(context, level),
            inactive: inactiveColor ?? scheme.onSurface.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }
}

class _SignalBarsPainter extends CustomPainter {
  _SignalBarsPainter({required this.bars, required this.active, required this.inactive});

  final int bars;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 4;
    final gap = size.width * 0.08;
    final barWidth = (size.width - gap * (count - 1)) / count;
    final radius = Radius.circular(math.min(barWidth / 3, 3));
    for (var i = 0; i < count; i++) {
      final height = size.height * (i + 1) / count;
      final rect = Rect.fromLTWH(i * (barWidth + gap), size.height - height, barWidth, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()..color = i < bars ? active : inactive,
      );
    }
  }

  @override
  bool shouldRepaint(_SignalBarsPainter old) =>
      old.bars != bars || old.active != active || old.inactive != inactive;
}
