import 'package:flutter/material.dart';

import 'feedback.dart';

enum AsyncButtonVariant { filled, tonal, outlined, text, danger }

/// Bouton qui lance une action asynchrone : indicateur pendant l'action,
/// bouton désactivé, erreur traduite affichée en bas de l'écran.
class AsyncButton extends StatefulWidget {
  const AsyncButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = AsyncButtonVariant.filled,
  });

  /// `null` = bouton désactivé.
  final Future<void> Function()? onPressed;
  final String label;
  final IconData? icon;
  final AsyncButtonVariant variant;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed == null || _busy ? null : _run;
    final Widget icon = _busy
        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Icon(widget.icon ?? Icons.check_rounded);
    final label = Text(widget.label);
    final scheme = Theme.of(context).colorScheme;
    return switch (widget.variant) {
      AsyncButtonVariant.filled => FilledButton.icon(onPressed: onPressed, icon: icon, label: label),
      AsyncButtonVariant.tonal => FilledButton.tonalIcon(onPressed: onPressed, icon: icon, label: label),
      AsyncButtonVariant.outlined => OutlinedButton.icon(onPressed: onPressed, icon: icon, label: label),
      AsyncButtonVariant.text => TextButton.icon(onPressed: onPressed, icon: icon, label: label),
      AsyncButtonVariant.danger => FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          onPressed: onPressed,
          icon: icon,
          label: label,
        ),
    };
  }
}
