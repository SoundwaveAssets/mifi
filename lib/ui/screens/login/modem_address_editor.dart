import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/util/modem_address.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';

/// Édition de l'adresse du modem (écran de connexion et réglages) :
/// validation, suggestion de la passerelle du Wi-Fi actuel, retour à
/// l'adresse par défaut et test de joignabilité.
class ModemAddressEditor extends StatefulWidget {
  const ModemAddressEditor({super.key, this.confirmChange});

  /// Appelée avant d'enregistrer une nouvelle adresse (ex. confirmation
  /// quand une session est ouverte). `false` annule.
  final Future<bool> Function(String address)? confirmChange;

  @override
  State<ModemAddressEditor> createState() => _ModemAddressEditorState();
}

enum _Probe { idle, running, ok, failed }

class _ModemAddressEditorState extends State<ModemAddressEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: context.read<SessionController>().modemAddress);
  String? _gateway;
  _Probe _probe = _Probe.idle;
  Object? _probeError;

  @override
  void initState() {
    super.initState();
    _loadGateway();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadGateway() async {
    final status = await context.read<NativeBridge>().wifiStatus();
    if (mounted) setState(() => _gateway = status.gateway);
  }

  Future<void> _save([String? value]) async {
    final normalized = ModemAddress.normalize(value ?? _controller.text);
    if (normalized == null) return;
    final session = context.read<SessionController>();
    if (normalized == session.modemAddress) return;
    final confirm = widget.confirmChange;
    if (confirm != null && !await confirm(normalized)) return;
    await session.setModemAddress(normalized);
    _controller.text = normalized;
    if (mounted) setState(() => _probe = _Probe.idle);
  }

  Future<void> _test() async {
    setState(() {
      _probe = _Probe.running;
      _probeError = null;
    });
    await _save();
    if (!mounted) return;
    try {
      await context.read<ModemApi>().getConfig(timeout: const Duration(seconds: 5));
      if (mounted) setState(() => _probe = _Probe.ok);
    } catch (e) {
      if (mounted) {
        setState(() {
          _probe = _Probe.failed;
          _probeError = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = context.watch<SessionController>().modemAddress;
    final gateway = _gateway;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.url,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l.loginAddressLabel,
            helperText: l.loginAddressHelper,
            prefixText: 'http://',
          ),
          validator: (value) => ModemAddress.normalize(value ?? '') == null ? l.commonInvalidHost : null,
          onFieldSubmitted: _save,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (gateway != null && gateway != ModemAddress.hostOf(current))
              ActionChip(
                avatar: const Icon(Icons.wifi_rounded, size: 18),
                label: Text(l.loginUseGateway(gateway)),
                onPressed: () {
                  _controller.text = gateway;
                  _save(gateway);
                },
              ),
            if (current != ModemAddress.defaultAddress)
              ActionChip(
                avatar: const Icon(Icons.restore_rounded, size: 18),
                label: Text(l.loginResetAddress(ModemAddress.defaultAddress)),
                onPressed: () {
                  _controller.text = ModemAddress.defaultAddress;
                  _save(ModemAddress.defaultAddress);
                },
              ),
            ActionChip(
              avatar: _probe == _Probe.running
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.network_check_rounded, size: 18),
              label: Text(l.loginTestAddress),
              onPressed: _probe == _Probe.running ? null : _test,
            ),
          ],
        ),
        if (_probe == _Probe.ok)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: context.statusColors.good, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l.loginReachable)),
              ],
            ),
          ),
        if (_probe == _Probe.failed && _probeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              describeError(l, _probeError!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
