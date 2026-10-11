import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/core/formatting/quantity_formatter.dart';
import 'package:yumly/features/recipes/domain/controlled_values.dart';
import 'package:yumly/features/recipes/domain/unit.dart';
import 'package:yumly/features/shopping_list/domain/ingredient_aggregator.dart';
import 'package:yumly/features/shopping_list/domain/shopping_ingredient.dart';
import 'package:yumly/features/shopping_list/domain/shopping_list_entry.dart';

import '../helpers/fixtures.dart';

const nbsp = QuantityFormatter.nbsp;

void main() {
  final catalog = parseCatalog([
    recipeJson(
      'a',
      ingredients: [
        ing('farine', quantity: 0.5, unit: 'kg', name: 'Farine'),
        ing(
          'lait',
          quantity: 20,
          unit: 'cl',
          category: 'produits_laitiers_alternatives',
          name: 'Lait',
        ),
        ing(
          'oignon',
          quantity: 1,
          unit: 'piece',
          category: 'fruits_legumes',
          name: 'Oignon',
        ),
        ing('sel', category: 'epices_condiments', name: 'Sel'),
        ing('huile', quantity: 1, unit: 'c_a_s', name: 'Huile'),
      ],
    ),
    recipeJson(
      'b',
      overrides: {'defaultServings': 2},
      ingredients: [
        ing('farine', quantity: 350, unit: 'g', name: 'Farine T55'),
        ing(
          'lait',
          quantity: 300,
          unit: 'ml',
          category: 'produits_laitiers_alternatives',
          name: 'Lait',
        ),
        ing(
          'lait',
          quantity: 100,
          unit: 'g',
          category: 'produits_laitiers_alternatives',
          name: 'Lait',
        ),
        ing(
          'oignon-rouge',
          quantity: 1,
          unit: 'piece',
          category: 'fruits_legumes',
          name: 'Oignon',
        ),
        ing('sel', category: 'epices_condiments', name: 'Sel'),
        ing(
          'sel',
          quantity: 1,
          unit: 'pincee',
          category: 'epices_condiments',
          name: 'Sel',
        ),
        ing('huile', quantity: 15, unit: 'ml', name: 'Huile'),
      ],
    ),
  ]);

  ShoppingIngredient find(
    List<ShoppingIngredient> items,
    String id,
    UnitDimension? dim,
  ) => items.singleWhere((i) => i.key == ShoppingIngredient.keyFor(id, dim));

  test('met à l’échelle avec les portions de chaque entrée', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'a', servings: 8), // ×2
    ]);
    expect(find(items, 'farine', UnitDimension.mass).canonicalAmount, 1000);
    expect(find(items, 'oignon', UnitDimension.count).canonicalAmount, 2);
  });

  test(
    'fusionne même ingredientId et unités compatibles (kg + g, cl + ml)',
    () {
      final items = IngredientAggregator.aggregate(catalog, [
        ShoppingListEntry(recipeId: 'a', servings: 4), // ×1
        ShoppingListEntry(recipeId: 'b', servings: 4), // ×2
      ]);
      final farine = find(items, 'farine', UnitDimension.mass);
      expect(farine.canonicalAmount, 500 + 700);
      expect(farine.formattedQuantity, '1,2${nbsp}kg');
      expect(
        farine.name,
        'Farine',
        reason: 'libellé de la première occurrence',
      );

      final laitVolume = find(items, 'lait', UnitDimension.volume);
      expect(laitVolume.canonicalAmount, 200 + 600);
      expect(laitVolume.formattedQuantity, '80${nbsp}cl');
    },
  );

  test('ne fusionne jamais des dimensions incompatibles', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'a', servings: 4),
      ShoppingListEntry(recipeId: 'b', servings: 2),
    ]);
    expect(find(items, 'lait', UnitDimension.mass).canonicalAmount, 100);
    expect(find(items, 'lait', UnitDimension.volume).canonicalAmount, 500);
    // c. à s. et ml restent séparés : pas de conversion de cuillère.
    expect(find(items, 'huile', UnitDimension.tablespoon).canonicalAmount, 1);
    expect(find(items, 'huile', UnitDimension.volume).canonicalAmount, 15);
  });

  test('ne fusionne pas des identifiants différents au même libellé', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'a', servings: 4),
      ShoppingListEntry(recipeId: 'b', servings: 2),
    ]);
    expect(items.where((i) => i.name == 'Oignon'), hasLength(2));
  });

  test('ingrédients sans quantité : une ligne, sans valeur inventée', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'a', servings: 4),
      ShoppingListEntry(recipeId: 'b', servings: 2),
    ]);
    final sansQuantite = find(items, 'sel', null);
    expect(sansQuantite.hasQuantity, isFalse);
    expect(sansQuantite.formattedQuantity, isNull);
    expect(find(items, 'sel', UnitDimension.pinch).canonicalAmount, 1);
  });

  test('ignore les recettes absentes du catalogue', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'disparue', servings: 4),
    ]);
    expect(items, isEmpty);
  });

  test('regroupe par catégorie dans un ordre stable, sans catégorie vide', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'a', servings: 4),
    ]);
    final groups = IngredientAggregator.groupByCategory(items);
    expect(groups.map((g) => g.category), [
      IngredientCategory.fruitsLegumes,
      IngredientCategory.epicerieSeche,
      IngredientCategory.produitsLaitiers,
      IngredientCategory.epicesCondiments,
    ]);
    expect(groups[1].items.map((i) => i.name), ['Farine', 'Huile']);
  });

  test('génère le texte copié avec catégories et quantités', () {
    final items = IngredientAggregator.aggregate(catalog, [
      ShoppingListEntry(recipeId: 'a', servings: 4),
    ]);
    expect(
      IngredientAggregator.toClipboardText(items),
      'Liste de courses Yumly\n'
      '\n'
      'Fruits et légumes\n'
      '- Oignon : 1${nbsp}pièce\n'
      '\n'
      'Épicerie sèche\n'
      '- Farine : 500${nbsp}g\n'
      '- Huile : 1${nbsp}c. à s.\n'
      '\n'
      'Produits laitiers et alternatives végétales\n'
      '- Lait : 20${nbsp}cl\n'
      '\n'
      'Épices et condiments\n'
      '- Sel',
    );
  });

  test('portions bornées de 1 à 100', () {
    expect(ShoppingListEntry(recipeId: 'a', servings: 0).servings, 1);
    expect(ShoppingListEntry(recipeId: 'a', servings: 250).servings, 100);
  });

  test('calcul de portions depuis la quantité d’origine', () {
    final recipe = catalog.byId('b')!;
    final farine = recipe.ingredients.first;
    expect(farine.scaledQuantity(recipe.coefficientFor(3)), 525);
    expect(farine.scaledQuantity(recipe.coefficientFor(1)), 175);
    expect(farine.quantity, 350, reason: 'le catalogue n’est pas modifié');
  });
}
