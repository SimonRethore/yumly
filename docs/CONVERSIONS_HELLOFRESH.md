# Conversions des recettes HelloFresh

Les recettes HelloFresh comptent souvent en contenants de la box (« 1 paquet »,
« ½ sachet », « 2 pots ») et nomment des produits maison (« épices
italiennes », « sauce asiatique sucrée »). Ce fichier liste les équivalences
déjà retenues dans le catalogue, pour que le même ingrédient soit converti de
la même façon d'une recette à l'autre.

Toute conversion faite à la saisie est aussi notée en **A** dans la ligne de
la recette de `TODO_REVIEW.md`.

**À mettre à jour à chaque recette HelloFresh ajoutée ou modifiée** :
ajouter les nouvelles équivalences, compléter la colonne « Recettes » des
lignes réutilisées, et signaler dans « À harmoniser » toute conversion qui
contredit une ligne existante.

## Méthode

- **Lire les données par nombre de personnes.** La page contient les quantités
  pour 1 à 6 personnes (`__NEXT_DATA__` → `yields`). Prendre celles du
  `defaultServings` retenu, en général celui de la source (2 ou 4).
- **La taille des contenants dépend du nombre de personnes.** Un « paquet »
  pour 4 n'est pas deux « paquets » pour 2 : la version 4 personnes des
  nouilles dan dan garde 1 seul paquet de bœuf et 1 seul sachet de sauce
  soja. Toujours préciser pour combien de personnes une équivalence vaut.
- **Vérifier avec les valeurs nutritionnelles.** Elles sont données par
  portion (kcal, lipides, protéines, sel). Recalculer à partir des
  quantités estimées permet de valider un poids (bœuf, fromage, beurre de
  cacahuète) ou un volume de sauce soja (via le sel).
- **Une quantité explicite (g, ml) l'emporte toujours** sur une estimation.

## Contenants : poids et volumes retenus

