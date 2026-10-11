import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Photo de recette au ratio stable, avec placeholder aux couleurs de la
/// charte si l'image est absente ou illisible.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.asset,
    this.aspectRatio = 16 / 10,
    this.iconSize = 48,
  });

  final String? asset;
  final double? aspectRatio;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(iconSize: iconSize);
    final Widget image = asset == null
        ? placeholder
        : Image.asset(
            asset!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => placeholder,
          );
    // Image décorative : le titre de la recette est toujours affiché à côté.
    final content = ExcludeSemantics(child: image);
    if (aspectRatio == null) return content;
    return AspectRatio(aspectRatio: aspectRatio!, child: content);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.jauneClair, AppColors.saugeClair],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: iconSize,
          color: AppColors.vertForet.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
