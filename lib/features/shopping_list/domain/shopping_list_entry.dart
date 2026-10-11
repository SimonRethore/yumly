import '../../recipes/domain/recipe.dart';

/// Recette prévue dans la liste active. Seuls l'identifiant et les portions
/// sont stockés : les ingrédients sont dérivés du catalogue.
class ShoppingListEntry {
  ShoppingListEntry({required this.recipeId, required int servings})
    : servings = ServingsLimits.clamp(servings);

  final String recipeId;
  final int servings;

  ShoppingListEntry withServings(int servings) =>
      ShoppingListEntry(recipeId: recipeId, servings: servings);

  Map<String, Object?> toJson() => {'recipeId': recipeId, 'servings': servings};

  /// Retourne `null` si l'objet persisté est invalide.
  static ShoppingListEntry? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final id = json['recipeId'];
    final servings = json['servings'];
    if (id is! String || id.isEmpty || servings is! int) return null;
    return ShoppingListEntry(recipeId: id, servings: servings);
  }

  @override
  bool operator ==(Object other) =>
      other is ShoppingListEntry &&
      other.recipeId == recipeId &&
      other.servings == servings;

  @override
  int get hashCode => Object.hash(recipeId, servings);
}
