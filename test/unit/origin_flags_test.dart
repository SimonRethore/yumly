import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/recipes/domain/origin_flags.dart';

void main() {
  group('OriginFlags', () {
    test('donne le drapeau des pays, au masculin comme au féminin', () {
      expect(OriginFlags.of('Italien'), '🇮🇹');
      expect(OriginFlags.of('Française'), '🇫🇷');
      expect(OriginFlags.of('indienne'), '🇮🇳');
      expect(OriginFlags.of('Grecque'), '🇬🇷');
    });

    test('rattache les régions à leur pays', () {
      expect(OriginFlags.of('Breton'), '🇫🇷');
      expect(OriginFlags.of('Bretonne'), '🇫🇷');
      expect(OriginFlags.of('Alsacien'), '🇫🇷');
      expect(OriginFlags.of('Tex-Mex'), '🇺🇸');
    });

    test('ignore les origines multi-pays', () {
      expect(OriginFlags.of('Maghrébin'), isNull);
    });

    test('préfixe le libellé uniquement quand le drapeau existe', () {
      expect(OriginFlags.label('Japonais'), '🇯🇵 Japonais');
      expect(OriginFlags.label('Maghrébin'), 'Maghrébin');
    });
  });
}
