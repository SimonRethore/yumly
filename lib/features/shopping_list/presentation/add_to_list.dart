import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/servings_stepper.dart';
import '../../recipes/domain/recipe.dart';
import '../data/shopping_list_repository.dart';

void _showSnack(BuildContext context, String message) {
  final router = GoRouter.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () => router.go(AppRoutes.shoppingList),
        ),
      ),
    );
}

/// Depuis la fiche : ajoute la recette avec les portions choisies, ou met à
/// jour les portions si elle est déjà dans la liste (pas de doublon).
void addRecipeWithServings(
  BuildContext context,
  WidgetRef ref,
  Recipe recipe,
  int servings,
) {
  final result = ref
      .read(shoppingListProvider.notifier)
      .addOrUpdate(recipe.id, servings);
  final label = servingsLabel(servings, recipe.servingsUnit);
  _showSnack(context, switch (result) {
    AddToListResult.added => 'Ajoutée à la liste de courses ($label)',
    AddToListResult.updated => 'Portions mises à jour : $label',
    AddToListResult.unchanged => 'Déjà dans la liste de courses ($label)',
  });
}

/// Depuis une carte : ajoute la recette avec ses portions par défaut. Si elle
/// est déjà présente, ses portions sont conservées (aucun nombre n'a été
/// choisi sur la carte).
void addRecipeFromCard(BuildContext context, WidgetRef ref, Recipe recipe) {
  final existing = ref.read(shoppingListProvider.notifier).entryFor(recipe.id);
  if (existing != null) {
    _showSnack(
      context,
      'Déjà dans la liste de courses (${servingsLabel(existing.servings, recipe.servingsUnit)})',
    );
    return;
  }
  addRecipeWithServings(context, ref, recipe, recipe.defaultServings);
}
