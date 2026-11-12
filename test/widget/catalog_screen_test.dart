import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/core/widgets/recipe_image.dart';
import 'package:yumly/features/recipes/data/catalog_parser.dart';
import 'package:yumly/features/recipes/domain/controlled_values.dart';
import 'package:yumly/features/recipes/domain/recipe.dart';
import 'package:yumly/features/recipes/presentation/recipe_card.dart';

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

      expect(find.textContaining('Catalogue de démonstration'), findsNothing);
      // Recettes d'automne-hiver : aussi présentes dans « De saison »
      // (horloge des tests au 10 octobre).
      expect(find.text('De saison'), findsOneWidget);
      // Le compteur est sous les rubriques de l'accueil.
      await scrollTo(tester, find.text('69 recettes'));
      expect(find.text('69 recettes'), findsOneWidget);
      // Ordre alphabétique par défaut : les cartes sont plus bas.
      await scrollTo(tester, find.widgetWithText(RecipeCard, 'Flammekueche'));
      await scrollTo(
        tester,
        find.widgetWithText(RecipeCard, 'Lasagnes à la bolognaise'),
      );
    },
  );

  testWidgets('recette à tester ou à revoir : ruban sur la photo', (
    tester,
  ) async {
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

    await tester.enterText(find.byType(TextField), 'nouilles au boeuf');
    await tester.pumpAndSettle();
    expect(find.text('Nouilles au bœuf sauté à la thaï'), findsOneWidget);
    expect(ribbon('À revoir'), findsOneWidget);

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
    // Cartes allégées : pas de badges dans la grille.
    expect(find.byType(RecipeBadge), findsNothing);
    // Titres sur deux lignes au plus, « … » au-delà.
    final title = tester.widget<Text>(
      find.descendant(
        of: gridCard('Curry de lentilles corail'),
        matching: find.text('Curry de lentilles corail'),
      ),
    );
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
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

    await tester.tap(find.byTooltip('Filtres'));
    await tester.pumpAndSettle();
    await scrollSheetTo(
      tester,
      find.widgetWithText(FilterChip, '🇲🇽 Mexicain'),
    );
    // Options issues du catalogue uniquement.
    expect(find.widgetWithText(FilterChip, '🇲🇽 Mexicain'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '🇯🇵 Japonais'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, '🇲🇽 Mexicain'));
    await scrollSheetTo(tester, find.widgetWithText(FilterChip, '🇮🇳 Indien'));
    await tester.tap(find.widgetWithText(FilterChip, '🇮🇳 Indien'));
    await tester.pumpAndSettle();
    expect(find.text('Voir 3 recettes'), findsOneWidget);

    await scrollSheetTo(
      tester,
      find.widgetWithText(FilterChip, 'Apéritif'),
      delta: -100,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Apéritif'));
    await tester.pumpAndSettle();
    expect(find.text('Voir 1 recette'), findsOneWidget);

    await tester.tap(find.text('Voir 1 recette'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Filtres (3)'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '🇲🇽 Mexicain'), findsOneWidget);
    expect(find.text('1 recette'), findsOneWidget);
    // Un seul type de plat : repris par sa pastille rapide, pas en double.
    expect(find.widgetWithText(InputChip, 'Apéritif'), findsNothing);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Apéritif'))
          .selected,
      isTrue,
    );

    // Retirer un filtre ne réinitialise pas les autres.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Tout'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Filtres (2)'), findsOneWidget);
    // Curry et chili de saison : le compteur est sous le carrousel.
    await scrollTo(tester, find.text('3 recettes'));
    expect(find.text('3 recettes'), findsOneWidget);

    await scrollTo(tester, find.text('Réinitialiser les filtres'), delta: -250);
    await tester.tap(find.text('Réinitialiser les filtres'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byTooltip('Filtres'), delta: -250);
    expect(find.byTooltip('Filtres'), findsOneWidget);
    expect(find.text('8 recettes'), findsOneWidget);
  });

  testWidgets('pastilles de type de plat sous la recherche', (tester) async {
    await pumpYumly(tester, prefs: await freshPrefs());
    final seasonal = carouselCards('De saison');
    Finder chip(String label) => find.widgetWithText(ChoiceChip, label);
    bool isSelected(String label) =>
        tester.widget<ChoiceChip>(chip(label)).selected;
    Future<void> tapChip(String label) async {
      await tester.ensureVisible(chip(label));
      await tester.tap(chip(label));
      await tester.pumpAndSettle();
    }

    // Tous les types du catalogue, dans l'ordre du repas.
    final labels = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .map((c) => (c.label as Text).data)
        .toList();
    expect(labels, ['Tout', 'Apéritif', 'Entrée', 'Plat', 'Dessert']);
    expect(isSelected('Tout'), isTrue);
    expect(isSelected('Entrée'), isFalse);
    expect(find.text('8 recettes'), findsOneWidget);

    await tapChip('Dessert');
    expect(isSelected('Dessert'), isTrue);
    expect(isSelected('Tout'), isFalse);
    expect(find.text('2 recettes'), findsOneWidget);
    // Pas de pastille « Dessert » en double dans les filtres actifs.
    expect(find.widgetWithText(InputChip, 'Dessert'), findsNothing);
    // « De saison » reste affiché, filtré : la tarte aux pommes (octobre).
    expect(find.text('De saison'), findsOneWidget);
    expect(seasonal, findsOneWidget);

    // Un seul type à la fois.
    await tapChip('Plat');
    expect(isSelected('Dessert'), isFalse);
    expect(find.text('3 recettes'), findsOneWidget);

    await tapChip('Tout');
    expect(isSelected('Tout'), isTrue);
    expect(find.text('8 recettes'), findsOneWidget);
  });

  testWidgets('« De saison » exclut les recettes à revoir', (tester) async {
    final catalog = const CatalogParser()
        .parse(File('assets/data/recipes.json').readAsStringSync())
        .catalog;
    // Juillet : les nouilles au bœuf à la thaï (à revoir) sont de saison.
    await pumpYumly(
      tester,
      prefs: await freshPrefs(),
      catalog: catalog,
      now: DateTime(2026, 7, 1),
    );
    final expected = catalog.recipes.where(
      (r) => r.months.contains(7) && r.status != RecipeStatus.aRevoir,
    );
    await scrollTo(tester, find.text('De saison'));
    final seasonal = carouselCards('De saison');
    expect(seasonal, findsNWidgets(expected.length));
    expect(
      tester
          .widgetList<RecipeCard>(seasonal)
          .any((c) => c.recipe.status == RecipeStatus.aRevoir),
      isFalse,
    );
  });

  testWidgets('section « De saison » calculée depuis les mois', (tester) async {
    await pumpYumly(
      tester,
      prefs: await freshPrefs(),
      now: DateTime(2026, 7, 1),
    );
    expect(find.text('De saison'), findsOneWidget);
    // En juillet : guacamole et taboulé uniquement.
    final seasonal = carouselCards('De saison');
    expect(seasonal, findsNWidgets(2));

    // Aucun dessert de saison en juillet : la section disparaît.
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Dessert'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dessert'));
    await tester.pumpAndSettle();
    expect(find.text('De saison'), findsNothing);
  });

  testWidgets('rubrique « À tester » : recettes pas encore réalisées', (
    tester,
  ) async {
    final catalog = const CatalogParser()
        .parse(File('assets/data/recipes.json').readAsStringSync())
        .catalog;
    await pumpYumly(tester, prefs: await freshPrefs(), catalog: catalog);
    final toTest = carouselCards('À tester');
    await scrollTo(tester, find.text('À tester'));
    final undone = catalog.recipes
        .where((r) => r.status == RecipeStatus.aTester)
        .toList();
    expect(toTest, findsNWidgets(undone.length));
    expect(
      tester
          .widgetList<RecipeCard>(toTest)
          .every((c) => c.recipe.status == RecipeStatus.aTester),
      isTrue,
    );

    // Masquée pendant une recherche.
    await scrollTo(tester, find.byType(TextField), delta: -250);
    await tester.enterText(find.byType(TextField), 'brioche');
    await tester.pumpAndSettle();
    expect(find.text('À tester'), findsNothing);
  });

  testWidgets('tri : la feuille de filtres change l’ordre de la liste', (
    tester,
  ) async {
    final catalog = const CatalogParser()
        .parse(File('assets/data/recipes.json').readAsStringSync())
        .catalog;
    await pumpYumly(tester, prefs: await freshPrefs(), catalog: catalog);
    // La grille est sous le carrousel « De saison ».
    Future<String> firstCard() async {
      await scrollTo(tester, find.text('Toutes les recettes'));
      return tester
          .widget<RecipeCard>(
            find
                .descendant(
                  of: find.byType(SliverList),
                  matching: find.byType(RecipeCard),
                )
                .first,
          )
          .recipe
          .title;
    }

    // « De saison » garde son ordre aléatoire, quel que soit le tri.
    List<String> seasonalTitles() => tester
        .widgetList<RecipeCard>(carouselCards('De saison'))
        .map((card) => card.recipe.title)
        .toList();
    final seasonalOrder = seasonalTitles();
    expect(seasonalOrder.length, greaterThan(1));

    // Ordre alphabétique par défaut.
    expect(await firstCard(), 'Aiguillettes de poulet façon teriyaki');

    Future<void> choose(String label) async {
      await scrollTo(tester, find.byTooltip('Filtres'), delta: -250);
      await tester.tap(find.byTooltip('Filtres'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voir 69 recettes'));
      await tester.pumpAndSettle();
    }

    await choose('Alphabétique inversé');
    expect(seasonalTitles(), seasonalOrder);

    await choose('Plus récentes');
    expect(seasonalTitles(), seasonalOrder);
    expect(await firstCard(), catalog.recipes.last.title);

    await choose('Plus anciennes');
    expect(await firstCard(), catalog.recipes.first.title);

    await choose('Alphabétique inversé');
    expect(await firstCard(), 'Wok de nouilles sautées sauce cacahuètes');
  });
}
