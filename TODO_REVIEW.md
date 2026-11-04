# TODO REVIEW

## Fonctionnalités

- Unité de portion : l’application compte toujours en personnes (`servingsLabel`). Ajouter un champ du type `servingsUnit` pour afficher « 12 muffins » plutôt que « 6 personnes » (muffins, crêpes, pancakes, cookies).
- Liste de courses : un même ingrédient saisi dans des unités de dimensions différentes ne fusionne pas. C’est le cas des poivrons (pièces / g), de la tomate (pièces / kg), du sucre vanillé (sachet / g) et du concentré de tomates (g / c. à c. / c. à s.). Harmoniser les unités dans les recettes, ou accepter des lignes séparées.
- `restTimeMinutes` est inclus dans la durée totale : le poulet tandoori (marinade de 8 h) affiche plus de 9 h et le kebab (3 h) plus de 3 h 50. Faut-il distinguer marinade et repos ?

## Recettes

Légende : **A** = arbitrage fait lors de la saisie (à confirmer), **?** = ambiguïté à trancher.

### Petit-déjeuner

- **Tartines avocat et œuf mollet** — ? Aucune origine renseignée (pas de drapeau).
- **Pancake** — A : 4 personnes pour environ 12 pancakes (voir `servingsUnit`).
- **Muffins aux pépites de chocolat** — A : 6 personnes pour 12 muffins (voir `servingsUnit`).
- **Bagel saumon avocat** — ? « Philadelphia » est une marque : garder ce nom ou mettre « fromage frais » ?

### Entrées / apéritif

- **Pain à l’ail** — A : version garlic bread (baguette en accordéon), classée en apéritif avec l’origine « Américain ». ? Le « Préfou à l’ail » (vendéen) a disparu de `TODO_RECIPES.md` : est-ce cette recette qui le remplace ? Le « Naan à l’ail » reste à faire à part.
- **Cake jambon et olives** — ? Ni sel ni poivre dans la recette source.
- **Cake pesto et lardons** — A : 10 personnes (taille de part apéritif), contre 6 pour les deux autres cakes.

### Plats

