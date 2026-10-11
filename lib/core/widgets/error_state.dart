import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/recipes/data/catalog_parser.dart';
import 'empty_state.dart';

/// Erreur de chargement du catalogue. En mode debug, le détail des erreurs
/// de validation est affiché pour faciliter la correction du JSON.
class CatalogErrorState extends StatelessWidget {
  const CatalogErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final details = switch (error) {
      CatalogException(:final errors) => errors.join('\n'),
      _ => error.toString(),
    };
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        EmptyState(
          scrollable: false,
          icon: Icons.error_outline,
          iconColor: AppColors.corailFonce,
          title: 'Impossible de charger les recettes',
          message:
              'Le catalogue intégré à l’application est illisible. '
              'Vos favoris et votre liste de courses sont conservés.',
          actionLabel: onRetry == null ? null : 'Réessayer',
          onAction: onRetry,
        ),
        if (kDebugMode)
          SelectableText(details, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
