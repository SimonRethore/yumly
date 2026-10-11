import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/recipes/domain/recipe.dart';

String servingsLabel(int servings) =>
    servings > 1 ? '$servings personnes' : '$servings personne';

/// Sélecteur du nombre de personnes (entier de 1 à 100).
class ServingsStepper extends StatelessWidget {
  const ServingsStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = value > ServingsLimits.min;
    final canIncrease = value < ServingsLimits.max;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bordure),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Retirer une personne',
            onPressed: canDecrease ? () => onChanged(value - 1) : null,
          ),
          Flexible(
            child: Semantics(
              liveRegion: true,
              label: 'Nombre de personnes : $value',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 20,
                      color: AppColors.vertForet,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        compact ? '$value' : servingsLabel(value),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.vertForet,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une personne',
            onPressed: canIncrease ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
