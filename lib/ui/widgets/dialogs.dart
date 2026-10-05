import 'package:flutter/material.dart';

import '../l10n_helpers.dart';

/// Demande de confirmation. Renvoie `true` si l'utilisateur confirme.
/// [destructive] colore le bouton de confirmation en rouge.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: icon == null ? null : Icon(icon, color: destructive ? scheme.error : null),
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel ?? l.commonConfirm),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Confirmation renforcée : le bouton ne s'active qu'une fois
/// [confirmationWord] saisi (ex. seconde étape de la réinitialisation
/// d'usine).
Future<bool> showTypedConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmationWord,
  String? confirmLabel,
  IconData icon = Icons.dangerous_outlined,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _TypedConfirmDialog(
      title: title,
      message: message,
      word: confirmationWord,
      confirmLabel: confirmLabel,
      icon: icon,
    ),
  );
  return result ?? false;
}

class _TypedConfirmDialog extends StatefulWidget {
  const _TypedConfirmDialog({
    required this.title,
    required this.message,
    required this.word,
    required this.confirmLabel,
    required this.icon,
  });

  final String title;
  final String message;
  final String word;
  final String? confirmLabel;
  final IconData icon;

  @override
  State<_TypedConfirmDialog> createState() => _TypedConfirmDialogState();
}

class _TypedConfirmDialogState extends State<_TypedConfirmDialog> {
  final _controller = TextEditingController();

  bool get _matches => _controller.text.trim().toUpperCase() == widget.word.trim().toUpperCase();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(widget.icon, color: scheme.error),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.message),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l.commonTypeToConfirm(widget.word)),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(widget.confirmLabel ?? l.commonConfirm),
        ),
      ],
    );
  }
}

/// Simple message avec un bouton « OK ».
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon == null ? null : Icon(icon),
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonOk),
        ),
      ],
    ),
  );
}
