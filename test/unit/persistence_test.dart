import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumly/core/storage/local_storage.dart';
import 'package:yumly/features/favorites/presentation/favorites_controller.dart';
import 'package:yumly/features/recipes/data/recipe_repository.dart';
import 'package:yumly/features/recipes/domain/unit.dart';
import 'package:yumly/features/shopping_list/data/shopping_list_repository.dart';
import 'package:yumly/features/shopping_list/domain/shopping_ingredient.dart';
import 'package:yumly/features/shopping_list/domain/shopping_list_entry.dart';

import '../helpers/fixtures.dart';

void main() {
  final catalog = parseCatalog([
    recipeJson('a', ingredients: [ing('farine', quantity: 100, unit: 'g')]),
    recipeJson(
      'b',
      ingredients: [
        ing('farine', quantity: 50, unit: 'g'),
        ing('sucre', quantity: 20, unit: 'g'),
      ],
    ),
  ]);
  final farineKey = ShoppingIngredient.keyFor('farine', UnitDimension.mass);
  final sucreKey = ShoppingIngredient.keyFor('sucre', UnitDimension.mass);

  late SharedPreferences prefs;

  /// Nouveau conteneur sur le même stockage : simule un redémarrage.
  Future<ProviderContainer> boot() async {
    final container = ProviderContainer.test(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogProvider.overrideWith((ref) async => catalog),
      ],
    );
    await container.read(catalogProvider.future);
    return container;
  }

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('favoris persistés et restaurés', () async {
    var container = await boot();
    container.read(favoritesProvider.notifier).toggle('a');
    container.read(favoritesProvider.notifier).toggle('b');
    container.read(favoritesProvider.notifier).toggle('b');
    await flush();
    container.dispose();

    container = await boot();
    expect(container.read(favoritesProvider), {'a'});
  });

  test('favori inconnu du catalogue ignoré sans erreur', () async {
    final container = await boot();
    container.read(favoritesProvider.notifier).toggle('supprimee');
    container.read(favoritesProvider.notifier).toggle('a');
    expect(container.read(favoriteRecipesProvider).map((r) => r.id), ['a']);
  });

  test('liste active persistée, sans doublon', () async {
    var container = await boot();
    final list = container.read(shoppingListProvider.notifier);
    expect(list.addOrUpdate('a', 4), AddToListResult.added);
    expect(list.addOrUpdate('b', 2), AddToListResult.added);
    expect(list.addOrUpdate('a', 6), AddToListResult.updated);
    expect(list.addOrUpdate('a', 6), AddToListResult.unchanged);
    list.setServings('b', 3);
    await flush();
    container.dispose();

    container = await boot();
    expect(container.read(shoppingListProvider), [
      ShoppingListEntry(recipeId: 'a', servings: 6),
      ShoppingListEntry(recipeId: 'b', servings: 3),
    ]);
    container.read(shoppingListProvider.notifier).remove('a');
    expect(container.read(shoppingListProvider).map((e) => e.recipeId), ['b']);
  });

  test('cases cochées persistées et orphelines nettoyées', () async {
    var container = await boot();
    final list = container.read(shoppingListProvider.notifier);
    list.addOrUpdate('a', 4);
    list.addOrUpdate('b', 4);
    final checked = container.read(checkedIngredientsProvider.notifier);
    checked.toggle(farineKey);
    checked.toggle(sucreKey);
    await flush();
    container.dispose();

    container = await boot();
    expect(container.read(checkedIngredientsProvider), {farineKey, sucreKey});

    // Changer les portions conserve l'état coché (même clé).
    container.read(shoppingListProvider.notifier).setServings('a', 8);
    expect(container.read(checkedIngredientsProvider), {farineKey, sucreKey});

    // Retirer « b » fait disparaître le sucre : son état est supprimé.
    container.read(shoppingListProvider.notifier).remove('b');
    expect(container.read(checkedIngredientsProvider), {farineKey});

    // S'il revient, il repart décoché.
    container.read(shoppingListProvider.notifier).addOrUpdate('b', 4);
    expect(container.read(checkedIngredientsProvider), {farineKey});
    await flush();
    container.dispose();

    container = await boot();
    expect(container.read(checkedIngredientsProvider), {farineKey});
    container.read(checkedIngredientsProvider.notifier).uncheckAll();
    expect(container.read(checkedIngredientsProvider), isEmpty);
  });

  test('orphelins nettoyés au démarrage si la liste a changé', () async {
    await prefs.setString(
      CheckedIngredientsNotifier.key,
      '{"version":1,"data":["$farineKey","$sucreKey","inconnu|mass"]}',
    );
    await prefs.setString(
      ShoppingListNotifier.key,
      '{"version":1,"data":[{"recipeId":"a","servings":4}]}',
    );
    final container = await boot();
    expect(container.read(checkedIngredientsProvider), {farineKey});
  });

  test('données corrompues : seul l’état concerné est réinitialisé', () async {
    await prefs.setString(FavoritesNotifier.key, 'pas du json');
    await prefs.setString(
      ShoppingListNotifier.key,
      '{"version":1,"data":[{"recipeId":"a","servings":2}]}',
    );
    final container = await boot();
    expect(container.read(favoritesProvider), isEmpty);
    expect(container.read(shoppingListProvider), hasLength(1));
    await flush();
    expect(container.read(storageIssueProvider), contains('favoris'));
    expect(prefs.getString(FavoritesNotifier.key), isNull);
  });

  test('version de stockage inconnue réinitialisée', () async {
    await prefs.setString(FavoritesNotifier.key, '{"version":99,"data":["a"]}');
    final container = await boot();
    expect(container.read(favoritesProvider), isEmpty);
  });
}
