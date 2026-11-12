import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/recipes/data/catalog_parser.dart';
import 'package:yumly/features/recipes/domain/controlled_values.dart';
import 'package:yumly/features/recipes/domain/servings_unit.dart';
import 'package:yumly/features/recipes/domain/unit.dart';

import '../helpers/demo_catalog.dart';
import '../helpers/fixtures.dart';

void main() {
  const parser = CatalogParser();

  Matcher throwsCatalogError(String fragment) => throwsA(
    isA<CatalogException>().having(
      (e) => e.errors.join('\n'),
      'errors',
      contains(fragment),
    ),
  );

  test('désérialise un catalogue valide', () {
    final source = catalogSource([
      recipeJson(
        'curry',
        overrides: {
          'description': 'Parfumé',
          'dietTypes': ['vegan', 'vegetarian'],
          'origin': 'Indien',
          'course': 'plat',
          'seasons': ['automne'],
          'months': [10, 11],
          'difficulty': 'facile',
          'prepTimeMinutes': 15,
          'cookTimeMinutes': 30,
          'restTimeMinutes': 5,
          'steps': [
            {'order': 2, 'text': 'Cuire.'},
            {'order': 1, 'text': 'Couper.'},
          ],
          'equipment': ['Casserole'],
          'sourceUrl': 'https://example.com/curry',
        },
        ingredients: [
          ing('lentilles', quantity: 250, unit: 'g'),
          ing('sel', category: 'epices_condiments'),
        ],
      ),
    ]);
    final recipe = parser.parse(source).catalog.recipes.single;
    expect(recipe.title, 'Recette curry');
    expect(recipe.dietTypes, {DietType.vegan, DietType.vegetarian});
    expect(recipe.course, Course.plat);
    expect(recipe.seasons, {Season.automne});
    expect(recipe.difficulty, Difficulty.facile);
    expect(recipe.totalTimeMinutes, 50);
    expect(recipe.steps.map((s) => s.text), ['Couper.', 'Cuire.']);
    expect(recipe.ingredients.first.unit, Unit.g);
    expect(recipe.ingredients.last.hasQuantity, isFalse);
    expect(recipe.equipment, ['Casserole']);
    expect(recipe.sourceUrl, 'https://example.com/curry');
    expect(recipe.status, RecipeStatus.realisee);
  });

  test('portions en personnes par défaut, ou en pièces si précisé', () {
    final source = catalogSource([
      recipeJson('curry'),
      recipeJson(
        'canneles',
        overrides: {
          'defaultServings': 12,
          'servingsUnit': {'singular': 'cannelé', 'plural': 'cannelés'},
        },
      ),
    ]);
    final recipes = parser.parse(source).catalog.recipes;
    expect(recipes.first.servingsUnit, ServingsUnit.personnes);
    expect(
      recipes.last.servingsUnit,
      const ServingsUnit(singular: 'cannelé', plural: 'cannelés'),
    );
  });

  test('rejette une unité de portion incomplète', () {
    final source = catalogSource([
      recipeJson(
        'canneles',
        overrides: {
          'servingsUnit': {'singular': 'cannelé'},
        },
      ),
    ]);
    expect(
      () => parser.parse(source),
      throwsCatalogError('« servingsUnit » doit être un objet'),
    );
  });

  test('« status » lu si précisé', () {
    for (final status in RecipeStatus.values) {
      final source = catalogSource([
        recipeJson('curry', overrides: {'status': status.id}),
      ]);
      expect(parser.parse(source).catalog.recipes.single.status, status);
    }
  });

  test('rejette un « status » inconnu', () {
    final source = catalogSource([
      recipeJson('curry', overrides: {'status': 'oui'}),
    ]);
    expect(
      () => parser.parse(source),
      throwsCatalogError('valeur inconnue pour « status » : oui.'),
    );
  });

  test('rejette un lien source qui n’est pas une adresse http(s)', () {
    final source = catalogSource([
      recipeJson('curry', overrides: {'sourceUrl': 'example.com/curry'}),
    ]);
    expect(
      () => parser.parse(source),
      throwsCatalogError('« sourceUrl » doit être une adresse http ou https.'),
    );
  });

  test('le catalogue intégré est valide', () {
    final source = File('assets/data/recipes.json').readAsStringSync();
    final result = parser.parse(source);
    expect(result.catalog.recipes, hasLength(69));
    expect(result.catalog.isDemo, isFalse);
    expect(result.warnings, isEmpty);
  });

  test('le catalogue de démonstration est valide', () {
    final result = parser.parse(demoCatalogJson);
    expect(result.catalog.recipes, hasLength(8));
    expect(result.catalog.isDemo, isTrue);
    expect(result.warnings, isEmpty);
  });

  test('rejette un JSON mal formé', () {
    expect(() => parser.parse('{'), throwsCatalogError('JSON mal formé'));
  });

  test('rejette une version de schéma inconnue', () {
    expect(
      () => parser.parse(catalogSource([], version: 2)),
      throwsCatalogError('Version de schéma non prise en charge'),
    );
  });

  test('rejette un schéma sans champs requis', () {
    expect(
      () => parser.parse(
        catalogSource([
          {'id': 'x', 'steps': [], 'ingredients': []},
        ]),
      ),
      throwsCatalogError('« title » est obligatoire'),
    );
  });

  test('détecte les identifiants dupliqués', () {
    expect(
      () => parser.parse(catalogSource([recipeJson('a'), recipeJson('a')])),
      throwsCatalogError('Identifiant de recette dupliqué : « a »'),
    );
  });

  test('rejette les valeurs contrôlées inconnues', () {
    expect(
      () => parser.parse(
        catalogSource([
          recipeJson('a', overrides: {'course': 'goûter'}),
        ]),
      ),
      throwsCatalogError('valeur inconnue pour « course »'),
    );
    expect(
      () => parser.parse(
        catalogSource([
          recipeJson('a', ingredients: [ing('x', quantity: 1, unit: 'tasse')]),
        ]),
      ),
      throwsCatalogError('valeur inconnue pour « unit »'),
    );
  });

  test('rejette portions, mois et étapes incohérents', () {
    expect(
      () => parser.parse(
        catalogSource([
          recipeJson('a', overrides: {'defaultServings': 0}),
        ]),
      ),
      throwsCatalogError('« defaultServings » doit être un entier ≥ 1'),
    );
    expect(
      () => parser.parse(
        catalogSource([
          recipeJson(
            'a',
            overrides: {
              'months': [13],
            },
          ),
        ]),
      ),
      throwsCatalogError('entiers de 1 à 12'),
    );
    expect(
      () => parser.parse(
        catalogSource([
          recipeJson(
            'a',
            overrides: {
              'steps': [
                {'order': 1, 'text': 'A'},
                {'order': 1, 'text': 'B'},
              ],
            },
          ),
        ]),
      ),
      throwsCatalogError('ordre d’étape dupliqué'),
    );
  });

  test('exige une unité pour une quantité numérique', () {
    expect(
      () => parser.parse(
        catalogSource([
          recipeJson('a', ingredients: [ing('x', quantity: 2)]),
        ]),
      ),
      throwsCatalogError('« unit » est obligatoire'),
    );
  });

  test('remplace une image absente par le placeholder avec avertissement', () {
    final result = parser.parse(
      catalogSource([
        recipeJson('a', overrides: {'imageAsset': 'assets/recipes/a.jpg'}),
        recipeJson('b', overrides: {'imageAsset': 'assets/recipes/b.jpg'}),
      ]),
      availableAssets: {'assets/recipes/b.jpg'},
    );
    expect(result.catalog.byId('a')!.imageAsset, isNull);
    expect(result.catalog.byId('b')!.imageAsset, 'assets/recipes/b.jpg');
    expect(result.warnings.single, contains('assets/recipes/a.jpg'));
  });

  test('signale les libellés incohérents pour un même ingredientId', () {
    final result = parser.parse(
      catalogSource([
        recipeJson('a', ingredients: [ing('oignon', name: 'Oignon')]),
        recipeJson('b', ingredients: [ing('oignon', name: 'Oignon jaune')]),
      ]),
    );
    expect(result.warnings.single, contains('libellés différents'));
  });
}
