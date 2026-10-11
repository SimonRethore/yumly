import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../recipes/data/recipe_repository.dart';
import '../domain/ingredient_aggregator.dart';
import '../domain/shopping_ingredient.dart';
import '../../recipes/domain/recipe.dart';
import '../domain/shopping_list_entry.dart';

/// Résultat d'un ajout à la liste active.
enum AddToListResult { added, updated, unchanged }

/// Liste active : recettes prévues et portions (persistée).
final shoppingListProvider =
    NotifierProvider<ShoppingListNotifier, List<ShoppingListEntry>>(
      ShoppingListNotifier.new,
    );

class ShoppingListNotifier extends PersistedNotifier<List<ShoppingListEntry>> {
  static const String key = 'shopping_list';

  @override
  String get storageKey => key;
  @override
  String get stateLabel => 'recettes de la liste de courses';
  @override
  List<ShoppingListEntry> get emptyState => const [];

  @override
  List<ShoppingListEntry>? decode(Object? data) {
    if (data is! List<Object?>) return null;
    final seen = <String>{};
    return [
      for (final item in data)
        if (ShoppingListEntry.fromJson(item) case final entry?)
          if (seen.add(entry.recipeId)) entry,
    ];
  }

  @override
  Object? encode(List<ShoppingListEntry> value) => [
    for (final entry in value) entry.toJson(),
  ];

  @override
  List<ShoppingListEntry> build() => restore();

  ShoppingListEntry? entryFor(String recipeId) {
    for (final entry in state) {
      if (entry.recipeId == recipeId) return entry;
    }
    return null;
  }

  /// Ajoute la recette, ou met à jour les portions de l'entrée existante
  /// (aucun doublon).
  AddToListResult addOrUpdate(String recipeId, int servings) {
    final existing = entryFor(recipeId);
    if (existing == null) {
      save([
        ...state,
        ShoppingListEntry(recipeId: recipeId, servings: servings),
      ]);
      return AddToListResult.added;
    }
    if (existing.servings == ServingsLimits.clamp(servings)) {
      return AddToListResult.unchanged;
    }
    setServings(recipeId, servings);
    return AddToListResult.updated;
  }

  void setServings(String recipeId, int servings) {
    save([
      for (final entry in state)
        entry.recipeId == recipeId ? entry.withServings(servings) : entry,
    ]);
  }

  void remove(String recipeId) {
    save([
      for (final entry in state)
        if (entry.recipeId != recipeId) entry,
    ]);
  }
}

/// Entrées de la liste dont la recette existe dans le catalogue.
final activeEntriesProvider = Provider<List<ShoppingListEntry>>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  return ref
      .watch(shoppingListProvider)
      .where((entry) => catalog.contains(entry.recipeId))
      .toList();
});

/// Ingrédients consolidés, dérivés du catalogue et de la liste active.
/// `null` tant que le catalogue n'est pas chargé.
final shoppingIngredientsProvider = Provider<List<ShoppingIngredient>?>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return null;
  return IngredientAggregator.aggregate(
    catalog,
    ref.watch(shoppingListProvider),
  );
});

/// Clés des ingrédients cochés (persistées séparément). Les clés orphelines
/// sont supprimées dès que la liste consolidée change.
final checkedIngredientsProvider =
    NotifierProvider<CheckedIngredientsNotifier, Set<String>>(
      CheckedIngredientsNotifier.new,
    );

class CheckedIngredientsNotifier extends PersistedNotifier<Set<String>> {
  static const String key = 'shopping_checked';

  @override
  String get storageKey => key;
  @override
  String get stateLabel => 'produits cochés';
  @override
  Set<String> get emptyState => const {};

  @override
  Set<String>? decode(Object? data) =>
      data is List<Object?> ? data.whereType<String>().toSet() : null;

  @override
  Object? encode(Set<String> value) => value.toList();

  @override
  Set<String> build() {
    ref.listen(shoppingIngredientsProvider, (_, next) {
      if (next != null) _prune(next);
    });
    final restored = restore();
    final current = ref.read(shoppingIngredientsProvider);
    if (current == null) return restored;
    final valid = {for (final item in current) item.key};
    return restored.intersection(valid);
  }

  void _prune(List<ShoppingIngredient> items) {
    final valid = {for (final item in items) item.key};
    final pruned = state.intersection(valid);
    if (pruned.length != state.length) save(pruned);
  }

  void toggle(String ingredientKey) {
    final next = {...state};
    if (!next.remove(ingredientKey)) next.add(ingredientKey);
    save(next);
  }

  void uncheckAll() => save(const {});
}
