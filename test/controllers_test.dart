import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mifi/core/api/modem_api.dart';
import 'package:mifi/core/api/modem_client.dart';
import 'package:mifi/core/api/modem_exception.dart';
import 'package:mifi/core/api/modem_transport.dart';
import 'package:mifi/core/data/in_memory_app_data_store.dart';
import 'package:mifi/core/mobile_data/data_cut.dart';
import 'package:mifi/core/mobile_data/reconnect.dart';
import 'package:mifi/core/native/native_bridge.dart';

import 'support/fake_modem.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/native');
  late FakeModem modem;
  late InMemoryAppDataStore store;
  late ApnDataCut cut;
  late ReconnectController reconnect;
  late DateTime now;
  Future<void> Function()? onDelay;

  setUp(() async {
    // Pas de test réel d'internet hors Android : l'état du modem fait foi.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
    modem = FakeModem();
    final client = ModemClient(ModemTransport(baseUri: Uri.parse('http://192.168.100.1'), httpClient: modem.client));
    await client.login(const ModemCredentials(password: 'admin'));
    final api = ModemApi(client);
    store = InMemoryAppDataStore();
    cut = ApnDataCut(api, store);
    now = DateTime(2026, 10, 5, 10);
    onDelay = null;
    reconnect = ReconnectController(
      cut: cut,
      api: api,
      bridge: NativeBridge(channel: channel),
      store: store,
      delay: (duration) async {
        now = now.add(duration);
        await onDelay?.call();
      },
      clock: () => now,
    );
  });

  String currentApn() {
    final list = modem.apn['apnlist'] as List;
    return (list[modem.apn['apncurrent'] as int] as Map)['apn'] as String;
  }

  test('internet revient dès la première tentative : réinscription puis mode d\'origine remis', () async {
    expect(await reconnect.reconnect(), isTrue);
    expect(reconnect.attempt, 1);
    expect(modem.netmodeHistory, ['2', '0']);
    expect(currentApn(), 'camtel');
    expect(await cut.isAnyRequested(), isFalse);
    expect(reconnect.isBusy, isFalse);
  });

  test('recommence jusqu\'au retour d\'internet', () async {
    modem.status['internetState'] = 'disconnected';
    onDelay = () async {
      // Internet revient pendant la troisième tentative.
      if (modem.netmodeHistory.length >= 6) modem.status['internetState'] = 'connected';
    };
    expect(await reconnect.reconnect(), isTrue);
    expect(reconnect.attempt, 3);
    expect(modem.netmode, '0');
    expect(currentApn(), 'camtel');
  });

  test('« Arrêter » : fin après la tentative en cours, connexion rétablie', () async {
    modem.status['internetState'] = 'disconnected';
    onDelay = () async {
      if (reconnect.step == ReconnectStep.waitingForInternet) reconnect.stop();
    };
    expect(await reconnect.reconnect(), isFalse);
    expect(reconnect.stopRequested, isTrue);
    expect(reconnect.attempt, 1);
    expect(currentApn(), 'camtel');
    expect(modem.netmode, '0');
    expect(await cut.isAnyRequested(), isFalse);
  });

  test('réparation automatique : nombre de tentatives limité', () async {
    modem.status['internetState'] = 'disconnected';
    expect(await reconnect.reconnect(maxAttempts: 2), isFalse);
    expect(reconnect.attempt, 2);
    expect(reconnect.stopRequested, isFalse);
    expect(currentApn(), 'camtel');
  });

  test('rétablissement refusé : la coupure n\'est pas maintenue, mode réseau remis', () async {
    onDelay = () async {
      // Le modem refuse ensuite tout changement de profil APN.
      if (reconnect.step == ReconnectStep.reregistering) modem.unknownCommands.add('setcurrentapn');
    };
    await expectLater(reconnect.reconnect(), throwsA(isA<UnsupportedCommandException>()));
    expect(await cut.isAnyRequested(), isFalse);
    expect(modem.netmode, '0');
    expect(reconnect.isBusy, isFalse);
  });

  test('mode réseau resté provisoire (appli interrompue) : remis au démarrage', () async {
    await store.writeState('reconnect.network_mode', '0');
    modem.netmode = '2';
    expect(await reconnect.restoreNetworkMode(), isTrue);
    expect(modem.netmode, '0');
    expect(await store.readState('reconnect.network_mode'), isNull);
  });
}
