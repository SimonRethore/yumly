/// Dimension physique d'une unité. Seules les unités d'une même dimension
/// peuvent être converties et additionnées.
enum UnitDimension {
  mass,
  volume,
  count,
  // Les unités de cuisine forment chacune leur propre dimension : aucune
  // conversion n'est définie entre cuillères, pincées, grammes ou millilitres.
  teaspoon,
  tablespoon,
  pinch,
}

/// Unités normalisées autorisées dans le catalogue.
enum Unit {
  g('g', UnitDimension.mass, 1),
  kg('kg', UnitDimension.mass, 1000),
  ml('ml', UnitDimension.volume, 1),
  cl('cl', UnitDimension.volume, 10),
  l('l', UnitDimension.volume, 1000),
  piece('piece', UnitDimension.count, 1),
  cuillereACafe('c_a_c', UnitDimension.teaspoon, 1),
  cuillereASoupe('c_a_s', UnitDimension.tablespoon, 1),
  pincee('pincee', UnitDimension.pinch, 1);

  const Unit(this.id, this.dimension, this.factorToCanonical);

  /// Identifiant utilisé dans le JSON.
  final String id;
  final UnitDimension dimension;

  /// Facteur multiplicatif vers l'unité canonique de la dimension
  /// (g pour la masse, ml pour le volume).
  final double factorToCanonical;

  static Unit? fromId(String id) {
    for (final unit in values) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  /// Unité canonique d'une dimension, utilisée pour additionner.
  static Unit canonicalFor(UnitDimension dimension) => switch (dimension) {
    UnitDimension.mass => Unit.g,
    UnitDimension.volume => Unit.ml,
    UnitDimension.count => Unit.piece,
    UnitDimension.teaspoon => Unit.cuillereACafe,
    UnitDimension.tablespoon => Unit.cuillereASoupe,
    UnitDimension.pinch => Unit.pincee,
  };

  double toCanonical(double amount) => amount * factorToCanonical;

  double fromCanonical(double canonicalAmount) =>
      canonicalAmount / factorToCanonical;
}
