/// Normalisation de texte pour la recherche locale : insensible à la casse
/// et aux accents (« Crème » et « creme » donnent la même forme).
abstract final class TextNormalizer {
  static const Map<String, String> _replacements = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    'œ': 'oe', 'æ': 'ae',
    '’': "'",
  };

  static final RegExp _whitespace = RegExp(r'\s+');

  /// Retourne le texte en minuscules, sans accents et avec des espaces
  /// simples.
  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_replacements[char] ?? char);
    }
    return buffer.toString().replaceAll(_whitespace, ' ').trim();
  }

  /// Découpe une requête normalisée en mots non vides.
  static List<String> tokens(String input) {
    final normalized = normalize(input);
    if (normalized.isEmpty) return const [];
    return normalized.split(' ');
  }
}
