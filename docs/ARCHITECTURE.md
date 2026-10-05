# Architecture de l'application MiFi

Application Android (Flutter 3.44, Dart 3.12) qui pilote le modem 4G HiMILink
décrit dans [BRIEF_APP_MODEM.md](BRIEF_APP_MODEM.md).

## Arborescence

```
lib/
  main.dart                 démarrage + point d'entrée `backgroundMain` (tâches Android)
  core/                     logique sans interface (utilisable en arrière-plan)
    api/                    transport HTTP, client de session, API typée, erreurs
    models/                 modèles des réponses (objet JSON brut conservé)
    util/                   signal, IP/nom d'hôte, opérateur (IMSI), adresse, QR Wi-Fi
    settings/               réglages (SharedPreferences) et mot de passe (Keystore)
    session/                SessionController : connexion, déconnexion, attente du modem
    status/                 StatusController : rafraîchissement toutes les 10 s
    monitoring/             surveillance (historique, coupures, alertes) et notifications
    mobile_data/            coupure des données (profil APN) et « Relancer la connexion »
    background/             tâches Android (vérification périodique, programmation, tuile)
    data/                   stockage local SQLite (historiques, appareils, tests de débit)
    native/                 pont Dart ↔ Kotlin (canal `com.assoumou.mifi/native`)
    l10n/                   langue effective, formatage des durées
    app_services.dart       construction de tous les services (un jeu par moteur Flutter)
    app_wiring.dart         liaisons entre services dans l'interface
  l10n/                     traductions (ARB) et classes générées
  ui/
    app.dart                MaterialApp, AppScope (Provider), RootGate
    theme.dart              thème Material 3 clair/sombre, couleurs d'état
    l10n_helpers.dart       context.l10n, describeError, libellés partagés, dates
    shell/home_shell.dart   barre de navigation : Accueil, Appareils, Réglages
    widgets/                widgets partagés (voir plus bas)
    screens/<module>/       un dossier par écran
android/                    code natif Kotlin (pont, tuile, widget, WorkManager)
assets/logo/                logo « MiFi » (icône de l'appli)
tool/generate_logo.ps1      génération du logo et des icônes Android
test/                       tests unitaires (faux modem dans test/support/)
```

## Principes

- **Une seule source pour chaque commande** : les `cmdid` sont dans
  `core/api/commands.dart`, les appels dans `ModemApi`. `sethimiimei` n'est
  jamais implémenté (illégal).
- **Objet JSON brut conservé** : les commandes `set…` attendent « l'objet
  complet, modifié ». Les modèles gardent la map d'origine et `copyWith`
  conserve le type de chaque champ (`"1"`, `1` ou `true`).
- **Erreurs typées, sans texte** : `ModemException` et ses sous-classes ;
  l'interface les traduit avec `describeError(context.l10n, erreur)`.
- **Session** : `ModemClient` ajoute `sessionId` et `Authorization`, se
  reconnecte tout seul sur `SessionOut` (une reconnexion partagée) et envoie
  les requêtes une par une. Délai standard : 10 s.
- **Commandes qui coupent la connexion** (`setwifiinfo`, `closewifiap`,
  `setdhcpinfo`, `setsimnum`, `rebootcmd`) : `ModemApi` renvoie `false` si le
  modem n'a pas répondu, ce qui est normal pendant un redémarrage. Ensuite,
  `showModemRestartDialog` attend son retour.
- **Valeurs fausses du modem réel** : opérateur déduit de l'IMSI
  (`resolveOperator`), compteurs d'appareils calculés à partir de la liste
  (`DeviceCounts`), champs à 0 masqués (getters `null`), version logicielle
  lue dans l'API (`Overview.softwareVersion`).
- **Niveaux du signal et du débit** : 5 niveaux (inexistant, faible, moyen,
  bon, excellent). Signal : paliers de la 4G (`signalBarsFromDbm` : -80,
  -90, -100, -110 dBm), barres vertes, orange ou rouges selon le niveau.
  Débit : `SpeedQuality.fromMbps` (0,5, 2, 8, 25 Mb/s), affiché pendant et
  après le test, et dans l'historique.
