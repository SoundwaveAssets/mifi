# Brief : application Flutter pour piloter mon modem MiFi 4G

## Contexte

- Modem de poche 4G générique, vendu sous le nom « Wireless Mobile WIFI Pro / E5573 » (clone, **pas** un vrai Huawei).
- Firmware HiMILink : `HMIFI_X4S1U1W1_CM_V03_0401…`
- Utilisé au Cameroun avec des SIM de **différents opérateurs** : je peux changer de SIM à tout moment. L'appli ne doit dépendre d'**aucun opérateur en particulier**.
- L'interface web d'origine ne me plaît pas. Je veux une **application Android en Flutter, en français**, qui fasse **tout ce que fait l'interface d'origine**, plus un **mode avion**.

## Accès au modem

- Adresse par défaut : `http://192.168.100.1` (HTTP en clair). L'adresse peut changer via les réglages DHCP, donc elle doit être configurable dans l'appli.
- Une seule route API : `POST http://<ip>/himiapi/json`
- En-têtes : `Content-Type: application/json;charset=UTF-8` et `Authorization: <session>`
- Le corps JSON contient toujours `cmdid`, plus `sessionId: <session>` une fois connecté.
- Les réponses ont la forme `{"reply": "ok", "params": {...}}`. Toute autre valeur de `reply` est un échec.
- Une commande **inconnue** renvoie une réponse **vide** (testé).
- Une session expirée renvoie `{"reply":"SessionOut"}`. Il faut alors se reconnecter automatiquement et relancer la requête.
- L'interface d'origine considère la session perdue après environ 5 minutes sans activité.

### Connexion / déconnexion

```json
{"cmdid": "login", "username": "admin", "password": "<mot de passe>"}
→ {"reply": "ok", "session": "<id de session>"}

{"cmdid": "logout"}
```

`getconfig` fonctionne **sans** session et renvoie à la racine (pas dans `params`) : `simnum`, `simhaspwd`, `langindex`, `isvpn`, `issdcard`, `copyrights`.

## Toutes les commandes (extraites du code de l'interface d'origine)

### Accueil / état

| cmdid | Réponse `params` |
|---|---|
| `getallstatus` | `simCardState` ("invalid" = pas de SIM), `imsi`, `carrier`, `internetState` ("disconnected" ou autre), `signalStrength` (dBm), `wifiapstatus` ("on"/"off") |
| `getoverview` | `SSID`, `IMEI`, `ICCID`, `IMSI`, `SIGNAL`, `WANIP`, `HWVER`, `SYSVER`, `WEBVER` |
| `getsysinfo` | `ethnum`, `wifinum`, `bsid`, `cellid`, `cputemp`, `systime`, `sysruntime` (secondes) |
| `getconnectedsta` | liste `[{devname, devtype (0 = Wi-Fi, 1 = filaire), devip, devmac}]` |

L'interface d'origine rafraîchit ces données toutes les 10 s.

Barres de signal (`signalStrength` en dBm) : au-dessus de -44 ou en dessous de -120, aucun signal. Sinon, ≥ -95 donne 4 barres, ≥ -102 en donne 3, ≥ -108 en donne 2 et ≥ -115 en donne 1.

### Wi-Fi

| cmdid | Corps / réponse |
|---|---|
| `getwifiinfo` | → `wifistate` ("open"/"close"), `wifissid`, `wifipass`, `wifichan` ("1"…"13"), `wifiauth` ("0" aucun, "1" WPA_PSK, "4" WPA2_PSK), `wifibrocast` (bool) |
| `setwifiinfo` | `params` = objet complet ci-dessus, modifié. Mot de passe de 8 à 32 caractères, SSID de 64 au maximum. |
| `openwifiap` | allume le point d'accès Wi-Fi |
| `closewifiap` | éteint le point d'accès Wi-Fi (voir avertissement plus bas) |

### DHCP

| cmdid | Corps / réponse |
|---|---|
| `getdhcpinfo` | → `gwip`, `netmask`, `dhcpserver` (bool), `ippoolstart`, `ippoolend`, `leasetime` (heures) |
| `setdhcpinfo` | `params` = objet complet modifié. Le modem redémarre. Si `gwip` change, l'appli doit utiliser la nouvelle adresse. Vérifier que la plage d'adresses est dans le même sous-réseau que `gwip`. Le champ `dhcpserver` est **en lecture seule** : il est grisé dans l'interface d'origine, donc l'afficher sans permettre de le modifier. |

