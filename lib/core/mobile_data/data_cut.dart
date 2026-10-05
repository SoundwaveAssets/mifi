import 'dart:convert';

import '../api/modem_api.dart';
import '../data/app_data_store.dart';
import '../models/mobile_models.dart';
import '../models/status_models.dart';
import '../util/operators.dart';

/// Le modem n'a pas appliqué la coupure (ou le rétablissement) d'internet.
class DataCutFailedException implements Exception {
  const DataCutFailedException();

  @override
  String toString() => 'DataCutFailedException()';
}

/// Raison pour laquelle une coupure demandée ne tient pas.
enum DataCutProblem {
  /// Le modem quitte sans cesse le profil de coupure pour son profil habituel.
  profileLost,

  /// Le profil de coupure est actif mais internet passe quand même (le réseau
  /// de l'opérateur accepte n'importe quel APN).
  internetStillUp,
}

/// La coupure demandée ne tient pas : internet reste accessible.
class DataCutNotHoldingException implements Exception {
  const DataCutNotHoldingException(this.problem);

  final DataCutProblem problem;

  @override
  String toString() => 'DataCutNotHoldingException(${problem.name})';
}

/// Raison d'une coupure volontaire d'internet : données coupées par
/// l'utilisateur, ou coupure brève de « Relancer la connexion ».
enum DataCutReason { mobileDataOff, reconnect }