| Ingrédient HelloFresh | Quantité source | Pour | Catalogue | Recettes |
| --- | --- | --- | --- | --- |
| Beurre | 2 cc | 2 pers. | 10 g (1 cc ≈ 5 g) | Porc mexicain, Orzotto toscane |
| Beurre | 2 cs / 2,5 cs | 4 pers. | 30 g / 35 g (1 cs ≈ 15 g) | Mijoté abricots, Orzo ail-citron |
| Beurre de cacahuètes | 2 tubes / 2 pots | 2 pers. | 30 g (≈ 15 g l'unité) | Wok nouilles, Dan dan |
| Beurre de cacahuètes | 4 tubes | 4 pers. | 80 g (20 g l'unité) | Mafé |
| Broccolini | 1 sachet | 2 pers. | 150 g | Riz sauté broccolini |
| Cacahuètes non salées | 1 sachet | 2 pers. | 20 g | Dan dan, Riz sauté broccolini |
| Chair à saucisse | 1 paquet | 2 pers. | 250 g | Porc mexicain |
| Chair de tomates | 1 paquet | 2 pers. | 400 g | Porc mexicain |
| Chutney d'abricots | 1 sachet | 4 pers. | 120 g | Mijoté abricots |
| Amandes effilées | 1 sachet | 4 pers. | 30 g | Mijoté abricots |
| Concentré de tomates | 1 (sans unité) | 4 pers. | 70 g (petite boîte) | Mafé |
| Concentré de tomates | ½ sachet | 2 pers. | 35 g | Mijoté porc petits pois |
| Copeaux de grana padano | 1 sachet | 2 pers. | 20 g (vérifié aux lipides) | Orzotto toscane |
| Crème épaisse | 1 pot | 2 pers. | 10 cl | Porc mexicain |
| Crème épaisse | 1 pot | 4 pers. | 30 cl | Orzo ail-citron |
| Crème liquide | 2 paquets | 4 pers. | 40 cl (20 cl le paquet) | Mijoté abricots |
| Crème liquide | 1 paquet | 2 pers. | 20 cl, légère (vérifié aux lipides) | Mijoté porc petits pois |
| Crevettes | 1 paquet | 2 pers. | 160 g | Orzotto toscane |
| Émincés de porc marinés à la mexicaine | 1 paquet | 2 pers. | 250 g d'émincés de porc (vérifié aux protéines) + ½ c. à c. d'épices mexicaines par personne | Mijoté porc petits pois |
| Épinards | 1 sachet | 2 pers. | 100 g | Orzotto toscane |
| Huile de sésame | 1 sachet | 2 pers. | 1 cl (vérifié aux lipides) | Riz sauté broccolini |
| Petits pois en conserve | 1 pièce | 2 pers. | 1 boîte de 400 g (280 g égouttés) | Mijoté porc petits pois |
| Sauce soja | 1 sachet | 2 pers. | 3 cl (vérifié au sel) | Dan dan |
| Sauce soja | 1 sachet, dont « 10 ml par personne » dans l'étape | 2 pers. | 2 cl (la quantité de l'étape) | Riz sauté broccolini |
| Sauce sriracha | 1 sachet | 2 pers. | 2 c. à c. | Riz sauté broccolini |
| Sauce soja | 1 sachet | 4 pers. | 4 cl | Nasi goreng |
| Tomates semi-séchées | 1 paquet | 2 pers. | 50 g | Orzotto toscane |
| Viande hachée au bœuf | 1 paquet | 2 pers. | 240 g (vérifié aux protéines) | Dan dan |

## Bouillon

HelloFresh donne le bouillon en ml, ou parfois en cubes (« ½ cube », repris tel quel). Le catalogue le convertit en cubes :
**1 cube jusqu'à 500 ml**, 2 cubes au-delà (325 à 400 ml → 1 cube ;
800 ml → 2 cubes). L'eau est indiquée dans l'étape, en proportion de la
céréale (« 27 cl pour 100 g d'orzo ») ou par personne, selon
`docs/FORMAT_RECETTES.md`.

## Herbes fraîches

| HelloFresh | Pour | Catalogue |
| --- | --- | --- |
| Coriandre, 1 sachet | 4 pers. | 1 bouquet |
| Coriandre, ½ sachet | 2 pers. | quelques brins |
| Persil, 1 sachet | 4 pers. | ½ bouquet |
| Persil, ½ sachet | 2 pers. | quelques brins |
| Persil, 5 g | 4 pers. | quelques brins |
| Ciboulette, 1 sachet | 4 pers. | quelques brins |
| Coriandre et menthe, 10 g | 4 pers. | quelques brins de chaque |

## Mélanges et sauces maison

| HelloFresh | Pour | Catalogue | Recette |
| --- | --- | --- | --- |
| Curcuma en poudre, ½ sachet | 2 pers. | 1 c. à c. | Porc mexicain |
| Paprika fumé, ½ sachet | 2 pers. | 1 c. à c. | Mijoté porc petits pois |
| Herbes de Provence, ½ sachet | 2 pers. | 1 c. à c. | Mijoté porc petits pois |
| Coriandre moulue, ⅔ sachet | 2 pers. | 1 c. à c. | Dan dan |
| Épices mexicaines, ½ sachet | 2 pers. | 3 c. à c. | Porc mexicain |
| Épices du Moyen-Orient, 2 sachets | 4 pers. | 4 c. à c. de mélange d'épices marocain | Mijoté abricots |
| Épices africaines, 1⅓ sachet | 4 pers. | 1 c. à c. de paprika + 1 pincée de piment de Cayenne | Mafé |
| Épices italiennes, 1⅓ sachet | 4 pers. | 2 c. à s. d'herbes italiennes | Orzo ail-citron |
| Épices italiennes, ½ sachet (« ça pique ») | 2 pers. | 1 c. à s. d'herbes italiennes + 1 pincée de piment concassé par personne | Orzotto toscane |
| Sauce asiatique sucrée, 4 sachets | 4 pers. | 4 c. à s. de gochujang + 2 c. à s. de miel | Bibimbap |
| Sauce asiatique sucrée, 4 sachets | 4 pers. | 3 c. à s. de sauce d'huître + 1 c. à s. de sucre | Nouilles bœuf thaï |
| Sauce asiatique sucrée, 1 sachet (plat végétarien) | 2 pers. | 2 c. à s. de kecap manis | Riz sauté broccolini |
| Pâte épicée javanaise, 2 sachets | 4 pers. | 4 c. à s. de kecap manis + 2 c. à c. de sambal oelek | Nasi goreng |
| Oignons frits, ⅔ sachet | 4 pers. | « pour servir » | Nasi goreng |

La « sauce asiatique sucrée » change selon la recette : la remplacer d'après
le goût du plat, pas d'après un équivalent fixe.

## Libellés

| HelloFresh | Catalogue (`ingredientId`) |
| --- | --- |
| Riz | Riz basmati (`riz`) |
| Riz au jasmin | Riz jasmin (`riz-jasmin`), quand la source le précise |
| Semoule | Semoule moyenne |
| Poivron | Poivron rouge (`poivron-rouge`) |
| (Mini) Concombre | Concombre |
| Viande hachée au bœuf | Bœuf haché (`boeuf-hache`) |
| Crevettes | Crevettes décortiquées (`crevettes`) |
| Fromage râpé à l'italienne | Parmesan râpé (`parmesan-rape`) |
| Salade en sachet | Salade roquette-mâche |
| Crème épaisse | Crème fraîche épaisse |
| Oignon nouveau, 1 botte | Oignon nouveau (cébette), « 1 botte » |
| Oignon nouveau, 25 g | Oignon nouveau (cébette), 1 pièce |
| Piment | Piment rouge frais (`piment-rouge`), même fraction |
| Gingembre frais, en cm | Gingembre frais, même mention (« 1 cm ») |
| Vinaigre balsamique noir | Vinaigre balsamique (`vinaigre-balsamique`) |
| cs / cc | `c_a_s` / `c_a_c` |

## À harmoniser

Ces conversions diffèrent d'une recette à l'autre et attendent une décision
(voir aussi `TODO_REVIEW.md`) :

- **« Tête d'ail »** : HelloFresh désigne en fait une gousse. Le catalogue
  compte 1 tête = 1 gousse dans 7 recettes (Mafé, Mijoté abricots, Orzo
  ail-citron, Bibimbap, Nasi goreng, Nouilles bœuf thaï, Aiguillettes
  teriyaki), mais 1 tête = 2 gousses dans le Wok de nouilles et le Dan dan.
- **Beurre de cacahuètes** : 20 g le tube dans le Mafé (4 pers.), environ
  15 g dans le Wok et le Dan dan (2 pers.), d'après les valeurs
  nutritionnelles. Les tubes ont peut-être des tailles différentes selon
  la box.
- **Épices italiennes** : 1,5 c. à s. d'herbes italiennes par sachet dans
  l'Orzo ail-citron, 2 c. à s. et du piment dans l'Orzotto toscane.
- **« Vinaigre balsamique blanc / riz »** : noté vinaigre de riz dans le
  Mijoté abricots, le Gyudon et le Riz sauté broccolini, vinaigre balsamique blanc dans le Bibimbap
  et l'Orzotto toscane.
