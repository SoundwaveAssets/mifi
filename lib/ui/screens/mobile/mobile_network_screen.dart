import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/api/modem_exception.dart';
import '../../../core/mobile_data/data_cut.dart';
import '../../../core/mobile_data/mobile_data.dart';
import '../../../core/models/mobile_models.dart';
import '../../l10n_helpers.dart';
import '../../widgets/async_button.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/section_card.dart';
import 'apn_editor_screen.dart';

/// Réseau mobile : SIM, données mobiles, APN, mode réseau, partage USB et
/// détection de coupure. Chaque section se charge et échoue séparément.
class MobileNetworkScreen extends StatelessWidget {
  const MobileNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.hubMobileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SimSection(),
          SizedBox(height: 16),
          _MobileDataSection(),
          SizedBox(height: 16),
          _ApnSection(),
          SizedBox(height: 16),
          _NetworkModeSection(),
          SizedBox(height: 16),
          _UsbSection(),
          SizedBox(height: 16),
          _ConnectionDetectSection(),
        ],
      ),
    );
  }
}

/// Section qui charge ses données et affiche chargement ou erreur.
class _Loading<T> extends StatefulWidget {
  const _Loading({required this.title, required this.icon, required this.load, required this.builder});

  final String title;
  final IconData icon;
  final Future<T> Function(ModemApi api) load;
  final Widget Function(BuildContext context, T data, Future<void> Function() reload) builder;

  @override
  State<_Loading<T>> createState() => _LoadingState<T>();
}

class _LoadingState<T> extends State<_Loading<T>> {
  late Future<T> _future = widget.load(context.read<ModemApi>());

  Future<void> _reload() async {
    final future = widget.load(context.read<ModemApi>());
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // Affiché par le FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: widget.title,
      icon: widget.icon,
      children: [
        FutureBuilder<T>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      describeError(context.l10n, snapshot.error!),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  TextButton(onPressed: _reload, child: Text(context.l10n.commonRetry)),
                ],
              );
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return widget.builder(context, snapshot.data as T, _reload);
          },
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------- SIM

class _SimSection extends StatelessWidget {
  const _SimSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Loading<SimSettings>(
      title: l.mobileSimSection,
      icon: Icons.sim_card_outlined,
      load: (api) => api.getSimSettings(),
      builder: (context, sims, reload) => _SimChooser(sims: sims, reload: reload),
    );
  }
}

class _SimChooser extends StatefulWidget {
  const _SimChooser({required this.sims, required this.reload});

  final SimSettings sims;
  final Future<void> Function() reload;

  @override
  State<_SimChooser> createState() => _SimChooserState();
}

class _SimChooserState extends State<_SimChooser> {
  bool _switching = false;

