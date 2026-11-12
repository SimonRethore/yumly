import '../../../core/formatting/text_normalizer.dart';
import 'controlled_values.dart';
import 'recipe.dart';

/// Tranches de temps de cuisson, disjointes pour pouvoir être combinées
/// en OU.
enum CookTimeRange implements ControlledValue {
  sansCuisson('sans_cuisson', 'Sans cuisson', 0, 0),
  rapide('rapide', '15 min ou moins', 1, 15),
  moyen('moyen', '16 à 30 min', 16, 30),
  long('long', '31 à 60 min', 31, 60),
  tresLong('tres_long', 'Plus d’1 h', 61, null);

  const CookTimeRange(this.id, this.label, this.minMinutes, this.maxMinutes);

  @override
  final String id;
  @override
  final String label;
  final int minMinutes;
  final int? maxMinutes;

  bool contains(int minutes) =>
      minutes >= minMinutes && (maxMinutes == null || minutes <= maxMinutes!);

  static CookTimeRange of(int minutes) =>
      values.firstWhere((range) => range.contains(minutes));
}

/// Critères de recherche et de filtrage. Les valeurs d'une même famille se
/// combinent en OU, les familles entre elles en ET.
class RecipeFilters {
  const RecipeFilters({
    this.query = '',
    this.diets = const {},
    this.origins = const {},
    this.courses = const {},
    this.months = const {},
    this.seasons = const {},
    this.difficulties = const {},
    this.cookTimes = const {},
    this.statuses = const {},
  });

  final String query;
  final Set<DietType> diets;

  /// Origines telles qu'écrites dans le catalogue.
  final Set<String> origins;
  final Set<Course> courses;
  final Set<int> months;
  final Set<Season> seasons;
  final Set<Difficulty> difficulties;
  final Set<CookTimeRange> cookTimes;
  final Set<RecipeStatus> statuses;

  bool get hasActiveFilters =>
      diets.isNotEmpty ||
      origins.isNotEmpty ||
      courses.isNotEmpty ||
      months.isNotEmpty ||
      seasons.isNotEmpty ||
      difficulties.isNotEmpty ||
      cookTimes.isNotEmpty ||
      statuses.isNotEmpty;

  bool get isEmpty => !hasActiveFilters && query.trim().isEmpty;

  int get activeFilterCount =>
      diets.length +
      origins.length +
      courses.length +
      months.length +
      seasons.length +
      difficulties.length +
      cookTimes.length +
      statuses.length;

  RecipeFilters copyWith({
    String? query,
    Set<DietType>? diets,
    Set<String>? origins,
    Set<Course>? courses,
    Set<int>? months,
    Set<Season>? seasons,
    Set<Difficulty>? difficulties,
    Set<CookTimeRange>? cookTimes,
    Set<RecipeStatus>? statuses,
  }) => RecipeFilters(
    query: query ?? this.query,
    diets: diets ?? this.diets,
    origins: origins ?? this.origins,
    courses: courses ?? this.courses,
    months: months ?? this.months,
    seasons: seasons ?? this.seasons,
    difficulties: difficulties ?? this.difficulties,
    cookTimes: cookTimes ?? this.cookTimes,
    statuses: statuses ?? this.statuses,
  );

  /// Conserve la requête et retire tous les filtres.
  RecipeFilters clearFilters() => RecipeFilters(query: query);

  bool matches(Recipe recipe) {
    if (diets.isNotEmpty && !diets.any(recipe.dietTypes.contains)) {
      return false;
    }
    if (origins.isNotEmpty && !origins.contains(recipe.origin)) return false;
    if (courses.isNotEmpty && !courses.contains(recipe.course)) return false;
    if (months.isNotEmpty && !months.any(recipe.months.contains)) return false;
    if (seasons.isNotEmpty && !seasons.any(recipe.seasons.contains)) {
      return false;
    }
    if (difficulties.isNotEmpty && !difficulties.contains(recipe.difficulty)) {
      return false;
    }
    if (cookTimes.isNotEmpty &&
        !cookTimes.contains(CookTimeRange.of(recipe.cookTimeMinutes))) {
      return false;
    }
    if (statuses.isNotEmpty && !statuses.contains(recipe.status)) {
      return false;
    }
    return _matchesQuery(recipe);
  }

  bool _matchesQuery(Recipe recipe) {
    final tokens = TextNormalizer.tokens(query);
    if (tokens.isEmpty) return true;
    final haystack = TextNormalizer.normalize(
      [
        recipe.title,
        recipe.description ?? '',
        for (final ingredient in recipe.ingredients) ingredient.name,
      ].join(' '),
    );
    return tokens.every(haystack.contains);
  }

  /// Applique les critères au catalogue complet, en conservant l'ordre.
  List<Recipe> apply(List<Recipe> recipes) =>
      recipes.where(matches).toList(growable: false);
}

/// Options de filtres calculées à partir des valeurs présentes dans le
/// catalogue : une option sans recette n'est jamais proposée.
class FilterOptions {
  const FilterOptions({
    required this.diets,
    required this.origins,
    required this.courses,
    required this.months,
    required this.seasons,
    required this.difficulties,
    required this.cookTimes,
    required this.statuses,
  });

  factory FilterOptions.fromRecipes(List<Recipe> recipes) {
    final diets = <DietType>{};
    final origins = <String>{};
    final courses = <Course>{};
    final months = <int>{};
    final seasons = <Season>{};
    final difficulties = <Difficulty>{};
    final cookTimes = <CookTimeRange>{};
    final statuses = <RecipeStatus>{};
    for (final recipe in recipes) {
      diets.addAll(recipe.dietTypes);
      if (recipe.origin != null) origins.add(recipe.origin!);
      if (recipe.course != null) courses.add(recipe.course!);
      months.addAll(recipe.months);
      seasons.addAll(recipe.seasons);
      if (recipe.difficulty != null) difficulties.add(recipe.difficulty!);
      cookTimes.add(CookTimeRange.of(recipe.cookTimeMinutes));
      statuses.add(recipe.status);
    }

    List<T> inEnumOrder<T extends Enum>(Set<T> set) =>
        set.toList()..sort((a, b) => a.index.compareTo(b.index));

    return FilterOptions(
      diets: inEnumOrder(diets),
      origins: origins.toList()
        ..sort(
          (a, b) =>
              TextNormalizer.normalize(a)
                  .compareTo(TextNormalizer.normalize(b)),
        ),
      courses: inEnumOrder(courses),
      months: months.toList()..sort(),
      seasons: inEnumOrder(seasons),
      difficulties: inEnumOrder(difficulties),
      cookTimes: inEnumOrder(cookTimes),
      statuses: inEnumOrder(statuses),
    );
  }

  final List<DietType> diets;
  final List<String> origins;
  final List<Course> courses;
  final List<int> months;
  final List<Season> seasons;
  final List<Difficulty> difficulties;
  final List<CookTimeRange> cookTimes;
  final List<RecipeStatus> statuses;
}
