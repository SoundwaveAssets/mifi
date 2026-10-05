import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show md5;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_api.dart';
import '../../../core/api/modem_exception.dart';
import '../../../core/models/system_models.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/status/status_controller.dart';
import '../../l10n_helpers.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/modem_restart_dialog.dart';
import '../../widgets/section_card.dart';

/// Mise à jour du firmware (avancé) : `putcrcsystem`, envoi du `.zip` sur
/// `/upload`, puis `getcrcsystem`.
class FirmwareScreen extends StatefulWidget {
  const FirmwareScreen({super.key});

  @override
  State<FirmwareScreen> createState() => _FirmwareScreenState();
}

enum _Phase { idle, preparing, uploading, verifying, done }

class _FirmwareScreenState extends State<FirmwareScreen> {
  final _crc = TextEditingController();
  bool _battery = false;
  bool _plugged = false;
  bool _risks = false;
  XFile? _file;
  int _size = 0;
  bool _computing = false;
  _Phase _phase = _Phase.idle;
  int _sent = 0;
  Completer<void>? _cancel;
  String? _modemError;

  late final StatusController _status = context.read<StatusController>();
  late final NativeBridge _bridge = context.read<NativeBridge>();

  bool get _busy => _phase != _Phase.idle && _phase != _Phase.done;
  bool get _ready => _battery && _plugged && _risks && _file != null && _crc.text.trim().isNotEmpty && !_busy;

