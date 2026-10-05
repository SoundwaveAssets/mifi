import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/models/dhcp_models.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/util/ip_utils.dart';
import '../../../core/util/modem_address.dart';
import '../../l10n_helpers.dart';
import '../../widgets/async_button.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/modem_restart_dialog.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';

/// Réseau local (DHCP) : adresse du modem, masque, plage d'adresses, bail.
/// Le serveur DHCP est affiché en lecture seule, comme dans l'interface
/// d'origine. Enregistrer redémarre le modem.
class DhcpScreen extends StatelessWidget {
  const DhcpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.hubDhcpTitle)),
      body: FutureLoader<DhcpInfo>(
        load: context.read<ModemApi>().getDhcpInfo,
        builder: (context, info, reload) => _DhcpForm(key: ObjectKey(info), initial: info, reload: reload),
      ),
    );
  }
}

class _DhcpForm extends StatefulWidget {
  const _DhcpForm({super.key, required this.initial, required this.reload});

  final DhcpInfo initial;
  final Future<void> Function() reload;

  @override
  State<_DhcpForm> createState() => _DhcpFormState();
}

class _DhcpFormState extends State<_DhcpForm> {
  final _formKey = GlobalKey<FormState>();
  late final _gateway = TextEditingController(text: widget.initial.gatewayIp);
  late final _netmask = TextEditingController(text: widget.initial.netmask);
  late final _start = TextEditingController(text: widget.initial.poolStart);
  late final _end = TextEditingController(text: widget.initial.poolEnd);
  late final _lease = TextEditingController(text: '${widget.initial.leaseTimeHours ?? ''}');

  @override
  void initState() {
    super.initState();
    for (final c in [_gateway, _netmask, _start, _end, _lease]) {
      c.addListener(_changed);
    }
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    for (final c in [_gateway, _netmask, _start, _end, _lease]) {
      c.dispose();
    }
    super.dispose();
  }

  DhcpInfo get _draft => widget.initial.copyWith(
        gatewayIp: _gateway.text,
        netmask: _netmask.text,
        poolStart: _start.text,
        poolEnd: _end.text,
        leaseTimeHours: int.tryParse(_lease.text.trim()),
      );

  String _message(DhcpValidationError error) {
    final l = context.l10n;
    return switch (error) {
      DhcpValidationError.invalidIp => l.commonInvalidIpv4,
      DhcpValidationError.invalidNetmask => l.dhcpErrorNetmask,
      DhcpValidationError.networkOrBroadcastAddress => l.dhcpErrorReserved,
      DhcpValidationError.outsideGatewaySubnet => l.dhcpErrorSubnet,
      DhcpValidationError.poolStartAfterEnd => l.dhcpErrorOrder,
      DhcpValidationError.gatewayInsidePool => l.dhcpErrorGatewayInPool,
      DhcpValidationError.invalidLeaseTime => l.dhcpErrorLease(DhcpInfo.maxLeaseHours),
    };
  }

  String? _error(DhcpField field) {
    final error = _draft.validate()[field];
    return error == null ? null : _message(error);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _draft.validate().isNotEmpty) return;
    final l = context.l10n;
    final api = context.read<ModemApi>();
    final session = context.read<SessionController>();
    final draft = _draft;
    final newGateway = draft.gatewayIp;
    final addressChanges = newGateway != widget.initial.gatewayIp;
    final ok = await showConfirmDialog(
      context,
      title: l.dhcpSaveTitle,
      message: addressChanges ? '${l.dhcpSaveWarning}\n\n${l.dhcpNewAddress(newGateway)}' : l.dhcpSaveWarning,
      confirmLabel: l.commonSave,
      icon: Icons.restart_alt_rounded,
    );
    if (!ok || !mounted) return;
    await api.setDhcpInfo(draft);
    if (addressChanges) {
      // Garder le port éventuel de l'adresse actuelle.
      final current = session.modemAddress;
      final port = current.contains(':') ? current.substring(current.lastIndexOf(':')) : '';
      await session.setModemAddress(ModemAddress.normalize('$newGateway$port') ?? newGateway);
    }
    if (!mounted) return;
    final back = await showModemRestartDialog(context, initialDelay: const Duration(seconds: 20));
    if (!mounted) return;
    if (back) {
      showSnack(context, l.commonSaved);
      await widget.reload();
    } else {
      await showInfoDialog(context, title: l.dhcpSaveTitle, message: l.dhcpNotBack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.initial;
    final draft = _draft;
    final valid = draft.validate().isEmpty;
    String? requiredIp(String? value) => isValidIpv4(value ?? '') ? null : l.commonInvalidIpv4;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WarningBanner(message: l.dhcpWarning, title: l.commonWarning),
          const SizedBox(height: 16),
          SectionCard(
            title: l.dhcpModemSection,
            icon: Icons.router_outlined,
            children: [
              TextFormField(
                controller: _gateway,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.dhcpGateway, errorText: _error(DhcpField.gatewayIp)),
                validator: requiredIp,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _netmask,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.dhcpNetmask, errorText: _error(DhcpField.netmask)),
                validator: requiredIp,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l.dhcpServerSection,
            icon: Icons.lan_outlined,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.dhcpServer),
                subtitle: Text(l.dhcpReadOnly),
                trailing: Switch(value: info.dhcpServerEnabled ?? true, onChanged: null),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _start,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.dhcpPoolStart, errorText: _error(DhcpField.poolStart)),
                      validator: requiredIp,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _end,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.dhcpPoolEnd, errorText: _error(DhcpField.poolEnd)),
                      validator: requiredIp,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lease,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.dhcpLease,
                  suffixText: l.dhcpHours,
                  errorText: _error(DhcpField.leaseTime),
                ),
              ),
              if (valid) ...[
                const SizedBox(height: 12),
                Text(
                  l.dhcpSummary(
                    networkAddress(draft.gatewayIp, draft.netmask) ?? '',
                    netmaskPrefixLength(draft.netmask) ?? 0,
                    ipv4ToInt(draft.poolEnd)! - ipv4ToInt(draft.poolStart)! + 1,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AsyncButton(onPressed: valid ? _save : null, label: l.commonSave, icon: Icons.save_rounded),
        ],
      ),
    );
  }
}
