import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../core/settings/app_settings.dart';
import '../l10n_helpers.dart';
import 'app_logo.dart';

/// Verrouillage de l'appli par empreinte (ou code du téléphone) : demandé à
/// l'ouverture et après plus d'une minute en arrière-plan, si l'option est
/// activée dans les réglages.
///
/// Placé au-dessus de la navigation (`MaterialApp.builder`) : un
/// reverrouillage masque aussi les écrans ouverts, sans les fermer.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  static const Duration _relockAfter = Duration(minutes: 1);

  final _auth = LocalAuthentication();
  late final AppLifecycleListener _lifecycle;
  bool _unlocked = false;
  bool _authenticating = false;
  bool _failed = false;
  DateTime? _hiddenAt;

  /// L'appli a déjà été affichée (déverrouillée ou verrou désactivé).
  bool _shown = false;
  bool? _wasEnabled;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _hiddenAt = DateTime.now(),
      onResume: () {
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (hiddenAt != null && DateTime.now().difference(hiddenAt) > _relockAfter && _lockEnabled) {
          setState(() => _unlocked = false);
          _authenticate();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lockEnabled) _authenticate();
    });
  }

  bool get _lockEnabled => context.read<AppSettings>().appLockEnabled;

  Future<void> _authenticate() async {
    if (_authenticating || !mounted) return;
    final reason = context.l10n.lockReason;
    setState(() {
      _authenticating = true;
      _failed = false;
    });
    var ok = false;
    try {
      // Sans empreinte ni code configurés, l'appli reste accessible.
      ok = !await _auth.isDeviceSupported() ||
          await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      _authenticating = false;
      _unlocked = ok;
      _failed = !ok;
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<AppSettings, bool>((s) => s.appLockEnabled);
    // Verrou activé à l'instant dans les réglages, après authentification.
    if (enabled && _wasEnabled == false) _unlocked = true;
    _wasEnabled = enabled;
    final locked = enabled && !_unlocked;
    if (!locked) _shown = true;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Écrans gardés en mémoire mais invisibles et inactifs pendant le verrouillage.
        if (_shown) Offstage(offstage: locked, child: TickerMode(enabled: !locked, child: widget.child)),
        if (locked) _lockScreen(context),
      ],
    );
  }

  Widget _lockScreen(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 96),
                const SizedBox(height: 24),
                Text(l.lockTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  _failed ? l.lockFailed : l.lockReason,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _authenticating ? null : _authenticate,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(l.lockUnlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
