import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/shopping_list/data/shopping_list_repository.dart';

import '../helpers/test_app.dart';

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Les écrans principaux restent utilisables (sans débordement) avec une
/// taille de texte système doublée.
void main() {
  testWidgets('écrans principaux avec texte ×2', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final prefs = await freshPrefs({
      ShoppingListNotifier.key: '{"version":1,"data":[{"recipeId":"curry-lentilles-001","servings":4}]}',
    });
    await pumpYumly(tester, prefs: prefs);

    await scrollTo(tester, find.text('Toutes les recettes'));
    await scrollTo(tester, find.text('Chili sin carne'));
    await tester.tap(find.text('Chili sin carne').last);
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Ajouter à la liste de courses'));
    await scrollTo(tester, find.text('Équipements'));

    await tester.tap(navTab('Courses'));
    await tester.pumpAndSettle();
    expect(find.text('Pour 4 personnes'), findsOneWidget);
    await tester.tap(find.text('Voir les ingrédients à acheter'));
    await tester.pumpAndSettle();
    expect(find.text('Fruits et légumes'), findsOneWidget);

    await tester.tap(navTab('Accueil'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byTooltip('Filtres'), delta: -250);
    await tester.tap(find.byTooltip('Filtres'));
    await tester.pumpAndSettle();
    expect(find.text('Réinitialiser les filtres'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    await tester.tap(navTab('Paramètres'));
    await tester.pumpAndSettle();
    expect(find.text('Vos données'), findsOneWidget);
  });
}
