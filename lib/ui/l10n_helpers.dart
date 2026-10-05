import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/api/modem_exception.dart';
import '../core/mobile_data/data_cut.dart';
import '../core/models/mobile_models.dart';
import '../core/models/status_models.dart';
import '../core/models/wifi_models.dart';
import '../core/util/operators.dart';
import '../core/util/signal.dart';
import '../core/util/speed.dart';
import '../l10n/app_localizations.dart';

export '../core/l10n/formatters.dart' show formatDuration;

/// Accès court aux traductions : `context.l10n.commonSave`.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Message traduit pour une erreur quelconque (voir `ModemException`).
String describeError(AppLocalizations l, Object error) {
  return switch (error) {
    ModemUnreachableException e => l.errorUnreachable(e.address),
    ModemTimeoutException _ => l.errorTimeout,
    LoginFailedException _ => l.errorLoginFailed,
    SessionExpiredException _ => l.errorSessionExpired,
    CommandFailedException e => l.errorCommandFailed(e.reply),
    UnsupportedCommandException _ => l.errorUnsupported,
    InvalidResponseException _ => l.errorInvalidResponse,
    OperationCancelledException _ => l.errorCancelled,
    DataCutFailedException _ => l.dataCutFailed,
    DataCutNotHoldingException(problem: DataCutProblem.profileLost) => l.dataCutProfileLost,
    DataCutNotHoldingException(problem: DataCutProblem.internetStillUp) => l.dataCutInternetStillUp,
    _ => l.errorUnexpected('$error'),
  };
}

/// Nom d'opérateur à afficher : nom de service de la SIM (ex. « blue »),
/// sinon nom tiré de l'IMSI (MTN, Orange…), sinon « Opérateur 624-XX ».
String operatorLabel(AppLocalizations l, AllStatus? status) {
  if (status == null) return l.operatorUnknown;
  if (!status.hasSim) return l.noSim;
  final service = status.serviceName;
  if (service != null) return service;
  final info = status.operator;
  if (info == null) return l.operatorUnknown;
  return info.name ?? l.operatorCode(info.code);
}

/// Nom d'un opérateur à partir de son code `624-05` (comparatif).
String operatorCodeLabel(AppLocalizations l, String code, {String? serviceName}) {
  if (serviceName != null && serviceName.isNotEmpty) return serviceName;
  final known = knownOperators[code.replaceAll('-', '')];
  return known ?? l.operatorCode(code);
}

/// Erreur liée à la connexion avec le modem (afficher l'aide Wi-Fi).
bool isConnectivityError(Object error) =>
    error is ModemUnreachableException || error is ModemTimeoutException;

// ------------------------------------------------------------- Dates/heures

/// Heure (ex. 14:05:32).
String formatTime(BuildContext context, DateTime time) =>
    DateFormat.Hms(context.l10n.localeName).format(time);

/// Date et heure courtes (ex. 3 oct. 14:05).
String formatDateTime(BuildContext context, DateTime time) =>
    DateFormat.MMMd(context.l10n.localeName).add_Hm().format(time);

/// Date et heure complètes (ex. 3 oct. 2026 14:05).
String formatFullDateTime(BuildContext context, DateTime time) =>
    DateFormat.yMMMd(context.l10n.localeName).add_Hm().format(time);

/// Nombre décimal selon la langue (ex. 12,5 en français).
String formatDecimal(BuildContext context, double value, {int digits = 1}) =>
    NumberFormat.decimalPatternDigits(locale: context.l10n.localeName, decimalDigits: digits).format(value);

// ---------------------------------------------------------------- Libellés

String deviceTypeLabel(AppLocalizations l, DeviceConnectionType type) => switch (type) {
      DeviceConnectionType.wifi => l.deviceTypeWifi,
      DeviceConnectionType.wired => l.deviceTypeWired,
      DeviceConnectionType.unknown => l.deviceTypeUnknown,
    };

String signalQualityLabel(AppLocalizations l, SignalQuality quality) => switch (quality) {
      SignalQuality.none => l.signalQualityNone,
      SignalQuality.poor => l.signalQualityPoor,
      SignalQuality.fair => l.signalQualityFair,
      SignalQuality.good => l.signalQualityGood,
      SignalQuality.excellent => l.signalQualityExcellent,
    };

String speedQualityLabel(AppLocalizations l, SpeedQuality quality) => switch (quality) {
      SpeedQuality.none => l.speedQualityNone,
      SpeedQuality.poor => l.speedQualityPoor,
      SpeedQuality.fair => l.speedQualityFair,
      SpeedQuality.good => l.speedQualityGood,
      SpeedQuality.excellent => l.speedQualityExcellent,
    };

/// Ce que permet un débit de cette qualité.
String speedQualityHint(AppLocalizations l, SpeedQuality quality) => switch (quality) {
      SpeedQuality.none => l.speedQualityNoneHint,
      SpeedQuality.poor => l.speedQualityPoorHint,
      SpeedQuality.fair => l.speedQualityFairHint,
      SpeedQuality.good => l.speedQualityGoodHint,
      SpeedQuality.excellent => l.speedQualityExcellentHint,
    };

/// Sécurité Wi-Fi (`wifiauth`) ; valeur inconnue affichée telle quelle.
String wifiAuthLabel(AppLocalizations l, String code) => switch (code.trim()) {
      WifiInfo.authNone => l.wifiAuthNone,
      WifiInfo.authWpaPsk => l.wifiAuthWpaPsk,
      WifiInfo.authWpa2Psk => l.wifiAuthWpa2Psk,
      _ => code.isEmpty ? l.commonNotDefined : code,
    };

/// Mode réseau (`netmode`) ; valeur inconnue affichée telle quelle.
String networkModeLabel(AppLocalizations l, String code) => switch (code.trim()) {
      NetworkModes.auto4g3g => l.networkModeAuto,
      NetworkModes.only4g => l.networkMode4gOnly,
      NetworkModes.only3g => l.networkMode3gOnly,
      _ => code.isEmpty ? l.commonNotDefined : code,
    };

/// Authentification APN ; "-1" ou valeur inconnue → « Non défini ».
String apnAuthLabel(AppLocalizations l, String code) => switch (code.trim()) {
      ApnProfile.authNone => l.apnAuthNone,
      ApnProfile.authPap => l.apnAuthPap,
      ApnProfile.authChap => l.apnAuthChap,
      ApnProfile.authPapChap => l.apnAuthPapChap,
      _ => l.commonNotDefined,
    };

/// Type PDP ("IP" et "IPV4" → IPv4) ; valeur inconnue affichée telle quelle.
String pdpTypeLabel(AppLocalizations l, String code) => switch (code.trim().toUpperCase()) {
      'IP' || 'IPV4' => l.pdpTypeIpv4,
      'IPV6' => l.pdpTypeIpv6,
      'IPV4V6' => l.pdpTypeIpv4v6,
      _ => code.isEmpty ? l.commonNotDefined : code,
    };

/// Langue de l'appli (`null` = langue du téléphone).
String languageLabel(AppLocalizations l, String? code) => switch (code) {
      'fr' => l.languageFrench,
      'en' => l.languageEnglish,
      _ => l.languageSystem,
    };
