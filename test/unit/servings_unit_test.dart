import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/recipes/domain/servings_unit.dart';

void main() {
  const canneles = ServingsUnit(singular: 'cannelé', plural: 'cannelés');

  test('libellé accordé au singulier et au pluriel', () {
    expect(ServingsUnit.personnes.label(1), '1 personne');
    expect(ServingsUnit.personnes.label(4), '4 personnes');
    expect(canneles.label(1), '1 cannelé');
    expect(canneles.label(12), '12 cannelés');
  });

  test('infobulles et accessibilité selon l’unité', () {
    expect(ServingsUnit.personnes.increaseTooltip, 'Ajouter une personne');
    expect(ServingsUnit.personnes.decreaseTooltip, 'Retirer une personne');
    expect(canneles.increaseTooltip, 'Ajouter 1 cannelé');
    expect(canneles.decreaseTooltip, 'Retirer 1 cannelé');
    expect(canneles.semanticsLabel(12), 'Nombre de cannelés : 12');
  });
}
