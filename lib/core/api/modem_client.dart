import 'dart:async';

import 'commands.dart';
import 'modem_exception.dart';
import 'modem_transport.dart';

/// Identifiants de l'interface d'administration du modem.
class ModemCredentials {
  const ModemCredentials({this.username = defaultUsername, required this.password});

  /// Seul compte connu de l'interface d'origine.
  static const String defaultUsername = 'admin';

  final String username;
  final String password;
}

/// Réponse décodée `{"reply": "...", "params": ...}`.
class ModemResponse {
  const ModemResponse(this.cmdid, this.raw);

  final String cmdid;
  final Map<String, dynamic> raw;

  String get reply => '${raw['reply'] ?? ''}';
  bool get isOk => reply.toLowerCase() == 'ok';
  bool get isSessionOut => reply.toLowerCase() == 'sessionout';
  Object? get params => raw['params'];

  /// `params` sous forme d'objet ; lève [InvalidResponseException] sinon.
  Map<String, dynamic> get paramsMap {
    final params = raw['params'];
    if (params is Map) return Map<String, dynamic>.from(params);
    throw InvalidResponseException(cmdid, 'params is not an object');
  }

  /// `params` sous forme de liste. Tolère un objet contenant une liste et
  /// l'absence de `params` (liste vide).
  List<dynamic> get paramsList {
    final params = raw['params'];
    if (params == null) return const [];
    if (params is List) return params;
    if (params is Map) {
      for (final value in params.values) {
        if (value is List) return value;
      }
      if (params.isEmpty) return const [];
    }
    throw InvalidResponseException(cmdid, 'params is not a list');
  }
}

/// Client de session du modem.
///
/// - ajoute `sessionId` au corps et l'en-tête `Authorization` ;
/// - sur `{"reply":"SessionOut"}`, se reconnecte automatiquement (une seule
///   reconnexion partagée entre les requêtes concurrentes) puis relance la
///   requête une fois ;
/// - envoie les requêtes une par une : le serveur web embarqué du modem
///   supporte mal les requêtes simultanées.
class ModemClient {
  ModemClient(this.transport);

  final ModemTransport transport;

  String? _session;
  ModemCredentials? _credentials;
  Future<void>? _relogin;
  Future<void> _queue = Future<void>.value();
  final _sessionLost = StreamController<ModemException>.broadcast();

  String? get session => _session;
  bool get hasSession => _session != null;
  ModemCredentials? get credentials => _credentials;

  /// Émet quand la session est définitivement perdue (reconnexion refusée,
  /// ex. mot de passe changé depuis un autre appareil).
  Stream<ModemException> get sessionLost => _sessionLost.stream;

  /// Ouvre une session. Lève [LoginFailedException] si le mot de passe est
  /// refusé.
  Future<void> login(ModemCredentials credentials, {Duration timeout = ModemTransport.defaultTimeout}) async {
    final raw = await _enqueue(() => transport.postJson(
          ModemCommands.login,
          {
            'cmdid': ModemCommands.login,
            'username': credentials.username,
            'password': credentials.password,
          },
          timeout: timeout,
        ));
    final response = ModemResponse(ModemCommands.login, raw);
    if (!response.isOk) throw LoginFailedException(response.reply);
    final session = raw['session'];
    if (session == null || '$session'.isEmpty) {
      throw const InvalidResponseException(ModemCommands.login, 'missing session');
    }
    _session = '$session';
    _credentials = credentials;
  }

  /// Remplace le mot de passe mémorisé pour la reconnexion automatique
  /// (après `changepwd`).
  void updatePassword(String password) {
    final current = _credentials;
    if (current == null) return;
    _credentials = ModemCredentials(username: current.username, password: password);
  }

  /// Oublie la session courante (modem redémarré, adresse modifiée…) mais
  /// garde les identifiants : la prochaine requête se reconnectera.
  void dropSession() => _session = null;

