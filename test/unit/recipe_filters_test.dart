import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/recipes/domain/controlled_values.dart';
import 'package:yumly/features/recipes/domain/recipe_filters.dart';

import '../helpers/fixtures.dart';

void main() {
  final catalog = parseCatalog([
    recipeJson(
      'curry',
      overrides: {
        'title': 'Curry de lentilles',
        'dietTypes': ['vegan', 'vegetarian'],
        'origin': 'Indien',
        'course': 'plat',
        'seasons': ['automne', 'hiver'],
        'months': [10, 11],
        'difficulty': 'facile',
        'cookTimeMinutes': 30,
      },
      ingredients: [ing('lait-coco', name: 'Lait de coco')],
    ),
    recipeJson(
      'chili',
      overrides: {
        'title': 'Chili sin carne',
        'dietTypes': ['vegan'],
        'origin': 'Mexicain',
        'course': 'plat',
        'months': [1],
        'difficulty': 'moyen',
        'cookTimeMinutes': 45,
      },
    ),
    recipeJson(
      'flan',
      overrides: {
        'title': 'Flan pâtissier',
        'description': 'À la crème vanillée',
        'dietTypes': ['vegetarian'],
        'origin': 'Français',
        'course': 'dessert',
        'seasons': ['ete'],
        'months': [7],
        'difficulty': 'difficile',
        'cookTimeMinutes': 0,
      },
    ),
    recipeJson(
      'churros',
      overrides: {
        'title': 'Churros',
        'origin': 'Mexicain',
        'course': 'dessert',
        'cookTimeMinutes': 10,
      },
    ),
  ]);

  List<String> ids(RecipeFilters filters) =>
      filters.apply(catalog.recipes).map((r) => r.id).toList();

  group('Recherche', () {
    test('insensible à la casse et aux accents', () {
      expect(ids(const RecipeFilters(query: 'CREME')), ['flan']);
      expect(ids(const RecipeFilters(query: 'patissier')), ['flan']);
    });

    test('cherche aussi dans les ingrédients', () {
      expect(ids(const RecipeFilters(query: 'coco')), ['curry']);
    });

    test('tous les mots doivent correspondre', () {
      expect(ids(const RecipeFilters(query: 'chili carne')), ['chili']);
      expect(ids(const RecipeFilters(query: 'chili flan')), isEmpty);
    });

    test('une requête vide retourne tout le catalogue', () {
      expect(ids(const RecipeFilters(query: '  ')), hasLength(4));
    });
  });

  group('Combinaison des filtres', () {
    test('OU dans une même famille', () {
      expect(ids(const RecipeFilters(origins: {'Indien', 'Mexicain'})), [
        'curry',
        'chili',
        'churros',
      ]);
    });

    test('ET entre familles', () {
      expect(
        ids(
          const RecipeFilters(
            origins: {'Indien', 'Mexicain'},
            diets: {DietType.vegan},
            courses: {Course.dessert},
          ),
        ),
        isEmpty,
      );
      expect(
        ids(
          const RecipeFilters(origins: {'Mexicain'}, courses: {Course.dessert}),
        ),
        ['churros'],
      );
    });

    test('régime, mois, saison, difficulté, cuisson', () {
      expect(ids(const RecipeFilters(diets: {DietType.vegetarian})), [
        'curry',
        'flan',
      ]);
      expect(ids(const RecipeFilters(months: {1, 7})), ['chili', 'flan']);
      expect(ids(const RecipeFilters(seasons: {Season.hiver})), ['curry']);
      expect(ids(const RecipeFilters(difficulties: {Difficulty.moyen})), [
        'chili',
      ]);
      expect(
        ids(
          const RecipeFilters(
            cookTimes: {CookTimeRange.sansCuisson, CookTimeRange.rapide},
          ),
        ),
        ['flan', 'churros'],
      );
    });

    test('filtres et recherche se combinent', () {
      expect(ids(const RecipeFilters(query: 'chur', origins: {'Mexicain'})), [
        'churros',
      ]);
    });

    test('effacer les filtres conserve la requête', () {
      const filters = RecipeFilters(query: 'x', origins: {'Indien'});
      final cleared = filters.clearFilters();
      expect(cleared.query, 'x');
      expect(cleared.hasActiveFilters, isFalse);
    });
  });

  test('options générées depuis le catalogue, triées et sans valeur vide', () {
    final options = FilterOptions.fromRecipes(catalog.recipes);
    expect(options.origins, ['Français', 'Indien', 'Mexicain']);
    expect(options.diets, [DietType.vegetarian, DietType.vegan]);
    expect(options.courses, [Course.plat, Course.dessert]);
    expect(options.months, [1, 7, 10, 11]);
    expect(options.seasons, [Season.ete, Season.automne, Season.hiver]);
    expect(options.difficulties, [
      Difficulty.facile,
      Difficulty.moyen,
      Difficulty.difficile,
    ]);
    expect(options.cookTimes, [
      CookTimeRange.sansCuisson,
      CookTimeRange.rapide,
      CookTimeRange.moyen,
      CookTimeRange.long,
    ]);
  });

  test('tranches de cuisson', () {
    expect(CookTimeRange.of(0), CookTimeRange.sansCuisson);
    expect(CookTimeRange.of(15), CookTimeRange.rapide);
    expect(CookTimeRange.of(16), CookTimeRange.moyen);
    expect(CookTimeRange.of(60), CookTimeRange.long);
    expect(CookTimeRange.of(61), CookTimeRange.tresLong);
  });
}
