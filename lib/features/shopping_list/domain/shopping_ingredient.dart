import '../../../core/formatting/quantity_formatter.dart';
import '../../recipes/domain/controlled_values.dart';
import '../../recipes/domain/unit.dart';

/// Ligne consolidée de la liste de courses.
class ShoppingIngredient {
  const ShoppingIngredient({
    required this.ingredientId,
    required this.name,
    required this.category,
    this.dimension,
    this.canonicalAmount,
    this.preferredUnit,
  });

  final String ingredientId;

  /// Libellé canonique (première occurrence dans la liste active).
  final String name;
  final IngredientCategory category;

  /// `null` pour un ingrédient sans quantité.
  final UnitDimension? dimension;

  /// Total exprimé dans l'unité canonique de [dimension] (g, ml…).
  final double? canonicalAmount;

  /// Unité de la première occurrence, utilisée pour choisir l'affichage.
  final Unit? preferredUnit;

  /// Clé stable : identifiant d'ingrédient + dimension d'unité. Sert au
  /// regroupement et à l'état coché.
  String get key => keyFor(ingredientId, dimension);

  static String keyFor(String ingredientId, UnitDimension? dimension) =>
      '$ingredientId|${dimension?.name ?? 'sans_quantite'}';

  bool get hasQuantity => canonicalAmount != null && preferredUnit != null;

  /// Quantité formatée (« 1,2 kg ») ou `null` sans quantité.
  String? get formattedQuantity {
    if (!hasQuantity) return null;
    final unit = preferredUnit!;
    return QuantityFormatter.format(unit.fromCanonical(canonicalAmount!), unit);
  }

  ShoppingIngredient addCanonical(double amount) => ShoppingIngredient(
    ingredientId: ingredientId,
    name: name,
    category: category,
    dimension: dimension,
    canonicalAmount: (canonicalAmount ?? 0) + amount,
    preferredUnit: preferredUnit,
  );
}

/// Ingrédients d'une catégorie, pour l'affichage groupé.
class ShoppingCategoryGroup {
  const ShoppingCategoryGroup(this.category, this.items);

  final IngredientCategory category;
  final List<ShoppingIngredient> items;
}
