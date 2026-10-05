import 'package:flutter/material.dart';

/// Logo « MiFi » de l'appli (`assets/logo/mifi_logo.png`, blanc sur noir).
/// En thème sombre, un liseré le détache du fond.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  static const String assetPath = 'assets/logo/mifi_logo.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.wifi_rounded, size: size * 0.6, color: theme.colorScheme.primary),
    );
    if (theme.brightness == Brightness.light) return image;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: image,
    );
  }
}
