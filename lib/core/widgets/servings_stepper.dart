import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/recipes/domain/recipe.dart';
import '../../features/recipes/domain/servings_unit.dart';

/// « 4 personnes » par défaut, ou « 12 cannelés » selon [unit].
String servingsLabel(
  int servings, [
  ServingsUnit unit = ServingsUnit.personnes,
]) => unit.label(servings);

/// Sélecteur du nombre de portions (entier de 1 à 100), en personnes ou en
/// pièces selon [unit].
class ServingsStepper extends StatelessWidget {
  const ServingsStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
    this.unit = ServingsUnit.personnes,
  });

  final int value;
  final ServingsUnit unit;
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
            tooltip: unit.decreaseTooltip,
            onPressed: canDecrease ? () => onChanged(value - 1) : null,
          ),
          Flexible(
            child: Semantics(
              liveRegion: true,
              label: unit.semanticsLabel(value),
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      unit.isPersons ? Icons.people_outline : Icons.tag,
                      size: 20,
                      color: AppColors.vertForet,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        compact ? '$value' : servingsLabel(value, unit),
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
            tooltip: unit.increaseTooltip,
            onPressed: canIncrease ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
