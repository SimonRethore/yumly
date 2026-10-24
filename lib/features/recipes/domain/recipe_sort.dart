import '../../../core/formatting/text_normalizer.dart';
import 'recipe.dart';

/// Ordre d'affichage du catalogue. Le catalogue n'a pas de date d'ajout :
/// les recettes y sont ajoutées à la fin, son ordre sert donc de chronologie.
enum RecipeSort {
  alphabetique('Alphabétique'),
  alphabetiqueInverse('Alphabétique inversé'),
  plusRecentes('Plus récentes'),
  plusAnciennes('Plus anciennes');

  const RecipeSort(this.label);

  final String label;

  /// Trie [recipes], supposées dans l'ordre du catalogue.
  List<Recipe> apply(List<Recipe> recipes) {
    int byTitle(Recipe a, Recipe b) =>
        TextNormalizer.normalize(a.title)
            .compareTo(TextNormalizer.normalize(b.title));

    return switch (this) {
      alphabetique => [...recipes]..sort(byTitle),
      alphabetiqueInverse => [...recipes]..sort((a, b) => byTitle(b, a)),
      plusRecentes => recipes.reversed.toList(growable: false),
      plusAnciennes => recipes,
    };
  }
}
