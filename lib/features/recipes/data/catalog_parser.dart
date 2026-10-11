import 'dart:convert';

import '../domain/controlled_values.dart';
import '../domain/ingredient.dart';
import '../domain/recipe.dart';
import '../domain/recipe_step.dart';
import '../domain/unit.dart';

/// Erreur de catalogue : le JSON intégré est invalide. Contient la liste
/// complète des problèmes détectés pour faciliter la correction.
class CatalogException implements Exception {
  CatalogException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'Catalogue invalide :\n- ${errors.join('\n- ')}';
}

class CatalogParseResult {
  const CatalogParseResult(this.catalog, this.warnings);

  final Catalog catalog;

  /// Problèmes non bloquants (image absente, libellés incohérents…).
  final List<String> warnings;
}

/// Désérialise et valide le catalogue JSON (format décrit dans
/// `docs/FORMAT_RECETTES.md`).
class CatalogParser {
  const CatalogParser();

  static const int supportedSchemaVersion = 1;

  /// Analyse [source]. Si [availableAssets] est fourni, les références
  /// d'images absentes sont signalées et remplacées par le placeholder.
  ///
  /// Lève [CatalogException] si le catalogue est invalide.
  CatalogParseResult parse(String source, {Set<String>? availableAssets}) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException catch (e) {
      throw CatalogException(['JSON mal formé : ${e.message}']);
    }
    final errors = <String>[];
    final warnings = <String>[];

    if (root is! Map<String, Object?>) {
      throw CatalogException(['La racine du catalogue doit être un objet.']);
    }
    final version = root['schemaVersion'];
    if (version is! int) {
      throw CatalogException(['« schemaVersion » est obligatoire (entier).']);
    }
    if (version != supportedSchemaVersion) {
      throw CatalogException([
        'Version de schéma non prise en charge : $version '
            '(attendue : $supportedSchemaVersion).',
      ]);
    }
    final rawRecipes = root['recipes'];
    if (rawRecipes is! List<Object?>) {
      throw CatalogException(['« recipes » doit être une liste.']);
    }

    final recipes = <Recipe>[];
    final seenIds = <String>{};
    for (var i = 0; i < rawRecipes.length; i++) {
      final reader = _Reader(rawRecipes[i], 'recipes[$i]', errors);
      final recipe = _parseRecipe(reader, availableAssets, warnings);
      if (recipe == null) continue;
      if (!seenIds.add(recipe.id)) {
        errors.add('Identifiant de recette dupliqué : « ${recipe.id} ».');
        continue;
      }
      recipes.add(recipe);
    }

    if (errors.isNotEmpty) throw CatalogException(errors);
    warnings.addAll(_checkIngredientConsistency(recipes));
    return CatalogParseResult(
      Catalog(
        schemaVersion: version,
        recipes: recipes,
        isDemo: root['isDemo'] == true,
      ),
      warnings,
    );
  }

  Recipe? _parseRecipe(
    _Reader r,
    Set<String>? availableAssets,
    List<String> warnings,
  ) {
    if (!r.isObject) {
      r.error('doit être un objet.');
      return null;
    }
    final errorCount = r.errors.length;
    final id = r.requiredString('id');
    if (id != null) r.context = '${r.context} « $id »';

    final title = r.requiredString('title');
    final description = r.optionalString('description');
    var imageAsset = r.optionalString('imageAsset');
    if (imageAsset != null &&
        availableAssets != null &&
        !availableAssets.contains(imageAsset)) {
      warnings.add(
        '${r.context} : image « $imageAsset » absente des assets, '
        'placeholder utilisé.',
      );
      imageAsset = null;
    }

    final dietTypes = r.controlledSet('dietTypes', DietType.fromId);
    final origin = r.optionalString('origin');
    final course = r.optionalControlled('course', Course.fromId);
    final seasons = r.controlledSet('seasons', Season.fromId);
    final months = r.monthSet('months');
    final difficulty = r.optionalControlled('difficulty', Difficulty.fromId);
    final prep = r.nonNegativeInt('prepTimeMinutes');
    final cook = r.nonNegativeInt('cookTimeMinutes');
    final rest = r.nonNegativeInt('restTimeMinutes');
    final servings = r.positiveInt('defaultServings');
    final ingredients = _parseIngredients(r);
    final steps = _parseSteps(r);
    final equipment = r.stringList('equipment');

    if (r.errors.length != errorCount ||
        id == null ||
        title == null ||
        servings == null) {
      return null;
    }
    return Recipe(
      id: id,
      title: title,
      description: description,
      imageAsset: imageAsset,
      dietTypes: dietTypes,
      origin: origin,
      course: course,
      seasons: seasons,
      months: months,
      difficulty: difficulty,
      prepTimeMinutes: prep,
      cookTimeMinutes: cook,
      restTimeMinutes: rest,
      defaultServings: servings,
      ingredients: ingredients,
      steps: steps,
      equipment: equipment,
    );
  }

  List<Ingredient> _parseIngredients(_Reader r) {
    final result = <Ingredient>[];
    final raw = r.list('ingredients', required: true);
    for (var i = 0; i < raw.length; i++) {
      final ir = _Reader(raw[i], '${r.context} ingredients[$i]', r.errors);
      if (!ir.isObject) {
        ir.error('doit être un objet.');
        continue;
      }
      final before = ir.errors.length;
      final ingredientId = ir.requiredString('ingredientId');
      final name = ir.requiredString('name');
      final category = ir.optionalControlled(
        'category',
        IngredientCategory.fromId,
        required: true,
      );
      final quantity = ir.optionalNonNegativeNumber('quantity');
      final unit = ir.optionalControlled('unit', Unit.fromId);
      final note = ir.optionalString('quantityNote');
      if (quantity != null && unit == null && !ir.has('unit')) {
        ir.error('« unit » est obligatoire lorsque « quantity » est défini.');
      }
      if (unit != null && quantity == null) {
        ir.error('« quantity » est obligatoire lorsque « unit » est défini.');
      }
      if (ir.errors.length != before) continue;
      result.add(
        Ingredient(
          ingredientId: ingredientId!,
          name: name!,
          category: category!,
          quantity: quantity,
          unit: unit,
          quantityNote: note,
        ),
      );
    }
    return result;
  }

  List<RecipeStep> _parseSteps(_Reader r) {
    final result = <RecipeStep>[];
    final orders = <int>{};
    final raw = r.list('steps', required: true);
    for (var i = 0; i < raw.length; i++) {
      final sr = _Reader(raw[i], '${r.context} steps[$i]', r.errors);
      if (!sr.isObject) {
        sr.error('doit être un objet.');
        continue;
      }
      final order = sr.positiveInt('order');
      final text = sr.requiredString('text');
      if (order == null || text == null) continue;
      if (!orders.add(order)) {
        sr.error('ordre d’étape dupliqué : $order.');
        continue;
      }
      result.add(RecipeStep(order: order, text: text));
    }
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  /// Signale les `ingredientId` utilisés avec des libellés ou catégories
  /// différents : le regroupement reste fondé sur l'identifiant.
  List<String> _checkIngredientConsistency(List<Recipe> recipes) {
    final names = <String, Set<String>>{};
    final categories = <String, Set<IngredientCategory>>{};
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        (names[ingredient.ingredientId] ??= {}).add(ingredient.name);
        (categories[ingredient.ingredientId] ??= {}).add(ingredient.category);
      }
    }
    return [
      for (final MapEntry(:key, :value) in names.entries)
        if (value.length > 1)
          'Ingrédient « $key » : libellés différents (${value.join(', ')}).',
      for (final MapEntry(:key, :value) in categories.entries)
        if (value.length > 1)
          'Ingrédient « $key » : catégories différentes '
              '(${value.map((c) => c.id).join(', ')}).',
    ];
  }
}

