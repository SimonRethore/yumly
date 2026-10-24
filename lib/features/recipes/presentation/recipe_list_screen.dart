import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/brand_title.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../shopping_list/presentation/shopping_list_button.dart';
import '../data/recipe_repository.dart';
import '../domain/controlled_values.dart';
import '../domain/recipe.dart';
import '../domain/recipe_filters.dart';
import 'recipe_card.dart';
import 'recipe_filter_sheet.dart';
import 'recipes_controller.dart';

/// Accueil : découverte et catalogue (recherche, filtres, cartes).
class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const BrandTitle(),
        actions: const [ShoppingListButton(), SizedBox(width: 4)],
      ),
      body: switch (catalog) {
        AsyncData(:final value) => _CatalogView(catalog: value),
        AsyncError(:final error) => CatalogErrorState(
          error: error,
          onRetry: () => ref.invalidate(catalogProvider),
        ),
        _ => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Chargement'),
        ),
      },
    );
  }
}

class _CatalogView extends ConsumerStatefulWidget {
  const _CatalogView({required this.catalog});

  final Catalog catalog;

  @override
  ConsumerState<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends ConsumerState<_CatalogView> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(recipeFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openRecipe(Recipe recipe) =>
      context.go(AppRoutes.recipeDetail(recipe.id));

  @override
  Widget build(BuildContext context) {
    // Garde le champ synchronisé si la requête est effacée ailleurs.
    ref.listen(recipeFiltersProvider.select((f) => f.query), (_, query) {
      if (_search.text != query) _search.text = query;
    });
    final theme = Theme.of(context);
    final filters = ref.watch(recipeFiltersProvider);
    final notifier = ref.read(recipeFiltersProvider.notifier);
    final recipes = ref.watch(filteredRecipesProvider);
    final seasonal = ref.watch(seasonalRecipesProvider);
    final toTest = ref.watch(toTestRecipesProvider);
    final quickCourse = _quickCourse(filters);
    // Le type de plat choisi par pastille rapide n'est pas répété plus bas.
    final chips = activeFilters(
      quickCourse == null ? filters : filters.copyWith(courses: {}),
    );

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverList.list(
            children: [
              Text(
                'Qu’est-ce qu’on cuisine aujourd’hui ?',
                style: theme.textTheme.headlineSmall,
              ),
              if (widget.catalog.isDemo) ...[
                const SizedBox(height: 8),
                const _DemoNotice(),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: notifier.setQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Rechercher une recette, un ingrédient…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filters.query.isNotEmpty)
                        IconButton(
                          tooltip: 'Effacer la recherche',
                          icon: const Icon(Icons.close),
                          onPressed: () => notifier.setQuery(''),
                        ),
                      IconButton(
                        tooltip: filters.hasActiveFilters
                            ? 'Filtres (${filters.activeFilterCount})'
                            : 'Filtres',
                        onPressed: () => showRecipeFilterSheet(context),
                        icon: Badge(
                          isLabelVisible: filters.hasActiveFilters,
                          label: Text('${filters.activeFilterCount}'),
                          child: const Icon(Icons.tune),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CourseChips(
                selected: quickCourse,
                hasOtherCourses:
                    quickCourse == null && filters.courses.isNotEmpty,
                onSelected: (course) =>
                    notifier.update((f) => f.copyWith(courses: {?course})),
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final chip in chips)
                      InputChip(
                        label: Text(chip.label),
                        selected: true,
                        showCheckmark: false,
                        onPressed: () => showRecipeFilterSheet(context),
                        deleteButtonTooltipMessage:
                            'Retirer le filtre ${chip.label}',
                        onDeleted: () => notifier.update(chip.remove),
                      ),
                    TextButton(
                      onPressed: notifier.clearFilters,
                      child: const Text('Réinitialiser les filtres'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (filters.query.trim().isEmpty && seasonal.isNotEmpty)
          SliverToBoxAdapter(
            child: RecipeCarousel(
              title: 'De saison',
              icon: Icons.eco_outlined,
              recipes: seasonal,
              onOpen: _openRecipe,
            ),
          ),
        if (filters.query.trim().isEmpty && toTest.isNotEmpty)
          SliverToBoxAdapter(
            child: RecipeCarousel(
              title: 'À tester',
              icon: Icons.explore_outlined,
              recipes: toTest,
              onOpen: _openRecipe,
            ),
          ),
        if (widget.catalog.recipes.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Aucune recette pour l’instant',
              message: 'Le catalogue est vide.',
            ),
          )
        else if (recipes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              title: 'Aucune recette ne correspond',
              message: 'Essayez une autre recherche ou retirez des filtres.',
              actionLabel: 'Effacer la recherche et les filtres',
              onAction: notifier.clearAll,
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      filters.isEmpty ? 'Toutes les recettes' : 'Résultats',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    recipes.length > 1
                        ? '${recipes.length} recettes'
                        : '${recipes.length} recette',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: _RecipeGrid(recipes: recipes, onOpen: _openRecipe),
          ),
        ],
      ],
    );
  }
}

/// Grille adaptative : deux colonnes sur téléphone, plus sur grand écran.
/// Les hauteurs restent libres pour supporter les grandes tailles de texte.
class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes, required this.onOpen});

