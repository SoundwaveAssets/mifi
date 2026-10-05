import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/modem_exception.dart';
import '../../../core/session/session_controller.dart';
import '../../l10n_helpers.dart';
import '../../widgets/feedback.dart';
import '../../widgets/password_field.dart';

/// Changement du mot de passe administrateur du modem. L'appli se
/// reconnecte avec le nouveau mot de passe (et le mémorise s'il l'était).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  static final RegExp _printable = RegExp(r'^[\x21-\x7E]+$');

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    final session = context.read<SessionController>();
    setState(() => _busy = true);
    try {
      await session.changePassword(
        oldPassword: _old.text,
        newPassword: _new.text,
        confirmPassword: _confirm.text,
      );
      if (!mounted) return;
      showSnack(context, l.systemPasswordChanged);
      Navigator.of(context).pop();
    } on CommandFailedException {
      if (mounted) showSnack(context, l.systemPasswordRefused, error: true);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.dashboardChangePassword)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.systemPasswordIntro),
            const SizedBox(height: 16),
            PasswordField(
              controller: _old,
              label: l.systemOldPassword,
              validator: (v) => (v ?? '').isEmpty ? l.commonRequiredField : null,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _new,
              label: l.systemNewPassword,
              helperText: l.systemPasswordRules,
              maxLength: 32,
              validator: (v) {
                final value = v ?? '';
                if (value.length < 4 || value.length > 32 || !_printable.hasMatch(value)) return l.systemPasswordRules;
                if (value == _old.text) return l.systemPasswordSame;
                return null;
              },
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _confirm,
              label: l.systemConfirmPassword,
              validator: (v) => v != _new.text ? l.systemPasswordMismatch : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_rounded),
              label: Text(l.dashboardChangePassword),
            ),
          ],
        ),
      ),
    );
  }
}
