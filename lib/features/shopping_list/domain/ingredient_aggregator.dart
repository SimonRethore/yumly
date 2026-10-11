import '../../../core/formatting/text_normalizer.dart';
import '../../recipes/domain/controlled_values.dart';
import '../../recipes/domain/recipe.dart';
import 'shopping_ingredient.dart';
import 'shopping_list_entry.dart';

/// Consolide les ingrédients des recettes actives.
///
/// Règles : chaque ingrédient est d'abord mis à l'échelle avec les portions
/// de son entrée, puis fusionné uniquement si `ingredientId` et la dimension
/// d'unité sont identiques (g/kg ensemble, ml/cl/l ensemble). Les unités
/// incompatibles et les ingrédients sans quantité restent sur des lignes
/// distinctes ; aucun nom n'est utilisé pour fusionner.
abstract final class IngredientAggregator {
  static List<ShoppingIngredient> aggregate(
    Catalog catalog,
    List<ShoppingListEntry> entries,
  ) {
    final byKey = <String, ShoppingIngredient>{};
    for (final entry in entries) {
      final recipe = catalog.byId(entry.recipeId);
      if (recipe == null) continue;
      final coefficient = recipe.coefficientFor(entry.servings);
      for (final ingredient in recipe.ingredients) {
        final unit = ingredient.hasQuantity ? ingredient.unit : null;
        final key = ShoppingIngredient.keyFor(
          ingredient.ingredientId,
          unit?.dimension,
        );
        final existing =
            byKey[key] ??
            ShoppingIngredient(
              ingredientId: ingredient.ingredientId,
              name: ingredient.name,
              category: ingredient.category,
              dimension: unit?.dimension,
              preferredUnit: unit,
            );
        byKey[key] = unit == null
            ? existing
            : existing.addCanonical(
                unit.toCanonical(ingredient.scaledQuantity(coefficient)!),
              );
      }
    }
    final result = byKey.values.toList()..sort(_compare);
    return result;
  }

  static int _compare(ShoppingIngredient a, ShoppingIngredient b) {
    final byCategory = a.category.index.compareTo(b.category.index);
    if (byCategory != 0) return byCategory;
    final byName = TextNormalizer.normalize(a.name)
        .compareTo(TextNormalizer.normalize(b.name));
    if (byName != 0) return byName;
    return a.key.compareTo(b.key);
  }

  /// Regroupe par catégorie, dans l'ordre défini ; les catégories vides ne
  /// sont pas retournées.
  static List<ShoppingCategoryGroup> groupByCategory(
    List<ShoppingIngredient> items,
  ) {
    return [
      for (final category in IngredientCategory.values)
        if (items.any((item) => item.category == category))
          ShoppingCategoryGroup(
            category,
            items.where((item) => item.category == category).toList(),
          ),
    ];
  }

  /// Texte de la liste à copier : catégories en titres, ingrédients en
  /// puces. Tous les ingrédients sont inclus, cochés ou non.
  static String toClipboardText(List<ShoppingIngredient> items) {
    final buffer = StringBuffer('Liste de courses Yumly\n');
    for (final group in groupByCategory(items)) {
      buffer.write('\n${group.category.label}\n');
      for (final item in group.items) {
        final quantity = item.formattedQuantity;
        buffer.write(
          quantity == null
              ? '- ${item.name}\n'
              : '- ${item.name} : $quantity\n',
        );
      }
    }
    return buffer.toString().trimRight();
  }
}
