import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../recipes/data/recipe_repository.dart';
import '../../recipes/domain/recipe.dart';

/// Identifiants des recettes favorites (persistés).
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends PersistedNotifier<Set<String>> {
  static const String key = 'favorites';

  @override
  String get storageKey => key;
  @override
  String get stateLabel => 'favoris';
  @override
  Set<String> get emptyState => const {};

  @override
  Set<String>? decode(Object? data) =>
      data is List<Object?> ? data.whereType<String>().toSet() : null;

  @override
  Object? encode(Set<String> value) => value.toList();

  @override
  Set<String> build() => restore();

  bool isFavorite(String recipeId) => state.contains(recipeId);

  /// Retourne le nouvel état (`true` si la recette est désormais favorite).
  bool toggle(String recipeId) {
    final next = {...state};
    final added = next.add(recipeId);
    if (!added) next.remove(recipeId);
    save(next);
    return added;
  }
}

/// Recettes favorites existant dans le catalogue, dans l'ordre du catalogue.
/// Les identifiants inconnus (recette retirée) sont ignorés.
final favoriteRecipesProvider = Provider<List<Recipe>>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  final ids = ref.watch(favoritesProvider);
  return catalog.recipes.where((r) => ids.contains(r.id)).toList();
});