- **Données mobiles et « Relancer la connexion »** : l'API n'a pas de
  commande pour éteindre la radio ni couper les données. Les deux passent par
  `ApnDataCut` (`core/mobile_data/data_cut.dart`) : un profil APN de coupure
  « MiFi-OFF » coupe internet sur la SIM active, quelle qu'elle soit, sans
  jamais changer de SIM. Chaque fonction est une « raison » de coupure
  (`mobileDataOff`, `reconnect`) ; internet revient quand plus aucune ne la
  demande. Après un changement de SIM, `reapply` coupe aussi la nouvelle SIM.
  Interface `MobileDataStrategy` (`createMobileDataStrategy`) ; le contrôleur
  publie l'état vers la tuile « Données mobiles ». Le Wi-Fi du modem n'est
  jamais touché.

  Mode avion retiré à la demande de l'utilisateur (5 octobre 2026) : bouton,
  tuile, widget, raccourci et programmation. Une coupure laissée par une
  ancienne version (clé `monitor.airplane_expected`, devenue la raison
  `reconnect`) est levée au démarrage (`releaseLeftover`) ; les anciennes
  alarmes sont annulées par `BackgroundScheduler.sync`.

  « Relancer la connexion » (`ReconnectController`,
  `core/mobile_data/reconnect.dart`), cœur de l'appli : chaque tentative
  coupe la connexion comme un mode avion (profil de coupure, puis
  réinscription du modem sur le réseau : mode réseau provisoire 6 s puis
  mode d'origine), la rétablit et attend internet (test réel, 60 s au plus).
  Les tentatives se succèdent jusqu'au retour d'internet ou jusqu'à
  « Arrêter » (3 au plus pour la réparation automatique). Le mode réseau
  d'origine est mémorisé (`reconnect.network_mode`) et toujours remis, au
  besoin au démarrage suivant.

  Profil de coupure : APN `mifi.data.off.v6`, type PDP IPv6 seul. Orange CM
  accepte n'importe quel nom d'APN en IPv4 (le modem se reconnectait aussitôt
  avec l'ancien profil `mifi.data.off`, toujours reconnu et remplacé au
  passage). Constaté sur le modem réel (Orange CM, 4 octobre 2026) : avec
  le profil IPv6, le voyant « données » reste rouge.

  Maintien : l'état affiché est celui demandé (raisons mémorisées). À chaque
  relevé de l'état (toutes les 10 s appli ouverte, `periodic_check` sinon),
  `AppServices.maintainDataCut` appelle `ApnDataCut.maintain` :
  - le modem a quitté le profil de coupure → il est réactivé, 3 fois au plus
    par tranche de 10 min, puis problème `profileLost` jusqu'à la prochaine
    action de l'utilisateur ;
  - profil de coupure actif mais internet connecté plus de 2 min après
    l'activation → problème `internetStillUp` (réseau qui accepte tout APN),
    effacé dès que la connexion tombe.

  État internet : le modem renvoie un état autre que « disconnected » dès
  qu'il a une connexion au réseau de l'opérateur, même sans internet (SIM
  Orange sans forfait : portail captif ; profil de coupure accepté par
  l'opérateur). Quand il ne dit pas « disconnected », l'appli fait un test
  réel (`probeInternet` : page `generate_204` de Google puis de Cloudflare,
  comme Android, uniquement par le Wi-Fi du modem) qui fait foi
  (`AllStatus.withInternetCheck`) pour le voyant, le journal des coupures,
  le maintien et « Relancer la connexion ».

  Un problème s'affiche en `DataCutNotHoldingException` (bandeau du tableau
  de bord, texte des tuiles) et par une notification. « Relancer la
  connexion » appelle `withdraw` si le rétablissement échoue, pour ne pas
  maintenir une coupure non demandée. Un profil APN choisi par
  l'utilisateur (liste APN, création, restauration d'une sauvegarde) appelle
  `forget`.

## Conventions de code

- État et services par `provider` : `context.read<ModemApi>()`,
  `context.watch<StatusController>()`, `context.read<SessionController>()`…
  (liste dans `AppScope`, `ui/app.dart`).
