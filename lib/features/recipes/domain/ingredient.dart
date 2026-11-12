import 'controlled_values.dart';
import 'unit.dart';

/// Ingrédient d'une recette, tel que défini dans le catalogue (immuable).
class Ingredient {
  const Ingredient({
    required this.ingredientId,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    this.quantityNote,
  });

  /// Identifiant canonique utilisé pour regrouper la liste de courses.
  final String ingredientId;
  final String name;
  final IngredientCategory category;

  /// Quantité de base pour `defaultServings` portions ; `null` si non
  /// définie (dans ce cas [unit] est aussi `null`).
  final double? quantity;
  final Unit? unit;

  /// Mention libre non numérique (« au goût »…), facultative.
  final String? quantityNote;

  bool get hasQuantity => quantity != null && unit != null;

  /// Quantité mise à l'échelle, calculée depuis la valeur d'origine.
  double? scaledQuantity(double coefficient) =>
      quantity == null ? null : quantity! * coefficient;
}
