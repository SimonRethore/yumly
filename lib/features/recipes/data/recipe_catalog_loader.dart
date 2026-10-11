import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/recipe.dart';
import 'catalog_parser.dart';

/// Charge le catalogue intégré depuis les assets de l'application.
class RecipeCatalogLoader {
  const RecipeCatalogLoader(
    this._bundle, {
    this.parser = const CatalogParser(),
  });

  static const String catalogAsset = 'assets/data/recipes.json';

  final AssetBundle _bundle;
  final CatalogParser parser;

  /// Lève [CatalogException] si le catalogue est absent ou invalide.
  Future<Catalog> load() async {
    final String source;
    try {
      source = await _bundle.loadString(catalogAsset);
    } catch (e) {
      throw CatalogException(['Fichier « $catalogAsset » introuvable ($e).']);
    }
    final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    final result = parser.parse(
      source,
      availableAssets: manifest.listAssets().toSet(),
    );
    for (final warning in result.warnings) {
      debugPrint('[Yumly] Catalogue : $warning');
    }
    return result.catalog;
  }
}
