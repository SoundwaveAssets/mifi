import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session/session_controller.dart';
import '../l10n_helpers.dart';
import '../theme.dart';

/// Attend que le modem redémarre (DHCP, redémarrage, mise à jour…) puis
/// rouvre la session. Renvoie `true` si le modem est revenu.
///
/// [message] remplace le texte d'attente par défaut.
Future<bool> showModemRestartDialog(
  BuildContext context, {
  String? message,
  Duration timeout = const Duration(minutes: 3),
  Duration initialDelay = const Duration(seconds: 5),
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ModemRestartDialog(message: message, timeout: timeout, initialDelay: initialDelay),
  );
  return result ?? false;
}

class _ModemRestartDialog extends StatefulWidget {
  const _ModemRestartDialog({required this.message, required this.timeout, required this.initialDelay});

  final String? message;
  final Duration timeout;
  final Duration initialDelay;

  @override
  State<_ModemRestartDialog> createState() => _ModemRestartDialogState();
}

enum _Phase { waiting, success, timeout }

class _ModemRestartDialogState extends State<_ModemRestartDialog> {
  _Phase _phase = _Phase.waiting;
  bool _cancelled = false;
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _phase = _Phase.waiting);
    _cancelled = false;
    _watch
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    final ok = await context.read<SessionController>().waitForModem(
          timeout: widget.timeout,
          initialDelay: widget.initialDelay,
          isCancelled: () => _cancelled || !mounted,
        );
    _ticker?.cancel();
    _watch.stop();
    if (!mounted || _cancelled) return;
    if (ok) {
      setState(() => _phase = _Phase.success);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() => _phase = _Phase.timeout);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final Widget content = switch (_phase) {
      _Phase.waiting => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(widget.message ?? l.restartWaiting, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              l.restartElapsed(formatDuration(l, _watch.elapsed)),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(l.restartHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          ],
        ),
      _Phase.success => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 48, color: context.statusColors.good),
            const SizedBox(height: 12),
            Text(l.restartSuccess, textAlign: TextAlign.center),
          ],
        ),
      _Phase.timeout => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(l.restartTimeout, textAlign: TextAlign.center),
          ],
        ),
    };
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l.restartTitle),
        content: content,
        actions: switch (_phase) {
          _Phase.waiting => [
              TextButton(
                onPressed: () {
                  _cancelled = true;
                  Navigator.of(context).pop(false);
                },
                child: Text(l.restartStopWaiting),
              ),
            ],
          _Phase.success => const [],
          _Phase.timeout => [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.commonClose)),
              FilledButton(onPressed: _start, child: Text(l.commonRetry)),
            ],
        },
      ),
    );
  }
}
