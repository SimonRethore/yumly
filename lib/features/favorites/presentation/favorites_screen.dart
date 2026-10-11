import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../recipes/data/recipe_repository.dart';
import '../../recipes/presentation/recipe_card.dart';
import '../../shopping_list/presentation/shopping_list_button.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final favorites = ref.watch(favoriteRecipesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        actions: const [ShoppingListButton(), SizedBox(width: 4)],
      ),
      body: switch (catalog) {
        AsyncError(:final error) => CatalogErrorState(error: error),
        AsyncData() when favorites.isEmpty => EmptyState(
          icon: Icons.favorite_border,
          title: 'Aucun favori pour l’instant',
          message:
              'Touchez le cœur sur une recette pour la retrouver ici, '
              'même hors ligne.',
          actionLabel: 'Découvrir les recettes',
          onAction: () => context.go(AppRoutes.home),
        ),
        AsyncData() => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: favorites.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final recipe = favorites[index];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: RecipeCard(
                  recipe: recipe,
                  onTap: () => context.go(AppRoutes.favoriteDetail(recipe.id)),
                ),
              ),
            );
          },
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
