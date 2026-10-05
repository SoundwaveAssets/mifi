import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/session/session_controller.dart';
import '../../../core/settings/app_settings.dart';
import '../../l10n_helpers.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/password_field.dart';
import '../../widgets/state_views.dart';
import 'modem_address_editor.dart';

/// Connexion à l'interface d'administration du modem.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<SessionController>().signIn(_password.text, remember: _remember);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final session = context.watch<SessionController>();
    final busy = session.status == SessionStatus.signingIn;
    final error = session.lastError;
    return Scaffold(
      appBar: AppBar(actions: const [_LanguageButton()]),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 104)),
                    const SizedBox(height: 20),
                    Text(l.loginTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      l.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    PasswordField(
                      controller: _password,
                      label: l.loginPasswordLabel,
                      enabled: !busy,
                      autofocus: !session.hasSavedPassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signIn(),
                      validator: (value) => (value ?? '').isEmpty ? l.commonRequiredField : null,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _remember,
                      onChanged: busy ? null : (value) => setState(() => _remember = value ?? true),
                      title: Text(l.loginRemember),
                      subtitle: Text(l.loginRememberHint),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: busy ? null : _signIn,
                      icon: busy
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.login_rounded),
                      label: Text(l.loginAction),
                    ),
                    if (error != null && !busy) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                describeError(l, error),
                                style: TextStyle(color: theme.colorScheme.onErrorContainer),
                              ),
                              if (isConnectivityError(error)) ...[
                                const SizedBox(height: 8),
                                const ConnectivityHint(),
                              ],
                              if (session.hasSavedPassword && isConnectivityError(error)) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: session.retrySavedPassword,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: Text(l.loginRetrySaved),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.router_outlined),
                        title: Text(l.loginAddressTitle),
                        subtitle: Text(session.modemAddress),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: const [ModemAddressEditor()],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.loginDefaultPasswordHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = context.watch<AppSettings>();
    return PopupMenuButton<String>(
      tooltip: l.dashboardLanguage,
      icon: const Icon(Icons.translate_rounded),
      onSelected: (code) => settings.setLanguageCode(code == 'system' ? null : code),
      itemBuilder: (context) => [
        for (final code in ['system', ...AppSettings.supportedLanguages])
          CheckedPopupMenuItem(
            value: code,
            checked: (settings.languageCode ?? 'system') == code,
            child: Text(languageLabel(l, code == 'system' ? null : code)),
          ),
      ],
    );
  }
}
