import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../data/shopping_list_repository.dart';

/// Accès à la liste de courses depuis la barre d'application, avec le
/// nombre de recettes sélectionnées.
class ShoppingListButton extends ConsumerWidget {
  const ShoppingListButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(activeEntriesProvider.select((e) => e.length));
    return IconButton(
      tooltip: count == 0
          ? 'Liste de courses (vide)'
          : 'Liste de courses ($count ${count > 1 ? 'recettes' : 'recette'})',
      onPressed: () => context.go(AppRoutes.shoppingList),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_basket_outlined),
      ),
    );
  }
}
