import 'dart:io';

import '../models/dhcp_models.dart';
import '../models/mobile_models.dart';
import '../models/status_models.dart';
import '../models/system_models.dart';
import '../models/wifi_models.dart';
import 'commands.dart';
import 'modem_client.dart';
import 'modem_exception.dart';
import 'modem_transport.dart';

/// API typée du modem : une méthode par commande.
///
/// Les commandes qui coupent la connexion (redémarrage, réinitialisation,
/// DHCP, changement Wi-Fi…) renvoient `true` si le modem a confirmé et
/// `false` s'il n'a pas répondu (comportement normal pendant un redémarrage).
/// Un refus explicite lève toujours une [CommandFailedException].
class ModemApi {
  ModemApi(this.client);

  final ModemClient client;

  /// Délai de `setsimnum` : la bascule de SIM prend environ 20 s.
  static const Duration simSwitchTimeout = Duration(seconds: 45);

  // ---------------------------------------------------------------- Accueil

  /// `getconfig` (sans session) : sert aussi à vérifier que le modem répond.
  Future<ModemConfig> getConfig({Duration timeout = ModemTransport.defaultTimeout}) async =>
      ModemConfig(await client.callAnonymous(ModemCommands.getConfig, timeout: timeout));

  Future<AllStatus> getAllStatus() async =>
      AllStatus((await client.call(ModemCommands.getAllStatus)).paramsMap);

  Future<Overview> getOverview() async =>
      Overview((await client.call(ModemCommands.getOverview)).paramsMap);

  Future<SysInfo> getSysInfo() async =>
      SysInfo((await client.call(ModemCommands.getSysInfo)).paramsMap);

  Future<List<ConnectedDevice>> getConnectedDevices() async {
    final list = (await client.call(ModemCommands.getConnectedDevices)).paramsList;
    return [
      for (final item in list)
        if (item is Map) ConnectedDevice.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  // ------------------------------------------------------------------ Wi-Fi

  Future<WifiInfo> getWifiInfo() async =>
      WifiInfo((await client.call(ModemCommands.getWifiInfo)).paramsMap);

  /// Le Wi-Fi redémarre : la réponse peut ne jamais arriver.
  Future<bool> setWifiInfo(WifiInfo info) =>
      _expectingDisconnect(ModemCommands.setWifiInfo, params: info.toJson());

  Future<void> openWifiAp() => client.call(ModemCommands.openWifiAp);

  /// ⚠️ Coupe le Wi-Fi : l'appli perd aussitôt la connexion et ne pourra pas
  /// le rallumer (bouton du modem ou redémarrage nécessaire).
  Future<bool> closeWifiAp() => _expectingDisconnect(ModemCommands.closeWifiAp);

  // ------------------------------------------------------------------- DHCP

  Future<DhcpInfo> getDhcpInfo() async =>
      DhcpInfo((await client.call(ModemCommands.getDhcpInfo)).paramsMap);

  /// Le modem redémarre ensuite ; son adresse peut changer (`gwip`).
  Future<bool> setDhcpInfo(DhcpInfo info) =>
      _expectingDisconnect(ModemCommands.setDhcpInfo, params: info.toJson());

  // --------------------------------------------------------- Réseau mobile

  Future<SimSettings> getSimSettings() async =>
      SimSettings((await client.call(ModemCommands.getSimSettings)).paramsMap);

  /// Bascule sur l'emplacement SIM [index] (0 = SIM1, 1 = SIM2).
  /// `false` si le modem n'a pas répondu dans le délai (bascule en cours).
  Future<bool> setSimNumber(int index, String switchPassword) => _expectingDisconnect(
        ModemCommands.setSimNumber,
        params: index,
        extra: {'params1': switchPassword},
        timeout: simSwitchTimeout,
      );

  Future<ApnInfo> getApnInfo() async =>
      ApnInfo((await client.call(ModemCommands.getApnInfo)).paramsMap);

  Future<void> setCurrentApn(ApnProfile profile) =>
      client.call(ModemCommands.setCurrentApn, params: profile.toJson());

  Future<void> addApn(ApnProfile profile) => client.call(ModemCommands.addApn, params: profile.toJson());

  /// Code `netmode` actuel (voir [NetworkModes]).
  Future<String> getNetworkMode() async {
    final params = (await client.call(ModemCommands.getNetworkMode)).paramsMap;
    return '${params['netmode'] ?? ''}'.trim();
  }

  Future<void> setNetworkMode(String netmode) =>
      client.call(ModemCommands.setNetworkMode, params: {'netmode': netmode});

  /// Partage de connexion par USB activé ?
  Future<bool> getUsbTether() async {
    final params = (await client.call(ModemCommands.getUsbTether)).paramsMap;
    return '${params['usbstatus'] ?? '0'}'.trim() == '1';
  }

  /// `params` est une chaîne "0"/"1", pas un objet.
  Future<void> setUsbTether(bool enabled) =>
      client.call(ModemCommands.setUsbTether, params: enabled ? '1' : '0');

  Future<ConnectionDetectConfig> getConnectionDetect() async =>
      ConnectionDetectConfig((await client.call(ModemCommands.getConnectionDetect)).paramsMap);

  Future<void> setConnectionDetect(ConnectionDetectConfig config) =>
      client.call(ModemCommands.setConnectionDetect, params: config.toJson());

  // ---------------------------------------------------------------- Système

  Future<ProduceInfo> getProduceInfo() async =>
      ProduceInfo((await client.call(ModemCommands.getProduceInfo)).paramsMap);

  /// Change le mot de passe admin. La session se termine ensuite : préférer
  /// `SessionController.changePassword`, qui se reconnecte.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      client.call(ModemCommands.changePassword, params: {
        'oldPwd': oldPassword,
        'newPwd': newPassword,
        'confirmPwd': confirmPassword,
      });

