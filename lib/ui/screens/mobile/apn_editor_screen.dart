import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/mobile_data/data_cut.dart';
import '../../../core/mobile_data/mobile_data.dart';
import '../../../core/models/mobile_models.dart';
import '../../../core/status/status_controller.dart';
import '../../../core/util/ip_utils.dart';
import '../../../core/util/operators.dart';
import '../../l10n_helpers.dart';
import '../../widgets/async_button.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/password_field.dart';

/// Création d'un profil APN (`setnewapn`). Aucun APN n'est codé en dur :
/// MCC et MNC sont pré-remplis d'après la SIM insérée.
class ApnEditorScreen extends StatefulWidget {
  const ApnEditorScreen({super.key, required this.apnInfo});

  final ApnInfo apnInfo;

  @override
  State<ApnEditorScreen> createState() => _ApnEditorScreenState();
}

class _ApnEditorScreenState extends State<ApnEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _apn = TextEditingController();
  final _mcc = TextEditingController();
  final _mnc = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _proxy = TextEditingController();
  final _port = TextEditingController();
  String _pdpType = ApnProfile.pdpTypes.first;
  String _auth = ApnProfile.authNone;

  @override
  void initState() {
    super.initState();
    final codes = mccMncFromImsi(context.read<StatusController>().snapshot?.status.imsi);
    if (codes != null) {
      _mcc.text = codes.$1;
      _mnc.text = codes.$2;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _apn, _mcc, _mnc, _username, _password, _proxy, _port]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) => (value ?? '').trim().isEmpty ? context.l10n.commonRequiredField : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    final api = context.read<ModemApi>();
    final dataCut = context.read<ApnDataCut>();
    final mobileData = context.read<MobileDataController>();
    final navigator = Navigator.of(context);
    final profile = ApnProfile.create(
      id: widget.apnInfo.nextId(),
      name: _name.text.trim(),
      apn: _apn.text.trim(),
      pdpType: _pdpType,
      mcc: _mcc.text.trim(),
      mnc: _mnc.text.trim(),
      auth: _auth,
      username: _username.text.trim(),
      password: _password.text,
      proxy: _proxy.text.trim(),
      port: _port.text.trim(),
    );
    await api.addApn(profile);
    if (!mounted) return;
    final activate = await showConfirmDialog(
      context,
      title: l.mobileApnCreatedTitle,
      message: l.mobileApnActivateNow(profile.name),
      confirmLabel: l.mobileApnUse,
    );
    if (activate) {
      final updated = await api.getApnInfo();
      final created = updated.profiles
          .where((p) => p.name == profile.name && p.apn == profile.apn && p.mcc == profile.mcc && p.mnc == profile.mnc)
          .lastOrNull;
      if (created != null) {
        await api.setCurrentApn(created);
        // Profil choisi par l'utilisateur : les coupures en cours sont levées.
        await dataCut.forget();
        unawaited(mobileData.refresh());
      }
    }
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final digits = RegExp(r'^\d+$');
    return Scaffold(
      appBar: AppBar(title: Text(l.mobileApnNew)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.mobileApnNewHint, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l.mobileApnName),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apn,
              decoration: InputDecoration(labelText: l.mobileApnApn),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _pdpType,
              decoration: InputDecoration(labelText: l.mobileApnPdpType),
              items: [
                for (final type in ApnProfile.pdpTypes)
                  DropdownMenuItem(value: type, child: Text(pdpTypeLabel(l, type))),
              ],
              onChanged: (value) => setState(() => _pdpType = value ?? _pdpType),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mcc,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: InputDecoration(labelText: l.mobileApnMcc),
                    validator: (v) => digits.hasMatch(v ?? '') && v!.length == 3 ? null : l.mobileApnMccInvalid,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mnc,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: InputDecoration(labelText: l.mobileApnMnc),
                    validator: (v) =>
                        digits.hasMatch(v ?? '') && v!.length >= 2 ? null : l.mobileApnMncInvalid,
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: _auth,
              decoration: InputDecoration(labelText: l.mobileApnAuth),
              items: [
                for (final code in ApnProfile.authCodes)
                  DropdownMenuItem(value: code, child: Text(apnAuthLabel(l, code))),
              ],
              onChanged: (value) => setState(() => _auth = value ?? _auth),
            ),
            if (_auth != ApnProfile.authNone) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                decoration: InputDecoration(labelText: l.mobileApnUsername),
              ),
              const SizedBox(height: 12),
              PasswordField(controller: _password, label: l.mobileApnPassword),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _proxy,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l.commonProxyLabel, helperText: l.mobileApnOptional),
              validator: (v) => (v ?? '').trim().isEmpty || isValidIpv4OrHostname(v!) ? null : l.commonInvalidHost,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _port,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.mobileApnPort, helperText: l.mobileApnOptional),
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;
                final port = int.tryParse(text);
                return port != null && port >= 1 && port <= 65535 ? null : l.mobileApnPortInvalid;
              },
            ),
            const SizedBox(height: 20),
            AsyncButton(onPressed: _save, label: l.commonSave, icon: Icons.save_rounded),
          ],
        ),
      ),
    );
  }
}
