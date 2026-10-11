import 'dart:convert';

import 'package:yumly/features/recipes/data/catalog_parser.dart';
import 'package:yumly/features/recipes/domain/recipe.dart';

/// Construit une recette JSON minimale valide, surchargeable.
Map<String, Object?> recipeJson(
  String id, {
  Map<String, Object?> overrides = const {},
  List<Map<String, Object?>>? ingredients,
}) => {
  'id': id,
  'title': 'Recette $id',
  'defaultServings': 4,
  'ingredients':
      ingredients ??
      [
        {
          'ingredientId': 'oignon',
          'name': 'Oignon',
          'quantity': 1,
          'unit': 'piece',
          'category': 'fruits_legumes',
        },
      ],
  'steps': [
    {'order': 1, 'text': 'Étape unique.'},
  ],
  ...overrides,
};

Map<String, Object?> ing(
  String id, {
  num? quantity,
  String? unit,
  String category = 'epicerie_seche',
  String? name,
}) => {
  'ingredientId': id,
  'name': name ?? id,
  'quantity': ?quantity,
  'unit': ?unit,
  'category': category,
};

String catalogSource(List<Map<String, Object?>> recipes, {int version = 1}) =>
    jsonEncode({'schemaVersion': version, 'recipes': recipes});

Catalog parseCatalog(List<Map<String, Object?>> recipes) =>
    const CatalogParser().parse(catalogSource(recipes)).catalog;