### Réseau mobile

| cmdid | Corps / réponse |
|---|---|
| `getsimset` | → `simset`, `simcurrent` (index 0 = SIM1, 1 = SIM2), `spassw` |
| `setsimnum` | `{"cmdid":"setsimnum","params": <index>, "params1": "<spassw>"}` (la bascule prend environ 20 s) |
| `getapninfo` | → `apncurrent` (index, -1 si aucun), `apnlist[]` d'objets `{id, apnname, pdptype, apn, mmc, mnc, auth, username, passw, proxy, port}` |
| `setcurrentapn` | `params` = l'objet APN choisi dans `apnlist` |
| `setnewapn` | `params` = nouvel objet APN. `pdptype` vaut "IP", "IPV6" ou "IPV4V6" ; `auth` vaut "0" aucun, "1" PAP, "2" CHAP ou "3" PAP/CHAP. |
| `getnetworkmode` | → `netmode` ("0" = 4G/3G, "1" = 4G, "2" = 3G) |
| `setnetworkmode` | `params` = `{netmode}` |
| `gethimiusbtether` | → `usbstatus` ("0"/"1") : partage de connexion par USB |
| `sethimiusbtether` | `params` = "0" ou "1" (chaîne, pas un objet) |
| `getcondetect` | → `state` ("0" désactivé, "1" activé), `ipaddr1`, `ipaddr2`, `ipaddr3` : détection de coupure réseau |
| `setcondetect` | `params` = objet complet modifié |

### Système