  final List<Recipe> recipes;
  final ValueChanged<Recipe> onOpen;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.crossAxisExtent / 180).floor().clamp(2, 4);
        final rows = (recipes.length / columns).ceil();
        return SliverList.builder(
          itemCount: rows,
          itemBuilder: (context, row) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // Cartes d'une même rangée à la même hauteur.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (col > 0) const SizedBox(width: 12),
                    Expanded(
                      child: row * columns + col < recipes.length
                          ? RecipeCard(
                              recipe: recipes[row * columns + col],
                              onTap: () => onOpen(recipes[row * columns + col]),
                              imageAspectRatio: 4 / 3,
                              showActions: false,
                              showBadges: false,
                              compactTitle: true,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Types de plat proposés en pastilles rapides sous la recherche.
const _quickCourses = [Course.petitDejeuner, Course.plat, Course.dessert];

/// Type de plat choisi par pastille rapide, ou `null` si aucun filtre de type
/// ou une autre combinaison venant de la feuille de filtres.
Course? _quickCourse(RecipeFilters filters) =>
    filters.courses.length == 1 &&
        _quickCourses.contains(filters.courses.single)
    ? filters.courses.single
    : null;

/// Pastilles « Tout, Petit-déjeuner, Plat, Dessert » : un seul type à la fois.
class _CourseChips extends StatelessWidget {
  const _CourseChips({
    required this.selected,
    required this.hasOtherCourses,
    required this.onSelected,
  });

  final Course? selected;

  /// Types choisis dans la feuille de filtres : « Tout » n'est pas actif.
  final bool hasOtherCourses;
  final ValueChanged<Course?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Tout'),
            selected: selected == null && !hasOtherCourses,
            showCheckmark: false,
            onSelected: (_) => onSelected(null),
          ),
          for (final course in _quickCourses) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(course.label),
              selected: selected == course,
              showCheckmark: false,
              onSelected: (on) => onSelected(on ? course : null),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rubrique de l'accueil : titre et carrousel horizontal de cartes.
class RecipeCarousel extends StatelessWidget {
  const RecipeCarousel({
    super.key,
    required this.title,
    required this.icon,
    required this.recipes,
    required this.onOpen,
  });

  final String title;
  final IconData icon;
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: AppColors.vertForet),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Mêmes cartes que la grille ; la rangée prend la hauteur de la
          // plus grande carte, sans hauteur codée en dur.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, recipe) in recipes.indexed) ...[
                    if (index > 0) const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () => onOpen(recipe),
                        imageAspectRatio: 4 / 3,
                        showActions: false,
                        showBadges: false,
                        compactTitle: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.saugeClair,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.vertForet),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Catalogue de démonstration : recettes d’exemple fictives.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.vertForet),
            ),
          ),
        ],
      ),
    );
  }
}
