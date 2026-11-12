/// Unité dans laquelle on compte les portions d'une recette : des personnes
/// par défaut, ou des pièces (« 12 cannelés », « 8 crêpes »).
class ServingsUnit {
  const ServingsUnit({required this.singular, required this.plural});

  static const personnes = ServingsUnit(
    singular: 'personne',
    plural: 'personnes',
  );

  final String singular;
  final String plural;

  bool get isPersons => this == personnes;

  /// « 1 personne », « 4 personnes », « 12 cannelés ».
  String label(int count) => '$count ${count > 1 ? plural : singular}';

  /// Infobulle du bouton « + » (le chiffre évite d'accorder un/une).
  String get increaseTooltip =>
      isPersons ? 'Ajouter une personne' : 'Ajouter 1 $singular';

  /// Infobulle du bouton « − ».
  String get decreaseTooltip =>
      isPersons ? 'Retirer une personne' : 'Retirer 1 $singular';

  /// Libellé d'accessibilité du sélecteur.
  String semanticsLabel(int count) =>
      isPersons ? 'Nombre de personnes : $count' : 'Nombre de $plural : $count';

  @override
  bool operator ==(Object other) =>
      other is ServingsUnit &&
      other.singular == singular &&
      other.plural == plural;

  @override
  int get hashCode => Object.hash(singular, plural);
}
