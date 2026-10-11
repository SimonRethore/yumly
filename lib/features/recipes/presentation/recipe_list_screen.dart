import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/widgets/brand_title.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/recipe_image.dart';
import '../../shopping_list/presentation/shopping_list_button.dart';
import '../data/recipe_repository.dart';
import '../domain/recipe.dart';
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
    final chips = activeFilters(filters);

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
                  suffixIcon: filters.query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer la recherche',
                          icon: const Icon(Icons.close),
                          onPressed: () => notifier.setQuery(''),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => showRecipeFilterSheet(context),
                    icon: const Icon(Icons.tune),
                    label: Text(
                      filters.hasActiveFilters
                          ? 'Filtres (${filters.activeFilterCount})'
                          : 'Filtres',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recipes.length > 1
                          ? '${recipes.length} recettes'
                          : '${recipes.length} recette',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
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
        if (filters.isEmpty && seasonal.isNotEmpty)
          SliverToBoxAdapter(
            child: _SeasonalSection(recipes: seasonal, onOpen: _openRecipe),
          ),
        if (recipes.isEmpty)
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
              child: Text(
                filters.isEmpty ? 'Toutes les recettes' : 'Résultats',
                style: theme.textTheme.titleLarge,
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

/// Grille adaptative : une colonne sur téléphone, plus sur grand écran.
/// Les hauteurs restent libres pour supporter les grandes tailles de texte.
class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes, required this.onOpen});

  final List<Recipe> recipes;
  final ValueChanged<Recipe> onOpen;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.crossAxisExtent / 380).floor().clamp(1, 4);
        final rows = (recipes.length / columns).ceil();
        return SliverList.builder(
          itemCount: rows,
          itemBuilder: (context, row) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var col = 0; col < columns; col++) ...[
                  if (col > 0) const SizedBox(width: 16),
                  Expanded(
                    child: row * columns + col < recipes.length
                        ? RecipeCard(
                            recipe: recipes[row * columns + col],
                            onTap: () => onOpen(recipes[row * columns + col]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeasonalSection extends StatelessWidget {
  const _SeasonalSection({required this.recipes, required this.onOpen});

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
                const Icon(Icons.eco_outlined, color: AppColors.vertForet),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('De saison', style: theme.textTheme.titleLarge),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            // Image 16/10 sur 180 px + zone de texte qui suit la taille système.
            height: 113 + 24 + MediaQuery.textScalerOf(context).scale(66),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recipes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return SizedBox(
                  width: 180,
                  child: Card(
                    child: InkWell(
                      onTap: () => onOpen(recipe),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RecipeImage(
                            asset: recipe.imageAsset,
                            aspectRatio: 16 / 10,
                            iconSize: 32,
                          ),
                          // Zone de texte contrainte : le titre s'abrège
                          // plutôt que de déborder.
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      recipe.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RecipeMeta(
                                    icon: Icons.schedule,
                                    label: QuantityFormatter.formatDuration(
                                      recipe.totalTimeMinutes,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