- **Lasagnes à la bolognaise** — A : sauce bolognaise toute prête en plus du bœuf haché. ? 6 feuilles seulement pour 4 personnes, et 125 g de beurre pour 2 c. à s. de farine dans la béchamel : proportions de la source, à vérifier.
- **Chili con carne** — A : eau du bouillon ramenée à 7,5 cl par personne.
- **Croque-monsieur** — A : béchamel toute prête (50 cl).
- **Bruschetta** — ? C’est en réalité un pain gratiné au bœuf haché et au cheddar : garder le titre « Bruschetta » et l’origine « Italien » ? La sauce tomate aux olives n’a pas de quantité.
- **Poulet au curry et lait de coco** — A : riz basmati ajouté (300 g) ; lait de coco « léger de préférence » (source minceur).
- **Galette complète bretonne** — A : 1 personne (1 galette).
- **Makis** — A : 4 personnes pour environ 50 makis ; eau du riz à 13 cl pour 100 g.
- **Dahl de lentilles corail & œufs** — ? Les « herbes fraîches » de l’étape 6 ne sont pas dans les ingrédients.
- **Chakchouka** — ? Semoule couverte du « même volume d’eau » : le volume n’est pas déduisible des 280 g de la liste.
- **Poulet tikka massala** — A : riz basmati ajouté ; naans mentionnés en option, absents de la liste.
- **Porc épicé à la mexicaine** — A : chair à saucisse à la place du porc haché HelloFresh.
- **Gratin de raviolis à la ratatouille** — ? Le titre dit « raviolis » (la source, « ravioles ») mais l’ingrédient est « Tortellini au pesto ». 3 personnes.
- **Gnocchi au poulet, pesto rosso** — A : parmesan et persil facultatifs.
- **Mafé revisité** — A : origine « Malien » (le mafé est aussi sénégalais) ; laurier facultatif.
- **Pizza bourguignonne** — A : recette reconstituée d’après la pizza Basilic & Co, sans source. ? Quantités à valider en la réalisant.
- **Burritos** — ? 1,5 poivron.
- **Gyros de poulet** — A : tzatziki acheté (200 g) plutôt que fait maison ; cuisson au four, avec une variante « broche ».
- **Pâtes carbonara à la française** — A : version à la crème fraîche et à l’oignon, pas la carbonara italienne ; les blancs d’œufs ne servent pas.
- **Mijoté de poulet & confit d’abricots** — A : vinaigre de riz, ou balsamique blanc ; origine « Marocain ».
- **Orzo & crevettes** — A : vinaigre de vin blanc, ou vin blanc ; 2 cubes de bouillon.
- **Boulgour pilaf aux légumes** — A : origine « Turc » ; les 30 min de repos sont comptées en `restTimeMinutes`.
- **Bibimbap** — A : chair à saucisse pour le porc haché, riz basmati au lieu du riz rond, vinaigre balsamique blanc.
- **Poulet basquaise** — ? Aucun accompagnement (riz ?).
- **Boulettes de viande à la sauce tomate** — A : bœuf haché à la place du veau de la source ; boîte de 796 ml de tomates italiennes entières → 800 g de tomates pelées ; mesures canadiennes converties (60 ml de lait → 6 cl, ¼ tasse de persil → 4 c. à s.). ? Fenouil moulu difficile à trouver (graines pilées, ou à omettre) ; piment concassé en c. à c. ici, en pincée ailleurs (ne fusionne pas) ; 6 personnes selon la source pour 450 g de viande, plutôt 4 avec des pâtes.
- **Aiguillettes de poulet façon teriyaki** — A : recette retenue pour l’entrée « Poulet Teryaki » de la TODO.
- **Gyudon** — A : riz basmati au lieu du riz japonais.
- **Kebab** — A : épaule d’agneau (on aurait aussi pu prendre du veau ou du poulet), marinade de 3 h minimum.
- **Poulet tandoori** — A : riz basmati ajouté ; marinade de 8 h comptée en repos.
- **Burger poulet bacon** — A : recette maison sans source, retenue pour l’entrée « Burger » de la TODO.
- **Poke bowl au saumon** — ? Pas d’image.
- **Pâtes au pesto, petits pois & burrata** — ? Pas d’image ; petits pois classés en surgelés.
- **Enchiladas au poulet** — A : tortillas de maïs, sauce enchilada maison (roux + coulis).

### Desserts

- **Crêpes** — ? Pas de source ; sucre en poudre sans quantité ; l’étape 6 ajoute « un peu de lait » au-delà des 70 cl. A : classées en dessert, 6 personnes (voir `servingsUnit`).
- **Brioche perdue** — ? « Sachet de sucre vanillé » en 50 g (environ 7 sachets) : sucre vanillé en vrac ? Ne fusionne pas avec les sachets des autres recettes.
- **Cookies** — ? 4 personnes, mais combien de cookies ?
- **Brownies aux noix** — ? Vérifier que 100 g de noix suffisent : quantité estimée (la source dit « 1 grosse poignée »).
- **Gâteau au yaourt** — A : huile d’olive de la source remplacée par de l’huile de tournesol ; « pots » convertis en grammes (sucre 200 g, farine 210 g, huile 6 cl, levure 5 g pour ½ sachet) ; moule 22-24 cm et vérification au couteau dès 30 min ajoutés.
- **Crème brûlée** — ? 50 g de sucre gardés comme dans la source, à goûter : fourchette basse des recettes comparées (40 à 100 g pour 50 cl de liquide, médiane vers 75-80 g ; Pierre Hermé ~90 g, Norbert Tarayre 60 g) ; un commentaire de la source passe à 70 g, bon compromis si la crème manque de sucre. ? Cuisson 25 min adaptée à des ramequins peu profonds : ajouter le repère « bords pris, centre encore tremblotant » ? ? Les 6 blancs restent inutilisés. A : 6 œufs entiers dans la liste de courses (jaunes seuls dans la recette) ; difficulté « moyen » (bain-marie, chalumeau) ; les 4 h de réfrigération comptent dans la durée totale.
