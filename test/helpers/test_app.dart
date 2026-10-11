import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumly/app/app.dart';
import 'package:yumly/core/storage/local_storage.dart';
import 'package:yumly/features/recipes/data/catalog_parser.dart';
import 'package:yumly/features/recipes/data/recipe_repository.dart';
import 'package:yumly/features/recipes/domain/recipe.dart';
import 'package:yumly/features/recipes/presentation/recipes_controller.dart';

/// Catalogue intégré, lu directement depuis le disque (synchrone en test ;
/// évalué uniquement s'il est utilisé).
final Catalog bundledCatalog = const CatalogParser()
    .parse(File('assets/data/recipes.json').readAsStringSync())
    .catalog;

/// Monte l'application complète sur un écran de téléphone.
Future<void> pumpYumly(
  WidgetTester tester, {
  required SharedPreferences prefs,
  DateTime? now,
  bool realCatalogLoader = false,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // Nouvelle clé : chaque appel simule un redémarrage de l'application.
      key: UniqueKey(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Le vrai chargeur (assets + manifeste) est utilisé sur appareil et
        // dans le parcours d'intégration.
        if (!realCatalogLoader)
          catalogProvider.overrideWith((ref) async => bundledCatalog),
        clockProvider.overrideWithValue(() => now ?? DateTime(2026, 10, 10)),
      ],
      child: const YumlyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<SharedPreferences> freshPrefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// Intercepte le presse-papiers. Retourne la liste des textes copiés.
List<String> mockClipboard(WidgetTester tester, {bool fail = false}) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        if (fail) throw PlatformException(code: 'indisponible');
        copied.add(
          (call.arguments as Map<Object?, Object?>)['text']! as String,
        );
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

/// Fait défiler la zone principale jusqu'à rendre [finder] visible.
Future<void> scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find
        .descendant(
          of: find.byType(CustomScrollView).hitTestable().first,
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

/// Fait disparaître les snackbars affichés (ils peuvent recouvrir les
/// boutons du bas de l'écran).
Future<void> dismissSnackBars(WidgetTester tester) async {
  for (final element in find.byType(Scaffold).evaluate()) {
    ScaffoldMessenger.maybeOf(element)?.clearSnackBars();
  }
  await tester.pumpAndSettle();
}
