/// Valeurs contrôlées du catalogue : identifiants métier stables et libellés
/// français. Le texte affiché n'est jamais utilisé comme identifiant.
library;

/// Valeur contrôlée générique.
abstract interface class ControlledValue {
  String get id;
  String get label;
}

T? _byId<T extends ControlledValue>(List<T> values, String id) {
  for (final value in values) {
    if (value.id == id) return value;
  }
  return null;
}

enum DietType implements ControlledValue {
  vegetarian('vegetarian', 'Végétarien'),
  vegan('vegan', 'Végan');

  const DietType(this.id, this.label);
  @override
  final String id;
  @override
  final String label;

  static DietType? fromId(String id) => _byId(values, id);
}

/// Types de plat, dans l'ordre de la journée et du repas.
enum Course implements ControlledValue {
  petitDejeuner('petit_dejeuner', 'Petit-déjeuner'),
  aperitif('aperitif', 'Apéritif'),
  entree('entree', 'Entrée'),
  plat('plat', 'Plat'),
  accompagnement('accompagnement', 'Accompagnement'),
  dessert('dessert', 'Dessert'),
  boisson('boisson', 'Boisson');

  const Course(this.id, this.label);
  @override
  final String id;
  @override
  final String label;

  static Course? fromId(String id) => _byId(values, id);
}

/// Saisons usuelles de France métropolitaine, dans l'ordre naturel.
enum Season implements ControlledValue {
  printemps('printemps', 'Printemps'),
  ete('ete', 'Été'),
  automne('automne', 'Automne'),
  hiver('hiver', 'Hiver');

  const Season(this.id, this.label);
  @override
  final String id;
  @override
  final String label;

  static Season? fromId(String id) => _byId(values, id);
}

/// Niveaux de difficulté, dans l'ordre croissant.
enum Difficulty implements ControlledValue {
  facile('facile', 'Facile'),
  moyen('moyen', 'Moyen'),
  difficile('difficile', 'Difficile');

  const Difficulty(this.id, this.label);
  @override
  final String id;
  @override
  final String label;

  static Difficulty? fromId(String id) => _byId(values, id);
}

/// Catégories de produits de la liste de courses, dans l'ordre d'affichage.
enum IngredientCategory implements ControlledValue {
  fruitsLegumes('fruits_legumes', 'Fruits et légumes'),
  epicerieSeche('epicerie_seche', 'Épicerie sèche'),
  produitsFrais('produits_frais', 'Produits frais'),
  produitsLaitiers(
    'produits_laitiers_alternatives',
    'Produits laitiers et alternatives végétales',
  ),
  viandesPoissons('viandes_poissons', 'Viandes et poissons'),
  boulangerie('boulangerie', 'Boulangerie'),
  epicesCondiments('epices_condiments', 'Épices et condiments'),
  surgeles('surgeles', 'Surgelés'),
  boissons('boissons', 'Boissons'),
  autres('autres', 'Autres');

  const IngredientCategory(this.id, this.label);
  @override
  final String id;
  @override
  final String label;

  static IngredientCategory? fromId(String id) => _byId(values, id);
}

/// Libellés français des mois (index 1 à 12).
abstract final class Months {
  static const List<String> labels = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  static String label(int month) => labels[month - 1];
}
