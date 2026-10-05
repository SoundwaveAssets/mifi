import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'modem_exception.dart';

/// Progression d'un envoi de fichier.
typedef UploadProgressCallback = void Function(int sentBytes, int totalBytes);

/// Transport HTTP brut vers le modem : `POST /himiapi/json` et `POST /upload`.
///
/// Ne connaît pas les sessions (voir `ModemClient`). Toutes les erreurs
/// réseau sont converties en [ModemException].
class ModemTransport {
  ModemTransport({required this.baseUri, http.Client? httpClient})
      : _http = httpClient ?? _createDefaultClient();

  /// Délai standard d'une commande.
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Délai maximal de l'envoi du firmware (fichier jusqu'à 500 Mo).
  static const Duration uploadTimeout = Duration(minutes: 30);

  final http.Client _http;

  /// Adresse de base du modem, ex. `http://192.168.100.1` (modifiable : elle
  /// change si `gwip` est modifié dans les réglages DHCP).
  Uri baseUri;

  /// Adresse lisible (`192.168.100.1` ou `hôte:port`).
  String get address =>
      baseUri.hasPort && baseUri.port != 80 ? '${baseUri.host}:${baseUri.port}' : baseUri.host;

  static http.Client _createDefaultClient() {
    final client = HttpClient()
      ..connectionTimeout = defaultTimeout
      ..idleTimeout = const Duration(seconds: 15)
      // Le modem est sur le réseau local : jamais de proxy.
      ..findProxy = (_) => 'DIRECT';
    return IOClient(client);
  }

  /// Envoie [body] en JSON et renvoie l'objet JSON reçu.
  ///
  /// Une réponse vide signifie « commande inconnue »
  /// ([UnsupportedCommandException]).
  Future<Map<String, dynamic>> postJson(
    String cmdid,
    Map<String, Object?> body, {
    String? authorization,
    Duration timeout = defaultTimeout,
  }) async {
    final abort = Completer<void>();
    final timer = Timer(timeout, () {
      if (!abort.isCompleted) abort.complete();
    });
    final request = http.AbortableRequest(
      'POST',
      baseUri.replace(path: '/himiapi/json'),
      abortTrigger: abort.future,
    )
      ..headers['Content-Type'] = 'application/json;charset=UTF-8'
      ..bodyBytes = utf8.encode(jsonEncode(body));
    if (authorization != null && authorization.isNotEmpty) {
      request.headers['Authorization'] = authorization;
    }
    try {
      final streamed = await _http.send(request);
      final response = await http.Response.fromStream(streamed);
      return _decodeJson(cmdid, response);
    } on http.RequestAbortedException {
      throw ModemTimeoutException(cmdid, timeout);
    } on TimeoutException {
      throw ModemTimeoutException(cmdid, timeout);
    } on SocketException catch (e) {
      throw ModemUnreachableException(address, e);
    } on HttpException catch (e) {
      throw ModemUnreachableException(address, e);
    } on http.ClientException catch (e) {
      throw ModemUnreachableException(address, e);
    } finally {
      timer.cancel();
    }
  }

  /// Envoie un fichier en `multipart/form-data` sur `POST /upload`.
  ///
  /// [cancel] : compléter ce futur annule l'envoi
  /// ([OperationCancelledException]). Renvoie le corps de la réponse.
  Future<String> upload({
    required File file,
    required String filename,
    String fieldName = 'file',
    String? authorization,
    UploadProgressCallback? onProgress,
    Duration timeout = uploadTimeout,
    Future<void>? cancel,
  }) async {
    final total = await file.length();
    var sent = 0;
    final counted = file.openRead().map((chunk) {
      sent += chunk.length;
      onProgress?.call(sent, total);
      return chunk;
    });

    var cancelled = false;
    final abort = Completer<void>();
    final timer = Timer(timeout, () {
      if (!abort.isCompleted) abort.complete();
    });
    cancel?.then((_) {
      cancelled = true;
      if (!abort.isCompleted) abort.complete();
    });

    final request = http.AbortableMultipartRequest(
      'POST',
      baseUri.replace(path: '/upload'),
      abortTrigger: abort.future,
    )..files.add(http.MultipartFile(fieldName, counted, total, filename: filename));
    if (authorization != null && authorization.isNotEmpty) {
      request.headers['Authorization'] = authorization;
    }
    try {
      final streamed = await _http.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CommandFailedException('upload', 'HTTP ${response.statusCode}');
      }
      final text = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
      // Si le modem répond en JSON, vérifier `reply`.
      if (text.startsWith('{')) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is Map && decoded['reply'] != null) {
            final reply = '${decoded['reply']}';
            if (reply.toLowerCase() != 'ok') throw CommandFailedException('upload', reply);
          }
        } on FormatException {
          // Réponse non JSON : on se contente du code HTTP.
        }
      }
      return text;
    } on http.RequestAbortedException {
      if (cancelled) throw const OperationCancelledException();
      throw ModemTimeoutException('upload', timeout);
    } on SocketException catch (e) {
      throw ModemUnreachableException(address, e);
    } on HttpException catch (e) {
      throw ModemUnreachableException(address, e);
    } on http.ClientException catch (e) {
      if (cancelled) throw const OperationCancelledException();
      throw ModemUnreachableException(address, e);
    } finally {
      timer.cancel();
    }
  }

  Map<String, dynamic> _decodeJson(String cmdid, http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CommandFailedException(cmdid, 'HTTP ${response.statusCode}');
    }
    // Décodage UTF-8 explicite : le modem n'annonce pas toujours le charset.
    final text = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
    if (text.isEmpty) throw UnsupportedCommandException(cmdid);
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (e) {
      throw InvalidResponseException(cmdid, e.message);
    }
    if (decoded is! Map) throw InvalidResponseException(cmdid, 'not a JSON object');
    return Map<String, dynamic>.from(decoded);
  }

  void close() => _http.close();
}
