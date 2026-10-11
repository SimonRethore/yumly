import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import 'favorites_controller.dart';

/// Bouton cœur : icône pleine/contour (pas seulement une couleur) et
/// libellé accessible explicite.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    this.onImage = false,
  });

  final String recipeId;
  final String recipeTitle;

  /// Affiche un fond blanc circulaire pour rester lisible sur une photo.
  final bool onImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(recipeId)),
    );
    final button = IconButton(
      isSelected: isFavorite,
      icon: const Icon(Icons.favorite_border, color: AppColors.vertForet),
      selectedIcon: const Icon(Icons.favorite, color: AppColors.corail),
      tooltip: isFavorite
          ? 'Retirer « $recipeTitle » des favoris'
          : 'Ajouter « $recipeTitle » aux favoris',
      style: onImage
          ? IconButton.styleFrom(
              backgroundColor: AppColors.blanc.withValues(alpha: 0.92),
            )
          : null,
      onPressed: () {
        final added = ref.read(favoritesProvider.notifier).toggle(recipeId);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                added ? 'Ajoutée aux favoris' : 'Retirée des favoris',
              ),
            ),
          );
      },
    );
    return button;
  }
}
