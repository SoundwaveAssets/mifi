import 'dart:async';
import 'dart:io';

import '../../../core/data/app_data_store.dart';

/// Échec d'un test de débit.
class SpeedTestException implements Exception {
  const SpeedTestException(this.kind);

  final SpeedTestFailure kind;

  @override
  String toString() => 'SpeedTestException($kind)';
}

enum SpeedTestFailure { noInternet, timeout, cancelled, server }

/// Mesure le débit descendant en téléchargeant un fichier de test à travers
/// le modem (le processus est lié au Wi-Fi du modem).
class SpeedTester {
  /// Durée maximale du transfert : au-delà, le débit mesuré est conservé.
  static const Duration maxTransfer = Duration(seconds: 45);

  static Uri urlFor(int bytes) => Uri.parse('https://speed.cloudflare.com/__down?bytes=$bytes');

  HttpClient? _client;
  bool _cancelled = false;

  /// Lance le test. [onProgress] reçoit les octets reçus et la durée du
  /// transfert ; renvoie le résultat (non enregistré).
  Future<SpeedTestResult> run({
    required int bytes,
    void Function(int received, Duration elapsed)? onProgress,
    String? operatorCode,
  }) async {
    _cancelled = false;
    final url = urlFor(bytes);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 5);
    _client = client;
    final total = Stopwatch()..start();
    try {
      final request = await client.getUrl(url).timeout(const Duration(seconds: 20));
      final response = await request.close().timeout(const Duration(seconds: 20));
      if (response.statusCode != HttpStatus.ok) throw const SpeedTestException(SpeedTestFailure.server);
      final latency = total.elapsed;
      final transfer = Stopwatch()..start();
      var received = 0;
      await for (final chunk in response.timeout(const Duration(seconds: 20))) {
        if (_cancelled) throw const SpeedTestException(SpeedTestFailure.cancelled);
        received += chunk.length;
        onProgress?.call(received, transfer.elapsed);
        if (transfer.elapsed > maxTransfer) break;
      }
      transfer.stop();
      if (received == 0) throw const SpeedTestException(SpeedTestFailure.server);
      return SpeedTestResult(
        time: DateTime.now(),
        bytes: received,
        duration: transfer.elapsed,
        latency: latency,
        url: url.toString(),
        operatorCode: operatorCode,
      );
    } on SpeedTestException {
      rethrow;
    } on TimeoutException {
      throw SpeedTestException(_cancelled ? SpeedTestFailure.cancelled : SpeedTestFailure.timeout);
    } on SocketException {
      throw SpeedTestException(_cancelled ? SpeedTestFailure.cancelled : SpeedTestFailure.noInternet);
    } on HttpException {
      throw SpeedTestException(_cancelled ? SpeedTestFailure.cancelled : SpeedTestFailure.noInternet);
    } on HandshakeException {
      throw const SpeedTestException(SpeedTestFailure.noInternet);
    } finally {
      client.close(force: true);
      _client = null;
    }
  }

  void cancel() {
    _cancelled = true;
    _client?.close(force: true);
  }
}
