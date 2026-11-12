import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/recipe_image.dart';
import '../../../core/widgets/servings_stepper.dart';
import '../../recipes/data/recipe_repository.dart';
import '../../recipes/domain/recipe.dart';
import '../data/shopping_list_repository.dart';
import '../domain/shopping_list_entry.dart';

/// Liste de courses — vue « Recettes sélectionnées ».
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final entries = ref.watch(activeEntriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Liste de courses')),
      body: switch (catalog) {
        AsyncError(:final error) => CatalogErrorState(error: error),
        AsyncData() when entries.isEmpty => EmptyState(
          icon: Icons.shopping_basket_outlined,
          title: 'Votre liste est vide',
          message:
              'Ajoutez des recettes depuis le catalogue : leurs ingrédients '
              'seront regroupés ici.',
          actionLabel: 'Parcourir les recettes',
          onAction: () => context.go(AppRoutes.home),
        ),
        AsyncData(:final value) => _EntriesView(
          catalog: value,
          entries: entries,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _EntriesView extends ConsumerWidget {
  const _EntriesView({required this.catalog, required this.entries});

  final Catalog catalog;
  final List<ShoppingListEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(
                  entries.length > 1
                      ? '${entries.length} recettes sélectionnées'
                      : '1 recette sélectionnée',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EntryTile(
                    recipe: catalog.byId(entry.recipeId)!,
                    entry: entry,
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.checklist),
                label: const Text('Voir les ingrédients à acheter'),
                onPressed: () => context.go(AppRoutes.shoppingIngredients),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.recipe, required this.entry});

  final Recipe recipe;
  final ShoppingListEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(shoppingListProvider.notifier);
    return Card(
      child: InkWell(
        onTap: () => context.go(AppRoutes.shoppingRecipeDetail(recipe.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: RecipeImage(
                    asset: recipe.imageAsset,
                    aspectRatio: 1,
                    iconSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              recipe.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Retirer « ${recipe.title} » de la liste',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.corailFonce,
                          ),
                          onPressed: () {
                            notifier.remove(recipe.id);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '« ${recipe.title} » retirée de la liste',
                                  ),
                                  action: SnackBarAction(
                                    label: 'Annuler',
                                    onPressed: () => notifier.addOrUpdate(
                                      entry.recipeId,
                                      entry.servings,
                                    ),
                                  ),
                                ),
                              );
                          },
                        ),
                      ],
                    ),
                    Text(
                      'Pour ${servingsLabel(entry.servings, recipe.servingsUnit)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    ServingsStepper(
                      compact: true,
                      unit: recipe.servingsUnit,
                      value: entry.servings,
                      onChanged: (value) =>
                          notifier.setServings(recipe.id, value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
