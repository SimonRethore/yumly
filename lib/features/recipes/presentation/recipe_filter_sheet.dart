import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/controlled_values.dart';
import '../domain/origin_flags.dart';
import '../domain/recipe_filters.dart';
import '../domain/recipe_sort.dart';
import 'difficulty_gauge.dart';
import 'recipes_controller.dart';

/// Une pastille de filtre active (supprimable individuellement).
class ActiveFilter {
  const ActiveFilter(this.label, this.remove);

  final String label;
  final RecipeFilters Function(RecipeFilters) remove;
}

/// Liste des filtres actifs, dans l'ordre des familles.
List<ActiveFilter> activeFilters(RecipeFilters f) => [
  for (final v in f.diets)
    ActiveFilter(v.label, (s) => s.copyWith(diets: toggled(s.diets, v))),
  for (final v in f.origins)
    ActiveFilter(
      OriginFlags.label(v),
      (s) => s.copyWith(origins: toggled(s.origins, v)),
    ),
  for (final v in f.courses)
    ActiveFilter(v.label, (s) => s.copyWith(courses: toggled(s.courses, v))),
  for (final v in f.seasons)
    ActiveFilter(v.label, (s) => s.copyWith(seasons: toggled(s.seasons, v))),
  for (final v in f.months)
    ActiveFilter(
      Months.label(v),
      (s) => s.copyWith(months: toggled(s.months, v)),
    ),
  for (final v in f.difficulties)
    ActiveFilter(
      v.label,
      (s) => s.copyWith(difficulties: toggled(s.difficulties, v)),
    ),
  for (final v in f.cookTimes)
    ActiveFilter(
      'Cuisson : ${v.label.toLowerCase()}',
      (s) => s.copyWith(cookTimes: toggled(s.cookTimes, v)),
    ),
  for (final v in f.statuses)
    ActiveFilter(v.label, (s) => s.copyWith(statuses: toggled(s.statuses, v))),
];

Future<void> showRecipeFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const RecipeFilterSheet(),
  );
}

/// Feuille de tri et de filtres : chaque famille n'affiche que les valeurs présentes
/// dans le catalogue. Les filtres s'appliquent immédiatement.
class RecipeFilterSheet extends ConsumerWidget {
  const RecipeFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(filterOptionsProvider);
    final filters = ref.watch(recipeFiltersProvider);
    final count = ref.watch(filteredRecipesProvider).length;
    final sort = ref.watch(recipeSortProvider);
    final notifier = ref.read(recipeFiltersProvider.notifier);
    if (options == null) return const SizedBox.shrink();

    Widget family<T>(
      String title,
      List<T> values,
      Set<T> Function(RecipeFilters) selectedIn,
      String Function(T) label,
      RecipeFilters Function(RecipeFilters, Set<T>) apply, {
      Widget Function(T)? leading,
    }) {
      if (values.isEmpty) return const SizedBox.shrink();
      return _FilterFamily(
        title: title,
        children: [
          for (final value in values)
            FilterChip(
              label: leading == null
                  ? Text(label(value))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        leading(value),
                        const SizedBox(width: 6),
                        Flexible(child: Text(label(value))),
                      ],
                    ),
              selected: selectedIn(filters).contains(value),
              // Bascule calculée sur l'état courant (taps rapprochés).
              onSelected: (_) => notifier.update(
                (s) => apply(s, toggled(selectedIn(s), value)),
              ),
            ),
        ],
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 1,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            // Wrap : le bouton passe à la ligne avec une grande taille de texte.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: filters.hasActiveFilters
                      ? notifier.clearFilters
                      : null,
                  child: const Text('Réinitialiser les filtres'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterFamily(
                  title: 'Trier par',
                  children: [
                    for (final option in RecipeSort.values)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: option == sort,
                        onSelected: (_) =>
                            ref.read(recipeSortProvider.notifier).set(option),
                      ),
                  ],
                ),
                family(
                  'Régime',
                  options.diets,
                  (s) => s.diets,
                  (v) => v.label,
                  (s, v) => s.copyWith(diets: v),
                ),
                family(
                  'Type de plat',
                  options.courses,
                  (s) => s.courses,
                  (v) => v.label,
                  (s, v) => s.copyWith(courses: v),
                ),
                family(
                  'Origine',
                  options.origins,
                  (s) => s.origins,
                  OriginFlags.label,
                  (s, v) => s.copyWith(origins: v),
                ),
                family(
                  'Saison',
                  options.seasons,
                  (s) => s.seasons,
                  (v) => v.label,
                  (s, v) => s.copyWith(seasons: v),
                ),
                family(
                  'Mois',
                  options.months,
                  (s) => s.months,
                  Months.label,
                  (s, v) => s.copyWith(months: v),
                ),
                family(
                  'Difficulté',
                  options.difficulties,
                  (s) => s.difficulties,
                  (v) => v.label,
                  (s, v) => s.copyWith(difficulties: v),
                  leading: (v) => DifficultyGauge(difficulty: v),
                ),
                family(
                  'Temps de cuisson',
                  options.cookTimes,
                  (s) => s.cookTimes,
                  (v) => v.label,
                  (s, v) => s.copyWith(cookTimes: v),
                ),
                family(
                  'Statut',
                  options.statuses,
                  (s) => s.statuses,
                  (v) => v.label,
                  (s, v) => s.copyWith(statuses: v),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    count == 0
                        ? 'Aucune recette'
                        : 'Voir $count ${count > 1 ? 'recettes' : 'recette'}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterFamily extends StatelessWidget {
  const _FilterFamily({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}
