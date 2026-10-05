import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_services.dart';
import '../core/l10n/app_locale.dart';
import '../core/session/session_controller.dart';
import '../core/settings/app_settings.dart';
import '../l10n/app_localizations.dart';
import 'l10n_helpers.dart';
import 'screens/login/login_screen.dart';
import 'shell/home_shell.dart';
import 'theme.dart';
import 'widgets/app_lock.dart';
import 'widgets/app_logo.dart';

/// Expose les services à l'interface (`context.read<ModemApi>()`…).
class AppScope extends StatelessWidget {
  const AppScope({super.key, required this.services, required this.child});

  final AppServices services;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: services),
        Provider.value(value: services.api),
        Provider.value(value: services.client),
        Provider.value(value: services.bridge),
        Provider.value(value: services.store),
        Provider.value(value: services.credentials),
        Provider.value(value: services.notifications),
        Provider.value(value: services.monitoring),
        Provider.value(value: services.scheduler),
        Provider.value(value: services.dataCut),
        ChangeNotifierProvider.value(value: services.settings),
        ChangeNotifierProvider.value(value: services.session),
        ChangeNotifierProvider.value(value: services.status),
        ChangeNotifierProvider.value(value: services.reconnect),
        ChangeNotifierProvider.value(value: services.mobileData),
      ],
      child: child,
    );
  }
}

class MifiApp extends StatelessWidget {
  const MifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: (locales, supported) =>
          resolveAppLocale(settings.locale, locales ?? const []),
      builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
      home: const RootGate(),
    );
  }
}

/// Écran selon l'état de la session : démarrage, connexion ou appli.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<SessionController, SessionStatus>((s) => s.status);
    final Widget child = switch (status) {
      SessionStatus.starting => const _SplashScreen(),
      SessionStatus.signedOut || SessionStatus.signingIn => const LoginScreen(),
      SessionStatus.signedIn => const HomeShell(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(child.runtimeType), child: child),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 112),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(context.l10n.splashConnecting, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