/// Coupe internet sur la SIM active, quelle qu'elle soit, en activant un
/// profil APN volontairement invalide (« MiFi-OFF », IPv6 seul) : le Wi-Fi
/// reste actif et aucune SIM n'est changée. Le rétablissement réactive le
/// profil précédent (mémorisé dans l'appli).
///
/// Partagée par les données mobiles et « Relancer la connexion » : internet
/// reste coupé tant qu'une des deux raisons est active. Les raisons sont
/// mémorisées dans [store] et marquent aussi les coupures volontaires dans le
/// journal.
///
/// La coupure est immédiate (aucune attente), puis maintenue : à chaque
/// relevé de l'état du modem, [maintain] réactive le profil de coupure si le
/// modem l'a quitté et note une coupure qui ne tient pas.
///
/// Le modem n'a pas de commande dédiée : pour changer d'approche, c'est la
/// seule classe à modifier.
class ApnDataCut {
  ApnDataCut(this.api, this.store, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final ModemApi api;
  final AppDataStore store;
  final DateTime Function() _now;

  /// Nom, APN et type PDP du profil de coupure (données techniques stockées
  /// sur le modem, pas des textes d'interface). IPv6 seul : un opérateur qui
  /// accepte n'importe quel nom d'APN (ex. Orange CM) refuse en général ce
  /// type, et sinon aucun appareil en IPv4 n'a internet.
  static const String blockerName = 'MiFi-OFF';
  static const String blockerApn = 'mifi.data.off.v6';
  static const String blockerPdpType = 'IPV6';

  /// Profil de coupure des versions précédentes (IPv4, accepté par certains
  /// opérateurs) : reconnu, mais remplacé par [blockerApn] dès que possible.
  static const String legacyBlockerApn = 'mifi.data.off';

  /// Au-delà, une connexion active malgré le profil de coupure signifie que
  /// le réseau l'accepte (marge pour un état du modem lent à se mettre à jour).
  static const Duration holdGrace = Duration(minutes: 2);

  /// Réactivations automatiques du profil de coupure, au plus [maxReapplies]
  /// par tranche de [reapplyWindow] ; ensuite le problème est signalé.
  static const int maxReapplies = 3;
  static const Duration reapplyWindow = Duration(minutes: 10);

  static const String _previousKey = 'mobile_data.previous_apn';
  static const String _appliedAtKey = 'mobile_data.applied_at';
  static const String _reappliesKey = 'mobile_data.reapplies';
  static const String _problemKey = 'mobile_data.problem';

  /// Vrai si [profile] est un profil de coupure créé par l'appli.
  static bool isBlocker(ApnProfile profile) {
    final apn = _apnOf(profile);
    return apn == blockerApn || apn == legacyBlockerApn;
  }

  static String _apnOf(ApnProfile profile) => profile.apn.trim().toLowerCase();

  static String _reasonKey(DataCutReason reason) => switch (reason) {
        DataCutReason.mobileDataOff => MonitorStateKeys.mobileDataOffExpected,
        DataCutReason.reconnect => MonitorStateKeys.reconnectCut,
      };

  Future<void> _queue = Future<void>.value();

  /// Exécute [action] après les opérations en cours : une seule à la fois.
  Future<T> _serialized<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// La coupure est-elle demandée pour [reason] ?
  Future<bool> isRequested(DataCutReason reason) async => await store.readState(_reasonKey(reason)) == '1';

  /// Une coupure est-elle demandée (données coupées ou coupure brève) ?
  Future<bool> isAnyRequested() async {
    for (final reason in DataCutReason.values) {
      if (await isRequested(reason)) return true;
    }
    return false;
  }

  /// Le profil de coupure est-il actif ? `null` si aucun profil n'est actif.
  Future<bool?> isBlocked() async {
    final current = (await api.getApnInfo()).current;
    return current == null ? null : isBlocker(current);
  }

  /// Problème de la coupure demandée pour [reason] (`null` si elle tient ou
  /// n'est pas demandée).
  Future<DataCutProblem?> problemFor(DataCutReason reason) async {
    if (!await isRequested(reason)) return null;
    final name = await store.readState(_problemKey);
    return DataCutProblem.values.where((p) => p.name == name).firstOrNull;
  }

  /// Problème de la coupure en cours, quelle qu'en soit la raison.
  Future<DataCutProblem?> problem() async {
    for (final reason in DataCutReason.values) {
      final problem = await problemFor(reason);
      if (problem != null) return problem;
    }
    return null;
  }

  /// Coupe internet pour [reason] (sans effet s'il est déjà coupé).
  Future<void> request(DataCutReason reason) => _serialized(() async {
        await store.writeState(_reasonKey(reason), '1');
        await _clearHealth();
        try {
          await _block();
        } catch (_) {
          await store.writeState(_reasonKey(reason), null);
          rethrow;
        }
      });

  /// Lève la coupure pour [reason] ; internet revient si aucune autre raison
  /// ne la maintient.
  Future<void> release(DataCutReason reason) => _serialized(() async {
        for (final other in DataCutReason.values) {
          if (other != reason && await isRequested(other)) {
            await store.writeState(_reasonKey(reason), null);
            return;
          }
        }
        await _restore();
        await store.writeState(_reasonKey(reason), null);
        await _clearHealth();
      });

  /// Oublie la coupure demandée pour [reason] sans rien changer sur le modem,
  /// pour qu'elle ne soit plus maintenue (rétablissement impossible pendant
  /// « Relancer la connexion »).
  Future<void> withdraw(DataCutReason reason) => _serialized(() async {
        await store.writeState(_reasonKey(reason), null);
        if (!await isAnyRequested()) await _clearHealth();
      });

  /// Lève une coupure brève restée en place : « Relancer la connexion »
  /// interrompu, ou mode avion laissé actif par une ancienne version.
  Future<void> releaseLeftover() async {
    if (await isRequested(DataCutReason.reconnect)) await release(DataCutReason.reconnect);
  }

  /// Réapplique une coupure demandée sur la SIM active : après un changement
  /// de SIM, le modem choisit le profil APN de la nouvelle SIM. Sans SIM dans
  /// l'emplacement, il n'y a rien à couper.
  Future<void> reapply() => _serialized(() async {
        if (!await isAnyRequested()) return;
        if (!(await api.getAllStatus()).hasSim) return;
        await _block();
      });

  /// Fait respecter la coupure demandée d'après un relevé [status] de l'état
  /// du modem : réactive le profil de coupure si le modem l'a quitté (au plus
  /// [maxReapplies] fois par [reapplyWindow], puis note le problème) et note
  /// une connexion qui passe malgré lui. Renvoie `true` si le problème noté
  /// a changé. Lève une `ModemException` ou une [DataCutFailedException] si
  /// la réactivation échoue.
  Future<bool> maintain(AllStatus status) => _serialized(() async {
        if (!await isAnyRequested()) return false;
        final current = (await api.getApnInfo()).current;
        if (current == null) return false;
        final blocked = isBlocker(current);
        if (blocked && _apnOf(current) == legacyBlockerApn && status.hasSim) {
          // Ancien profil de coupure (IPv4) : passer au profil IPv6.
          await _block();
          return false;
        }
        final problem = await store.readState(_problemKey);
        final now = _now().millisecondsSinceEpoch;
        if (!blocked) {
          // Emplacement vide : rien à couper.
          if (!status.hasSim) return false;
          // Abandon jusqu'à la prochaine action de l'utilisateur.
          if (problem == DataCutProblem.profileLost.name) return false;
          final attempts = [
            for (final value in (await store.readState(_reappliesKey) ?? '').split(','))
              if (int.tryParse(value) case final time? when now - time < reapplyWindow.inMilliseconds) time,
          ];
          if (attempts.length >= maxReapplies) {
            await store.writeState(_problemKey, DataCutProblem.profileLost.name);
            return true;
          }
          await store.writeState(_reappliesKey, [...attempts, now].join(','));
          await _block();
          return false;
        }
        if (!status.hasSim || !status.isInternetConnected) {
          // La coupure tient.
          if (problem == null) return false;
          await store.writeState(_problemKey, null);
          return true;
        }
        // Profil de coupure actif mais internet passe : laisser au modem le
        // temps de couper la connexion.
        final appliedAt = int.tryParse(await store.readState(_appliedAtKey) ?? '');
        if (appliedAt == null) {
          await store.writeState(_appliedAtKey, '$now');
          return false;
        }
        if (now - appliedAt < holdGrace.inMilliseconds) return false;
        if (problem == DataCutProblem.internetStillUp.name) return false;
        await store.writeState(_problemKey, DataCutProblem.internetStillUp.name);
        return true;
      });

  /// Oublie les coupures demandées, quand l'utilisateur choisit lui-même le
  /// profil APN à utiliser.
  Future<void> forget() => _serialized(() async {
        for (final reason in DataCutReason.values) {
          await store.writeState(_reasonKey(reason), null);
        }
        await store.writeState(_previousKey, null);
        await _clearHealth();
      });

  Future<void> _clearHealth() async {
    await store.writeState(_problemKey, null);
    await store.writeState(_reappliesKey, null);
    await store.writeState(_appliedAtKey, null);
  }

  Future<void> _block() async {
    var info = await api.getApnInfo();
    final current = info.current;
    if (current != null && _apnOf(current) == blockerApn) return;
    // Profil habituel à remettre ensuite (pas un ancien profil de coupure).
    if (current != null && !isBlocker(current)) await store.writeState(_previousKey, jsonEncode(current.toJson()));

    // Profil de coupure pour l'opérateur actuel (le modem trie par MCC/MNC).
    String mcc = current?.mcc ?? '', mnc = current?.mnc ?? '';
    if (mcc.isEmpty || mnc.isEmpty) {
      final codes = mccMncFromImsi((await api.getAllStatus()).imsi);
      if (codes != null) (mcc, mnc) = codes;
    }
    ApnProfile? blocker = _findBlocker(info, mcc, mnc);
    if (blocker == null) {
      await api.addApn(ApnProfile.create(
        id: info.nextId(),
        name: blockerName,
        apn: blockerApn,
        pdpType: blockerPdpType,
        mcc: mcc,
        mnc: mnc,
      ));
      info = await api.getApnInfo();
      blocker = _findBlocker(info, mcc, mnc);
      if (blocker == null) throw const DataCutFailedException();
    }
    await api.setCurrentApn(blocker);
    final after = (await api.getApnInfo()).current;
    if (after == null || _apnOf(after) != blockerApn) throw const DataCutFailedException();
    await store.writeState(_appliedAtKey, '${_now().millisecondsSinceEpoch}');
  }

  Future<void> _restore() async {
    final info = await api.getApnInfo();
    final current = info.current;
    if (current != null && !isBlocker(current)) return;
    final usable = info.profiles.where((p) => !isBlocker(p));
    // Sinon, un profil du même opérateur que le profil de coupure actif.
    final target = _previousProfile(usable, await store.readState(_previousKey)) ??
        usable.where((p) => current != null && p.mcc == current.mcc && p.mnc == current.mnc).firstOrNull ??
        usable.firstOrNull;
    if (target == null) throw const DataCutFailedException();
    await api.setCurrentApn(target);
    final after = (await api.getApnInfo()).current;
    if (after == null || isBlocker(after)) throw const DataCutFailedException();
    await store.writeState(_previousKey, null);
  }

  ApnProfile? _findBlocker(ApnInfo info, String mcc, String mnc) {
    final blockers = info.profiles.where((p) => _apnOf(p) == blockerApn).toList();
    return blockers.where((p) => p.mcc == mcc && p.mnc == mnc).firstOrNull ?? blockers.firstOrNull;
  }

  /// Profil d'avant la coupure, retrouvé dans la liste actuelle du modem.
  ApnProfile? _previousProfile(Iterable<ApnProfile> usable, String? savedJson) {
    if (savedJson == null) return null;
    try {
      final saved = ApnProfile(Map<String, dynamic>.from(jsonDecode(savedJson) as Map));
      return usable
          .where((p) => p.apn == saved.apn && p.name == saved.name && p.mcc == saved.mcc && p.mnc == saved.mnc)
          .firstOrNull;
    } on FormatException {
      return null;
    }
  }
}
