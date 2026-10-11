import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/shopping_list/data/shopping_list_repository.dart';

import '../helpers/test_app.dart';

const nbsp = ' ';

Future<void> openCurry(WidgetTester tester) async {
  await scrollTo(tester, find.text('Toutes les recettes'));
  await tester.tap(find.text('Curry de lentilles corail').last);
  await tester.pumpAndSettle();
}

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  testWidgets('la fiche présente critères, durées, ingrédients, étapes et '
      'équipements', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpYumly(tester, prefs: await freshPrefs());
    await openCurry(tester);

    expect(
      find.text('Un plat parfumé et réconfortant, prêt en 45 minutes.'),
      findsOneWidget,
    );
    expect(find.text('Indien'), findsOneWidget);
    expect(find.text('Végan'), findsOneWidget);
    expect(find.text('Plat'), findsOneWidget);
    expect(find.text('Facile'), findsOneWidget);
    expect(find.text('Automne, Hiver'), findsOneWidget);
    expect(find.bySemanticsLabel('Préparation : 15${nbsp}min'), findsOneWidget);
    expect(find.bySemanticsLabel('Cuisson : 30${nbsp}min'), findsOneWidget);
    expect(find.bySemanticsLabel('Repos : 0${nbsp}min'), findsOneWidget);
    expect(find.bySemanticsLabel('Total : 45${nbsp}min'), findsOneWidget);

    await scrollTo(tester, find.text('Lentilles corail'));
    expect(find.text('4 personnes'), findsOneWidget);
    expect(find.text('250${nbsp}g'), findsOneWidget);

    await scrollTo(tester, find.text('Râpe'));
    expect(
      find.text('Émincer l’oignon, hacher l’ail et râper le gingembre.'),
      findsOneWidget,
    );
    expect(find.text('Équipements'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('changer le nombre de personnes recalcule les quantités', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs());
    await openCurry(tester);
    await scrollTo(tester, find.byTooltip('Retirer une personne'));

    await tester.tap(find.byTooltip('Retirer une personne'));
    await tester.pump();
    await tester.tap(find.byTooltip('Retirer une personne'));
    await tester.pumpAndSettle();
    expect(find.text('2 personnes'), findsOneWidget);
    expect(find.text('125${nbsp}g'), findsOneWidget);
    expect(find.text('200${nbsp}ml'), findsOneWidget);

    await tester.tap(find.byTooltip('Retirer une personne'));
    await tester.pumpAndSettle();
    expect(find.text('1 personne'), findsOneWidget);
    // Minimum atteint : le bouton est désactivé.
    final decrease = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove),
    );
    expect(decrease.onPressed, isNull);

    await tester.tap(find.text('Revenir à 4 personnes'));
    await tester.pumpAndSettle();
    expect(find.text('250${nbsp}g'), findsOneWidget);
  });

  testWidgets('ajout depuis la fiche sans doublon, avec mise à jour des '
      'portions', (tester) async {
    await pumpYumly(tester, prefs: await freshPrefs());
    await openCurry(tester);
    await scrollTo(tester, find.byTooltip('Retirer une personne'));

    await tester.tap(find.byTooltip('Ajouter une personne'));
    await tester.pump();
    await tester.tap(find.byTooltip('Ajouter une personne'));
    await tester.pumpAndSettle();
    final addButton = find.text('Ajouter à la liste de courses');
    await scrollTo(tester, addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Ajoutée à la liste de courses (6 personnes)'),
      findsOneWidget,
    );
    await dismissSnackBars(tester);

    await scrollTo(tester, find.byTooltip('Retirer une personne'), delta: -250);
    await tester.tap(find.byTooltip('Retirer une personne'));
    await tester.pumpAndSettle();
    await scrollTo(tester, addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text('Portions mises à jour : 5 personnes'), findsOneWidget);
    await dismissSnackBars(tester);

    await tester.tap(navTab('Courses'));
    await tester.pumpAndSettle();
    expect(find.text('1 recette sélectionnée'), findsOneWidget);
    expect(find.text('Pour 5 personnes'), findsOneWidget);
  });

  testWidgets('une recette déjà dans la liste s’ouvre avec les portions de '
      'la liste', (tester) async {
    await pumpYumly(
      tester,
      prefs: await freshPrefs({
        ShoppingListNotifier.key: '{"version":1,"data":[{"recipeId":"curry-lentilles-001","servings":7}]}',
      }),
    );
    await openCurry(tester);

    await scrollTo(tester, find.text('Lentilles corail'));
    expect(find.text('7 personnes'), findsOneWidget);
    expect(find.text('Revenir à 4 personnes'), findsOneWidget);

    final addButton = find.text('Ajouter à la liste de courses');
    await scrollTo(tester, addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Déjà dans la liste de courses (7 personnes)'),
      findsOneWidget,
    );
  });

  testWidgets('favori basculé depuis la carte et visible dans Favoris', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs());

    await tester.tap(navTab('Favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun favori pour l’instant'), findsOneWidget);

    await tester.tap(navTab('Accueil'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byTooltip('Ajouter « Guacamole » aux favoris'));
    await tester.tap(find.byTooltip('Ajouter « Guacamole » aux favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Ajoutée aux favoris'), findsOneWidget);
    expect(find.byTooltip('Retirer « Guacamole » des favoris'), findsOneWidget);

    await tester.tap(navTab('Favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Guacamole'), findsOneWidget);

    // Ouverture du détail depuis les favoris, puis retrait du favori.
    await tester.tap(find.text('Guacamole'));
    await tester.pumpAndSettle();
    expect(find.text('Frais et acidulé, idéal à l’apéritif.'), findsOneWidget);
    await tester.tap(find.byTooltip('Retirer « Guacamole » des favoris'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun favori pour l’instant'), findsOneWidget);
  });
}
