import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../recipes/data/recipe_repository.dart';
import '../data/shopping_list_repository.dart';
import '../domain/ingredient_aggregator.dart';
import '../domain/shopping_ingredient.dart';

/// Liste de courses — vue « Ingrédients à acheter », groupée par catégorie.
class ShoppingIngredientsScreen extends ConsumerWidget {
  const ShoppingIngredientsScreen({super.key});

  Future<void> _copy(
    BuildContext context,
    List<ShoppingIngredient> items,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      await Clipboard.setData(
        ClipboardData(text: IngredientAggregator.toClipboardText(items)),
      );
      message = 'Liste copiée dans le presse-papiers';
    } catch (_) {
      message = 'Impossible de copier la liste. Veuillez réessayer.';
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingIngredientsProvider);
    final checked = ref.watch(checkedIngredientsProvider);
    final catalogError = ref.watch(catalogProvider).error;
    final hasItems = items != null && items.isNotEmpty;
    final checkedCount = hasItems
        ? items.where((i) => checked.contains(i.key)).length
        : 0;
    // Seuls les produits restant à acheter sont copiés.
    final toBuy = hasItems
        ? items.where((i) => !checked.contains(i.key)).toList()
        : const <ShoppingIngredient>[];
    final VoidCallback? copy = toBuy.isEmpty
        ? null
        : () => _copy(context, toBuy);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingrédients à acheter'),
        actions: [
          if (hasItems)
            IconButton(
              tooltip: 'Copier la liste',
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: copy,
            ),
        ],
      ),
      body: switch (items) {
        _ when catalogError != null => const EmptyState(
          icon: Icons.error_outline,
          title: 'Impossible de charger les recettes',
        ),
        null => const Center(child: CircularProgressIndicator()),
        [] => EmptyState(
          icon: Icons.shopping_basket_outlined,
          title: 'Aucun ingrédient à acheter',
          message: 'Ajoutez des recettes à votre liste de courses.',
          actionLabel: 'Parcourir les recettes',
          onAction: () => context.go(AppRoutes.home),
        ),
        final items => Column(
          children: [
            Expanded(
              child: _GroupedList(items: items, checked: checked),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: checkedCount == 0
                            ? null
                            : ref
                                  .read(checkedIngredientsProvider.notifier)
                                  .uncheckAll,
                        child: const Text('Tout décocher'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: copy,
                        icon: const Icon(Icons.copy_all_outlined),
                        label: const Text('Copier la liste'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.items, required this.checked});

  final List<ShoppingIngredient> items;
  final Set<String> checked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groups = IngredientAggregator.groupByCategory(items);
    final done = items.where((i) => checked.contains(i.key)).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            '$done sur ${items.length} produits achetés',
            style: theme.textTheme.bodySmall,
          ),
        ),
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                group.category.label,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (final (index, item) in group.items.indexed) ...[
                  if (index > 0) const Divider(height: 1, indent: 56),
                  _IngredientTile(
                    item: item,
                    checked: checked.contains(item.key),
                    onToggle: () => ref
                        .read(checkedIngredientsProvider.notifier)
                        .toggle(item.key),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.item,
    required this.checked,
    required this.onToggle,
  });

  final ShoppingIngredient item;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = item.formattedQuantity;
    // Coché : case pleine + texte barré + couleur atténuée (pas seulement
    // la couleur).
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      decoration: checked ? TextDecoration.lineThrough : null,
      color: checked ? AppColors.texteSecondaire : null,
    );
    return CheckboxListTile(
      value: checked,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(item.name, style: textStyle)),
          if (quantity != null) ...[
            const SizedBox(width: 12),
            Text(
              quantity,
              style: textStyle?.copyWith(
                fontWeight: FontWeight.w600,
                color: checked
                    ? AppColors.texteSecondaire
                    : AppColors.vertForet,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
