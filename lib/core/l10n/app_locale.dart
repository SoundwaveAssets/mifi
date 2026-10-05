import 'dart:ui';

import '../../l10n/app_localizations.dart';

/// Langue par défaut quand celle du téléphone n'est pas prise en charge.
const Locale defaultAppLocale = Locale('fr');

/// Langue effective de l'appli : [preferred] (choix de l'utilisateur) si elle
/// est prise en charge, sinon la première langue du téléphone prise en
/// charge, sinon le français.
Locale resolveAppLocale(Locale? preferred, Iterable<Locale> systemLocales) {
  bool supported(Locale locale) =>
      AppLocalizations.supportedLocales.any((s) => s.languageCode == locale.languageCode);
  if (preferred != null && supported(preferred)) return Locale(preferred.languageCode);
  for (final locale in systemLocales) {
    if (supported(locale)) return Locale(locale.languageCode);
  }
  return defaultAppLocale;
}

/// Traductions hors widgets (tâches d'arrière-plan, notifications, tuile).
AppLocalizations localizationsFor(Locale? preferred) =>
    lookupAppLocalizations(resolveAppLocale(preferred, PlatformDispatcher.instance.locales));
