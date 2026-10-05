import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_services.dart';
import 'background/task_handlers.dart';
import 'l10n/app_locale.dart';
import 'models/system_models.dart';
import 'status/status_controller.dart';
import 'util/signal.dart';

/// Relie les services entre eux dans le moteur principal (interface) :
/// - tâches Android confiées à l'appli ouverte ;
/// - connexion ↔ rafraîchissement automatique, données mobiles ;
/// - réglages ↔ tâches Android, canaux de notification, langue du modem ;
/// - relevés ↔ widget d'état.
void wireAppServices(AppServices services) {
  final session = services.session;
  final settings = services.settings;

  services.bridge.listen(taskHandler: BackgroundTaskHandlers(services).run);

  var wasSignedIn = false;
  session.addListener(() {
    final signedIn = session.isSignedIn;
    if (signedIn == wasSignedIn) return;
    wasSignedIn = signedIn;
    if (signedIn) {
      services.status.start();
      unawaited(services.refreshToggles());
      // Surveillance continue appli fermée, si l'utilisateur l'a acceptée.
      if (settings.monitorEnabled) unawaited(services.bridge.startMonitor());
    } else {
      services.status.stop();
      // Déconnexion : plus de session possible, la surveillance s'arrête.
      unawaited(services.bridge.stopMonitor());
    }
  });

  var previous = _SettingsSnapshot.of(services);
  settings.addListener(() {
    final current = _SettingsSnapshot.of(services);
    if (current.scheduleKey != previous.scheduleKey) unawaited(services.scheduler.sync());
    final languageChanged = current.languageCode != previous.languageCode;
    if (languageChanged) {
      unawaited(services.notifications.ensureChannels());
      unawaited(services.mobileData.publish());
      final snapshot = services.status.snapshot;
      if (snapshot != null) publishStatusWidget(services, snapshot);
    }
    final syncTurnedOn = current.applyToModem && !previous.applyToModem;
    if (current.applyToModem && (languageChanged || syncTurnedOn) && session.isSignedIn) {
      unawaited(applyLanguageToModem(services));
    }
    previous = current;
  });

  DateTime? lastPublished;
  services.status.addListener(() {
    final time = services.status.snapshot?.time;
    if (time == null || time == lastPublished) return;
    lastPublished = time;
    final snapshot = services.status.snapshot;
    if (snapshot != null) publishStatusWidget(services, snapshot);
  });
}

/// « Appliquer aussi à l'interface web du modem » : envoie `selectlang`.
/// Renvoie `true` si le modem a accepté.
Future<bool> applyLanguageToModem(AppServices services) async {
  final locale = resolveAppLocale(services.settings.locale, PlatformDispatcher.instance.locales);
  try {
    await services.api.selectLanguage(ModemWebLanguages.forAppLanguage(locale.languageCode));
    return true;
  } catch (e) {
    debugPrint('selectlang : $e');
    return false;
  }
}

/// Met à jour le widget d'état d'Android avec le relevé [snapshot] (interface
/// ou surveillance continue).
void publishStatusWidget(AppServices services, StatusSnapshot snapshot) {
  final l = services.localizations;
  final status = snapshot.status;
  final operator = snapshot.operator;
  final operatorText = !status.hasSim
      ? l.noSim
      : status.serviceName ?? operator?.name ?? (operator != null ? l.operatorCode(operator.code) : l.operatorUnknown);
  final dbm = status.signalDbm;
  final counts = snapshot.deviceCounts;
  // Connexion coupée par l'appli : barres vides et raison de la coupure.
  final cutText = services.mobileData.connectionCut ? '${l.mobileDataTitle} : ${l.mobileDataStateOff}' : null;
  unawaited(services.bridge.publishStatusWidget(
    operatorText: operatorText,
    signalBars: cutText != null ? 0 : status.signalBars,
    signalText: cutText ?? (isValidSignalDbm(dbm) ? l.signalDbm(dbm!) : l.signalQualityNone),
    internetOk: status.isInternetConnected,
    internetText: status.isInternetConnected ? l.widgetInternetOn : l.widgetInternetOff,
    devicesText: l.deviceCount(counts?.total ?? 0),
  ));
}


class _SettingsSnapshot {
  const _SettingsSnapshot(this.languageCode, this.applyToModem, this.scheduleKey);

  factory _SettingsSnapshot.of(AppServices services) {
    final s = services.settings;
    return _SettingsSnapshot(
      s.languageCode,
      s.applyLanguageToModem,
      '${s.backgroundChecksEnabled}|${s.rebootScheduleEnabled}|${s.rebootScheduleMinutes}',
    );
  }

  final String? languageCode;
  final bool applyToModem;
  final String scheduleKey;
}
