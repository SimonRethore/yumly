import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/features/recipes/domain/recipe_sort.dart';

import '../helpers/fixtures.dart';

void main() {
  final catalog = parseCatalog([
    recipeJson('flan', overrides: {'title': 'Flan pâtissier'}),
    recipeJson('eclair', overrides: {'title': 'Éclair au café'}),
    recipeJson('churros', overrides: {'title': 'churros'}),
  ]);

  List<String> ids(RecipeSort sort) =>
      sort.apply(catalog.recipes).map((r) => r.id).toList();

  test('alphabétique, insensible à la casse et aux accents', () {
    expect(ids(RecipeSort.alphabetique), ['churros', 'eclair', 'flan']);
    expect(ids(RecipeSort.alphabetiqueInverse), ['flan', 'eclair', 'churros']);
  });

  test('chronologique selon l’ordre du catalogue', () {
    expect(ids(RecipeSort.plusAnciennes), ['flan', 'eclair', 'churros']);
    expect(ids(RecipeSort.plusRecentes), ['churros', 'eclair', 'flan']);
  });
}
