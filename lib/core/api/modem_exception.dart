/// Erreurs de la couche d'accès au modem.
///
/// Elles ne contiennent aucun texte destiné à l'utilisateur : l'interface les
/// traduit avec `describeError` (lib/ui/l10n_helpers.dart).
sealed class ModemException implements Exception {
  const ModemException();
}

/// Modem injoignable : téléphone hors du Wi-Fi du modem, mauvaise adresse…
final class ModemUnreachableException extends ModemException {
  const ModemUnreachableException(this.address, [this.cause]);

  /// Adresse tentée (`192.168.100.1` ou `hôte:port`).
  final String address;
  final Object? cause;

  @override
  String toString() => 'ModemUnreachableException($address): $cause';
}

/// Le modem n'a pas répondu dans le délai imparti.
final class ModemTimeoutException extends ModemException {
  const ModemTimeoutException(this.cmdid, this.timeout);

  final String cmdid;
  final Duration timeout;

  @override
  String toString() => 'ModemTimeoutException($cmdid, $timeout)';
}

/// Identifiants refusés par le modem.
final class LoginFailedException extends ModemException {
  const LoginFailedException(this.reply);

  /// Valeur brute de `reply` renvoyée par le modem.
  final String reply;

  @override
  String toString() => 'LoginFailedException($reply)';
}

/// Session expirée et reconnexion automatique impossible.
final class SessionExpiredException extends ModemException {
  const SessionExpiredException();

  @override
  String toString() => 'SessionExpiredException()';
}

/// Le modem a répondu, mais `reply` ≠ "ok".
final class CommandFailedException extends ModemException {
  const CommandFailedException(this.cmdid, this.reply);

  final String cmdid;

  /// Valeur brute de `reply` (ou `HTTP <code>`).
  final String reply;

  @override
  String toString() => 'CommandFailedException($cmdid, $reply)';
}

/// Réponse vide : commande inconnue de ce firmware.
final class UnsupportedCommandException extends ModemException {
  const UnsupportedCommandException(this.cmdid);

  final String cmdid;

  @override
  String toString() => 'UnsupportedCommandException($cmdid)';
}

/// Réponse illisible ou de forme inattendue.
final class InvalidResponseException extends ModemException {
  const InvalidResponseException(this.cmdid, [this.details]);

  final String cmdid;
  final String? details;

  @override
  String toString() => 'InvalidResponseException($cmdid, $details)';
}

/// Opération annulée par l'utilisateur (ex. envoi du firmware).
final class OperationCancelledException extends ModemException {
  const OperationCancelledException();

  @override
  String toString() => 'OperationCancelledException()';
}
