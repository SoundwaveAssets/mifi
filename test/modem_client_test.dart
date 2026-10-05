import 'package:flutter_test/flutter_test.dart';
import 'package:mifi/core/api/modem_api.dart';
import 'package:mifi/core/api/modem_client.dart';
import 'package:mifi/core/api/modem_exception.dart';
import 'package:mifi/core/api/modem_transport.dart';

import 'support/fake_modem.dart';

void main() {
  late FakeModem modem;
  late ModemClient client;
  late ModemApi api;

  setUp(() {
    modem = FakeModem();
    client = ModemClient(ModemTransport(baseUri: Uri.parse('http://192.168.100.1'), httpClient: modem.client));
    api = ModemApi(client);
  });

  test('connexion puis commande avec sessionId et Authorization', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    final status = await api.getAllStatus();
    expect(status.signalBars, 3);
    expect(modem.last('getallstatus')!['sessionId'], modem.session);
    expect(modem.headers.last['Authorization'], modem.session);
  });

  test('mot de passe refusé', () async {
    expect(
      () => client.login(const ModemCredentials(password: 'faux')),
      throwsA(isA<LoginFailedException>()),
    );
  });

  test('SessionOut : reconnexion automatique puis relance', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    modem.expireNext = true;
    final status = await api.getAllStatus();
    expect(status.isInternetConnected, isTrue);
    expect(modem.loginCount, 2);
  });

  test('plusieurs requêtes en SessionOut : une seule reconnexion', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    modem.session = 'expirée';
    await Future.wait([api.getAllStatus(), api.getWifiInfo(), api.getSimSettings()]);
    expect(modem.loginCount, 2);
  });

  test('mot de passe changé ailleurs : session perdue', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    final lost = client.sessionLost.first;
    modem
      ..password = 'nouveau'
      ..session = 'expirée';
    await expectLater(api.getAllStatus(), throwsA(isA<SessionExpiredException>()));
    expect(await lost, isA<LoginFailedException>());
  });

  test('commande inconnue : réponse vide', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    modem.unknownCommands.add('getsysinfo');
    expect(api.getSysInfo(), throwsA(isA<UnsupportedCommandException>()));
  });

  test('corps exacts de setsimnum et sethimiusbtether', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    await api.setSimNumber(1, 'k3y');
    expect(modem.last('setsimnum')!['params'], 1);
    expect(modem.last('setsimnum')!['params1'], 'k3y');
    await api.setUsbTether(true);
    expect(modem.last('sethimiusbtether')!['params'], '1');
    await api.setNetworkMode('1');
    expect(modem.last('setnetworkmode')!['params'], {'netmode': '1'});
  });

  test('getconfig sans session, langindex en code de langue', () async {
    final config = await api.getConfig();
    expect(config.webLanguage, 'fr');
    expect(config.simSlots, 2);
  });

  test('liste des appareils dans params.devlist', () async {
    await client.login(const ModemCredentials(password: 'admin'));
    final devices = await api.getConnectedDevices();
    expect(devices.single.mac, 'AA:BB:CC:DD:EE:01');
  });
}
