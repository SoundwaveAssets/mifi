import 'package:flutter_test/flutter_test.dart';
import 'package:mifi/core/background/daily_time.dart';
import 'package:mifi/core/models/dhcp_models.dart';
import 'package:mifi/core/models/mobile_models.dart';
import 'package:mifi/core/models/status_models.dart';
import 'package:mifi/core/models/wifi_models.dart';
import 'package:mifi/core/util/ip_utils.dart';
import 'package:mifi/core/util/modem_address.dart';
import 'package:mifi/core/util/operators.dart';
import 'package:mifi/core/util/password_generator.dart';
import 'package:mifi/core/util/signal.dart';
import 'package:mifi/core/util/speed.dart';
import 'package:mifi/core/util/wifi_qr.dart';

void main() {
  test('barres de signal : 5 niveaux selon les paliers de la 4G', () {
    expect(signalBarsFromDbm(null), 0);
    expect(signalBarsFromDbm(-43), 0);
    expect(signalBarsFromDbm(-44), 4);
    expect(signalBarsFromDbm(-80), 4);
    expect(signalBarsFromDbm(-81), 3);
    expect(signalBarsFromDbm(-90), 3);
    expect(signalBarsFromDbm(-91), 2);
    expect(signalBarsFromDbm(-100), 2);
    expect(signalBarsFromDbm(-101), 1);
    expect(signalBarsFromDbm(-110), 1);
    expect(signalBarsFromDbm(-111), 0);
    expect(signalBarsFromDbm(-121), 0);
    expect(SignalQuality.fromDbm(-75), SignalQuality.excellent);
    expect(SignalQuality.fromDbm(-85), SignalQuality.good);
    expect(SignalQuality.fromDbm(-95), SignalQuality.fair);
    expect(SignalQuality.fromDbm(-105), SignalQuality.poor);
    expect(SignalQuality.fromDbm(-115), SignalQuality.none);
  });

  test('qualité du débit : 5 niveaux', () {
    expect(SpeedQuality.fromMbps(0), SpeedQuality.none);
    expect(SpeedQuality.fromMbps(0.49), SpeedQuality.none);
    expect(SpeedQuality.fromMbps(0.5), SpeedQuality.poor);
    expect(SpeedQuality.fromMbps(1.99), SpeedQuality.poor);
    expect(SpeedQuality.fromMbps(2), SpeedQuality.fair);
    expect(SpeedQuality.fromMbps(7.9), SpeedQuality.fair);
    expect(SpeedQuality.fromMbps(8), SpeedQuality.good);
    expect(SpeedQuality.fromMbps(24.9), SpeedQuality.good);
    expect(SpeedQuality.fromMbps(25), SpeedQuality.excellent);
  });

  test('internet : le test réel fait foi quand le modem ne dit pas « disconnected »', () {
    final retrying = AllStatus({'internetState': 'connecting'});
    expect(retrying.isInternetConnected, isTrue);
    expect(retrying.withInternetCheck(false).isInternetConnected, isFalse);
    expect(retrying.withInternetCheck(true).isInternetConnected, isTrue);
    expect(retrying.withInternetCheck(null).isInternetConnected, isTrue);
    expect(AllStatus({'internetState': 'disconnected'}).withInternetCheck(true).isInternetConnected, isFalse);
  });

  test('aucune barre de signal sans carte SIM', () {
    expect(AllStatus({'simCardState': 'ready', 'signalStrength': -75}).signalBars, 4);
    expect(AllStatus({'simCardState': 'invalid', 'signalStrength': -75}).signalBars, 0);
  });

  test('opérateur déduit de l\'IMSI, jamais de « China Telecom »', () {
    expect(resolveOperator('624051234567890')!.name, 'Camtel');
    expect(resolveOperator('624011234567890')!.name, 'MTN');
    final unknown = resolveOperator('624991234567890')!;
    expect(unknown.name, isNull);
    expect(unknown.code, '624-99');
    final status = AllStatus({'carrier': 'China Telecom', 'imsi': '624051', 'simCardState': 'ready'});
    expect(status.serviceName, isNull);
    expect(AllStatus({'carrier': 'blue'}).serviceName, 'blue');
  });

  test('champs à zéro masqués et compteurs calculés depuis la liste', () {
    final sys = SysInfo({'bsid': '0', 'cellid': 0, 'cputemp': '0', 'sysruntime': 0, 'ethnum': '0'});
    expect(sys.baseStationId, isNull);
    expect(sys.cellId, isNull);
    expect(sys.cpuTemperature, isNull);
    expect(sys.uptime, isNull);
    final counts = DeviceCounts.of([
      ConnectedDevice.fromJson({'devname': 'a', 'devtype': 0, 'devip': '1', 'devmac': 'x'}),
      ConnectedDevice.fromJson({'devname': 'b', 'devtype': 0, 'devip': '2', 'devmac': 'y'}),
    ]);
    expect(counts.wifi, 2);
    expect(counts.total, 2);
  });

  test('copyWith Wi-Fi : champs inconnus et types d\'origine conservés', () {
    final info = WifiInfo({'wifichan': '6', 'wifibrocast': true, 'wifiauth': '4', 'extra': 1});
    final next = info.copyWith(channel: '11', broadcastSsid: false);
    expect(next.raw['wifichan'], '11');
    expect(next.raw['wifibrocast'], false);
    expect(next.raw['extra'], 1);
    expect(WifiInfo.validatePassword('court', authCode: '4'), WifiValidationError.passwordTooShort);
    expect(WifiInfo.validatePassword('', authCode: '0'), isNull);
  });

  test('validation DHCP', () {
    DhcpInfo dhcp(String gw, String start, String end) => DhcpInfo({
          'gwip': gw,
          'netmask': '255.255.255.0',
          'ippoolstart': start,
          'ippoolend': end,
          'leasetime': '1',
          'dhcpserver': true,
        });
    expect(dhcp('192.168.100.1', '192.168.100.2', '192.168.100.254').validate(), isEmpty);
    expect(dhcp('192.168.100.1', '192.168.1.2', '192.168.100.254').validate()[DhcpField.poolStart],
        DhcpValidationError.outsideGatewaySubnet);
    expect(dhcp('192.168.100.1', '192.168.100.50', '192.168.100.10').validate()[DhcpField.poolEnd],
        DhcpValidationError.poolStartAfterEnd);
    expect(dhcp('192.168.100.20', '192.168.100.2', '192.168.100.254').validate()[DhcpField.gatewayIp],
        DhcpValidationError.gatewayInsidePool);
    expect(DhcpInfo({'leasetime': '1'}).copyWith(leaseTimeHours: 2).raw['leasetime'], '2');
  });

  test('APN : auth « -1 » et identifiant suivant', () {
    final info = ApnInfo({
      'apncurrent': 0,
      'apnlist': [
        {'id': 0, 'apnname': 'Camtel', 'auth': '-1', 'pdptype': 'IPV4'},
        {'id': 3, 'apnname': 'Autre', 'auth': '1'},
      ],
    });
    expect(info.current!.isAuthUndefined, isTrue);
    expect(info.nextId(), 4);
  });

  test('détection de coupure : IPv4 et noms d\'hôte', () {
    expect(ConnectionDetectConfig.validateAddress('8.8.8.8'), isNull);
    expect(ConnectionDetectConfig.validateAddress('www.google.com'), isNull);
    expect(ConnectionDetectConfig.validateAddress('pas valide!'), ConnectionDetectError.invalidHost);
    expect(isValidHostname('999.1.1.1'), isFalse);
  });

  test('QR code Wi-Fi avec échappement', () {
    expect(
      buildWifiQrPayload(ssid: 'Mon;Wi-Fi', password: r'a:b\c', authCode: '4'),
      r'WIFI:T:WPA;S:Mon\;Wi-Fi;P:a\:b\\c;;',
    );
    expect(buildWifiQrPayload(ssid: 'Ouvert', password: '', authCode: '0', hidden: true), 'WIFI:T:nopass;S:Ouvert;H:true;;');
  });

  test('adresse du modem normalisée', () {
    expect(ModemAddress.normalize('http://192.168.100.1/'), '192.168.100.1');
    expect(ModemAddress.normalize('192.168.8.1:8080'), '192.168.8.1:8080');
    expect(ModemAddress.normalize('pas une adresse'), isNull);
  });

  test('mot de passe Wi-Fi généré', () {
    final password = generateWifiPassword();
    expect(password.length, 12);
    expect(password, matches(RegExp(r'[A-Z]')));
    expect(password, matches(RegExp(r'[a-z]')));
    expect(password, matches(RegExp(r'[2-9]')));
    expect(password, isNot(matches(RegExp(r'[IOl10]'))));
  });

  test('heure programmée : aujourd\'hui ou le lendemain', () {
    expect(nextDailyOccurrence(23 * 60, DateTime(2026, 10, 4, 22)), DateTime(2026, 10, 4, 23));
    expect(nextDailyOccurrence(6 * 60, DateTime(2026, 10, 4, 23, 30)), DateTime(2026, 10, 5, 6));
    expect(nextDailyOccurrence(6 * 60, DateTime(2026, 10, 31, 6)), DateTime(2026, 11, 1, 6));
  });

  test('sous-réseaux', () {
    expect(sameSubnet('192.168.100.1', '192.168.100.200', '255.255.255.0'), isTrue);
    expect(isValidNetmask('255.255.0.255'), isFalse);
    expect(broadcastAddress('192.168.100.1', '255.255.255.0'), '192.168.100.255');
  });
}
