import 'package:flutter_test/flutter_test.dart';
import 'package:mifi/core/api/modem_api.dart';
import 'package:mifi/core/api/modem_client.dart';
import 'package:mifi/core/api/modem_transport.dart';
import 'package:mifi/core/data/app_data_store.dart';
import 'package:mifi/core/data/in_memory_app_data_store.dart';
import 'package:mifi/core/mobile_data/data_cut.dart';
import 'package:mifi/core/mobile_data/mobile_data.dart';

import 'support/fake_modem.dart';

void main() {
  late FakeModem modem;
  late InMemoryAppDataStore store;
  late ModemApi api;
  late ApnDataCut cut;
  late ApnMobileData data;

  setUp(() async {
    modem = FakeModem();
    final client = ModemClient(ModemTransport(baseUri: Uri.parse('http://192.168.100.1'), httpClient: modem.client));
    await client.login(const ModemCredentials(password: 'admin'));
    store = InMemoryAppDataStore();
    api = ModemApi(client);
    cut = ApnDataCut(api, store);
    data = ApnMobileData(cut);
  });

  List<Map> profiles() => (modem.apn['apnlist'] as List).cast<Map>();
  String currentApn() => profiles()[modem.apn['apncurrent'] as int]['apn'] as String;

  test('données coupées sans changer de SIM, puis rétablies', () async {
    expect(await data.isEnabled(), isTrue);
    await data.setEnabled(false);
    expect(await data.isEnabled(), isFalse);
    expect(currentApn(), ApnDataCut.blockerApn);
    expect(await store.readState(MonitorStateKeys.mobileDataOffExpected), '1');
    expect(modem.requests.where((r) => r['cmdid'] == 'setsimnum'), isEmpty);

    await data.setEnabled(true);
    expect(await data.isEnabled(), isTrue);
    expect(currentApn(), 'camtel');
    expect(await store.readState(MonitorStateKeys.mobileDataOffExpected), isNull);
  });

  test('profil de coupure IPv6 créé pour l\'opérateur actuel, jamais dupliqué', () async {
    await data.setEnabled(false);
    final blocker = profiles().last;
    expect(blocker['apn'], ApnDataCut.blockerApn);
    expect(blocker['pdptype'], 'IPV6');
    expect(blocker['mmc'], '624');
    expect(blocker['mnc'], '05');
    expect(blocker['id'], 1);

    await data.setEnabled(true);
    await cut.request(DataCutReason.reconnect);
    await cut.release(DataCutReason.reconnect);
    expect(profiles().where((p) => p['apn'] == ApnDataCut.blockerApn), hasLength(1));
    expect(profiles(), hasLength(2));
  });

  test('coupure brève de la relance : les données restent activées', () async {
    await cut.request(DataCutReason.reconnect);
    expect(currentApn(), ApnDataCut.blockerApn);
    expect(await data.isEnabled(), isTrue);
    await cut.release(DataCutReason.reconnect);
    expect(currentApn(), 'camtel');
  });

  test('relance pendant que les données sont coupées : elles le restent', () async {
    await data.setEnabled(false);
    await cut.request(DataCutReason.reconnect);
    await cut.release(DataCutReason.reconnect);
    expect(currentApn(), ApnDataCut.blockerApn);
    expect(await data.isEnabled(), isFalse);
  });

  test('changement de SIM pendant la coupure : elle suit', () async {
    await data.setEnabled(false);
    // Nouvelle SIM : le modem active le profil de son opérateur.
    modem.apn['apncurrent'] = 0;
    expect(await cut.isBlocked(), isFalse);
    expect(await data.isEnabled(), isFalse);
    await cut.reapply();
    expect(await cut.isBlocked(), isTrue);
  });

  test('emplacement vide : rien à couper', () async {
    await data.setEnabled(false);
    modem.apn['apncurrent'] = 0;
    modem.status['simCardState'] = 'invalid';
    await cut.reapply();
    expect(currentApn(), 'camtel');
  });

  test('profil choisi par l\'utilisateur : coupures oubliées', () async {
    await data.setEnabled(false);
    await cut.forget();
    expect(await cut.isAnyRequested(), isFalse);
  });

  test('coupure brève restée en place (mode avion d\'une ancienne version) : levée au démarrage', () async {
    await cut.request(DataCutReason.reconnect);
    // Redémarrage de l'appli.
    cut = ApnDataCut(api, store);
    await cut.releaseLeftover();
    expect(currentApn(), 'camtel');
    expect(await cut.isAnyRequested(), isFalse);
  });

  test('coupure brève restée en place pendant que les données sont coupées : elles le restent', () async {
    await data.setEnabled(false);
    await store.writeState(MonitorStateKeys.reconnectCut, '1');
    await cut.releaseLeftover();
    expect(currentApn(), ApnDataCut.blockerApn);
    expect(await data.isEnabled(), isFalse);
  });

  test('coupure qui tient : rien à signaler ni à réactiver', () async {
    await data.setEnabled(false);
    expect((await api.getAllStatus()).isInternetConnected, isFalse);
    final before = modem.requests.length;
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(await cut.problem(), isNull);
    expect(modem.requests.skip(before).where((r) => r['cmdid'] == 'setcurrentapn'), isEmpty);
  });

  test('aucune coupure demandée : le maintien ne touche à rien', () async {
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(modem.requests.where((r) => r['cmdid'] == 'setcurrentapn'), isEmpty);
    expect(currentApn(), 'camtel');
  });

  test('le modem remet son profil habituel : la coupure est réactivée', () async {
    await data.setEnabled(false);
    modem.apn['apncurrent'] = 0;
    expect((await api.getAllStatus()).isInternetConnected, isTrue);
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(currentApn(), ApnDataCut.blockerApn);
    expect(await data.problem(), isNull);
  });

  test('le modem quitte sans cesse la coupure : réactivations limitées puis problème signalé', () async {
    await data.setEnabled(false);
    for (var i = 0; i < ApnDataCut.maxReapplies; i++) {
      modem.apn['apncurrent'] = 0;
      expect(await cut.maintain(await api.getAllStatus()), isFalse);
      expect(currentApn(), ApnDataCut.blockerApn);
    }
    modem.apn['apncurrent'] = 0;
    expect(await cut.maintain(await api.getAllStatus()), isTrue);
    expect(currentApn(), 'camtel');
    expect(
      await data.problem(),
      isA<DataCutNotHoldingException>().having((e) => e.problem, 'problem', DataCutProblem.profileLost),
    );
    // Plus de réactivation jusqu'à la prochaine action de l'utilisateur.
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(currentApn(), 'camtel');
    await data.setEnabled(true);
    expect(await cut.problem(), isNull);
    await data.setEnabled(false);
    expect(currentApn(), ApnDataCut.blockerApn);
  });

  test('réactivations espacées : aucun problème signalé', () async {
    var now = DateTime(2026, 10, 4, 12);
    cut = ApnDataCut(api, store, clock: () => now);
    data = ApnMobileData(cut);
    await data.setEnabled(false);
    for (var i = 0; i < 3 * ApnDataCut.maxReapplies; i++) {
      modem.apn['apncurrent'] = 0;
      await cut.maintain(await api.getAllStatus());
      expect(currentApn(), ApnDataCut.blockerApn);
      now = now.add(const Duration(minutes: 4));
    }
    expect(await cut.problem(), isNull);
  });

  test('réseau qui accepte tout APN : signalé après le délai, effacé quand la coupure tient', () async {
    var now = DateTime(2026, 10, 4, 12);
    cut = ApnDataCut(api, store, clock: () => now);
    data = ApnMobileData(cut);
    modem.networkAcceptsAnyApn = true;
    await data.setEnabled(false);
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(await data.problem(), isNull);
    now = now.add(ApnDataCut.holdGrace);
    expect(await cut.maintain(await api.getAllStatus()), isTrue);
    expect(
      await data.problem(),
      isA<DataCutNotHoldingException>().having((e) => e.problem, 'problem', DataCutProblem.internetStillUp),
    );
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    modem.networkAcceptsAnyApn = false;
    expect(await cut.maintain(await api.getAllStatus()), isTrue);
    expect(await data.problem(), isNull);
  });

  test('ancien profil de coupure (IPv4) : remplacé par le profil IPv6', () async {
    (modem.apn['apnlist'] as List).add({
      'id': 1,
      'apnname': 'MiFi-OFF',
      'pdptype': 'IP',
      'apn': ApnDataCut.legacyBlockerApn,
      'mmc': '624',
      'mnc': '05',
      'auth': '-1',
      'username': '',
      'passw': '',
      'proxy': '',
      'port': '',
    });
    modem.apn['apncurrent'] = 1;
    await store.writeState(MonitorStateKeys.mobileDataOffExpected, '1');
    expect(await cut.isBlocked(), isTrue);
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(currentApn(), ApnDataCut.blockerApn);
    expect(profiles().last['pdptype'], 'IPV6');
    await data.setEnabled(true);
    expect(currentApn(), 'camtel');
  });

  test('retrait sans toucher au modem : la coupure n\'est plus maintenue', () async {
    await cut.request(DataCutReason.reconnect);
    await cut.withdraw(DataCutReason.reconnect);
    expect(await cut.isAnyRequested(), isFalse);
    expect(currentApn(), ApnDataCut.blockerApn);
    modem.apn['apncurrent'] = 0;
    expect(await cut.maintain(await api.getAllStatus()), isFalse);
    expect(currentApn(), 'camtel');
  });
}
