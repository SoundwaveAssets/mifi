import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Faux modem HiMILink en mémoire, branché sur [MockClient] : sessions,
/// `SessionOut`, commande inconnue (réponse vide), état modifiable et
/// journal des requêtes reçues.
class FakeModem {
  FakeModem({this.password = 'admin'});

  String password;
  String? session;
  int _sessions = 0;
  int loginCount = 0;

  /// La prochaine commande authentifiée répondra `SessionOut`.
  bool expireNext = false;

  /// Commandes auxquelles le modem répond par un corps vide.
  final Set<String> unknownCommands = {};

  /// Le réseau accepte n'importe quel APN : la connexion aboutit même avec le
  /// profil de coupure de l'appli.
  bool networkAcceptsAnyApn = false;

  /// Mode réseau (`netmode`) et modes successivement demandés.
  String netmode = '0';
  final List<String> netmodeHistory = [];

  final List<Map<String, dynamic>> requests = [];
  final List<Map<String, String>> headers = [];

  Map<String, dynamic> status = {
    'simCardState': 'ready',
    'imsi': '624051234567890',
    'carrier': 'China Telecom',
    'internetState': 'connected',
    'signalStrength': -90,
    'wifiapstatus': 'on',
  };
  Map<String, dynamic> sims = {'simset': '1', 'simcurrent': 0, 'spassw': 'k3y'};
  Map<String, dynamic> wifi = {
    'wifistate': 'open',
    'wifissid': 'MiFi-1234',
    'wifipass': 'secret123',
    'wifichan': '6',
    'wifiauth': '4',
    'wifibrocast': true,
    'extra': 'keep-me',
  };
  Map<String, dynamic> apn = {
    'apncurrent': 0,
    'apnlist': <Map<String, dynamic>>[
      {
        'id': 0,
        'apnname': 'Camtel',
        'pdptype': 'IPV4',
        'apn': 'camtel',
        'mmc': '624',
        'mnc': '05',
        'auth': '-1',
        'username': '',
        'passw': '',
        'proxy': '',
        'port': '',
      },
    ],
  };

  late final http.Client client = MockClient(_handle);

  Future<http.Response> _handle(http.Request request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    requests.add(body);
    headers.add(request.headers);
    final cmd = body['cmdid'] as String;
    if (unknownCommands.contains(cmd)) return http.Response('', 200);
    switch (cmd) {
      case 'login':
        loginCount++;
        if (body['password'] != password) return _json({'reply': 'error'});
        session = 's${++_sessions}';
        return _json({'reply': 'ok', 'session': session});
      case 'getconfig':
        return _json({'reply': 'ok', 'simnum': 2, 'langindex': 'fr', 'copyrights': 'HiMILink'});
    }
    if (expireNext || body['sessionId'] != session || request.headers['Authorization'] != session) {
      expireNext = false;
      return _json({'reply': 'SessionOut'});
    }
    switch (cmd) {
      case 'logout':
        session = null;
        return _ok({});
      case 'getallstatus':
        // Profil de coupure actif : aucune connexion n'aboutit.
        return _ok({...status, if (_blockerActive && !networkAcceptsAnyApn) 'internetState': 'disconnected'});
      case 'getsimset':
        return _ok(sims);
      case 'setsimnum':
        if (body['params1'] != sims['spassw']) return _json({'reply': 'error'});
        sims['simcurrent'] = body['params'] as int;
        return _ok({});
      case 'getwifiinfo':
        return _ok(wifi);
      case 'setwifiinfo':
        wifi = Map<String, dynamic>.from(body['params'] as Map);
        return _ok({});
      case 'getapninfo':
        return _ok(apn);
      case 'setcurrentapn':
        final list = apn['apnlist'] as List;
        apn['apncurrent'] = list.indexWhere((p) => (p as Map)['apn'] == (body['params'] as Map)['apn']);
        return _ok({});
      case 'setnewapn':
        (apn['apnlist'] as List).add(Map<String, dynamic>.from(body['params'] as Map));
        return _ok({});
      case 'getnetworkmode':
        return _ok({'netmode': netmode});
      case 'setnetworkmode':
        netmode = '${body['params']['netmode']}';
        netmodeHistory.add(netmode);
        return _ok({});
      case 'getconnectedsta':
        return _ok({
          'devlist': [
            {'devname': 'Pixel', 'devtype': 0, 'devip': '192.168.100.10', 'devmac': 'aa-bb-cc-dd-ee-01'},
          ],
        });
    }
    return _ok({});
  }

  bool get _blockerActive {
    final list = apn['apnlist'] as List;
    final current = apn['apncurrent'] as int;
    return current >= 0 && current < list.length && '${(list[current] as Map)['apn']}'.startsWith('mifi.data.off');
  }

  /// Dernière requête reçue pour [cmdid].
  Map<String, dynamic>? last(String cmdid) => requests.lastWhere((r) => r['cmdid'] == cmdid, orElse: () => {});

  static http.Response _ok(Map<String, dynamic> params) => _json({'reply': 'ok', 'params': params});

  static http.Response _json(Map<String, dynamic> body) =>
      http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
}
