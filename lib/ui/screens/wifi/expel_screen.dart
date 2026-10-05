import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/models/wifi_models.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/util/password_generator.dart';
import '../../../core/util/wifi_qr.dart';
import '../../l10n_helpers.dart';
import '../../theme.dart';
import '../../widgets/feedback.dart';

/// « Expulser les intrus » : le modem ne sait pas bloquer un appareil, donc
/// on change le mot de passe Wi-Fi (et on peut masquer le nom du réseau).
/// Tous les appareils sont déconnectés ; le nouveau QR code s'affiche
/// aussitôt et la session reprend dès que le téléphone est reconnecté.
class ExpelIntrudersScreen extends StatefulWidget {
  const ExpelIntrudersScreen({super.key});

  @override
  State<ExpelIntrudersScreen> createState() => _ExpelIntrudersScreenState();
}

enum _Step { intro, applying, done }

class _ExpelIntrudersScreenState extends State<ExpelIntrudersScreen> {
  _Step _step = _Step.intro;
  bool _hideSsid = false;
  WifiInfo? _applied;
  bool _waiting = false;
  bool? _reconnected;

  Future<void> _apply() async {
    final api = context.read<ModemApi>();
    setState(() => _step = _Step.applying);
    try {
      final current = await api.getWifiInfo();
      final authCode = current.isOpenNetwork ? WifiInfo.authWpa2Psk : current.authCode;
      final next = current.copyWith(
        password: generateWifiPassword(),
        authCode: authCode,
        broadcastSsid: _hideSsid ? false : current.broadcastSsid,
      );
      // Le Wi-Fi redémarre aussitôt : la réponse peut ne jamais arriver.
      await api.setWifiInfo(next);
      if (!mounted) return;
      setState(() {
        _applied = next;
        _step = _Step.done;
      });
      unawaited(_waitForReconnection());
    } catch (e) {
      if (!mounted) return;
      setState(() => _step = _Step.intro);
      showErrorSnack(context, e);
    }
  }

  Future<void> _waitForReconnection() async {
    setState(() {
      _waiting = true;
      _reconnected = null;
    });
    final ok = await context.read<SessionController>().waitForModem(
          timeout: const Duration(minutes: 5),
          initialDelay: const Duration(seconds: 8),
          isCancelled: () => !mounted,
        );
    if (!mounted) return;
    setState(() {
      _waiting = false;
      _reconnected = ok;
    });
  }

  Future<void> _reconnectPhone() async {
    final info = _applied;
    if (info == null) return;
    await context.read<NativeBridge>().suggestWifiNetwork(
          ssid: info.ssid,
          password: info.password,
          hidden: !info.broadcastSsid,
        );
  }

  Future<void> _share() async {
    final info = _applied;
    if (info == null) return;
    final l = context.l10n;
    await context.read<NativeBridge>().shareText(
          text: l.wifiShareText(info.ssid, info.password),
          title: l.wifiShareMessage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      canPop: _step != _Step.applying,
      child: Scaffold(
        appBar: AppBar(title: Text(l.expelTitle)),
        body: switch (_step) {
          _Step.intro || _Step.applying => _buildIntro(context),
          _Step.done => _buildDone(context),
        },
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final busy = _step == _Step.applying;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.shield_outlined, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(l.expelIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wifi_off_rounded, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.expelWarning,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _hideSsid,
          onChanged: busy ? null : (value) => setState(() => _hideSsid = value),
          title: Text(l.expelHideSsid),
          subtitle: Text(l.expelHideSsidHint),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: busy ? null : _apply,
          icon: busy
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.key_rounded),
          label: Text(l.expelApply),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final info = _applied!;
    final payload = buildWifiQrPayload(
      ssid: info.ssid,
      password: info.password,
      authCode: info.authCode,
      hidden: !info.broadcastSsid,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.expelDone, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: QrImageView(data: payload, size: 220, backgroundColor: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        _CopyLine(label: l.expelNetwork, value: info.ssid),
        _CopyLine(label: l.expelNewPassword, value: info.password, emphasize: true),
        if (!info.broadcastSsid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l.expelHiddenNote, style: theme.textTheme.bodySmall),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _reconnectPhone,
          icon: const Icon(Icons.wifi_rounded),
          label: Text(l.expelReconnectPhone),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.share_rounded),
          label: Text(l.wifiShareMessage),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: _waiting
                ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Icon(
                    _reconnected == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: _reconnected == true ? context.statusColors.good : theme.colorScheme.error,
                  ),
            title: Text(_waiting
                ? l.expelWaiting
                : _reconnected == true
                    ? l.expelReconnected
                    : l.expelNotReconnected),
            trailing: !_waiting && _reconnected != true
                ? TextButton(onPressed: _waitForReconnection, child: Text(l.commonRetry))
                : null,
          ),
        ),
      ],
    );
  }
}

class _CopyLine extends StatelessWidget {
  const _CopyLine({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: SelectableText(
        value,
        style: emphasize
            ? theme.textTheme.headlineSmall?.copyWith(fontFamily: 'monospace', letterSpacing: 1.5)
            : theme.textTheme.bodyLarge,
      ),
      trailing: IconButton(
        tooltip: context.l10n.commonCopy,
        icon: const Icon(Icons.copy_rounded),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: value));
          if (context.mounted) showSnack(context, context.l10n.commonCopied);
        },
      ),
    );
  }
}