- Widgets partagés (`ui/widgets/`) : `SectionCard`, `ListSectionHeader`,
  `FutureLoader`, `LoadingView`, `ErrorView`, `ConnectivityHint`,
  `showConfirmDialog`, `showTypedConfirmDialog`, `showInfoDialog`,
  `PasswordField`, `AsyncButton`, `WarningBanner`, `showSnack`,
  `showErrorSnack`, `InfoTile`, `SignalBars`, `showModemRestartDialog`.
- Commentaires en français, sobres, seulement quand ils apportent quelque
  chose.
- API Flutter 3.44 à éviter (dépréciées) : `withOpacity` → `withValues(alpha:)` ;
  `WillPopScope` → `PopScope` ; `DropdownButtonFormField(value:)` →
  `initialValue:` ; `RadioListTile(groupValue:)` → `RadioGroup` ou
  `SegmentedButton` ; `Switch(activeColor:)` → `activeThumbColor` ;
  `surfaceVariant` → `surfaceContainerHighest` ; `CardTheme` → `CardThemeData`.
- Zéro remarque de `dart analyze` (erreurs, avertissements et infos).

## Traductions

- Français par défaut (modèle `app_fr.arb`) et anglais. Pour ajouter une
  langue : créer `lib/l10n/app_<code>.arb`, puis l'ajouter à
  `AppSettings.supportedLanguages` et aux libellés de langue.
- **Aucun texte affiché en dur** : tout passe par `context.l10n` (ou
  `localizationsFor(...)` hors widgets).
- Termes imposés (corrections de l'interface d'origine) : « Activé /
  Désactivé » (jamais « Rendre possible / infirme »), « Proxy », « Type »,
  « 0 appareil » (pluriel ICU : `{count, plural, one{…} other{…}}`).
- Clés préfixées par le module (ex. `wifiSsidLabel`). Après chaque
  modification des fichiers ARB : `flutter gen-l10n` (également lancé
  automatiquement par `flutter run` et `flutter build`).

## Pont natif (canal `com.assoumou.mifi/native`)

Le canal est enregistré sur le moteur principal (`MainActivity`) et sur
chaque moteur d'arrière-plan. Côté Dart : `core/native/native_bridge.dart`.

### Dart → Kotlin

