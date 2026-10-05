import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n_helpers.dart';
import 'feedback.dart';

/// Ligne « libellé : valeur », copiable d'un appui long si [copyable].
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.copyable = false,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool copyable;
  final Widget? trailing;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) showSnack(context, context.l10n.commonCopied);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: icon == null ? null : Icon(icon),
      title: Text(label),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing ??
          (copyable
              ? IconButton(
                  tooltip: context.l10n.commonCopy,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () => _copy(context),
                )
              : null),
      onLongPress: copyable ? () => _copy(context) : null,
    );
  }
}
