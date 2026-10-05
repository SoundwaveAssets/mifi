// Lecture et écriture tolérantes des valeurs JSON du modem, dont les types
// sont parfois incohérents ("1", 1, true…).

/// Valeur en chaîne ; [fallback] si absente.
String jsonString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  return value is String ? value : '$value';
}

/// Valeur entière, ou `null` si absente ou illisible.
int? jsonInt(Object? value) {
  return switch (value) {
    int v => v,
    double v when v.isFinite => v.round(),
    String v => int.tryParse(v.trim()) ?? double.tryParse(v.trim())?.round(),
    bool v => v ? 1 : 0,
    _ => null,
  };
}

/// Valeur décimale, ou `null` si absente ou illisible.
double? jsonDouble(Object? value) {
  return switch (value) {
    num v => v.toDouble(),
    String v => double.tryParse(v.trim().replaceAll(',', '.')),
    _ => null,
  };
}

/// Valeur booléenne : accepte true/false, 1/0, "1"/"0", "on"/"off",
/// "open"/"close", "yes"/"no", "enable"/"disable"…
bool? jsonBool(Object? value) {
  return switch (value) {
    bool v => v,
    num v => v != 0,
    String v => switch (v.trim().toLowerCase()) {
        'true' || '1' || 'on' || 'open' || 'yes' || 'enable' || 'enabled' => true,
        'false' || '0' || 'off' || 'close' || 'closed' || 'no' || 'disable' || 'disabled' => false,
        _ => null,
      },
    _ => null,
  };
}

/// `null` si la valeur est absente, vide ou nulle (0, "0", "0.0"…).
///
/// Sur le modem réel, `bsid`, `cellid`, `cputemp` et `sysruntime` valent 0 :
/// ces champs doivent alors être masqués plutôt qu'affichés « 0 ».
String? nonZeroString(Object? value) {
  if (value == null) return null;
  final text = (value is String ? value : '$value').trim();
  if (text.isEmpty) return null;
  final number = double.tryParse(text);
  if (number != null && number == 0) return null;
  return text;
}

/// Encode [value] avec la même représentation que [original] : booléen,
/// nombre, ou chaîne ("1"/"0", "true"/"false", "on"/"off", "open"/"close"…).
Object boolLike(Object? original, bool value) {
  switch (original) {
    case bool():
      return value;
    case int():
      return value ? 1 : 0;
    case double():
      return value ? 1.0 : 0.0;
    case String text:
      const pairs = [
        ('true', 'false'),
        ('on', 'off'),
        ('open', 'close'),
        ('yes', 'no'),
        ('enable', 'disable'),
        ('enabled', 'disabled'),
      ];
      final lower = text.trim().toLowerCase();
      for (final (yes, no) in pairs) {
        if (lower == yes || lower == no) return value ? yes : no;
      }
      return value ? '1' : '0';
    default:
      return value;
  }
}

/// Encode [value] (texte saisi) avec le type de [original] : nombre si
/// l'original était un nombre et que le texte est numérique, sinon chaîne.
Object stringLike(Object? original, String value) {
  if (original is int) return int.tryParse(value.trim()) ?? value;
  if (original is double) return double.tryParse(value.trim()) ?? value;
  return value;
}

/// Encode l'entier [value] avec le type de [original] (chaîne ou nombre).
/// Si l'original est absent, [asStringByDefault] décide.
Object intLike(Object? original, int value, {bool asStringByDefault = true}) {
  if (original is String) return '$value';
  if (original is num) return value;
  return asStringByDefault ? '$value' : value;
}

/// Copie modifiable d'un objet JSON quelconque (`null` → objet vide).
Map<String, dynamic> jsonObject(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