| Méthode | Arguments | Résultat |
|---|---|---|
| `bindToWifi` | — | état Wi-Fi (voir ci-dessous) après liaison du processus au Wi-Fi |
| `getWifiStatus` | — | état Wi-Fi, sans rien modifier |
| `setKeepScreenOn` | `{on: bool}` | — (sans effet hors activité) |
| `ensureNotificationChannels` | `{channels: [{id, name, description, highImportance}]}` | — |
| `showNotification` | `{id: int, channelId, title, body}` | — (un appui ouvre l'appli) |
| `requestNotificationPermission` | — | `bool` autorisé (Android 13+ : demande `POST_NOTIFICATIONS`) |
| `areNotificationsEnabled` | — | `bool` |
| `saveDocument` | `{fileName, mimeType, bytes}` | `bool` : `true` si enregistré (« Enregistrer sous… » SAF), `false` si annulé |
| `publishToggleState` | `{toggle: mobile_data, state: on/off/switching/unknown/error, label, stateText, switchingText}` | — : mémorise et rafraîchit la tuile « Données mobiles » |
| `setPeriodicCheck` | `{enabled: bool, intervalMinutes: int}` | — : travail périodique unique WorkManager `periodic_check` |
| `scheduleTask` | `{task, atMillis}` | — : alarme (exacte si autorisée, sinon `setAndAllowWhileIdle`) |
| `cancelScheduledTask` | `{task}` | — |
| `getBackgroundTask` | — | `{task, payload}` dans un moteur d'arrière-plan, sinon `null` |
| `backgroundTaskCompleted` | `{success, message}` | — : termine la tâche du moteur d'arrière-plan |
| `probeInternet` | — | `bool?` : internet passe par le Wi-Fi du modem (`null` sans Wi-Fi) |
| `startMonitor` / `stopMonitor` | — | démarre (`bool`) ou arrête la surveillance continue |
| `isMonitorRunning` | — | `bool` : moteur de surveillance actif |
| `isAppVisible` | — | `bool` : interface affichée (la surveillance se met en pause) |
| `isIgnoringBatteryOptimizations` | — | `bool` : appli sans restriction de batterie |
| `requestIgnoreBatteryOptimizations` | — | — : demande système « autoriser en arrière-plan » |
| `canScheduleExactAlarms` | — | `bool` (toujours `true` avant Android 12) |
| `openExactAlarmSettings` | — | `bool` : écran « Alarmes et rappels » de l'appli |
| `openAutostartSettings` | — | `bool` : démarrage automatique Xiaomi, sinon fiche de l'appli |
| `openAppSettings` | — | `bool` : fiche de l'appli (batterie, autorisations) |

État Wi-Fi : `{wifiConnected, bound, validated, gateway?, ipAddress?, prefixLength?}`.

### Kotlin → Dart (moteur principal uniquement)

| Méthode | Arguments | Résultat |
|---|---|---|
| `runTask` | `{task, payload: Map}` | `{success, message}` |

### Relevés et surveillance continue

- Appli ouverte : `StatusController` relève le modem toutes les 2 s (test
  réel d'internet compris), les détails (aperçu, système, appareils) toutes
  les 10 s. `MonitoringService` retient une coupure après 5 s sans internet
  (datée du premier relevé sans internet) et garde un point d'historique du
  signal toutes les 30 s au plus.
- Appli fermée : `MonitorService` (service au premier plan de type
  `specialUse`, notification discrète « Surveillance active ») fait tourner
  `monitorMain` dans son propre moteur Flutter : `ConnectionMonitor` relève
  toutes les 15 s quand internet passe, toutes les 5 s sinon, et se met en
  pause quand l'interface est affichée. Aucun verrou d'éveil. Les tâches
  Android lui sont confiées quand l'interface est fermée (une seule session
  avec le modem).
- Autorisations demandées une fois après la connexion
  (`offerBackgroundMonitoringOnce`) : notifications, puis exemption
  d'optimisation de la batterie. Réglage « Surveillance continue » dans les
  réglages de l'appli. Relancée au démarrage du téléphone et à la mise à
  jour (`BootReceiver`), et par la vérification périodique si Android l'a
  arrêtée.

### Exécution des tâches

Tâches (`core/background/background_tasks.dart`) : `periodic_check`,
`mobile_data_toggle`, `scheduled_reboot`, `reschedule`.

1. Déclencheurs :
   - appui sur la tuile « Données mobiles » → `mobile_data_toggle` ;
   - alarme → `scheduled_reboot` ;
   - démarrage du téléphone ou mise à jour de l'appli → `reschedule` ;
   - WorkManager périodique → `periodic_check`.

   Chacun met en file un travail WorkManager accéléré (expedited).
2. Le worker exécute une tâche à la fois (verrou commun au processus) :
   - `periodic_check` quand l'appli est visible → rien à faire, le
     rafraîchissement de l'interface s'en charge ;
   - moteur principal vivant (appli ouverte) → `runTask` sur ce moteur, qui
     garde ainsi une seule session avec le modem ;
   - sinon → nouveau `FlutterEngine` qui exécute `backgroundMain` (dans
     `main.dart`) avec les arguments `[tâche, charge JSON]`. Le worker attend
     `backgroundTaskCompleted` (9 min au plus), puis détruit le moteur.
3. Wi-Fi forcé : `ConnectivityManager.requestNetwork` sur le transport Wi-Fi
   sans exiger `NET_CAPABILITY_INTERNET`, puis `bindProcessToNetwork` sur ce
   réseau. Les requêtes vers le modem passent ainsi par le Wi-Fi, même
   « sans internet ».

## Points à confirmer sur le matériel

- Le profil APN de coupure « MiFi-OFF » coupe-t-il internet sur toutes les
  SIM ? Le modem le garde-t-il (redémarrage,
  perte du réseau) ? Sinon `maintain` le réactive et signale le problème.
- Mise à jour du firmware : algorithme et format du « code CRC », et nom du
  champ multipart (`file` par défaut). Le code CRC est saisi par
  l'utilisateur ; un calcul CRC32 du fichier est proposé en aide.
- Identifiant d'un nouvel APN (`setnewapn`) : max + 1 des identifiants
  existants.
- Champ `Authorization` avant connexion : non envoyé tant qu'il n'y a pas de
  session.
