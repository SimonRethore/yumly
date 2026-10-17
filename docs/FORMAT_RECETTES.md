# Format du catalogue de recettes

Le catalogue est un fichier JSON intégré à l'application :
`assets/data/recipes.json`. Il est chargé et validé au démarrage
(`lib/features/recipes/data/catalog_parser.dart`) et par le test
`test/unit/catalog_parser_test.dart` (« le catalogue intégré est valide »).

Un catalogue invalide n'entraîne pas de plantage : l'application affiche un
écran d'erreur (avec le détail des erreurs en mode debug) et conserve les
favoris et la liste de courses.

## Racine

| Champ           | Type    | Obligatoire | Description                                              |
| --------------- | ------- | ----------- | -------------------------------------------------------- |
| `schemaVersion` | entier  | oui         | Version du schéma. Seule la version `1` est acceptée.     |
| `isDemo`        | booléen | non         | `true` : catalogue de démonstration (bandeau affiché).   |
| `recipes`       | liste   | oui         | Liste des recettes.                                      |

Toute modification incompatible du schéma doit incrémenter `schemaVersion`.
Un catalogue d'une version inconnue est **rejeté** avec un message explicite
(pas de migration automatique en version 1).

## Recette

| Champ             | Type              | Obligatoire | Règles                                                        |
| ----------------- | ----------------- | ----------- | ------------------------------------------------------------- |
| `id`              | texte             | oui         | Unique et stable (ex. `curry-lentilles-001`). Ne jamais le réutiliser pour une autre recette : favoris et listes s'y réfèrent. |
| `title`           | texte             | oui         |                                                               |
| `description`     | texte             | non         |                                                               |
| `imageAsset`      | texte             | non         | Chemin d'une image sous `assets/recipes/`. Absente → placeholder + avertissement. |
| `dietTypes`       | liste de textes   | non         | `vegetarian`, `vegan`. Si la source ne le précise pas, le déduire des ingrédients à la saisie (l'application ne déduit rien elle-même). |
| `origin`          | texte             | non         | Libellé français affiché tel quel (`Indien`, `Mexicain`…).     |
| `course`          | texte             | non         | `aperitif`, `entree`, `plat`, `accompagnement`, `dessert`, `petit_dejeuner`, `boisson`. |
| `seasons`         | liste de textes   | non         | `printemps`, `ete`, `automne`, `hiver`.                        |
| `months`          | liste d'entiers   | non         | 1 à 12. Alimente le filtre « Mois » et la section « De saison ». |
| `difficulty`      | texte             | non         | `facile`, `moyen`, `difficile`.                               |
| `prepTimeMinutes` | entier ≥ 0        | non (0)     |                                                               |
| `cookTimeMinutes` | entier ≥ 0        | non (0)     | Alimente le filtre « Temps de cuisson ».                      |
| `restTimeMinutes` | entier ≥ 0        | non (0)     | Durée totale = préparation + cuisson + repos.                 |
| `defaultServings` | entier ≥ 1        | oui         | Nombre de personnes des quantités de base.                    |
| `ingredients`     | liste             | oui         | Ordonnée, voir ci-dessous.                                    |
| `steps`           | liste             | oui         | Voir ci-dessous.                                              |
| `equipment`       | liste de textes   | non         | Section masquée si vide.                                      |
| `sourceUrl`       | texte             | non         | Lien vers la recette d'origine, adresse `http` ou `https` complète. |
| `done`            | booléen           | non (`true`) | Recette déjà réalisée. `false` pour une recette pas encore testée. |

Les valeurs contrôlées inconnues (faute de frappe, nouvelle valeur) sont
**rejetées** : ajouter d'abord la valeur et son libellé dans
`lib/features/recipes/domain/controlled_values.dart`.

## Ingrédient

| Champ           | Type        | Obligatoire | Règles                                                  |
| --------------- | ----------- | ----------- | ------------------------------------------------------- |
| `ingredientId`  | texte       | oui         | Identifiant canonique, partagé entre recettes.          |
| `name`          | texte       | oui         | Libellé français.                                       |
| `category`      | texte       | oui         | Catégorie de produit (voir ci-dessous).                 |
| `quantity`      | nombre ≥ 0  | non         | Toujours numérique, jamais « 2 c. à s. » en texte.      |
| `unit`          | texte       | si quantité | Unité normalisée (voir ci-dessous).                     |
| `quantityNote`  | texte       | non         | Mention libre non numérique : « au goût », « quelques brins ». |

`quantity` et `unit` vont ensemble : l'un sans l'autre est une erreur.

### Conventions d'identifiants d'ingrédients

- Minuscules, sans accents, mots séparés par des tirets : `creme-fraiche`,
  `huile-olive`, `tomates-concassees`.
- **Le même ingrédient garde le même identifiant dans toutes les recettes** :
  c'est la seule clé de fusion de la liste de courses. Deux ingrédients au
  même nom mais aux identifiants différents ne sont jamais fusionnés
  (`oignon` ≠ `oignon-rouge`).
- Utiliser le même `name` et la même `category` pour un identifiant donné ;
  sinon un avertissement est émis au chargement (le premier libellé
  rencontré dans la liste est affiché).

## Unités

| Identifiant | Libellé    | Dimension  | Conversion          |
| ----------- | ---------- | ---------- | ------------------- |
| `g`         | g          | masse      | base                |
| `kg`        | kg         | masse      | 1 kg = 1 000 g      |
| `ml`        | ml         | volume     | base                |
| `cl`        | cl         | volume     | 1 cl = 10 ml        |
| `l`         | l          | volume     | 1 l = 1 000 ml      |
| `piece`     | pièce(s)   | comptage   | —                   |
| `c_a_c`     | c. à c.    | cuillère à café  | aucune        |
| `c_a_s`     | c. à s.    | cuillère à soupe | aucune        |
| `pincee`    | pincée(s)  | pincée     | aucune              |

- Seules les unités d'une même dimension sont additionnées (g + kg, ml + cl + l).
- Aucune conversion volume ↔ masse, ni cuillère ↔ ml/g : les lignes restent
  séparées.
- Affichage : à partir de 1 000 g → kg, à partir de 1 000 ml → l ; les
  centilitres sont conservés si la recette les utilise. Les calculs gardent
  la précision complète, l'arrondi n'intervient qu'à l'affichage.

## Catégories de produits (ordre d'affichage)

| Identifiant                      | Libellé                                      |
| -------------------------------- | -------------------------------------------- |
| `fruits_legumes`                 | Fruits et légumes                            |
| `epicerie_seche`                 | Épicerie sèche                               |
| `produits_frais`                 | Produits frais                               |
| `produits_laitiers_alternatives` | Produits laitiers et alternatives végétales  |
| `viandes_poissons`               | Viandes et poissons                          |
| `boulangerie`                    | Boulangerie                                  |
| `epices_condiments`              | Épices et condiments                         |
| `surgeles`                       | Surgelés                                     |
| `boissons`                       | Boissons                                     |
| `autres`                         | Autres                                       |

## Étape

| Champ   | Type       | Obligatoire | Règles                                              |
| ------- | ---------- | ----------- | --------------------------------------------------- |
| `order` | entier ≥ 1 | oui         | Unique dans la recette. Les étapes sont triées par `order`. |
| `text`  | texte      | oui         | `\n` pour un retour à la ligne.                     |

## Exemple minimal

```json
{
  "schemaVersion": 1,
  "recipes": [
    {
      "id": "soupe-poireaux-009",
      "title": "Soupe de poireaux",
      "imageAsset": "assets/recipes/soupe-poireaux.jpg",
      "dietTypes": ["vegetarian"],
      "course": "entree",
      "months": [11, 12, 1, 2],
      "difficulty": "facile",
      "prepTimeMinutes": 10,
      "cookTimeMinutes": 25,
      "defaultServings": 4,
      "ingredients": [
        { "ingredientId": "poireau", "name": "Poireau", "quantity": 3, "unit": "piece", "category": "fruits_legumes" },
        { "ingredientId": "sel", "name": "Sel", "category": "epices_condiments", "quantityNote": "au goût" }
      ],
      "steps": [
        { "order": 1, "text": "Émincer les poireaux." },
        { "order": 2, "text": "Cuire 25 minutes puis mixer." }
      ],
      "equipment": ["Faitout", "Mixeur"]
    }
  ]
}
```
