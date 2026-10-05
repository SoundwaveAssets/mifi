import 'package:flutter/material.dart';

import '../l10n_helpers.dart';
import '../theme.dart';

/// Message bref en bas de l'écran.
void showSnack(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final scheme = Theme.of(context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        message,
        style: error ? TextStyle(color: scheme.onErrorContainer) : null,
      ),
      backgroundColor: error ? scheme.errorContainer : null,
      duration: Duration(seconds: error ? 6 : 3),
    ));
}

/// Erreur traduite en bas de l'écran.
void showErrorSnack(BuildContext context, Object error) =>
    showSnack(context, describeError(context.l10n, error), error: true);

enum BannerSeverity { info, warning, danger }

/// Encadré d'information ou d'avertissement (opérations sensibles).
class WarningBanner extends StatelessWidget {
  const WarningBanner({
    super.key,
    required this.message,
    this.title,
    this.severity = BannerSeverity.warning,
    this.icon,
    this.action,
  });

  final String message;
  final String? title;
  final BannerSeverity severity;
  final IconData? icon;

  /// Bouton affiché sous le message (ex. « Relancer la connexion »).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (Color background, Color foreground, IconData defaultIcon) = switch (severity) {
      BannerSeverity.info => (scheme.secondaryContainer, scheme.onSecondaryContainer, Icons.info_outline_rounded),
      BannerSeverity.warning => (
          context.statusColors.warning.withValues(alpha: 0.16),
          scheme.onSurface,
          Icons.warning_amber_rounded,
        ),
      BannerSeverity.danger => (scheme.errorContainer, scheme.onErrorContainer, Icons.dangerous_outlined),
    };
    final iconColor = severity == BannerSeverity.warning ? context.statusColors.warning : foreground;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(color: foreground),
                    ),
                  ),
                Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: foreground)),
                if (action != null) ...[
                  const SizedBox(height: 10),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
