import 'dart:convert';

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
      // Décodage direct : au-delà de 50 Ko, loadString passe par un isolate,
      // superflu pour cette taille et jamais terminé dans les tests de widgets.
      final data = await _bundle.load(catalogAsset);
      source = utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
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
