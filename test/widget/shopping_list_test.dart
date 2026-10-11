import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/shopping_list/data/shopping_list_repository.dart';

import '../helpers/test_app.dart';

const nbsp = ' ';

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> openShoppingList(WidgetTester tester) async {
  await tester.tap(navTab('Courses'));
  await tester.pumpAndSettle();
}

Map<String, Object> withList(String json) => {
  ShoppingListNotifier.key: '{"version":1,"data":$json}',
};

const curryAndChili =
    '[{"recipeId":"curry-lentilles-001","servings":4},'
    '{"recipeId":"chili-sin-carne-002","servings":4}]';

void main() {
  testWidgets('liste vide : état vide avec retour au catalogue', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs());
    await openShoppingList(tester);
    expect(find.text('Votre liste est vide'), findsOneWidget);
    await tester.tap(find.text('Parcourir les recettes'));
    await tester.pumpAndSettle();
    expect(find.text('Qu’est-ce qu’on cuisine aujourd’hui ?'), findsOneWidget);
  });

  testWidgets('ajout depuis une carte, badge, portions et suppression', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs());
    await scrollTo(
      tester,
      find.byTooltip('Ajouter « Guacamole » à la liste de courses'),
    );
    await tester.tap(
      find.byTooltip('Ajouter « Guacamole » à la liste de courses'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Ajoutée à la liste de courses (4 personnes)'),
      findsOneWidget,
    );
    // Deuxième ajout depuis la carte : pas de doublon.
    await tester.tap(
      find.byTooltip('« Guacamole » est dans la liste de courses'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Déjà dans la liste de courses (4 personnes)'),
      findsOneWidget,
    );
    expect(find.byTooltip('Liste de courses (1 recette)'), findsOneWidget);

    await tester.tap(find.byTooltip('Liste de courses (1 recette)'));
    await tester.pumpAndSettle();
    expect(find.text('1 recette sélectionnée'), findsOneWidget);
    await tester.tap(find.byTooltip('Ajouter une personne'));
    await tester.pumpAndSettle();
    expect(find.text('Pour 5 personnes'), findsOneWidget);

    await tester.tap(find.byTooltip('Retirer « Guacamole » de la liste'));
    await tester.pumpAndSettle();
    expect(find.text('Votre liste est vide'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Pour 5 personnes'), findsOneWidget);
  });

  testWidgets('portions modifiables indépendamment pour chaque recette', (
    tester,
  ) async {
    await pumpYumly(tester, prefs: await freshPrefs(withList(curryAndChili)));
    await openShoppingList(tester);
    expect(find.text('2 recettes sélectionnées'), findsOneWidget);
    expect(find.text('Pour 4 personnes'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Ajouter une personne').first);
    await tester.pumpAndSettle();
    expect(find.text('Pour 5 personnes'), findsOneWidget);
    expect(find.text('Pour 4 personnes'), findsOneWidget);
  });

  testWidgets('ingrédients fusionnés, catégories, cases et copie', (
    tester,
  ) async {
    final prefs = await freshPrefs(withList(curryAndChili));
    final copied = mockClipboard(tester);
    await pumpYumly(tester, prefs: prefs);
    await openShoppingList(tester);
    await tester.tap(find.text('Voir les ingrédients à acheter'));
    await tester.pumpAndSettle();

    expect(find.text('Ingrédients à acheter'), findsOneWidget);
    expect(find.text('Fruits et légumes'), findsOneWidget);
    expect(find.text('Épicerie sèche'), findsOneWidget);
    // Catégories vides non affichées.
    expect(find.text('Boulangerie'), findsNothing);
    // Oignon (1 + 1) et tomates (400 g + 800 g) fusionnés.
    expect(find.text('2${nbsp}pièces'), findsWidgets);
    expect(find.text('1,2${nbsp}kg'), findsOneWidget);
    expect(find.text('Oignon'), findsOneWidget);

    final oignon = find.widgetWithText(CheckboxListTile, 'Oignon');
    await tester.tap(oignon);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(oignon).value, isTrue);
    expect(find.textContaining('1 sur'), findsOneWidget);

    await tester.tap(find.text('Copier la liste'));
    await tester.pumpAndSettle();
    expect(find.text('Liste copiée dans le presse-papiers'), findsOneWidget);
    expect(
      copied.single,
      startsWith('Liste de courses Yumly\n\nFruits et légumes\n'),
    );
    expect(copied.single, contains('- Oignon : 2${nbsp}pièces'));
    expect(
      copied.single,
      contains('- Tomates concassées en conserve : 1,2${nbsp}kg'),
    );
    expect(copied.single, contains('\nÉpices et condiments\n'));
    await dismissSnackBars(tester);

    await tester.tap(find.text('Tout décocher'));
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(oignon).value, isFalse);
  });

  testWidgets('erreur de presse-papiers signalée clairement', (tester) async {
    mockClipboard(tester, fail: true);
    await pumpYumly(tester, prefs: await freshPrefs(withList(curryAndChili)));
    await openShoppingList(tester);
    await tester.tap(find.text('Voir les ingrédients à acheter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copier la liste'));
    await tester.pumpAndSettle();
    expect(
      find.text('Impossible de copier la liste. Veuillez réessayer.'),
      findsOneWidget,
    );
  });
}
