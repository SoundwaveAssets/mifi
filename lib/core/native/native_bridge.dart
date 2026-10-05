import 'dart:async';

import 'package:flutter/services.dart';

/// État du Wi-Fi du téléphone, vu par Android.
class WifiStatus {
  const WifiStatus({
    required this.supported,
    required this.wifiConnected,
    required this.bound,
    required this.validated,
    this.gateway,
    this.ipAddress,
    this.prefixLength,
  });

  factory WifiStatus.fromMap(Map<Object?, Object?> map) => WifiStatus(
        supported: true,
        wifiConnected: map['wifiConnected'] == true,
        bound: map['bound'] == true,
        validated: map['validated'] == true,
        gateway: map['gateway'] as String?,
        ipAddress: map['ipAddress'] as String?,
        prefixLength: map['prefixLength'] as int?,
      );

  /// Hors Android (tests) : pas d'information.
  static const unsupported = WifiStatus(supported: false, wifiConnected: false, bound: false, validated: false);

  /// `false` si la plateforme ne fournit pas l'information.
  final bool supported;

  /// Le téléphone est connecté à un réseau Wi-Fi.
  final bool wifiConnected;

  /// Le processus est lié à ce réseau (`bindProcessToNetwork`) : toutes les
  /// requêtes passent par le Wi-Fi, même s'il est marqué « sans internet ».
  final bool bound;

  /// Android a validé l'accès à internet sur ce Wi-Fi.
  final bool validated;

  /// Passerelle du Wi-Fi (normalement l'adresse du modem).
  final String? gateway;
  final String? ipAddress;
  final int? prefixLength;
}

/// Canal de notification Android (nom et description déjà traduits).
class NotificationChannelSpec {
  const NotificationChannelSpec({
    required this.id,
    required this.name,
    required this.description,
    this.highImportance = false,
  });

  final String id;
  final String name;
  final String description;
  final bool highImportance;

  Map<String, Object?> toMap() =>
      {'id': id, 'name': name, 'description': description, 'highImportance': highImportance};
}

/// Interrupteurs rapides publiés vers Android (tuile « Réglages rapides »).
enum QuickToggle {
  mobileData('mobile_data');

  const QuickToggle(this.id);
  final String id;
}

/// État affiché par une tuile « Réglages rapides » ou un widget.
enum ToggleDisplayState { on, off, switching, unknown, error }

/// Résultat d'une tâche d'arrière-plan.
class BackgroundTaskResult {
  const BackgroundTaskResult({required this.success, this.message});

  const BackgroundTaskResult.ok([this.message]) : success = true;
  const BackgroundTaskResult.failed([this.message]) : success = false;

  final bool success;

  /// Information technique (journal), jamais affichée telle quelle.
  final String? message;

  Map<String, Object?> toMap() => {'success': success, 'message': message};
}

/// Gestionnaire d'une tâche d'arrière-plan exécutée dans le moteur principal
/// (quand l'appli est ouverte, Android lui confie la tâche au lieu de
/// démarrer un moteur Flutter séparé).
typedef BackgroundTaskHandler = Future<BackgroundTaskResult> Function(String task, Map<String, Object?> payload);

/// Pont vers le code Kotlin (`android/app/src/main/kotlin/.../NativeBridge.kt`).
///
/// Canal unique `com.assoumou.mifi/native`, enregistré sur le moteur principal
/// et sur les moteurs d'arrière-plan. Hors Android, toutes les méthodes
/// renvoient une valeur neutre.
class NativeBridge {
  NativeBridge({MethodChannel? channel}) : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'com.assoumou.mifi/native';

  final MethodChannel _channel;
  BackgroundTaskHandler? _taskHandler;
  final _routes = StreamController<String>.broadcast();

  /// Écrans demandés par Android pendant que l'appli est ouverte
  /// (raccourci, action de notification, widget).
  Stream<String> get routes => _routes.stream;

  // ------------------------------------------------------------------- Wi-Fi

  /// Lie le processus au réseau Wi-Fi actuel (et aux suivants) pour que les
  /// requêtes vers le modem ne partent pas par les données mobiles.
  Future<WifiStatus> bindToWifi() => _wifi('bindToWifi');

  /// État actuel du Wi-Fi (sans rien modifier).
  Future<WifiStatus> wifiStatus() => _wifi('getWifiStatus');