  /// Langue de l'interface web du modem (voir [ModemWebLanguages]).
  Future<void> selectLanguage(String lang) =>
      client.call(ModemCommands.selectLanguage, params: {'lang': lang});

  Future<bool> reboot() => _expectingDisconnect(ModemCommands.reboot, params: 'reboot');

  /// ⚠️ Réinitialisation d'usine : Wi-Fi et mot de passe reviennent aux
  /// valeurs d'usine.
  Future<bool> factoryReset() => _expectingDisconnect(ModemCommands.reboot, params: 'freset');

  // ---------------------------------------------------------------- Firmware

  Future<void> putCrcSystem(FirmwareCheck check) =>
      client.call(ModemCommands.putCrcSystem, params: check.toJson());

  /// Envoie le fichier `.zip` sur `/upload` (multipart, champ `file`).
  Future<String> uploadFirmware(
    File file, {
    required String fileName,
    UploadProgressCallback? onProgress,
    Future<void>? cancel,
  }) {
    return client.upload((session) => client.transport.upload(
          file: file,
          filename: fileName,
          authorization: session,
          onProgress: onProgress,
          cancel: cancel,
        ));
  }

  Future<FirmwareCheck> getCrcSystem(FirmwareCheck check) async =>
      FirmwareCheck((await client.call(ModemCommands.getCrcSystem, params: check.toJson())).paramsMap);

  // ------------------------------------------------------------------ Outils

  /// Commande susceptible de couper la connexion : une absence de réponse
  /// (délai dépassé, connexion coupée) n'est pas une erreur.
  Future<bool> _expectingDisconnect(
    String cmdid, {
    Object? params,
    Map<String, Object?> extra = const {},
    Duration timeout = ModemTransport.defaultTimeout,
  }) async {
    try {
      await client.call(cmdid, params: params, extra: extra, timeout: timeout);
      return true;
    } on ModemTimeoutException {
      return false;
    } on ModemUnreachableException {
      return false;
    }
  }
}
