import '../l10n/app_localizations.dart';
import 'api/modem_api.dart';
import 'api/modem_client.dart';
import 'api/modem_exception.dart';
import 'api/modem_transport.dart';
import 'background/background_scheduler.dart';
import 'data/app_data_store.dart';
import 'data/in_memory_app_data_store.dart';
import 'data/sqflite_app_data_store.dart';
import 'l10n/app_locale.dart';
import 'mobile_data/data_cut.dart';
import 'mobile_data/mobile_data.dart';
import 'mobile_data/reconnect.dart';
import 'models/status_models.dart';
import 'monitoring/monitoring_service.dart';
import 'monitoring/notification_service.dart';
import 'native/native_bridge.dart';
import 'session/session_controller.dart';
import 'settings/app_settings.dart';
import 'settings/credentials_store.dart';
import 'status/status_controller.dart';

/// Tous les services de l'appli, construits une fois par moteur Flutter
/// (interface ou tâche d'arrière-plan).
class AppServices {
  AppServices._({
    required this.settings,
    required this.bridge,
    required this.client,
    required this.api,
    required this.credentials,
    required this.store,
    required this.notifications,
    required this.monitoring,
    required this.dataCut,
    required this.reconnect,
    required this.mobileData,
    required this.scheduler,
    required this.session,
  });

  static Future<AppServices> create() async {
    final settings = await AppSettings.load();
    final bridge = NativeBridge();
    final client = ModemClient(ModemTransport(baseUri: settings.modemBaseUri));
    final api = ModemApi(client);
    final credentials = CredentialsStore();
    AppDataStore store;
    try {
      store = await SqfliteAppDataStore.open();
    } catch (_) {
      store = InMemoryAppDataStore();
    }
    AppLocalizations l10n() => localizationsFor(settings.locale);
    final notifications = NotificationService(bridge: bridge, settings: settings, localizations: l10n);
    final dataCut = ApnDataCut(api, store);
    final services = AppServices._(
      settings: settings,
      bridge: bridge,
      client: client,
      api: api,
      credentials: credentials,
      store: store,
      notifications: notifications,
      monitoring: MonitoringService(store: store, notifications: notifications, settings: settings),
      dataCut: dataCut,
      reconnect: ReconnectController(cut: dataCut, api: api, bridge: bridge, store: store),
      mobileData: MobileDataController(
        strategy: createMobileDataStrategy(dataCut),
        bridge: bridge,
        localizations: l10n,
      ),
      scheduler: BackgroundScheduler(bridge: bridge, settings: settings),
      session: SessionController(
        client: client,
        api: api,
        settings: settings,
        credentials: credentials,
        bridge: bridge,
      ),
    );
    services.status = StatusController(
      api: api,
      monitoring: services.monitoring,
      autoRepair: services.runAutoRepair,
      onStatus: services.maintainDataCut,
      probeInternet: bridge.probeInternet,
    );
    return services;
  }

  final AppSettings settings;
  final NativeBridge bridge;
  final ModemClient client;
  final ModemApi api;
  final CredentialsStore credentials;
  final AppDataStore store;
  final NotificationService notifications;
  final MonitoringService monitoring;

  /// Coupure d'internet partagée par les données mobiles et « Relancer la
  /// connexion ».
  final ApnDataCut dataCut;
  final ReconnectController reconnect;
  final MobileDataController mobileData;
  final BackgroundScheduler scheduler;
  final SessionController session;
  late final StatusController status;

  /// Traductions selon le choix de l'utilisateur (hors widgets).
  AppLocalizations get localizations => localizationsFor(settings.locale);

  /// Hors interface (tâches, surveillance continue) : force le Wi-Fi du modem
  /// et ouvre une session si nécessaire avec le mot de passe enregistré.
  /// Lève une [SessionExpiredException] si aucun mot de passe n'est mémorisé.
  Future<void> ensureSignedIn() async {
    await bridge.bindToWifi();
    if (client.hasSession || client.credentials != null) return;
    final password = await credentials.readPassword();
    if (password == null) throw const SessionExpiredException();
    await client.login(ModemCredentials(password: password));
  }

  /// Relit l'état des données mobiles (après la connexion), après avoir
  /// défait une relance interrompue (coupure brève, mode réseau provisoire).
  Future<void> refreshToggles() async {
    await _undoSimSwitchAirplane();
    await reconnect.restoreNetworkMode();
    try {
      await dataCut.releaseLeftover();
    } on ModemException {
      // Modem injoignable : nouvel essai à la prochaine connexion.
    } on DataCutFailedException {
      // Rétablissement refusé : nouvel essai à la prochaine connexion.
    }
    await mobileData.refresh();
  }

  /// Emplacement de la SIM mémorisé par une version précédente, dont le mode
  /// avion basculait sur l'emplacement vide.
  static const String _legacyHomeSlotKey = 'airplane.home_slot';

  /// Si cette version a laissé le modem sur l'emplacement vide, revenir sur
  /// celui de la SIM (une seule fois).
  Future<void> _undoSimSwitchAirplane() async {
    final home = int.tryParse(await store.readState(_legacyHomeSlotKey) ?? '');
    if (home == null) return;
    try {
      final sims = await api.getSimSettings();
      if (sims.currentSim != null && sims.currentSim != home) {
        await api.setSimNumber(home, sims.switchPassword);
      }
      await store.writeState(_legacyHomeSlotKey, null);
      await store.writeState(MonitorStateKeys.reconnectCut, null);
    } on ModemException {
      // Modem injoignable : nouvel essai à la prochaine connexion.
    }
  }

  /// Fait respecter la coupure d'internet demandée (données coupées) d'après
  /// un relevé de l'état du modem, et prévient l'utilisateur si elle ne tient
  /// pas.
  Future<void> maintainDataCut(AllStatus status) async {
    if (reconnect.isBusy || mobileData.isBusy) return;
    try {
      if (!await dataCut.maintain(status)) return;
    } on ModemException {
      return; // Nouvel essai au prochain relevé.
    } on DataCutFailedException {
      return; // Réactivation refusée : nouvel essai au prochain relevé (nombre limité).
    }
    await mobileData.refresh();
    final problem = await dataCut.problem();
    if (problem != null) await notifications.dataCutNotHolding(problem);
  }

  /// Réparation automatique : « Relancer la connexion » (coupure puis retour
  /// d'internet), avec notification du début et du résultat.
  Future<void> runAutoRepair() async {
    if (reconnect.isBusy || mobileData.isBusy) return;
    await notifications.autoRepairStarted();
    try {
      final restored = await reconnect.reconnect(maxAttempts: ReconnectController.autoRepairAttempts);
      await notifications.autoRepairFinished(restored: restored);
    } catch (_) {
      await notifications.autoRepairFinished(restored: false);
    }
  }
}
