import 'controlled_values.dart';
import 'ingredient.dart';
import 'recipe_step.dart';

/// Nombre de personnes autorisé pour une recette ou une entrée de liste.
abstract final class ServingsLimits {
  static const int min = 1;
  static const int max = 100;

  static int clamp(int value) => value.clamp(min, max);
}

/// Recette du catalogue intégré. Les instances sont immuables : les
/// quantités affichées sont toujours dérivées, jamais réécrites.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.defaultServings,
    required this.ingredients,
    required this.steps,
    this.description,
    this.imageAsset,
    this.dietTypes = const {},
    this.origin,
    this.course,
    this.seasons = const {},
    this.months = const {},
    this.difficulty,
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.restTimeMinutes = 0,
    this.equipment = const [],
    this.sourceUrl,
    this.done = true,
  });

  final String id;
  final String title;
  final String? description;
  final String? imageAsset;
  final Set<DietType> dietTypes;
  final String? origin;
  final Course? course;
  final Set<Season> seasons;
  final Set<int> months;
  final Difficulty? difficulty;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int restTimeMinutes;
  final int defaultServings;
  final List<Ingredient> ingredients;

  /// Étapes triées par `order` au chargement.
  final List<RecipeStep> steps;
  final List<String> equipment;

  /// Lien vers la recette d'origine (http ou https).
  final String? sourceUrl;

  /// Recette déjà réalisée (vrai par défaut).
  final bool done;

  int get totalTimeMinutes =>
      prepTimeMinutes + cookTimeMinutes + restTimeMinutes;

  /// Coefficient de mise à l'échelle pour [servings] personnes.
  double coefficientFor(int servings) => servings / defaultServings;

  Recipe copyWithImage(String? imageAsset) => Recipe(
    id: id,
    title: title,
    description: description,
    imageAsset: imageAsset,
    dietTypes: dietTypes,
    origin: origin,
    course: course,
    seasons: seasons,
    months: months,
    difficulty: difficulty,
    prepTimeMinutes: prepTimeMinutes,
    cookTimeMinutes: cookTimeMinutes,
    restTimeMinutes: restTimeMinutes,
    defaultServings: defaultServings,
    ingredients: ingredients,
    steps: steps,
    equipment: equipment,
    sourceUrl: sourceUrl,
    done: done,
  );
}

/// Catalogue chargé et validé.
class Catalog {
  Catalog({
    required this.schemaVersion,
    required List<Recipe> recipes,
    this.isDemo = false,
  }) : recipes = List.unmodifiable(recipes),
       _byId = {for (final recipe in recipes) recipe.id: recipe};

  final int schemaVersion;

  /// Vrai pour le catalogue de démonstration (données fictives).
  final bool isDemo;
  final List<Recipe> recipes;
  final Map<String, Recipe> _byId;

  Recipe? byId(String id) => _byId[id];

  bool contains(String id) => _byId.containsKey(id);
}