  @override
  void dispose() {
    final file = _file;
    if (file != null) _deleteTemporaryCopy(file.path);
    _crc.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final l = context.l10n;
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(
        label: l.firmwareFileLabel,
        extensions: const ['zip'],
        mimeTypes: const ['application/zip', 'application/x-zip-compressed', 'application/octet-stream'],
      ),
    ]);
    if (file == null || !mounted) return;
    final size = await file.length();
    if (!mounted) return;
    if (!file.name.toLowerCase().endsWith('.zip')) {
      _deleteTemporaryCopy(file.path);
      showSnack(context, l.firmwareNotZip, error: true);
      return;
    }
    if (size <= 0 || size > FirmwareCheck.maxFileBytes) {
      _deleteTemporaryCopy(file.path);
      showSnack(context, l.firmwareTooBig, error: true);
      return;
    }
    // Copie du fichier choisi précédemment : plus utile.
    final previous = _file;
    if (previous != null && previous.path != file.path) _deleteTemporaryCopy(previous.path);
    setState(() {
      _file = file;
      _size = size;
      _modemError = null;
    });
  }

  Future<void> _compute({required bool useMd5}) async {
    final path = _file?.path;
    if (path == null) return;
    setState(() => _computing = true);
    try {
      final code = await Isolate.run(() => useMd5 ? _md5Of(path) : _crc32Of(path));
      if (mounted) setState(() => _crc.text = code);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _computing = false);
    }
  }

  Future<void> _start() async {
    final l = context.l10n;
    final file = _file;
    if (file == null) return;
    final ok = await showTypedConfirmDialog(
      context,
      title: l.firmwareConfirmTitle,
      message: l.firmwareConfirmMessage(file.name),
      confirmationWord: l.firmwareConfirmWord,
      confirmLabel: l.firmwareStart,
    );
    if (!ok || !mounted) return;
    final api = context.read<ModemApi>();
    final check = FirmwareCheck.create(crcCode: _crc.text.trim(), fileName: file.name);
    _status.pause(this);
    await _bridge.setKeepScreenOn(true);
    setState(() {
      _phase = _Phase.preparing;
      _sent = 0;
      _modemError = null;
      _cancel = Completer<void>();
    });
    try {
      await api.putCrcSystem(check);
      if (!mounted) return;
      setState(() => _phase = _Phase.uploading);
      await api.uploadFirmware(
        File(file.path),
        fileName: file.name,
        cancel: _cancel!.future,
        onProgress: (sent, total) {
          if (mounted) setState(() => _sent = sent);
        },
      );
      if (!mounted) return;
      setState(() => _phase = _Phase.verifying);
      // Le modem vérifie le fichier : relire tant que le statut est vide (60 s max).
      var result = await api.getCrcSystem(check);
      final deadline = DateTime.now().add(const Duration(seconds: 60));
      while (result.isPending && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(seconds: 2));
        result = await api.getCrcSystem(check);
      }
      if (!mounted) return;
      if (result.isOk) {
        setState(() => _phase = _Phase.done);
        await showInfoDialog(context, title: l.firmwareInProgressTitle, message: l.firmwareInProgress);
        if (mounted) {
          await showModemRestartDialog(
            context,
            message: l.firmwareWaitingRestart,
            timeout: const Duration(minutes: 10),
            initialDelay: const Duration(seconds: 60),
          );
        }
      } else {
        setState(() {
          _phase = _Phase.idle;
          _modemError = result.status.isEmpty ? l.firmwareNoAnswer : result.status;
        });
      }
    } on OperationCancelledException {
      if (mounted) setState(() => _phase = _Phase.idle);
    } catch (e) {
      if (mounted) {
        setState(() => _phase = _Phase.idle);
        showErrorSnack(context, e);
      }
    } finally {
      _status.resume(this);
      await _bridge.setKeepScreenOn(false);
    }
  }

  /// file_selector copie le fichier choisi dans le cache de l'appli : le
  /// supprimer quand il ne sert plus (autre choix, sortie de l'écran), pas
  /// après un envoi pour permettre un nouvel essai.
  void _deleteTemporaryCopy(String path) {
    try {
      if (path.startsWith(Directory.systemTemp.path) || path.contains('/cache/')) File(path).deleteSync();
    } catch (_) {
      // Fichier déjà supprimé ou hors du cache : rien à faire.
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_busy) return true;
    final l = context.l10n;
    final cancel = await showConfirmDialog(
      context,
      title: l.firmwareCancelTitle,
      message: l.firmwareCancelMessage,
      confirmLabel: l.firmwareCancel,
      destructive: true,
    );
    if (cancel && _cancel != null && !_cancel!.isCompleted) _cancel!.complete();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final file = _file;
    return PopScope(
      canPop: !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l.hubFirmwareTitle)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WarningBanner(title: l.firmwareDangerTitle, message: l.firmwareDanger, severity: BannerSeverity.danger),
            const SizedBox(height: 16),
            SectionCard(
              title: l.firmwareChecklist,
              icon: Icons.checklist_rounded,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _battery,
                  onChanged: _busy ? null : (v) => setState(() => _battery = v ?? false),
                  title: Text(l.firmwareCheckBattery),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _plugged,
                  onChanged: _busy ? null : (v) => setState(() => _plugged = v ?? false),
                  title: Text(l.firmwareCheckPlugged),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _risks,
                  onChanged: _busy ? null : (v) => setState(() => _risks = v ?? false),
                  title: Text(l.firmwareCheckRisks),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l.firmwareFileSection,
              icon: Icons.folder_zip_outlined,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pick,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: Text(file == null ? l.firmwareChoose : l.firmwareChooseAnother),
                ),
                if (file != null) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(file.name),
                    subtitle: Text(l.firmwareSize(formatDecimal(context, _size / (1024 * 1024)))),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: _crc,
                  enabled: !_busy,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(labelText: l.firmwareCrcLabel, helperText: l.firmwareCrcHelper, helperMaxLines: 3),
                ),
                if (file != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: _computing ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                        label: Text(l.firmwareComputeMd5),
                        onPressed: _computing || _busy ? null : () => _compute(useMd5: true),
                      ),
                      ActionChip(
                        label: Text(l.firmwareComputeCrc32),
                        onPressed: _computing || _busy ? null : () => _compute(useMd5: false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (_busy) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(switch (_phase) {
                        _Phase.preparing => l.firmwarePreparing,
                        _Phase.uploading => l.firmwareUploading(
                            formatDecimal(context, _sent / (1024 * 1024)), formatDecimal(context, _size / (1024 * 1024))),
                        _ => l.firmwareVerifying,
                      }),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _phase == _Phase.uploading && _size > 0 ? (_sent / _size).clamp(0.0, 1.0) : null,
                      ),
                      const SizedBox(height: 8),
                      Text(l.firmwareDoNotLeave, style: theme.textTheme.bodySmall),
                      if (_phase == _Phase.uploading)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: _confirmLeave, child: Text(l.firmwareCancel)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_modemError != null) ...[
              WarningBanner(title: l.firmwareRefused, message: _modemError!, severity: BannerSeverity.danger),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: _ready ? _start : null,
              icon: const Icon(Icons.system_update_alt_rounded),
              label: Text(l.firmwareStart),
            ),
          ],
        ),
      ),
    );
  }
}

/// MD5 du fichier (32 caractères hexadécimaux).
Future<String> _md5Of(String path) async => (await md5.bind(File(path).openRead()).first).toString();

/// CRC-32 (IEEE 802.3) du fichier, en 8 chiffres hexadécimaux majuscules.
Future<String> _crc32Of(String path) async {
  final table = Uint32List(256);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
    }
    table[n] = c;
  }
  var crc = 0xFFFFFFFF;
  await for (final chunk in File(path).openRead()) {
    for (final byte in chunk) {
      crc = table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
  }
  return ((crc ^ 0xFFFFFFFF) & 0xFFFFFFFF).toRadixString(16).toUpperCase().padLeft(8, '0');
}