| cmdid | Corps / réponse |
|---|---|
| `getproduceinfo` | → `calstatus`, `wificheckstatus` ("0"/"1") : infos de fabrication, en lecture seule |
| `changepwd` | `params` = `{oldPwd, newPwd, confirmPwd}`. La session se termine ensuite, il faut se reconnecter. |
| `selectlang` | `params` = `{lang}` ("fr", "en", …) : langue de l'interface web, optionnel |
| `rebootcmd` | `params` = `"reboot"` (redémarrage) ou `"freset"` (réinitialisation d'usine) |

### Mise à jour du firmware (avancé)

1. `{"cmdid":"putcrcsystem","params":{"syscrccode":"<code CRC>","fileurl":"<nom du fichier>","status":""}}`
2. Envoi du fichier `.zip` (500 Mo au maximum) en `multipart/form-data` sur `POST http://<ip>/upload`, avec l'en-tête `Authorization: <session>`.
3. `{"cmdid":"getcrcsystem","params":{...même objet}}`. Si `params.status` vaut `"ok"`, la mise à jour est en cours ; sinon `status` contient le message d'erreur.

## Observations sur mon modem réel (captures de l'interface)

Ces points viennent de l'interface d'origine en fonctionnement. L'appli doit en tenir compte.

- **Opérateur faux** : le modem affiche toujours « China Telecom » (`carrier`), quelle que soit la SIM. Il faut déduire l'opérateur des 5 premiers chiffres de l'IMSI (MCC + MNC) à l'aide d'une table. Pour le Cameroun (MCC 624) : `01` MTN, `02` Orange, `04` Nexttel, `05` Camtel. La table doit être facile à compléter. Si le code est inconnu, afficher « Opérateur 624-XX ».
- **Changement de SIM** : si l'IMSI change d'une session à l'autre, afficher « Nouvelle SIM détectée : <opérateur> » et proposer d'ouvrir les réglages APN. Ne **pas** coder d'APN en dur pour un opérateur.
- **Compteurs d'appareils faux** : `ethnum` et `wifinum` (getsysinfo) affichent 0 alors que `getconnectedsta` liste 2 appareils Wi-Fi. Calculer les compteurs **à partir de la liste**.
- **Valeurs à zéro** : `bsid`, `cellid`, `cputemp` et `sysruntime` valent 0 sur mon modem. Masquer un champ quand il vaut 0, plutôt qu'afficher « 0 » ou « 0D:0h:0m:0s ».
- **Version logicielle** : l'écran affiche `UFX03AC_V01_XXSSH_S2_CTCUCM_231…` (la valeur par défaut codée dans la page), alors que l'API renvoie `HMIFI_X4S1U1W1_CM_V03_0401…`. Afficher ce que renvoie l'API.
- **Signal** : par exemple `-90` dBm, ce qui donne 4 barres selon la règle ci-dessus.
- **APN** : le modem sélectionne un APN selon la SIM (MCC/MNC), avec un type PDP IPV4 et sans identifiant. Le champ `auth` peut valoir **"-1"**, une valeur absente de la liste des options : il faut la gérer (l'afficher comme « Non défini »).
- **Mode réseau** : 4G. **Internet USB** : activé.
- **Détection de connexion** : désactivée, avec les adresses `4.2.2.2`, `8.8.8.8` et `www.google.com`.
- **Production** : « Calibré », « WIFI testé ».
- **Bail DHCP** : 1 heure. Plage d'adresses : 192.168.100.2 à 192.168.100.254.
- **En-tête de l'interface** : 4 icônes d'état (Wi-Fi, SIM, signal, internet), l'opérateur, la langue, et un menu « administrateur » (changer le mot de passe, déconnexion). L'appli doit reprendre ces indicateurs en haut de l'écran principal.
- **Traductions incorrectes de l'interface d'origine, à corriger dans l'appli** : « Rendre infirme / Rendre possible » doit devenir « Désactivé / Activé », « Procuration » doit devenir « Proxy », « Taper » doit devenir « Type », et « 0 s » doit devenir « 0 appareil ».

## Fonctions de l'application

1. **Tableau de bord** : opérateur, état internet, barres de signal (+ dBm), IP WAN, appareils connectés, durée de fonctionnement, température CPU, versions. Rafraîchissement toutes les 10 s.
2. **Mode avion** (nouveau, absent de l'interface d'origine) : bascule sur l'emplacement SIM vide (SIM2) avec `setsimnum`, ce qui coupe le réseau mobile en gardant le Wi-Fi. Le second appui revient sur SIM1. Afficher un indicateur d'attente pendant la bascule.
   - ⚠️ **À confirmer** : je dois encore vérifier manuellement que basculer vers SIM2 coupe bien internet. Rendre l'approche facile à changer.
3. **Appareils connectés** : nom, type, IP, MAC.
4. **Wi-Fi** : nom, mot de passe (avec bouton afficher), canal, sécurité, diffusion du SSID.
5. **DHCP** : tous les champs, avec validation des adresses IP.
6. **Réseau mobile** : choix de la SIM, APN (choisir, créer), mode réseau, partage USB, détection de coupure.
7. **Système** : changer le mot de passe admin, redémarrer, réinitialisation d'usine, infos de fabrication, mise à jour du firmware.
8. **Connexion** : mot de passe admin enregistré de façon sécurisée (`flutter_secure_storage`), reconnexion automatique sur `SessionOut`, adresse du modem configurable.

## Langues

- L'appli est disponible en **français** (par défaut) et en **anglais**. L'architecture (`flutter_localizations` + fichiers ARB) doit permettre d'ajouter facilement d'autres langues.
- Le choix se fait dans les réglages de l'appli et est mémorisé. Option « Langue du téléphone ».
- Option dans les réglages : « Appliquer aussi à l'interface web du modem ». Elle envoie `selectlang` avec `{"lang":"fr"}` ou `{"lang":"en"}`. Langues acceptées par le modem : `en`, `fr`, `pl`, `ru`, `tk`, `zh`.
- Aucun texte en dur dans le code : tout passe par les fichiers de traduction.

## Fonctions supplémentaires (absentes de l'interface d'origine)

Toutes ces fonctions reposent uniquement sur les commandes listées plus haut.

1. **Tuile « Réglages rapides » Android et widget d'écran d'accueil** pour le mode avion. On bascule sans ouvrir l'appli.
2. **Partage du Wi-Fi par QR code** : générer `WIFI:T:WPA;S:<ssid>;P:<motdepasse>;;` à partir de `getwifiinfo`, que l'invité scanne avec son appareil photo.
3. **Historique du signal** : enregistrer le dBm à chaque rafraîchissement et afficher un graphique (dernière heure, dernières 24 h). Ajouter un **mode « Trouver le meilleur emplacement »** : grande jauge de signal mise à jour toutes les 2 à 3 s pendant qu'on déplace le modem.
4. **Journal des coupures** : noter chaque passage de `internetState` à "disconnected" et chaque retour, avec la durée. L'afficher sous forme d'historique.
5. **Appareils connectés améliorés** :
   - Donner un surnom à chaque appareil (mémorisé par adresse MAC, dans l'appli).
   - Alerte quand un **appareil inconnu** se connecte (MAC jamais vue).
6. **Bouton « Relancer la connexion »** : quand le réseau mobile bloque, enchaîner automatiquement mode avion puis réseau (SIM2 puis SIM1), plus rapide qu'un redémarrage complet. Le redémarrage reste disponible en option.
7. **Mode avion programmé** : par exemple couper de 0 h à 6 h. Utiliser WorkManager ou AlarmManager. Le téléphone doit être connecté au Wi-Fi du modem au moment prévu ; sinon, afficher une notification d'échec.
8. **Test de débit** : télécharger un fichier de test depuis le téléphone (via le modem) et afficher le débit en Mb/s, avec un historique des tests.
9. **Sauvegarde et restauration des réglages** : exporter en JSON les réglages Wi-Fi, APN, DHCP, mode réseau et détection de connexion, puis les réappliquer (utile après une réinitialisation d'usine). Ne jamais exporter le mot de passe admin.
10. **Notifications** (désactivables) : internet coupé, internet revenu, signal faible, nouvel appareil. Elles fonctionnent quand l'appli est ouverte ; en arrière-plan, vérification périodique via WorkManager (environ toutes les 15 min, limite Android).
11. **Thème clair / sombre / automatique.**
12. **« Expulser les intrus »** (le modem n'a pas de blocage par MAC, voici l'alternative) :
    - Bouton qui génère un nouveau mot de passe Wi-Fi solide (12 caractères), l'applique via `setwifiinfo` et affiche aussitôt le QR code du nouveau mot de passe.
    - Prévenir avant : « Tous les appareils, y compris ce téléphone, seront déconnectés. Reconnectez-vous avec le nouveau mot de passe. » Après la reconnexion du téléphone, l'appli reprend automatiquement sa session.
    - Proposer aussi de **masquer le nom du Wi-Fi** (désactiver `wifibrocast`) pour le rendre invisible aux voisins.
    - Depuis l'alerte « appareil inconnu », proposer directement ce bouton.
13. **Données mobiles** : option pour activer et désactiver les données mobiles (demande complémentaire).

### Impossible avec ce modem (ne pas implémenter)

L'API ne fournit pas ces données. Il ne faut pas les simuler :

- niveau de batterie ;
- compteur de données consommées ;
- blocage ou expulsion d'un appareil ;
- SMS ;
- solde ou forfait de l'opérateur.

## Protections obligatoires

- **Couper le Wi-Fi (`closewifiap`)** : l'appli perdra aussitôt la connexion et ne pourra pas le rallumer. Il faudra le bouton physique du modem ou un redémarrage. Afficher un avertissement clair avant.
- **Réinitialisation d'usine** : double confirmation. Le Wi-Fi et le mot de passe reviennent aux valeurs d'usine.
- **Mise à jour du firmware** : section « avancée » avec avertissement (un mauvais fichier peut rendre le modem inutilisable). Demander que la batterie soit chargée et que le modem ne soit pas débranché.
- **Changement de DHCP** : prévenir que le modem redémarre et que l'adresse peut changer.
- **Ne PAS implémenter `sethimiimei`** (changement d'IMEI) : c'est illégal et ça risque de faire bloquer le modem par l'opérateur.
- Pas de fonction SMS : testé, le firmware ne gère pas les SMS.

## Points techniques Android

- **HTTP en clair** : autoriser le trafic non chiffré vers l'adresse du modem via `network_security_config.xml` (ou `usesCleartextTraffic`), sinon Android bloque les requêtes.
- **Wi-Fi sans internet** : en « mode avion » (ou si le réseau mobile ne répond plus), Android peut marquer le Wi-Fi « sans internet » et envoyer les requêtes par les données mobiles du téléphone. Il faut forcer l'utilisation du Wi-Fi pour les appels au modem, avec un canal de plateforme Kotlin utilisant `ConnectivityManager.bindProcessToNetwork` sur le réseau Wi-Fi.
- Timeouts d'environ 10 s (plus longs pour l'envoi du firmware) et messages clairs si le téléphone n'est pas connecté au Wi-Fi du modem.
- Interface Material 3, simple, moderne et belle, en français.
