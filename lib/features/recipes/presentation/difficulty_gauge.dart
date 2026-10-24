import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/controlled_values.dart';

/// Jauge à trois barres : une verte pour facile, deux orange pour moyen,
/// trois rouges pour difficile. Décorative : le libellé est affiché à côté.
class DifficultyGauge extends StatelessWidget {
  const DifficultyGauge({super.key, required this.difficulty, this.size = 16});

  final Difficulty difficulty;
  final double size;

  static Color colorOf(Difficulty difficulty) => switch (difficulty) {
    Difficulty.facile => AppColors.difficulteFacile,
    Difficulty.moyen => AppColors.difficulteMoyen,
    Difficulty.difficile => AppColors.difficulteDifficile,
  };

  @override
  Widget build(BuildContext context) {
    final level = difficulty.index + 1;
    final barWidth = size / 4.5;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var bar = 1; bar <= 3; bar++)
              Container(
                width: barWidth,
                // Barres croissantes : 40 %, 60 % et 80 % de la hauteur.
                height: size * (0.2 + 0.2 * bar),
                margin: EdgeInsets.only(bottom: size * 0.1),
                decoration: BoxDecoration(
                  color: bar <= level
                      ? colorOf(difficulty)
                      : AppColors.jaugeVide,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
