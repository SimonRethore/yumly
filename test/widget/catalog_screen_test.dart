import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/core/widgets/recipe_image.dart';
import 'package:yumly/features/recipes/data/catalog_parser.dart';
import 'package:yumly/features/recipes/domain/recipe.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets(
    'catalogue intégré : chargé depuis les assets, sans bandeau démo',
    (tester) async {
      await pumpYumly(
        tester,
        prefs: await freshPrefs(),
        realCatalogLoader: true,
      );

      expect(find.text('16 recettes'), findsOneWidget);
      expect(find.textContaining('Catalogue de démonstration'), findsNothing);
      // Recettes d'automne-hiver : aussi présentes dans « De saison »
      // (horloge des tests au 10 octobre).
      expect(find.text('De saison'), findsOneWidget);
      await scrollTo(tester, find.text('Toutes les recettes'));
      expect(find.text('Lasagnes à la bolognaise'), findsWidgets);
      expect(find.text('Flammekueche'), findsWidgets);
    },
  );

  testWidgets('recette à tester : ruban sur la photo', (tester) async {
    // Catalogue intégré lu directement : le chargeur d'assets ne se relance
    // pas dans un second test du même fichier.
    final catalog = const CatalogParser()
        .parse(File('assets/data/recipes.json').readAsStringSync())
        .catalog;
    await pumpYumly(tester, prefs: await freshPrefs(), catalog: catalog);
    Finder ribbon(String message) => find.byWidgetPredicate(
      (w) => w is RecipeRibbon && w.message == message,
    );

    await tester.enterText(find.byType(TextField), 'brioche');
    await tester.pumpAndSettle();
    expect(find.text('Brioche perdue'), findsOneWidget);
    expect(ribbon('À tester'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'lasagnes');
    await tester.pumpAndSettle();
    expect(find.text('Lasagnes à la bolognaise'), findsOneWidget);
    expect(find.byType(RecipeRibbon), findsNothing);
  });

  testWidgets('catalogue vide : état vide dédié, sans bandeau démo', (
    tester,
  ) async {
    await pumpYumly(
      tester,
      prefs: await freshPrefs(),
      catalog: Catalog(schemaVersion: 1, recipes: []),
    );

    expect(find.text('Aucune recette pour l’instant'), findsOneWidget);
    expect(find.text('Effacer la recherche et les filtres'), findsNothing);
    expect(find.textContaining('Catalogue de démonstration'), findsNothing);
  });

  testWidgets('affiche les cartes de recettes du catalogue', (tester) async {
    await pumpYumly(tester, prefs: await freshPrefs());

    expect(find.text('Qu’est-ce qu’on cuisine aujourd’hui ?'), findsOneWidget);
    expect(find.textContaining('Catalogue de démonstration'), findsOneWidget);
    expect(find.text('8 recettes'), findsOneWidget);
    await scrollTo(tester, find.text('Toutes les recettes'));
    expect(find.text('Curry de lentilles corail'), findsWidgets);
    // Durée totale = préparation + cuisson + repos (15 + 30 + 0).
    expect(find.text('45 min'), findsWidgets);
    expect(find.text('Végan'), findsWidgets);
  });

  testWidgets('recherche insensible aux accents, état vide et effacement', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs());

    await tester.enterText(find.byType(TextField), 'CREPES');
    await tester.pumpAndSettle();
    expect(find.text('1 recette'), findsOneWidget);
    expect(find.text('Crêpes de la Chandeleur'), findsOneWidget);
    // La section « De saison » est masquée pendant une recherche.
    expect(find.text('De saison'), findsNothing);

    await tester.enterText(find.byType(TextField), 'introuvable');
    await tester.pumpAndSettle();
    expect(find.text('Aucune recette ne correspond'), findsOneWidget);

    await tester.tap(find.text('Effacer la recherche et les filtres'));
    await tester.pumpAndSettle();
    expect(find.text('8 recettes'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('filtres combinables, pastilles actives supprimables', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs());

    await tester.tap(find.text('Filtres'));
    await tester.pumpAndSettle();
    // Options issues du catalogue uniquement.
    expect(find.widgetWithText(FilterChip, 'Mexicain'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Japonais'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Mexicain'));
    await tester.tap(find.widgetWithText(FilterChip, 'Indien'));
    await tester.pumpAndSettle();
    expect(find.text('Voir 3 recettes'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.widgetWithText(FilterChip, 'Apéritif'),
      100,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Apéritif'));
    await tester.pumpAndSettle();
    expect(find.text('Voir 1 recette'), findsOneWidget);

    await tester.tap(find.text('Voir 1 recette'));
    await tester.pumpAndSettle();
    expect(find.text('Filtres (3)'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Mexicain'), findsOneWidget);
    expect(find.text('1 recette'), findsOneWidget);

    // Retirer un filtre ne réinitialise pas les autres.
    await tester.tap(find.byTooltip('Retirer le filtre Apéritif'));
    await tester.pumpAndSettle();
    expect(find.text('Filtres (2)'), findsOneWidget);
    expect(find.text('3 recettes'), findsOneWidget);

    await tester.tap(find.text('Réinitialiser les filtres'));
    await tester.pumpAndSettle();
    expect(find.text('Filtres'), findsOneWidget);
    expect(find.text('8 recettes'), findsOneWidget);
  });

  testWidgets('section « De saison » calculée depuis les mois', (tester) async {
    await pumpYumly(
      tester,
      prefs: await freshPrefs(),
      now: DateTime(2026, 7, 1),
    );
    expect(find.text('De saison'), findsOneWidget);
    // En juillet : guacamole et taboulé uniquement.
    final seasonal = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Card),
    );
    expect(seasonal, findsNWidgets(2));
  });
}
