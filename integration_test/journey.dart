import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/test_app.dart';

const _nbsp = ' ';

Finder _navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _addServings(WidgetTester tester, int times) async {
  for (var i = 0; i < times; i++) {
    await _tapAndSettle(tester, find.byTooltip('Ajouter une personne').first);
  }
}

/// Parcours essentiel de la spécification (§ 12.3), partagé entre le test
/// sur appareil (`integration_test/app_test.dart`) et sa version sans
/// appareil (`test/integration/journey_test.dart`).
Future<void> runEssentialJourney(
  WidgetTester tester,
  SharedPreferences prefs,
) async {
  Future<void> launch() =>
      pumpYumly(tester, prefs: prefs, realCatalogLoader: true);

  // 1. Lancer l'application hors ligne et afficher le catalogue.
  await launch();
  expect(find.text('8 recettes'), findsOneWidget);

  // 2. Rechercher une recette et filtrer les résultats.
  await tester.enterText(find.byType(TextField), 'lentilles');
  await tester.pumpAndSettle();
  expect(find.text('1 recette'), findsOneWidget);
  await _tapAndSettle(tester, find.byTooltip('Effacer la recherche'));
  await _tapAndSettle(tester, find.text('Filtres'));
  await _tapAndSettle(tester, find.widgetWithText(FilterChip, 'Indien'));
  await _tapAndSettle(tester, find.text('Voir 1 recette'));
  expect(find.text('1 recette'), findsOneWidget);

  // 3. Ouvrir le détail et passer à 6 personnes.
  await scrollTo(tester, find.text('Résultats'));
  await _tapAndSettle(tester, find.text('Curry de lentilles corail').last);
  await scrollTo(tester, find.byTooltip('Ajouter une personne'));
  await _addServings(tester, 2);
  expect(find.text('6 personnes'), findsOneWidget);
  expect(find.text('375${_nbsp}g'), findsOneWidget);

  // 4. Ajouter la recette à la liste de courses.
  await scrollTo(tester, find.text('Ajouter à la liste de courses'));
  await _tapAndSettle(tester, find.text('Ajouter à la liste de courses'));
  expect(
    find.text('Ajoutée à la liste de courses (6 personnes)'),
    findsOneWidget,
  );
  await dismissSnackBars(tester);

  // 5. Ajouter une deuxième recette partageant des ingrédients.
  await _tapAndSettle(tester, find.byTooltip('Retour'));
  await _tapAndSettle(tester, find.text('Réinitialiser les filtres'));
  await scrollTo(
    tester,
    find.byTooltip('Ajouter « Chili sin carne » à la liste de courses'),
  );
  await _tapAndSettle(
    tester,
    find.byTooltip('Ajouter « Chili sin carne » à la liste de courses'),
  );
  await dismissSnackBars(tester);

  // 6. Modifier les portions depuis la liste active (chili : 4 → 8).
  await _tapAndSettle(tester, _navTab('Courses'));
  expect(find.text('2 recettes sélectionnées'), findsOneWidget);
  for (var i = 0; i < 4; i++) {
    await _tapAndSettle(tester, find.byTooltip('Ajouter une personne').last);
  }
  expect(find.text('Pour 8 personnes'), findsOneWidget);
  expect(find.text('Pour 6 personnes'), findsOneWidget);

  // 7. Ingrédients : fusion, case cochée, copie.
  final copied = mockClipboard(tester);
  await _tapAndSettle(tester, find.text('Voir les ingrédients à acheter'));
  // Tomates : 400 g × 6/4 + 800 g × 8/4 = 2 200 g ; oignon : 1,5 + 2.
  expect(find.text('2,2${_nbsp}kg'), findsOneWidget);
  expect(find.text('3$_nbsp½${_nbsp}pièces'), findsOneWidget);
  await _tapAndSettle(tester, find.widgetWithText(CheckboxListTile, 'Oignon'));
  await _tapAndSettle(tester, find.text('Copier la liste'));
  expect(find.text('Liste copiée dans le presse-papiers'), findsOneWidget);
  expect(copied.single, contains('- Oignon : 3$_nbsp½${_nbsp}pièces'));
  await dismissSnackBars(tester);

  // 8. Relancer l'application : la liste et l'état coché sont conservés.
  await launch();
  await _tapAndSettle(tester, _navTab('Courses'));
  expect(find.text('2 recettes sélectionnées'), findsOneWidget);
  await _tapAndSettle(tester, find.text('Voir les ingrédients à acheter'));
  final oignon = find.widgetWithText(CheckboxListTile, 'Oignon');
  expect(tester.widget<CheckboxListTile>(oignon).value, isTrue);

  // 9. Retirer une recette et vérifier le recalcul.
  await _tapAndSettle(tester, find.byTooltip('Retour'));
  await _tapAndSettle(
    tester,
    find.byTooltip('Retirer « Curry de lentilles corail » de la liste'),
  );
  await dismissSnackBars(tester);
  await _tapAndSettle(tester, find.text('Voir les ingrédients à acheter'));
  expect(find.text('Lentilles corail'), findsNothing);
  expect(find.text('1,6${_nbsp}kg'), findsOneWidget);
  // L'oignon reste présent (même clé) : son état coché est conservé.
  expect(tester.widget<CheckboxListTile>(oignon).value, isTrue);

  // 10. Ajouter puis retirer un favori.
  await _tapAndSettle(tester, _navTab('Accueil'));
  await scrollTo(
    tester,
    find.byTooltip('Ajouter « Taboulé libanais » aux favoris'),
  );
  await _tapAndSettle(
    tester,
    find.byTooltip('Ajouter « Taboulé libanais » aux favoris'),
  );
  await _tapAndSettle(tester, _navTab('Favoris'));
  expect(find.text('Taboulé libanais'), findsOneWidget);
  await _tapAndSettle(
    tester,
    find.byTooltip('Retirer « Taboulé libanais » des favoris'),
  );
  expect(find.text('Aucun favori pour l’instant'), findsOneWidget);
}
