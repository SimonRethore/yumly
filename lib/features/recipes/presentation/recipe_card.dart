import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/widgets/recipe_image.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../../shopping_list/data/shopping_list_repository.dart';
import '../../shopping_list/presentation/add_to_list.dart';
import '../domain/controlled_values.dart';
import '../domain/recipe.dart';
import 'difficulty_gauge.dart';

/// Badges les plus pertinents d'une recette, sans surcharger la carte :
/// régime le plus strict, puis origine.
List<({String label, Color color})> recipeBadges(Recipe recipe, {int max = 2}) {
  final badges = <({String label, Color color})>[
    if (recipe.dietTypes.contains(DietType.vegan))
      (label: DietType.vegan.label, color: AppColors.saugeClair)
    else if (recipe.dietTypes.contains(DietType.vegetarian))
      (label: DietType.vegetarian.label, color: AppColors.saugeClair),
    if (recipe.origin != null)
      (label: recipe.origin!, color: AppColors.jauneClair),
    if (recipe.course != null)
      (label: recipe.course!.label, color: AppColors.jauneClair),
  ];
  return badges.take(max).toList();
}

/// Ruban affiché sur la photo d'une recette à tester ou à revoir.
String? recipeRibbon(Recipe recipe) =>
    recipe.status == RecipeStatus.realisee ? null : recipe.status.label;

class RecipeBadge extends StatelessWidget {
  const RecipeBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.vertForet),
      ),
    );
  }
}

/// Métadonnée icône + texte (durée), emoji + texte (drapeau), ou jauge +
/// texte (difficulté).
class RecipeMeta extends StatelessWidget {
  const RecipeMeta({
    super.key,
    required IconData this.icon,
    required this.label,
  }) : emoji = null,
       difficulty = null;

  const RecipeMeta.emoji({
    super.key,
    required String this.emoji,
    required this.label,
  }) : icon = null,
       difficulty = null;

  RecipeMeta.difficulty({super.key, required Difficulty this.difficulty})
    : label = difficulty.label,
      icon = null,
      emoji = null;

  final IconData? icon;
  final String? emoji;
  final Difficulty? difficulty;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null)
          ExcludeSemantics(
            child: Text(emoji!, style: const TextStyle(fontSize: 16)),
          )
        else if (difficulty != null)
          DifficultyGauge(difficulty: difficulty!)
        else
          Icon(icon, size: 16, color: AppColors.vertForet),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class RecipeCard extends ConsumerWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.imageAspectRatio = 16 / 10,
    this.showActions = true,
    this.showBadges = true,
    this.compactTitle = false,
  });

  final Recipe recipe;
  final VoidCallback onTap;

  /// Photo plus haute dans une carte étroite.
  final double imageAspectRatio;

  /// Boutons favori et liste de courses sur la photo.
  final bool showActions;

  /// Badges régime, origine ou type de plat sous la durée.
  final bool showBadges;

  /// Titre sur deux lignes au plus (« … » au-delà), avec toujours la place
  /// de deux lignes : les cartes gardent la même hauteur.
  final bool compactTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final inList = ref.watch(
      shoppingListProvider.select(
        (entries) => entries.any((e) => e.recipeId == recipe.id),
      ),
    );
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                RecipeImage(
                  asset: recipe.imageAsset,
                  aspectRatio: imageAspectRatio,
                  ribbon: recipeRibbon(recipe),
                ),
                if (showActions) ...[
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteButton(
                      recipeId: recipe.id,
                      recipeTitle: recipe.title,
                      onImage: true,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: IconButton(
                      tooltip: inList
                          ? '« ${recipe.title} » est dans la liste de courses'
                          : 'Ajouter « ${recipe.title} » à la liste de courses',
                      isSelected: inList,
                      style: IconButton.styleFrom(
                        backgroundColor: inList
                            ? AppColors.saugeClair
                            : AppColors.jauneSoleil,
                      ),
                      icon: const Icon(Icons.add_shopping_cart),
                      selectedIcon: const Icon(Icons.playlist_add_check),
                      onPressed: () => addRecipeFromCard(context, ref, recipe),
                    ),
                  ),
                ],
              ],
            ),
            // Boutons sur la photo : le texte garde toute la largeur de la
            // carte.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (compactTitle)
                    Stack(
                      children: [
                        // Réserve la hauteur de deux lignes à la taille de
                        // texte du système.
                        ExcludeSemantics(
                          child: Opacity(
                            opacity: 0,
                            child: Text(
                              '\n',
                              maxLines: 2,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        Text(
                          recipe.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    )
                  else
                    Text(recipe.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      RecipeMeta(
                        icon: Icons.schedule,
                        label: QuantityFormatter.formatDuration(
                          recipe.totalTimeMinutes,
                        ),
                      ),
                      if (recipe.difficulty != null)
                        RecipeMeta.difficulty(difficulty: recipe.difficulty!),
                    ],
                  ),
                  if (showBadges) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final badge in recipeBadges(recipe))
                          RecipeBadge(label: badge.label, color: badge.color),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
