import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recipe_repository.dart';
import '../domain/recipe.dart';
import '../domain/recipe_filters.dart';

/// Requête de recherche et filtres actifs du catalogue.
final recipeFiltersProvider =
    NotifierProvider<RecipeFiltersNotifier, RecipeFilters>(
      RecipeFiltersNotifier.new,
    );

class RecipeFiltersNotifier extends Notifier<RecipeFilters> {
  @override
  RecipeFilters build() => const RecipeFilters();

  void setQuery(String query) => state = state.copyWith(query: query);

  void update(RecipeFilters Function(RecipeFilters current) change) =>
      state = change(state);

  void clearFilters() => state = state.clearFilters();

  void clearAll() => state = const RecipeFilters();
}

/// Ajoute ou retire [value] d'un ensemble (bascule d'une pastille).
Set<T> toggled<T>(Set<T> set, T value) =>
    set.contains(value) ? ({...set}..remove(value)) : {...set, value};

/// Options de filtres issues du catalogue chargé.
final filterOptionsProvider = Provider<FilterOptions?>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  return catalog == null ? null : FilterOptions.fromRecipes(catalog.recipes);
});

/// Recettes correspondant à la recherche et aux filtres.
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  return ref.watch(recipeFiltersProvider).apply(catalog.recipes);
});

/// Horloge injectable (section « De saison »).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Recettes dont les mois de saisonnalité incluent le mois courant. Calculé
/// uniquement à partir des données du catalogue.
final seasonalRecipesProvider = Provider<List<Recipe>>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  final month = ref.watch(clockProvider)().month;
  return catalog.recipes.where((r) => r.months.contains(month)).toList();
});
