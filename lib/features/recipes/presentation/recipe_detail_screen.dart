import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/recipe_image.dart';
import '../../../core/widgets/servings_stepper.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../../shopping_list/data/shopping_list_repository.dart';
import '../../shopping_list/presentation/add_to_list.dart';
import '../../shopping_list/presentation/shopping_list_button.dart';
import '../data/recipe_repository.dart';
import '../domain/controlled_values.dart';
import '../domain/ingredient.dart';
import '../domain/origin_flags.dart';
import '../domain/recipe.dart';
import 'recipe_card.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return switch (catalog) {
      AsyncData(:final value) => switch (value.byId(recipeId)) {
        final recipe? => _RecipeDetail(recipe: recipe),
        null => Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.no_food_outlined,
            title: 'Recette introuvable',
            message: 'Cette recette n’est plus disponible dans le catalogue.',
            actionLabel: 'Retour',
            onAction: () => Navigator.of(context).maybePop(),
          ),
        ),
      },
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: CatalogErrorState(error: error),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _RecipeDetail extends ConsumerStatefulWidget {
  const _RecipeDetail({required this.recipe});

  final Recipe recipe;

  @override
  ConsumerState<_RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends ConsumerState<_RecipeDetail> {
  /// Portions affichées sur la fiche : n'affectent jamais le catalogue.
  /// Si la recette est déjà dans la liste, on part de ses portions pour ne
  /// pas les écraser par mégarde en l'ajoutant de nouveau.
  late int _servings =
      ref
          .read(shoppingListProvider.notifier)
          .entryFor(widget.recipe.id)
          ?.servings ??
      widget.recipe.defaultServings;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final theme = Theme.of(context);
    final coefficient = recipe.coefficientFor(_servings);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: AppColors.creme,
            foregroundColor: AppColors.vertForet,
            leading: Navigator.of(context).canPop()
                ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.blanc.withValues(
                          alpha: 0.92,
                        ),
                      ),
                      tooltip: 'Retour',
                      icon: const BackButtonIcon(),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  )
                : null,
            actions: [
              FavoriteButton(
                recipeId: recipe.id,
                recipeTitle: recipe.title,
                onImage: true,
              ),
              const SizedBox(width: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.blanc.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: const ShoppingListButton(),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeImage(
                asset: recipe.imageAsset,
                aspectRatio: null,
                iconSize: 72,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                Text(recipe.title, style: theme.textTheme.headlineMedium),
                if (recipe.description != null) ...[
                  const SizedBox(height: 8),
                  Text(recipe.description!, style: theme.textTheme.bodyLarge),
                ],
                const SizedBox(height: 16),
                _Criteria(recipe: recipe),
                const SizedBox(height: 20),
                _Durations(recipe: recipe),
                const SizedBox(height: 28),
                _SectionTitle('Ingrédients'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ServingsStepper(
                      value: _servings,
                      onChanged: (value) => setState(
                        () => _servings = ServingsLimits.clamp(value),
                      ),
                    ),
                    if (_servings != recipe.defaultServings)
                      TextButton(
                        onPressed: () =>
                            setState(() => _servings = recipe.defaultServings),
                        child: Text(
                          'Revenir à ${servingsLabel(recipe.defaultServings)}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final ingredient in recipe.ingredients)
                  _IngredientRow(
                    ingredient: ingredient,
                    coefficient: coefficient,
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        addRecipeWithServings(context, ref, recipe, _servings),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Ajouter à la liste de courses'),
                  ),
                ),
                const SizedBox(height: 28),
                _SectionTitle('Préparation'),
                const SizedBox(height: 12),
                for (final (index, step) in recipe.steps.indexed)
                  _StepRow(number: index + 1, text: step.text),
                if (recipe.equipment.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle('Équipements'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in recipe.equipment)
                        Chip(
                          avatar: const Icon(
                            Icons.kitchen_outlined,
                            size: 18,
                            color: AppColors.vertForet,
                          ),
                          label: Text(item),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

/// Origine, régime, type de plat, saisons, mois et difficulté.
class _Criteria extends StatelessWidget {
  const _Criteria({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final months = recipe.months.toList()..sort();
    final seasons = recipe.seasons.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final origin = recipe.origin;
    final flag = origin == null ? null : OriginFlags.of(origin);
    final items = <RecipeMeta>[
      if (origin != null)
        flag != null
            ? RecipeMeta.emoji(emoji: flag, label: origin)
            : RecipeMeta(icon: Icons.public, label: origin),
      for (final diet in DietType.values)
        if (recipe.dietTypes.contains(diet))
          RecipeMeta(icon: Icons.eco_outlined, label: diet.label),
      if (recipe.course != null)
        RecipeMeta(icon: Icons.restaurant, label: recipe.course!.label),
      if (recipe.difficulty != null)
        RecipeMeta(
          icon: Icons.signal_cellular_alt,
          label: recipe.difficulty!.label,
        ),
      if (seasons.isNotEmpty)
        RecipeMeta(
          icon: Icons.wb_sunny_outlined,
          label: seasons.map((s) => s.label).join(', '),
        ),
      if (months.isNotEmpty)
        RecipeMeta(
          icon: Icons.calendar_month_outlined,
          label: months.map(Months.label).join(', '),
        ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blanc,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bordure),
            ),
            child: item,
          ),
      ],
    );
  }
}

class _Durations extends StatelessWidget {
  const _Durations({required this.recipe});

  final Recipe recipe;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, c) => _build(context, c.maxWidth));

  /// Quatre cases sur une ligne si elles restent assez larges pour leurs
  /// libellés (« Préparation »), sinon deux lignes de deux.
  Widget _build(BuildContext context, double width) {
    final theme = Theme.of(context);
    final minCell = MediaQuery.textScalerOf(context).scale(96);
    final columns = (width - 3 * _gap) / 4 >= minCell ? 4 : 2;
    final cellWidth = (width - (columns - 1) * _gap) / columns;
    Widget cell(
      IconData icon,
      String label,
      int minutes, {
      bool highlight = false,
    }) => SizedBox(
      width: cellWidth,
      child: Semantics(
        container: true,
        label: '$label : ${QuantityFormatter.formatDuration(minutes)}',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: highlight ? AppColors.jauneClair : AppColors.blanc,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.vertForet),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                QuantityFormatter.formatDuration(minutes),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.vertForet,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    return Wrap(
      spacing: _gap,
      runSpacing: _gap,
      children: [
        cell(Icons.restaurant_outlined, 'Préparation', recipe.prepTimeMinutes),
        cell(
          Icons.local_fire_department_outlined,
          'Cuisson',
          recipe.cookTimeMinutes,
        ),
        cell(Icons.hourglass_empty, 'Repos', recipe.restTimeMinutes),
        cell(Icons.schedule, 'Total', recipe.totalTimeMinutes, highlight: true),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient, required this.coefficient});

  final Ingredient ingredient;
  final double coefficient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = ingredient.hasQuantity
        ? QuantityFormatter.format(
            ingredient.scaledQuantity(coefficient)!,
            ingredient.unit!,
          )
        : ingredient.quantityNote;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.bordure)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 12),
            child: Icon(Icons.circle, size: 8, color: AppColors.jauneSoleil),
          ),
          Expanded(
            child: Text(ingredient.name, style: theme.textTheme.bodyLarge),
          ),
          if (quantity != null) ...[
            const SizedBox(width: 12),
            Text(
              quantity,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.vertForet,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Étape $number',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.jauneSoleil,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.vertForetSurJaune,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(text, style: theme.textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
