import '../../../core/formatting/text_normalizer.dart';

/// Drapeau (emoji) associé à une origine du catalogue. Une origine régionale
/// prend le drapeau de son pays (« Breton » → France) ; une origine
/// multi-pays (« Maghrébin ») n'a pas de drapeau.
abstract final class OriginFlags {
  /// Adjectifs au masculin, normalisés, et code pays ISO 3166-1 alpha-2.
  static const Map<String, String> _countries = {
    // Régions, rattachées à leur pays.
    'alsacien': 'FR',
    'breton': 'FR',
    'bretonne': 'FR',
    'tex-mex': 'US',
    // Pays.
    'algerien': 'DZ',
    'allemand': 'DE',
    'americain': 'US',
    'anglais': 'GB',
    'argentin': 'AR',
    'australien': 'AU',
    'autrichien': 'AT',
    'belge': 'BE',
    'bresilien': 'BR',
    'britannique': 'GB',
    'canadien': 'CA',
    'chilien': 'CL',
    'chinois': 'CN',
    'colombien': 'CO',
    'coreen': 'KR',
    'cubain': 'CU',
    'danois': 'DK',
    'egyptien': 'EG',
    'espagnol': 'ES',
    'ethiopien': 'ET',
    'finlandais': 'FI',
    'francais': 'FR',
    'georgien': 'GE',
    'grec': 'GR',
    'grecque': 'GR',
    'hongrois': 'HU',
    'indien': 'IN',
    'indonesien': 'ID',
    'iranien': 'IR',
    'irlandais': 'IE',
    'israelien': 'IL',
    'italien': 'IT',
    'jamaicain': 'JM',
    'japonais': 'JP',
    'libanais': 'LB',
    'malaisien': 'MY',
    'marocain': 'MA',
    'mexicain': 'MX',
    'neerlandais': 'NL',
    'nepalais': 'NP',
    'norvegien': 'NO',
    'pakistanais': 'PK',
    'peruvien': 'PE',
    'philippin': 'PH',
    'polonais': 'PL',
    'portugais': 'PT',
    'russe': 'RU',
    'senegalais': 'SN',
    'suedois': 'SE',
    'suisse': 'CH',
    'syrien': 'SY',
    'thai': 'TH',
    'thailandais': 'TH',
    'tunisien': 'TN',
    'turc': 'TR',
    'turque': 'TR',
    'ukrainien': 'UA',
    'vietnamien': 'VN',
  };

  /// Emoji du drapeau de [origin], ou `null` si ce n'est pas un pays connu.
  /// Accepte le masculin et le féminin (« Italien », « italienne »).
  static String? of(String origin) {
    final key = TextNormalizer.normalize(origin);
    final code =
        _countries[key] ??
        (key.endsWith('enne')
            ? _countries[key.substring(0, key.length - 2)]
            : null) ??
        (key.endsWith('e')
            ? _countries[key.substring(0, key.length - 1)]
            : null);
    if (code == null) return null;
    // Deux symboles indicateurs régionaux forment le drapeau.
    return String.fromCharCodes(code.codeUnits.map((c) => 0x1F1E6 + c - 0x41));
  }

  /// Libellé précédé du drapeau quand il existe (« 🇮🇹 Italien »).
  static String label(String origin) {
    final flag = of(origin);
    return flag == null ? origin : '$flag $origin';
  }
}
