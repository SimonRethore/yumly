import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/favorites/presentation/favorites_screen.dart';
import '../features/recipes/presentation/recipe_detail_screen.dart';
import '../features/recipes/presentation/recipe_list_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shopping_list/presentation/shopping_ingredients_screen.dart';
import '../features/shopping_list/presentation/shopping_list_screen.dart';
import 'home_shell.dart';

/// Chemins de navigation. Chaque onglet a sa propre pile : la fiche d'une
/// recette s'ouvre dans l'onglet d'où elle est consultée, et le retour
/// système ramène à l'écran précédent sans perdre l'état.
abstract final class AppRoutes {
  static const String home = '/';
  static const String favorites = '/favoris';
  static const String shoppingList = '/courses';
  static const String shoppingIngredients = '/courses/ingredients';
  static const String settings = '/parametres';

  static String recipeDetail(String id) => '/recette/$id';
  static String favoriteDetail(String id) => '$favorites/recette/$id';
  static String shoppingRecipeDetail(String id) => '$shoppingList/recette/$id';
}

GoRoute _detailRoute(String path) => GoRoute(
  path: path,
  builder: (_, state) =>
      RecipeDetailScreen(recipeId: state.pathParameters['id']!),
);

GoRouter createRouter() => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, _) => const RecipeListScreen(),
              routes: [_detailRoute('recette/:id')],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (_, _) => const FavoritesScreen(),
              routes: [_detailRoute('recette/:id')],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.shoppingList,
              builder: (_, _) => const ShoppingListScreen(),
              routes: [
                GoRoute(
                  path: 'ingredients',
                  builder: (_, _) => const ShoppingIngredientsScreen(),
                ),
                _detailRoute('recette/:id'),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: TextButton(
        onPressed: () => context.go(AppRoutes.home),
        child: const Text('Page introuvable — retour à l’accueil'),
      ),
    ),
  ),
);
