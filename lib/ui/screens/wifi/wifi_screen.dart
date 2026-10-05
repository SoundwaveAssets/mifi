import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/models/wifi_models.dart';
import '../../../core/native/native_bridge.dart';
import '../../l10n_helpers.dart';
import '../../widgets/async_button.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/modem_restart_dialog.dart';
import '../../widgets/password_field.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';
import 'expel_screen.dart';
import 'wifi_qr_screen.dart';

/// Réglages Wi-Fi du modem : nom, mot de passe, sécurité, canal, diffusion,
/// point d'accès, partage et « Expulser les intrus ».
class WifiScreen extends StatelessWidget {
  const WifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.hubWifiTitle)),
      body: FutureLoader<WifiInfo>(
        load: context.read<ModemApi>().getWifiInfo,
        builder: (context, info, reload) => _WifiForm(key: ObjectKey(info), initial: info, reload: reload),
      ),
    );
  }
}

class _WifiForm extends StatefulWidget {
  const _WifiForm({super.key, required this.initial, required this.reload});

  final WifiInfo initial;
  final Future<void> Function() reload;

  @override
  State<_WifiForm> createState() => _WifiFormState();
}

class _WifiFormState extends State<_WifiForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ssid = TextEditingController(text: widget.initial.ssid);
  late final TextEditingController _password = TextEditingController(text: widget.initial.password);
  late String _auth = widget.initial.authCode;
  late String _channel = widget.initial.channel;
  late bool _broadcast = widget.initial.broadcastSsid;

  @override
  void dispose() {
    _ssid.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _ssidError(String? value) => switch (WifiInfo.validateSsid(value ?? '')) {
        WifiValidationError.ssidEmpty => context.l10n.commonRequiredField,
        WifiValidationError.ssidTooLong => context.l10n.wifiSsidTooLong(WifiInfo.ssidMaxLength),
        _ => null,
      };

  String? _passwordError(String? value) => switch (WifiInfo.validatePassword(value ?? '', authCode: _auth)) {
        WifiValidationError.passwordTooShort => context.l10n.wifiPasswordLength(
            WifiInfo.passwordMinLength, WifiInfo.passwordMaxLength),
        WifiValidationError.passwordTooLong => context.l10n.wifiPasswordLength(
            WifiInfo.passwordMinLength, WifiInfo.passwordMaxLength),
        WifiValidationError.passwordInvalidCharacters => context.l10n.wifiPasswordAscii,
        _ => null,
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    final api = context.read<ModemApi>();
    final open = _auth == WifiInfo.authNone;
    final ok = await showConfirmDialog(
      context,
      title: l.wifiSaveTitle,
      message: open ? '${l.wifiSaveWarning}\n\n${l.wifiOpenWarning}' : l.wifiSaveWarning,
      confirmLabel: l.commonSave,
      icon: Icons.wifi_rounded,
      destructive: open,
    );
    if (!ok || !mounted) return;
    final next = widget.initial.copyWith(
      ssid: _ssid.text.trim(),
      password: open ? widget.initial.password : _password.text,
      authCode: _auth,
      channel: _channel,
      broadcastSsid: _broadcast,
    );
    await api.setWifiInfo(next);
    if (!mounted) return;
    final back = await showModemRestartDialog(
      context,
      message: l.wifiReconnectMessage(next.ssid),
      initialDelay: const Duration(seconds: 8),
    );
    if (!mounted) return;
    if (back) {
      showSnack(context, l.commonSaved);
      await widget.reload();
    }
  }

  Future<void> _turnOff() async {
    final l = context.l10n;
    final api = context.read<ModemApi>();
    final ok = await showTypedConfirmDialog(
      context,
      title: l.wifiTurnOffTitle,
      message: l.wifiTurnOffWarning,
      confirmationWord: l.wifiTurnOffWord,
      confirmLabel: l.wifiTurnOff,
      icon: Icons.wifi_off_rounded,
    );
    if (!ok || !mounted) return;
    await api.closeWifiAp();
    if (!mounted) return;
    await showInfoDialog(context, title: l.wifiTurnOffTitle, message: l.wifiTurnedOffInfo, icon: Icons.wifi_off_rounded);
  }

  Future<void> _turnOn() async {
    await context.read<ModemApi>().openWifiAp();
    await widget.reload();
  }

  Future<void> _shareByMessage() async {
    final l = context.l10n;
    final info = widget.initial;
    await context.read<NativeBridge>().shareText(
          text: info.isOpenNetwork ? l.wifiShareTextOpen(info.ssid) : l.wifiShareText(info.ssid, info.password),
          title: l.wifiShareMessage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.initial;
    final authCodes = [...WifiInfo.authCodes, if (!WifiInfo.authCodes.contains(info.authCode)) info.authCode];
    final channels = [...WifiInfo.channels, if (!WifiInfo.channels.contains(info.channel)) info.channel];
    final open = _auth == WifiInfo.authNone;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: l.wifiNetworkSection,
            icon: Icons.wifi_rounded,
            children: [
              TextFormField(
                controller: _ssid,
                maxLength: WifiInfo.ssidMaxLength,
                decoration: InputDecoration(labelText: l.wifiSsidLabel),
                validator: _ssidError,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _auth,
                decoration: InputDecoration(labelText: l.wifiSecurityLabel),
                items: [
                  for (final code in authCodes) DropdownMenuItem(value: code, child: Text(wifiAuthLabel(l, code))),
                ],
                onChanged: (value) => setState(() => _auth = value ?? _auth),
              ),
              if (!open) ...[
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  label: l.wifiPasswordLabel,
                  helperText: l.wifiPasswordLength(WifiInfo.passwordMinLength, WifiInfo.passwordMaxLength),
                  maxLength: WifiInfo.passwordMaxLength,
                  validator: _passwordError,
                ),
              ] else ...[
                const SizedBox(height: 12),
                WarningBanner(message: l.wifiOpenWarning, severity: BannerSeverity.danger),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _channel,
                decoration: InputDecoration(labelText: l.wifiChannelLabel),
                items: [
                  for (final channel in channels)
                    DropdownMenuItem(value: channel, child: Text(l.wifiChannelValue(channel))),
                ],
                onChanged: (value) => setState(() => _channel = value ?? _channel),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.wifiBroadcastLabel),
                subtitle: Text(_broadcast ? l.commonEnabled : l.wifiBroadcastHiddenHint),
                value: _broadcast,
                onChanged: (value) => setState(() => _broadcast = value),
              ),
              const SizedBox(height: 8),
              AsyncButton(onPressed: _save, label: l.commonSave, icon: Icons.save_rounded),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l.wifiShareSection,
            icon: Icons.qr_code_2_rounded,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.qr_code_rounded),
                title: Text(l.wifiShareQr),
                subtitle: Text(l.wifiShareQrHint),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const WifiQrScreen())),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.share_rounded),
                title: Text(l.wifiShareMessage),
                subtitle: Text(l.wifiShareMessageHint),
                onTap: _shareByMessage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l.expelTitle,
            icon: Icons.shield_outlined,
            children: [
              Text(l.wifiExpelHint),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const ExpelIntrudersScreen())),
                icon: const Icon(Icons.key_rounded),
                label: Text(l.expelTitle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l.wifiApSection,
            icon: Icons.router_outlined,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.wifiApState),
                trailing: Text(info.isEnabled ? l.commonEnabled : l.commonDisabled),
              ),
              if (info.isEnabled)
                AsyncButton(
                  onPressed: _turnOff,
                  label: l.wifiTurnOff,
                  icon: Icons.wifi_off_rounded,
                  variant: AsyncButtonVariant.danger,
                )
              else
                AsyncButton(onPressed: _turnOn, label: l.wifiTurnOn, icon: Icons.wifi_rounded),
            ],
          ),
        ],
      ),
    );
  }
}
