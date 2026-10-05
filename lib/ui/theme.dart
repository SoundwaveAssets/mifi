import 'package:flutter/material.dart';

/// Couleurs d'état (bon / attention / mauvais), adaptées au thème clair ou
/// sombre. Accès : `context.statusColors`.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({required this.good, required this.warning, required this.bad});

  static const light = StatusColors(
    good: Color(0xFF2E7D32),
    warning: Color(0xFFB26A00),
    bad: Color(0xFFC62828),
  );

  static const dark = StatusColors(
    good: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    bad: Color(0xFFEF9A9A),
  );

  final Color good;
  final Color warning;
  final Color bad;

  @override
  StatusColors copyWith({Color? good, Color? warning, Color? bad}) =>
      StatusColors(good: good ?? this.good, warning: warning ?? this.warning, bad: bad ?? this.bad);

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      good: Color.lerp(good, other.good, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
    );
  }
}

extension StatusColorsContext on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}

/// Couleur de base de l'appli (bleu, rappel de l'opérateur Blue).
const Color _seed = Color(0xFF0B5FD3);

ThemeData buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    extensions: [brightness == Brightness.dark ? StatusColors.dark : StatusColors.light],
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