/// Lecture typée d'un objet JSON, avec accumulation des erreurs.
class _Reader {
  _Reader(this._raw, this.context, this.errors);

  final Object? _raw;
  String context;
  final List<String> errors;

  bool get isObject => _raw is Map<String, Object?>;
  Map<String, Object?> get _map => _raw as Map<String, Object?>;

  bool has(String key) => _map.containsKey(key) && _map[key] != null;

  void error(String message) => errors.add('$context : $message');

  String? requiredString(String key) {
    final value = _map[key];
    if (value is String && value.trim().isNotEmpty) return value;
    error('« $key » est obligatoire (texte non vide).');
    return null;
  }

  String? optionalString(String key) {
    final value = _map[key];
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value;
    error('« $key » doit être un texte.');
    return null;
  }

  int _int(String key, {required int min, required bool required}) {
    final value = _map[key];
    if (value == null && !required) return 0;
    if (value is int && value >= min) return value;
    error('« $key » doit être un entier ≥ $min.');
    return min;
  }

  int nonNegativeInt(String key) => _int(key, min: 0, required: false);

  int? positiveInt(String key) {
    final before = errors.length;
    final value = _int(key, min: 1, required: true);
    return errors.length == before ? value : null;
  }

  double? optionalNonNegativeNumber(String key) {
    final value = _map[key];
    if (value == null) return null;
    if (value is num && value >= 0) return value.toDouble();
    error('« $key » doit être un nombre positif ou nul.');
    return null;
  }

  List<Object?> list(String key, {bool required = false}) {
    final value = _map[key];
    if (value == null && !required) return const [];
    if (value is List<Object?>) return value;
    error('« $key » doit être une liste.');
    return const [];
  }

  List<String> stringList(String key) {
    final result = <String>[];
    for (final item in list(key)) {
      if (item is String && item.trim().isNotEmpty) {
        result.add(item);
      } else {
        error('« $key » ne doit contenir que des textes non vides.');
      }
    }
    return result;
  }

  T? optionalControlled<T>(
    String key,
    T? Function(String) parse, {
    bool required = false,
  }) {
    final value = _map[key];
    if (value == null) {
      if (required) error('« $key » est obligatoire.');
      return null;
    }
    final parsed = value is String ? parse(value) : null;
    if (parsed == null) error('valeur inconnue pour « $key » : $value.');
    return parsed;
  }

  Set<T> controlledSet<T>(String key, T? Function(String) parse) {
    final result = <T>{};
    for (final item in list(key)) {
      final parsed = item is String ? parse(item) : null;
      if (parsed == null) {
        error('valeur inconnue dans « $key » : $item.');
      } else {
        result.add(parsed);
      }
    }
    return result;
  }

  Set<int> monthSet(String key) {
    final result = <int>{};
    for (final item in list(key)) {
      if (item is int && item >= 1 && item <= 12) {
        result.add(item);
      } else {
        error('« $key » doit contenir des entiers de 1 à 12 (reçu : $item).');
      }
    }
    return result;
  }
}
