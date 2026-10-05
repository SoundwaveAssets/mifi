import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/models/wifi_models.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/util/wifi_qr.dart';
import '../../l10n_helpers.dart';
import '../../widgets/feedback.dart';
import '../../widgets/state_views.dart';

/// Partage du Wi-Fi par QR code (à scanner avec l'appareil photo).
class WifiQrScreen extends StatelessWidget {
  const WifiQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.wifiShareQr)),
      body: FutureLoader<WifiInfo>(
        load: context.read<ModemApi>().getWifiInfo,
        builder: (context, info, reload) => _QrView(info: info),
      ),
    );
  }
}

class _QrView extends StatefulWidget {
  const _QrView({required this.info});

  final WifiInfo info;

  @override
  State<_QrView> createState() => _QrViewState();
}

class _QrViewState extends State<_QrView> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final info = widget.info;
    final payload = buildWifiQrPayload(
      ssid: info.ssid,
      password: info.password,
      authCode: info.authCode,
      hidden: !info.broadcastSsid,
    );
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.wifiQrInstructions, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16)],
            ),
            child: QrImageView(data: payload, size: 240, backgroundColor: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.wifi_rounded),
          title: Text(l.wifiSsidLabel),
          subtitle: Text(info.ssid, style: theme.textTheme.titleMedium),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline_rounded),
          title: Text(l.wifiSecurityLabel),
          subtitle: Text(wifiAuthLabel(l, info.authCode)),
        ),
        if (!info.isOpenNetwork)
          ListTile(
            leading: const Icon(Icons.key_rounded),
            title: Text(l.wifiPasswordLabel),
            subtitle: Text(
              _showPassword ? info.password : '•' * info.password.length.clamp(8, 16),
              style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: _showPassword ? l.commonHidePassword : l.commonShowPassword,
                  icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
                IconButton(
                  tooltip: l.commonCopy,
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: info.password));
                    if (context.mounted) showSnack(context, l.commonCopied);
                  },
                ),
              ],
            ),
          ),
        if (!info.broadcastSsid)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: WarningBanner(message: l.wifiQrHiddenNote, severity: BannerSeverity.info),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.read<NativeBridge>().shareText(
                text: info.isOpenNetwork ? l.wifiShareTextOpen(info.ssid) : l.wifiShareText(info.ssid, info.password),
                title: l.wifiShareMessage,
              ),
          icon: const Icon(Icons.share_rounded),
          label: Text(l.wifiShareMessage),
        ),
      ],
    );
  }
}
