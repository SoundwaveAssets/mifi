import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mot de passe admin du modem, chiffré par le Keystore Android
/// (`flutter_secure_storage`). Jamais exporté, jamais journalisé.
class CredentialsStore {
  CredentialsStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kPassword = 'modem_admin_password';

  /// Mot de passe enregistré, ou `null`. Une erreur de lecture (clé du
  /// Keystore perdue…) est traitée comme « aucun mot de passe ».
  Future<String?> readPassword() async {
    try {
      final value = await _storage.read(key: _kPassword);
      return (value == null || value.isEmpty) ? null : value;
    } on PlatformException {
      return null;
    }
  }

  Future<void> savePassword(String password) => _storage.write(key: _kPassword, value: password);

  Future<void> clearPassword() async {
    try {
      await _storage.delete(key: _kPassword);
    } on PlatformException {
      // Rien à effacer.
    }
  }
}