  /// Déconnexion explicite : prévient le modem puis oublie tout.
  Future<void> logout() async {
    final session = _session;
    _session = null;
    _credentials = null;
    if (session == null) return;
    try {
      await _enqueue(() => transport.postJson(
            ModemCommands.logout,
            {'cmdid': ModemCommands.logout, 'sessionId': session},
            authorization: session,
            timeout: const Duration(seconds: 5),
          ));
    } on ModemException {
      // Sans importance : la session expirera d'elle-même.
    }
  }

  /// Commande sans session (`getconfig`). Renvoie l'objet JSON brut.
  Future<Map<String, dynamic>> callAnonymous(String cmdid, {Duration timeout = ModemTransport.defaultTimeout}) {
    return _enqueue(() => transport.postJson(cmdid, {'cmdid': cmdid}, timeout: timeout));
  }

  /// Envoie une commande authentifiée et renvoie la réponse (`reply` = ok).
  ///
  /// [params] devient le champ `params` ; [extra] ajoute d'autres champs à la
  /// racine (ex. `params1` de `setsimnum`).
  Future<ModemResponse> call(
    String cmdid, {
    Object? params,
    Map<String, Object?> extra = const {},
    Duration timeout = ModemTransport.defaultTimeout,
  }) async {
    var reloginAllowed = true;
    for (var attempt = 0; attempt < 4; attempt++) {
      await _ensureSession();
      final (usedSession, raw) = await _enqueue<(String?, Map<String, dynamic>?)>(() async {
        // Corps construit au moment de l'envoi, avec la session la plus récente.
        final session = _session;
        if (session == null) return (null, null);
        final body = <String, Object?>{
          'cmdid': cmdid,
          'params': ?params,
          ...extra,
          'sessionId': session,
        };
        final result = await transport.postJson(cmdid, body, authorization: session, timeout: timeout);
        return (session, result);
      });
      if (raw == null) continue; // Session perdue pendant l'attente : on recommence.

      final response = ModemResponse(cmdid, raw);
      if (response.isSessionOut) {
        if (_credentials == null) {
          _session = null;
          throw const SessionExpiredException();
        }
        if (!reloginAllowed) {
          // Session refusée juste après une reconnexion réussie : abandon.
          _session = null;
          _sessionLost.add(const SessionExpiredException());
          throw const SessionExpiredException();
        }
        reloginAllowed = false;
        await _reloginOnce(usedSession);
        continue;
      }
      if (!response.isOk) throw CommandFailedException(cmdid, response.reply);
      return response;
    }
    throw const SessionExpiredException();
  }

  /// Envoie un fichier sur `/upload` avec la session courante (après une
  /// reconnexion si nécessaire). Non sérialisé : peut durer plusieurs minutes.
  Future<String> upload(
    Future<String> Function(String session) send,
  ) async {
    await _ensureSession();
    final session = _session;
    if (session == null) throw const SessionExpiredException();
    return send(session);
  }

  Future<void> _ensureSession() async {
    if (_session != null) return;
    if (_credentials == null) throw const SessionExpiredException();
    await _reloginOnce(null);
  }

  /// Reconnexion partagée : si [staleSession] a déjà été remplacée par une
  /// autre requête, ne fait rien.
  Future<void> _reloginOnce(String? staleSession) {
    final current = _session;
    if (current != null && current != staleSession) return Future<void>.value();
    return _relogin ??= _doRelogin().whenComplete(() => _relogin = null);
  }

  Future<void> _doRelogin() async {
    final credentials = _credentials;
    if (credentials == null) throw const SessionExpiredException();
    _session = null;
    try {
      await login(credentials);
    } on LoginFailedException catch (e) {
      // Mot de passe changé ailleurs : inutile d'insister.
      _credentials = null;
      _sessionLost.add(e);
      throw const SessionExpiredException();
    }
  }

  /// Exécute [task] après les requêtes déjà en file.
  Future<T> _enqueue<T>(Future<T> Function() task) {
    final previous = _queue;
    final done = Completer<void>();
    _queue = done.future;
    return previous.then((_) => task()).whenComplete(done.complete);
  }

  void dispose() {
    _sessionLost.close();
    transport.close();
  }
}
