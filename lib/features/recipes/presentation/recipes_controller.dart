import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recipe_repository.dart';
import '../domain/controlled_values.dart';
import '../domain/recipe.dart';
import '../domain/recipe_filters.dart';
import '../domain/recipe_sort.dart';

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

/// Ordre d'affichage de la liste des recettes.
final recipeSortProvider = NotifierProvider<RecipeSortNotifier, RecipeSort>(
  RecipeSortNotifier.new,
);

class RecipeSortNotifier extends Notifier<RecipeSort> {
  @override
  RecipeSort build() => RecipeSort.alphabetique;

  void set(RecipeSort sort) => state = sort;
}

/// Ajoute ou retire [value] d'un ensemble (bascule d'une pastille).
Set<T> toggled<T>(Set<T> set, T value) =>
    set.contains(value) ? ({...set}..remove(value)) : {...set, value};

/// Options de filtres issues du catalogue chargé.
final filterOptionsProvider = Provider<FilterOptions?>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  return catalog == null ? null : FilterOptions.fromRecipes(catalog.recipes);
});

/// Recettes correspondant à la recherche et aux filtres, dans l'ordre choisi.
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  final recipes = ref.watch(recipeFiltersProvider).apply(catalog.recipes);
  return ref.watch(recipeSortProvider).apply(recipes);
});

/// Horloge injectable (section « De saison »).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Générateur aléatoire injectable (ordre des rubriques de l'accueil).
final randomProvider = Provider<Random>((ref) => Random());

/// Rang aléatoire de chaque recette, tiré une fois par lancement et par
/// rubrique : l'ordre d'une rubrique ne change pas quand on filtre, et deux
/// rubriques n'ont pas le même ordre.
final _carouselRanksProvider = Provider.family<Map<String, int>, String>((
  ref,
  carousel,
) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const {};
  final ids = [for (final recipe in catalog.recipes) recipe.id]
    ..shuffle(ref.watch(randomProvider));
  return {for (final (rank, id) in ids.indexed) id: rank};
});

/// Recettes de la rubrique [carousel] de l'accueil : celles qui passent les
/// filtres et [include] (la recherche texte n'est pas prise en compte : les
/// rubriques sont masquées pendant une recherche), dans l'ordre aléatoire du
/// lancement.
List<Recipe> _carouselRecipes(
  Ref ref,
  String carousel,
  bool Function(Recipe) include,
) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  final filters = ref.watch(recipeFiltersProvider).copyWith(query: '');
  final ranks = ref.watch(_carouselRanksProvider(carousel));
  return filters.apply(catalog.recipes).where(include).toList()
    ..sort((a, b) => ranks[a.id]!.compareTo(ranks[b.id]!));
}

/// Rubrique « De saison » : recettes dont les mois de saisonnalité incluent
/// le mois courant, hors recettes à revoir. Calculé uniquement à partir des
/// données du catalogue.
final seasonalRecipesProvider = Provider<List<Recipe>>((ref) {
  final month = ref.watch(clockProvider)().month;
  return _carouselRecipes(
    ref,
    'saison',
    (r) => r.months.contains(month) && r.status != RecipeStatus.aRevoir,
  );
});

/// Rubrique « À tester » : recettes pas encore réalisées.
final toTestRecipesProvider = Provider<List<Recipe>>(
  (ref) => _carouselRecipes(
    ref,
    'a_tester',
    (r) => r.status == RecipeStatus.aTester,
  ),
);