  Future<WifiStatus> _wifi(String method) async {
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(method);
      return map == null ? WifiStatus.unsupported : WifiStatus.fromMap(map);
    } on MissingPluginException {
      return WifiStatus.unsupported;
    } on PlatformException {
      return WifiStatus.unsupported;
    }
  }

  /// Propose à Android d'enregistrer ce réseau Wi-Fi (après un changement de
  /// mot de passe) : boîte « Enregistrer ce réseau ? » sur Android 11+, sinon
  /// ouverture des réglages Wi-Fi. `true` si quelque chose a été affiché.
  Future<bool> suggestWifiNetwork({required String ssid, required String password, bool hidden = false}) async =>
      await _invokeResult<bool>('suggestWifiNetwork', {'ssid': ssid, 'password': password, 'hidden': hidden}) ??
      false;

  // ----------------------------------------------------------------- Écran

  /// Garde l'écran allumé (mode « Trouver le meilleur emplacement »).
  Future<void> setKeepScreenOn(bool keepOn) => _invoke('setKeepScreenOn', {'on': keepOn});

  // --------------------------------------------------------- Notifications

  /// Crée ou met à jour les canaux (noms traduits). Idempotent.
  Future<void> ensureNotificationChannels(List<NotificationChannelSpec> channels) =>
      _invoke('ensureNotificationChannels', {'channels': [for (final c in channels) c.toMap()]});

  /// Affiche une notification. [route] : écran ouvert par un appui ;
  /// [actionLabel] et [actionRoute] : bouton d'action facultatif.
  Future<void> showNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    String? route,
    String? actionLabel,
    String? actionRoute,
  }) =>
      _invoke('showNotification', {
        'id': id,
        'channelId': channelId,
        'title': title,
        'body': body,
        'route': route,
        'actionLabel': actionLabel,
        'actionRoute': actionRoute,
      });

  /// Demande l'autorisation d'afficher des notifications (Android 13+).
  /// Renvoie `true` si elles sont autorisées.
  Future<bool> requestNotificationPermission() async =>
      await _invokeResult<bool>('requestNotificationPermission') ?? false;

  /// Les notifications sont-elles autorisées pour l'appli ?
  Future<bool> notificationsAllowed() async => await _invokeResult<bool>('areNotificationsEnabled') ?? false;

  // -------------------------------------------------------------- Partage

  /// Ouvre « Enregistrer sous… » (Storage Access Framework) et écrit
  /// [bytes]. `true` si enregistré, `false` si l'utilisateur annule.
  Future<bool> saveDocument({required String fileName, required String mimeType, required Uint8List bytes}) async =>
      await _invokeResult<bool>('saveDocument', {'fileName': fileName, 'mimeType': mimeType, 'bytes': bytes}) ??
      false;

  /// Partage un texte (WhatsApp, SMS…) par la feuille de partage d'Android.
  Future<void> shareText({required String text, String? title}) =>
      _invoke('shareText', {'text': text, 'title': title});

  // --------------------------------------------------- Tuiles et widgets

  /// Publie l'état d'un interrupteur rapide (textes traduits) pour sa tuile
  /// « Réglages rapides » et le widget. [switchingText] est affiché par
  /// Android dès l'appui, avant que la tâche Dart ne démarre.
  Future<void> publishToggleState({
    required QuickToggle toggle,
    required ToggleDisplayState state,
    required String label,
    required String stateText,
    required String switchingText,
  }) =>
      _invoke('publishToggleState', {
        'toggle': toggle.id,
        'state': state.name,
        'label': label,
        'stateText': stateText,
        'switchingText': switchingText,
      });

  /// Met à jour le widget d'état (textes déjà traduits).
  Future<void> publishStatusWidget({
    required String operatorText,
    required int signalBars,
    required String signalText,
    required bool internetOk,
    required String internetText,
    required String devicesText,
  }) =>
      _invoke('publishStatusWidget', {
        'operator': operatorText,
        'signalBars': signalBars,
        'signal': signalText,
        'internetOk': internetOk,
        'internet': internetText,
        'devices': devicesText,
      });

  // ------------------------------------------------ Tâches d'arrière-plan

  /// Active ou coupe la vérification périodique (WorkManager).
  Future<void> setPeriodicCheck({required bool enabled, int intervalMinutes = 15}) =>
      _invoke('setPeriodicCheck', {'enabled': enabled, 'intervalMinutes': intervalMinutes});

  /// Programme la tâche [task] à l'heure [at] (AlarmManager). Remplace une
  /// programmation précédente de la même tâche.
  Future<void> scheduleTask({required String task, required DateTime at}) =>
      _invoke('scheduleTask', {'task': task, 'atMillis': at.millisecondsSinceEpoch});

  Future<void> cancelScheduledTask(String task) => _invoke('cancelScheduledTask', {'task': task});

  /// Dans un moteur d'arrière-plan : tâche à exécuter, si elle n'a pas été
  /// transmise en argument du point d'entrée. `null` hors arrière-plan.
  Future<(String task, String payload)?> backgroundTask() async {
    final map = await _invokeResult<Map<Object?, Object?>>('getBackgroundTask');
    if (map == null || map['task'] == null) return null;
    return ('${map['task']}', '${map['payload'] ?? ''}');
  }

  /// Dans un moteur d'arrière-plan : signale la fin de la tâche à Android
  /// (qui détruit alors le moteur).
  Future<void> backgroundTaskCompleted(BackgroundTaskResult result) =>
      _invoke('backgroundTaskCompleted', result.toMap());

  /// Écran demandé au lancement de l'appli (raccourci, notification), une
  /// seule fois.
  Future<String?> takeLaunchRoute() => _invokeResult<String>('takeLaunchRoute');

  /// Internet passe-t-il réellement par le Wi-Fi du modem ? Même test
  /// qu'Android (page « generate_204 »). `null` si le test est impossible
  /// (pas de Wi-Fi, hors Android).
  Future<bool?> probeInternet() => _invokeResult<bool>('probeInternet');

  // ------------------------------------------- Surveillance continue

  /// Démarre la surveillance continue (service Android au premier plan,
  /// relancé au démarrage du téléphone). Renvoie `false` si Android refuse.
  Future<bool> startMonitor() async => await _invokeResult<bool>('startMonitor') ?? false;

  /// Arrête la surveillance continue.
  Future<void> stopMonitor() => _invoke('stopMonitor');

  Future<bool> isMonitorRunning() async => await _invokeResult<bool>('isMonitorRunning') ?? false;

  /// L'interface de l'appli est-elle affichée ? (Elle relève alors elle-même
  /// l'état du modem.)
  Future<bool> isAppVisible() async => await _invokeResult<bool>('isAppVisible') ?? false;

  /// L'appli peut-elle fonctionner en arrière-plan sans restriction de
  /// batterie ?
  Future<bool> isIgnoringBatteryOptimizations() async =>
      await _invokeResult<bool>('isIgnoringBatteryOptimizations') ?? true;

  /// Affiche la demande système « Autoriser en arrière-plan ? ».
  Future<void> requestIgnoreBatteryOptimizations() => _invoke('requestIgnoreBatteryOptimizations');

  // ------------------------------------------------ Réglages système

  /// Alarmes exactes autorisées (programmations à l'heure près).
  Future<bool> canScheduleExactAlarms() async => await _invokeResult<bool>('canScheduleExactAlarms') ?? true;

  /// Ouvre l'autorisation « Alarmes et rappels » de l'appli.
  Future<void> openExactAlarmSettings() => _invoke('openExactAlarmSettings');

  /// Ouvre le réglage « Démarrage automatique » (Xiaomi), sinon la fiche de
  /// l'appli.
  Future<void> openAutostartSettings() => _invoke('openAutostartSettings');

  /// Ouvre la fiche de l'appli dans les réglages Android (batterie…).
  Future<void> openAppSettings() => _invoke('openAppSettings');

  /// Dans le moteur principal : reçoit les tâches confiées par Android
  /// (`runTask`) et les écrans à ouvrir (`openRoute`, voir [routes]).
  void listen({BackgroundTaskHandler? taskHandler}) {
    _taskHandler = taskHandler;
    _channel.setMethodCallHandler((call) async {
      final args = (call.arguments as Map?) ?? const {};
      switch (call.method) {
        case 'runTask':
          final handler = _taskHandler;
          if (handler == null) return const BackgroundTaskResult.failed('no handler').toMap();
          final payload = Map<String, Object?>.from((args['payload'] as Map?) ?? const {});
          return (await handler('${args['task'] ?? ''}', payload)).toMap();
        case 'openRoute':
          final route = args['route'];
          if (route is String && route.isNotEmpty) _routes.add(route);
          return null;
      }
      throw MissingPluginException(call.method);
    });
  }

  // ----------------------------------------------------------------- Outils

  Future<void> _invoke(String method, [Object? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // Hors Android (tests).
    } on PlatformException {
      // Fonction indisponible (ex. pas d'activité en arrière-plan).
    }
  }

  Future<T?> _invokeResult<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
