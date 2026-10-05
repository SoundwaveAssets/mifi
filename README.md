# MiFi

<p align="center">
  <a href="https://github.com/SoundwaveAssets/mifi/releases/latest/download/mifi.apk">
    <img src="https://img.shields.io/badge/T%C3%A9l%C3%A9charger%20et%20installer-MiFi%20pour%20Android-2ea44f?style=for-the-badge&logo=android&logoColor=white" alt="Télécharger et installer MiFi pour Android" height="56">
  </a>
</p>

<p align="center">
  Touchez ce bouton depuis votre téléphone Android : l'appli se télécharge, puis touchez « Installer ».
</p>

Application Android pour piloter et surveiller le routeur de poche 4G/5G « MiFi », avec les cartes SIM Orange, blue et MTN.

<p align="center">
  <img src="docs/images/modem.jpg" alt="Routeur de poche 4G/5G MiFi compatible avec Orange, blue et MTN" width="420">
</p>

## Ce que MiFi apporte par rapport à l'interface du modem

L'interface web du modem (la passerelle `192.168.100.1`) permet de régler le modem. MiFi fait tout cela, et ajoute ce qu'elle ne fait pas :

| | Interface du modem | MiFi |
|---|:---:|:---:|
| État d'internet fiable (vrai test, même sans forfait ou derrière la page de l'opérateur) | ✗ (« connecté » dès que le modem est relié à l'opérateur) | ✓ |
| Relancer la connexion, en boucle jusqu'au retour d'internet | ✗ | ✓ |
| Activer ou désactiver les données mobiles | ✗ | ✓ |
| Alerte quand internet tombe ou revient, même appli fermée | ✗ | ✓ |
| Journal des coupures avec durées, export CSV | ✗ | ✓ |
| Signal sur 5 niveaux, mis à jour toutes les 2 secondes, historique, meilleur emplacement | ✗ (barres presque toujours pleines) | ✓ |
| Test de débit avec sa qualité, comparatif des opérateurs (Orange, blue, MTN) | ✗ | ✓ |
| Alerte « signal faible », « nouvel appareil », « nouvelle SIM » | ✗ | ✓ |
| Surnoms des appareils, expulsion des intrus en un geste | ✗ | ✓ |
| Partage du Wi-Fi par QR code | ✗ | ✓ |
| Redémarrage programmé, réparation automatique | ✗ | ✓ |
| Sauvegarde et restauration de la configuration | ✗ | ✓ |
| Tuile des réglages rapides, widget d'écran d'accueil | ✗ | ✓ |
| Reconnexion automatique, mot de passe mémorisé chiffré, verrouillage par empreinte | ✗ | ✓ |

## Télécharger

Le plus simple : le bouton « Télécharger et installer » en haut de cette page. Toutes les versions se trouvent aussi dans les [Releases](https://github.com/SoundwaveAssets/mifi/releases).

1. Touchez le bouton depuis le téléphone : le fichier `mifi.apk` se télécharge.
2. Ouvrez-le (notification de téléchargement ou dossier « Téléchargements »).
3. Si Android le demande, autorisez l'installation d'applis depuis votre navigateur.
4. Touchez « Installer ».

Configuration requise : Android 7.0 ou plus récent.

## Fonctionnalités

**Connexion et état en temps réel**
- Tableau de bord mis à jour toutes les 2 secondes : signal (valeur en dBm et 5 niveaux : inexistant, faible, moyen, bon, excellent, avec des barres vertes, orange ou rouges), opérateur, IP WAN, appareils connectés.
- État d'internet vérifié par un vrai test à travers le modem (le modem, lui, se dit « connecté » même sans forfait).
- Alerte immédiate quand internet ne passe plus, avec la relance à portée de main.

**Relancer la connexion**
- Coupe la connexion comme un mode avion (le modem décroche du réseau puis s'y réinscrit), la rétablit, puis vérifie qu'internet est revenu.
- Recommence automatiquement jusqu'au retour d'internet, ou jusqu'à ce que vous touchiez « Arrêter ».
- Suivi à l'écran : numéro de la tentative, étape en cours, temps écoulé.

**Données mobiles**
- Bouton pour activer ou désactiver les données mobiles du modem, sans changer de SIM ni couper le Wi-Fi.
- Disponible aussi en tuile dans les réglages rapides d'Android.

**Surveillance**
- Surveillance continue, même appli fermée (avec votre autorisation) : notifications quand internet est coupé ou revient, signal faible, nouvel appareil inconnu, nouvelle carte SIM.
- Journal des coupures (début, fin, durée), exportable en CSV.
- Historique du signal et aide pour trouver le meilleur emplacement du modem.
- Réparation automatique (option) : relance la connexion d'elle-même après une coupure.

**Mesures**
- Test de débit avec sa qualité (inexistant, faible, moyen, bon, excellent) et historique.
- Comparatif des opérateurs : signal, débit et coupures par SIM sur 7 jours.

**Réglages du modem**
- Wi-Fi : nom, mot de passe, partage par QR code, expulsion des appareils inconnus.
- Réseau mobile : choix de la SIM, mode réseau, profils APN.
- Réseau local (DHCP), sauvegarde et restauration de la configuration.
- Système : redémarrage (immédiat ou programmé), mot de passe administrateur, mise à jour du firmware.

**Confort**
- Widget « État du modem » sur l'écran d'accueil.
- Verrouillage par empreinte (option).
- Français et anglais, thème clair ou sombre.

## Première utilisation

1. Connectez le téléphone au Wi-Fi du modem (nom et mot de passe sur l'étiquette du modem).
2. Ouvrez MiFi et saisissez le mot de passe administrateur du modem. Laissez « Mémoriser le mot de passe » coché : la connexion sera automatique ensuite.
3. Acceptez la surveillance de la connexion : Android demande d'autoriser les notifications, puis le fonctionnement en arrière-plan.
4. Sur un téléphone Xiaomi, Redmi ou POCO, autorisez aussi le démarrage automatique. Les boutons se trouvent dans Réglages › Réglages de l'application › Automatismes.

Si Android signale « Pas d'accès à internet » pour le Wi-Fi du modem, c'est normal quand les données sont coupées : l'appli l'utilise quand même pour parler au modem.

## Autorisations

| Autorisation | Pourquoi |
|---|---|
| Accès au réseau | Dialoguer avec le modem par son Wi-Fi, même s'il n'a pas internet. |
| Notifications | Vous prévenir (internet coupé ou revenu, signal faible, nouvel appareil). |
| Fonctionnement en arrière-plan et service au premier plan | Surveillance continue appli fermée, signalée par une notification discrète « Surveillance active ». |
| Démarrage du téléphone | Relancer la surveillance et le redémarrage programmé. |
| Alarmes exactes | Redémarrage programmé à l'heure choisie. |
| Empreinte | Verrouillage de l'appli (option). |

## Batterie et données

- **Appli ouverte** : relevé du modem toutes les 2 secondes, avec un test d'internet très léger (environ 1 Ko).
- **Appli fermée** (surveillance continue) : un relevé toutes les 15 secondes quand tout va bien, toutes les 5 secondes quand internet ne passe plus, pour voir vite son retour. Aucun maintien du téléphone en éveil : en veille profonde, Android espace encore les relevés. Comptez environ 5 Mo de données par jour au plus.
- La surveillance s'arrête dans les réglages de l'appli à tout moment.

## Fonctionnement et limites

- Le modem n'a pas de commande pour couper ses données ou sa radio. L'appli active pour cela un profil APN de coupure « MiFi-OFF » (IPv6 seul) que les opérateurs refusent : le voyant « données » du modem reste rouge. Réactiver les données remet votre profil habituel.
- Pour « Relancer la connexion », l'appli change en plus le mode réseau pendant quelques secondes, ce qui oblige le modem à se réinscrire sur le réseau, puis remet toujours votre réglage.
- Toutes les fonctions passent par le Wi-Fi du modem : le téléphone doit y être connecté.
- Certains téléphones (Xiaomi notamment) arrêtent les applis en arrière-plan sans le démarrage automatique : une vérification de secours relance alors la surveillance environ toutes les 15 minutes.

## Modem compatible

Routeur de poche 4G/5G « MiFi » à interface web HiMILink (adresse `192.168.100.1` par défaut, API `POST /himiapi/json`). L'adresse du modem se change dans l'écran de connexion si elle a été modifiée.

## Pour les développeurs

- Flutter 3.44, Dart 3.12, Android SDK.
- `flutter pub get`, puis `flutter test` et `flutter build apk --release`.
- Signature des versions publiées : le fichier `android/key.properties` (jamais publié) indique la clé `android/keystore/mifi-release.jks` et son mot de passe. Sans ce fichier, l'APK est signé avec la clé de test du poste.
- L'architecture, les choix techniques et le pont Dart ↔ Kotlin sont décrits dans [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Le cahier des charges et la description de l'API du modem sont dans [docs/BRIEF_APP_MODEM.md](docs/BRIEF_APP_MODEM.md).