  Future<void> _switchTo(int index) async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.mobileSimSwitchTitle(index + 1),
      message: l.mobileSimSwitchWarning,
      confirmLabel: l.commonConfirm,
      icon: Icons.sim_card_outlined,
    );
    if (!ok || !mounted) return;
    final api = context.read<ModemApi>();
    final dataCut = context.read<ApnDataCut>();
    final mobileData = context.read<MobileDataController>();
    setState(() => _switching = true);
    try {
      final started = DateTime.now();
      await api.setSimNumber(index, widget.sims.switchPassword);
      // La bascule prend environ 20 s : relire jusqu'au changement (60 s max).
      final deadline = DateTime.now().add(const Duration(seconds: 60));
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(seconds: 3));
        try {
          if ((await api.getSimSettings()).currentSim == index) break;
        } on ModemException {
          // Modem occupé pendant la bascule.
        }
      }
      // Données coupées : la coupure suit la nouvelle SIM, une
      // fois la bascule terminée.
      if (await dataCut.isAnyRequested()) {
        final remaining = const Duration(seconds: 20) - DateTime.now().difference(started);
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
        await dataCut.reapply();
      }
      unawaited(mobileData.refresh());
      await widget.reload();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = widget.sims.currentSim;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.mobileSimCurrent(current == null ? l.commonUnknown : l.simSlot(current + 1))),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: [
            ButtonSegment(value: 0, label: Text(l.simSlot(1)), icon: const Icon(Icons.sim_card_outlined)),
            ButtonSegment(value: 1, label: Text(l.simSlot(2)), icon: const Icon(Icons.sim_card_outlined)),
          ],
          selected: {?current},
          emptySelectionAllowed: true,
          onSelectionChanged: _switching
              ? null
              : (selection) {
                  if (selection.isNotEmpty && selection.first != current) _switchTo(selection.first);
                },
        ),
        if (_switching) ...[
          const SizedBox(height: 12),
          Text(l.mobileSimSwitching),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

// --------------------------------------------------------- Données mobiles

class _MobileDataSection extends StatelessWidget {
  const _MobileDataSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final mobileData = context.watch<MobileDataController>();
    return SectionCard(
      title: l.mobileDataTitle,
      icon: Icons.swap_vert_rounded,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.mobileDataTitle),
          subtitle: Text(mobileData.isBusy
              ? l.mobileDataSwitching
              : switch (mobileData.enabled) {
                  true => l.mobileDataStateOn,
                  false => l.mobileDataStateOff,
                  null => l.commonUnknown,
                }),
          value: mobileData.enabled ?? false,
          onChanged: mobileData.isBusy
              ? null
              : (value) async {
                  try {
                    await mobileData.setEnabled(value);
                  } catch (e) {
                    if (context.mounted) showErrorSnack(context, e);
                  }
                },
        ),
        Text(l.mobileDataExplanation, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// --------------------------------------------------------------------- APN

class _ApnSection extends StatelessWidget {
  const _ApnSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Loading<ApnInfo>(
      title: l.mobileApnSection,
      icon: Icons.settings_input_antenna_rounded,
      load: (api) => api.getApnInfo(),
      builder: (context, info, reload) => _ApnList(info: info, reload: reload),
    );
  }
}

class _ApnList extends StatelessWidget {
  const _ApnList({required this.info, required this.reload});

  final ApnInfo info;
  final Future<void> Function() reload;

  Future<void> _activate(BuildContext context, ApnProfile profile) async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.mobileApnUseTitle,
      message: l.mobileApnUseMessage(profile.name),
      confirmLabel: l.mobileApnUse,
    );
    if (!ok || !context.mounted) return;
    final api = context.read<ModemApi>();
    final dataCut = context.read<ApnDataCut>();
    final mobileData = context.read<MobileDataController>();
    try {
      await api.setCurrentApn(profile);
      // Profil choisi par l'utilisateur : les coupures en cours sont levées.
      await dataCut.forget();
      unawaited(mobileData.refresh());
      await reload();
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _create(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ApnEditorScreen(apnInfo: info)),
    );
    if (created == true) await reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.mobileApnHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        if (info.profiles.isEmpty) Text(l.mobileApnEmpty),
        for (var i = 0; i < info.profiles.length; i++)
          _ApnTile(
            profile: info.profiles[i],
            active: i == info.currentIndex,
            onUse: () => _activate(context, info.profiles[i]),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _create(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(l.mobileApnNew),
        ),
      ],
    );
  }
}

class _ApnTile extends StatelessWidget {
  const _ApnTile({required this.profile, required this.active, required this.onUse});

  final ApnProfile profile;
  final bool active;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final blocker = ApnDataCut.isBlocker(profile);
    final details = <String>[
      '${l.mobileApnApn} : ${profile.apn.isEmpty ? l.commonNotDefined : profile.apn}',
      '${l.commonTypeLabel} : ${pdpTypeLabel(l, profile.pdpType)}',
      '${l.mobileApnMccMnc} : ${profile.mcc}-${profile.mnc}',
      '${l.mobileApnAuth} : ${apnAuthLabel(l, profile.auth)}',
      if (profile.username.isNotEmpty) '${l.mobileApnUsername} : ${profile.username}',
      if (profile.proxy.isNotEmpty) '${l.commonProxyLabel} : ${profile.proxy}${profile.port.isEmpty ? '' : ':${profile.port}'}',
    ];
    return Card(
      elevation: 0,
      color: active ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    blocker ? l.mobileApnBlockerName : (profile.name.isEmpty ? profile.apn : profile.name),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (active) Chip(label: Text(l.mobileApnActive), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 4),
            for (final line in details) Text(line, style: theme.textTheme.bodySmall),
            if (!active && !blocker)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: onUse, child: Text(l.mobileApnUse)),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Mode réseau

class _NetworkModeSection extends StatelessWidget {
  const _NetworkModeSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Loading<String>(
      title: l.mobileModeSection,
      icon: Icons.network_cell_rounded,
      load: (api) => api.getNetworkMode(),
      builder: (context, mode, reload) => _ModeChooser(mode: mode, reload: reload),
    );
  }
}

