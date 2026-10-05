import 'dart:math';

/// Caractères du mot de passe Wi-Fi généré : lettres et chiffres sans les
/// caractères ambigus (I, O, l, 1, 0), faciles à recopier à la main.
const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
const String _lower = 'abcdefghijkmnopqrstuvwxyz';
const String _digits = '23456789';

/// Mot de passe Wi-Fi solide (12 caractères par défaut, au moins une
/// majuscule, une minuscule et un chiffre), tiré d'une source aléatoire
/// cryptographique.
String generateWifiPassword({int length = 12, Random? random}) {
  assert(length >= 8 && length <= 32);
  final rng = random ?? Random.secure();
  const all = _upper + _lower + _digits;
  String pick(String set) => set[rng.nextInt(set.length)];
  final chars = <String>[
    pick(_upper),
    pick(_lower),
    pick(_digits),
    for (var i = 3; i < length; i++) pick(all),
  ];
  // Mélange de Fisher-Yates pour ne pas laisser les trois premiers en tête.
  for (var i = chars.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = chars[i];
    chars[i] = chars[j];
    chars[j] = tmp;
  }
  return chars.join();
}
