/// Identifiants de commande (`cmdid`) de l'API HiMILink `POST /himiapi/json`.
///
/// Source unique de vérité : aucun `cmdid` ne doit être écrit en dur ailleurs.
///
/// `sethimiimei` (changement d'IMEI) n'est volontairement PAS listé : c'est
/// illégal et l'opérateur peut bloquer le modem. Ne jamais l'ajouter.
abstract final class ModemCommands {
  // Session (`getconfig` fonctionne sans session).
  static const login = 'login';
  static const logout = 'logout';
  static const getConfig = 'getconfig';

  // Accueil / état.
  static const getAllStatus = 'getallstatus';
  static const getOverview = 'getoverview';
  static const getSysInfo = 'getsysinfo';
  static const getConnectedDevices = 'getconnectedsta';

  // Wi-Fi.
  static const getWifiInfo = 'getwifiinfo';
  static const setWifiInfo = 'setwifiinfo';
  static const openWifiAp = 'openwifiap';
  static const closeWifiAp = 'closewifiap';

  // DHCP.
  static const getDhcpInfo = 'getdhcpinfo';
  static const setDhcpInfo = 'setdhcpinfo';

  // Réseau mobile.
  static const getSimSettings = 'getsimset';
  static const setSimNumber = 'setsimnum';
  static const getApnInfo = 'getapninfo';
  static const setCurrentApn = 'setcurrentapn';
  static const addApn = 'setnewapn';
  static const getNetworkMode = 'getnetworkmode';
  static const setNetworkMode = 'setnetworkmode';
  static const getUsbTether = 'gethimiusbtether';
  static const setUsbTether = 'sethimiusbtether';
  static const getConnectionDetect = 'getcondetect';
  static const setConnectionDetect = 'setcondetect';

  // Système.
  static const getProduceInfo = 'getproduceinfo';
  static const changePassword = 'changepwd';
  static const selectLanguage = 'selectlang';
  static const reboot = 'rebootcmd';

  // Mise à jour du firmware.
  static const putCrcSystem = 'putcrcsystem';
  static const getCrcSystem = 'getcrcsystem';
}