class _ModeChooser extends StatefulWidget {
  const _ModeChooser({required this.mode, required this.reload});

  final String mode;
  final Future<void> Function() reload;

  @override
  State<_ModeChooser> createState() => _ModeChooserState();
}

class _ModeChooserState extends State<_ModeChooser> {
  bool _busy = false;

  Future<void> _set(String mode) async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.mobileModeChangeTitle,
      message: l.mobileModeChangeMessage(networkModeLabel(l, mode)),
      confirmLabel: l.commonApply,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await context.read<ModemApi>().setNetworkMode(mode);
      await widget.reload();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = widget.mode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RadioGroup<String>(
          groupValue: NetworkModes.all.contains(current) ? current : null,
          onChanged: (value) {
            if (!_busy && value != null && value != current) _set(value);
          },
          child: Column(
            children: [
              for (final mode in NetworkModes.all)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: mode,
                  title: Text(networkModeLabel(l, mode)),
                ),
            ],
          ),
        ),
        if (!NetworkModes.all.contains(current))
          Text(l.mobileModeUnknown(current), style: Theme.of(context).textTheme.bodySmall),
        if (_busy) const LinearProgressIndicator(),
      ],
    );
  }
}

// ------------------------------------------------------------- Partage USB

class _UsbSection extends StatelessWidget {
  const _UsbSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Loading<bool>(
      title: l.dashboardUsbTitle,
      icon: Icons.usb_rounded,
      load: (api) => api.getUsbTether(),
      builder: (context, enabled, reload) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l.mobileUsbLabel),
        subtitle: Text(enabled ? l.commonEnabled : l.commonDisabled),
        value: enabled,
        onChanged: (value) async {
          try {
            await context.read<ModemApi>().setUsbTether(value);
            await reload();
          } catch (e) {
            if (context.mounted) showErrorSnack(context, e);
          }
        },
      ),
    );
  }
}

// ----------------------------------------------------- Détection de coupure

class _ConnectionDetectSection extends StatelessWidget {
  const _ConnectionDetectSection();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Loading<ConnectionDetectConfig>(
      title: l.mobileDetectSection,
      icon: Icons.monitor_heart_outlined,
      load: (api) => api.getConnectionDetect(),
      builder: (context, config, reload) =>
          _DetectForm(key: ObjectKey(config), config: config, reload: reload),
    );
  }
}

class _DetectForm extends StatefulWidget {
  const _DetectForm({super.key, required this.config, required this.reload});

  final ConnectionDetectConfig config;
  final Future<void> Function() reload;

  @override
  State<_DetectForm> createState() => _DetectFormState();
}

class _DetectFormState extends State<_DetectForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _enabled = widget.config.enabled;
  late final List<TextEditingController> _addresses = [
    for (final address in widget.config.addresses) TextEditingController(text: address),
  ];

  @override
  void dispose() {
    for (final controller in _addresses) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final next = widget.config.copyWith(enabled: _enabled, addresses: [for (final c in _addresses) c.text]);
    if (next.validate() == ConnectionDetectError.noAddressWhenEnabled) {
      showSnack(context, context.l10n.mobileDetectNeedAddress, error: true);
      return;
    }
    await context.read<ModemApi>().setConnectionDetect(next);
    if (mounted) showSnack(context, context.l10n.commonSaved);
    await widget.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.mobileDetectHint, style: Theme.of(context).textTheme.bodySmall),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.mobileDetectLabel),
            subtitle: Text(_enabled ? l.commonEnabled : l.commonDisabled),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          for (var i = 0; i < _addresses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _addresses[i],
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: l.mobileDetectAddress(i + 1)),
                validator: (value) =>
                    ConnectionDetectConfig.validateAddress(value ?? '') == null ? null : l.commonInvalidHost,
              ),
            ),
          AsyncButton(onPressed: _save, label: l.commonSave, icon: Icons.save_rounded),
        ],
      ),
    );
  }
}
