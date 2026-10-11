import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/local_storage.dart';
import '../features/shopping_list/data/shopping_list_repository.dart';

/// Coque de navigation : barre persistante à quatre destinations.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Les erreurs de persistance sont signalées sans bloquer l'interface.
    ref.listen(storageIssueProvider, (_, message) {
      if (message == null) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      ref.read(storageIssueProvider.notifier).clear();
    });
    final listCount = ref.watch(activeEntriesProvider.select((e) => e.length));

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          // Toucher l'onglet actif revient à sa racine.
          initialLocation: index == shell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: listCount > 0,
              label: Text('$listCount'),
              child: const Icon(Icons.shopping_basket_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: listCount > 0,
              label: Text('$listCount'),
              child: const Icon(Icons.shopping_basket),
            ),
            label: 'Courses',
            tooltip: listCount == 0
                ? 'Liste de courses'
                : 'Liste de courses, $listCount '
                      '${listCount > 1 ? 'recettes' : 'recette'}',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
