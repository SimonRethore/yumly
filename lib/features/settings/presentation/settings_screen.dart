import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_info.dart';
import '../../../app/theme/app_colors.dart';
import '../../recipes/data/recipe_repository.dart';

/// Informations sur l'application (aucun compte, aucune synchronisation).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalog = ref.watch(catalogProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.vertForet,
                  ),
                  title: const Text(AppInfo.name),
                  subtitle: const Text('Version ${AppInfo.version}'),
                ),
                if (catalog != null)
                  ListTile(
                    leading: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.vertForet,
                    ),
                    title: Text(
                      catalog.isDemo
                          ? 'Catalogue de démonstration'
                          : 'Catalogue intégré',
                    ),
                    subtitle: Text(
                      '${catalog.recipes.length} recettes'
                      '${catalog.isDemo ? ' d’exemple, fictives' : ''}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vos données', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Yumly fonctionne entièrement hors ligne, sans compte. '
                    'Vos favoris et votre liste de courses restent sur cet '
                    'appareil et ne sont jamais envoyés ailleurs.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crédits', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Polices : Fredoka et Inter (SIL Open Font License 1.1). '
                    'Icônes : Material Icons (Apache 2.0).',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: AppInfo.name,
                applicationVersion: AppInfo.version,
              ),
              child: const Text('Licences des composants'),
            ),
          ),
        ],
      ),
    );
  }
}
