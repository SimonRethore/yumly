import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/core/formatting/quantity_formatter.dart';
import 'package:yumly/core/formatting/text_normalizer.dart';
import 'package:yumly/features/recipes/domain/unit.dart';

const nbsp = QuantityFormatter.nbsp;

void main() {
  group('TextNormalizer', () {
    test('ignore la casse et les accents', () {
      expect(TextNormalizer.normalize('Crème BRÛLÉE'), 'creme brulee');
      expect(TextNormalizer.normalize('Œuf  à   la Coque '), 'oeuf a la coque');
      expect(TextNormalizer.normalize('Maïs'), 'mais');
    });

    test('découpe la requête en mots', () {
      expect(TextNormalizer.tokens('  Pâtes   crème '), ['pates', 'creme']);
      expect(TextNormalizer.tokens('   '), isEmpty);
    });
  });

  group('Conversions d’unités', () {
    test('kg ↔ g', () {
      expect(Unit.kg.toCanonical(1.2), 1200);
      expect(Unit.kg.fromCanonical(500), 0.5);
    });

    test('l ↔ ml et cl ↔ ml', () {
      expect(Unit.l.toCanonical(0.75), 750);
      expect(Unit.cl.toCanonical(20), 200);
      expect(Unit.cl.fromCanonical(150), 15);
    });

    test('les dimensions incompatibles restent distinctes', () {
      expect(Unit.g.dimension, isNot(Unit.ml.dimension));
      expect(Unit.piece.dimension, isNot(Unit.g.dimension));
      expect(Unit.cuillereASoupe.dimension, isNot(Unit.ml.dimension));
      expect(
        Unit.cuillereACafe.dimension,
        isNot(Unit.cuillereASoupe.dimension),
      );
    });

    test('identifiants JSON', () {
      expect(Unit.fromId('c_a_s'), Unit.cuillereASoupe);
      expect(Unit.fromId('tasse'), isNull);
    });
  });

  group('QuantityFormatter', () {
    test('nombres à la française sans zéros inutiles', () {
      expect(QuantityFormatter.formatNumber(2), '2');
      expect(QuantityFormatter.formatNumber(2.5), '2,5');
      expect(QuantityFormatter.formatNumber(1.333333), '1,33');
      expect(
        QuantityFormatter.formatNumber(12500, maxDecimals: 0),
        '12${nbsp}500',
      );
      expect(
        QuantityFormatter.formatNumber(1234567, maxDecimals: 0),
        '1${nbsp}234${nbsp}567',
      );
    });

    test('masses', () {
      expect(QuantityFormatter.format(250, Unit.g), '250${nbsp}g');
      expect(QuantityFormatter.format(1200, Unit.g), '1,2${nbsp}kg');
      expect(QuantityFormatter.format(0.5, Unit.kg), '500${nbsp}g');
      expect(QuantityFormatter.format(2.5, Unit.g), '2,5${nbsp}g');
      expect(QuantityFormatter.format(187.5, Unit.g), '188${nbsp}g');
      expect(QuantityFormatter.format(1.125, Unit.kg), '1,13${nbsp}kg');
    });

    test('volumes', () {
      expect(QuantityFormatter.format(400, Unit.ml), '400${nbsp}ml');
      expect(QuantityFormatter.format(1500, Unit.ml), '1,5${nbsp}l');
      expect(QuantityFormatter.format(20, Unit.cl), '20${nbsp}cl');
      expect(QuantityFormatter.format(0.75, Unit.l), '75${nbsp}cl');
      expect(QuantityFormatter.format(0.5, Unit.cl), '5${nbsp}ml');
    });

    test('pièces et unités de cuisine', () {
      expect(QuantityFormatter.format(1, Unit.piece), '1${nbsp}pièce');
      expect(QuantityFormatter.format(3, Unit.piece), '3${nbsp}pièces');
      expect(QuantityFormatter.format(2, Unit.pincee), '2${nbsp}pincées');
    });

    test('pluriel à partir de 2', () {
      expect(QuantityFormatter.format(1.5, Unit.piece), '1$nbsp½${nbsp}pièce');
      expect(QuantityFormatter.format(1.9, Unit.piece), '2${nbsp}pièces');
    });

    test('fractions usuelles pour pièces, cuillères et pincées', () {
      expect(
        QuantityFormatter.format(0.75, Unit.cuillereASoupe),
        '¾${nbsp}c. à s.',
      );
      expect(QuantityFormatter.format(1 / 3, Unit.piece), '⅓${nbsp}pièce');
      expect(
        QuantityFormatter.format(2 / 3, Unit.cuillereACafe),
        '⅔${nbsp}c. à c.',
      );
      expect(
        QuantityFormatter.format(2.5, Unit.pincee),
        '2$nbsp½${nbsp}pincées',
      );
      expect(QuantityFormatter.format(3.5, Unit.piece), '3$nbsp½${nbsp}pièces');
      // Une quantité non nulle n'est jamais affichée « 0 ».
      expect(QuantityFormatter.format(0.1, Unit.pincee), '¼${nbsp}pincée');
    });

    test('durées', () {
      expect(QuantityFormatter.formatDuration(45), '45${nbsp}min');
      expect(QuantityFormatter.formatDuration(60), '1${nbsp}h');
      expect(QuantityFormatter.formatDuration(75), '1${nbsp}h${nbsp}15');
      expect(QuantityFormatter.formatDuration(125), '2${nbsp}h${nbsp}05');
    });
  });
}
