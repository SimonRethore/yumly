import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/recipe.dart';
import 'recipe_catalog_loader.dart';

/// Bundle d'assets utilisé pour le catalogue (remplaçable en test).
final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

/// Catalogue intégré, chargé et validé une seule fois au démarrage.
/// Une erreur de catalogue n'est pas retentée : elle est déterministe.
final catalogProvider = FutureProvider<Catalog>(
  (ref) => RecipeCatalogLoader(ref.watch(assetBundleProvider)).load(),
  retry: (_, _) => null,
);
