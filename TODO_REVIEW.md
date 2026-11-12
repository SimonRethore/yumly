# TODO REVIEW

## Fonctionnalités

- Liste de courses : un même ingrédient saisi dans des unités de dimensions différentes ne fusionne pas. C’est le cas des poivrons (pièces / g), de la tomate (pièces / kg), du sucre vanillé (sachet / g) et du concentré de tomates (g / c. à c. / c. à s.). Harmoniser les unités dans les recettes, ou accepter des lignes séparées.
- `restTimeMinutes` est inclus dans la durée totale : le poulet tandoori (marinade de 8 h) affiche plus de 9 h et le kebab (3 h) plus de 3 h 50. Faut-il distinguer marinade et repos ?

## Recettes

Légende : **A** = arbitrage fait lors de la saisie (à confirmer), **?** = ambiguïté à trancher.

### Petit-déjeuner

- **Tartines avocat et œuf mollet** — ? Aucune origine renseignée (pas de drapeau).
- **Bagel saumon avocat** — ? « Philadelphia » est une marque : garder ce nom ou mettre « fromage frais » ?

### Entrées / apéritif

- **Pain à l’ail** — A : version garlic bread (baguette en accordéon), classée en apéritif avec l’origine « Américain ». ? Le « Préfou à l’ail » (vendéen) a disparu de `TODO_RECIPES.md` : est-ce cette recette qui le remplace ? Le « Naan à l’ail » reste à faire à part.
- **Cake jambon et olives** — ? Ni sel ni poivre dans la recette source.
- **Cake pesto et lardons** — A : 10 personnes (taille de part apéritif), contre 6 pour les deux autres cakes.
- **Samoussas au bœuf** — A : 10 samoussas (2 par feuille de brick) ; variante au four (200 °C, 10 à 15 min) ajoutée ; « huile de friture » notée huile de tournesol « pour la cuisson » ; origine « Indien » ; classés en apéritif, toute l’année.

### Plats

- **Lasagnes à la bolognaise** — A : sauce bolognaise toute prête en plus du bœuf haché. ? 6 feuilles seulement pour 4 personnes, et 125 g de beurre pour 2 c. à s. de farine dans la béchamel : proportions de la source, à vérifier.
- **Chili con carne** — A : eau du bouillon ramenée à 7,5 cl par personne.
- **Croque-monsieur** — A : béchamel toute prête (50 cl).
- **Bruschetta** — ? C’est en réalité un pain gratiné au bœuf haché et au cheddar : garder le titre « Bruschetta » et l’origine « Italien » ? La sauce tomate aux olives n’a pas de quantité.
- **Poulet au curry et lait de coco** — A : riz basmati ajouté (300 g) ; lait de coco « léger de préférence » (source minceur).
- **Galette complète bretonne** — A : 1 personne (1 galette).
- **Makis** — A : comptés en pièces, 48 makis (8 demi-feuilles de nori × 6 morceaux, la source disait « environ 50 » pour 4 personnes) ; eau du riz à 13 cl pour 100 g ; assaisonnement du riz aligné sur les nigiri (15 ml de vinaigre et 8 g de sucre pour 100 g de riz, au lieu de 12 ml et 5 g), soit 7,5 cl de vinaigre et 40 g de sucre.
- **Dahl de lentilles corail & œufs** — ? Les « herbes fraîches » de l’étape 6 ne sont pas dans les ingrédients.
- **Chakchouka** — ? Semoule couverte du « même volume d’eau » : le volume n’est pas déduisible des 280 g de la liste.
- **Poulet tikka massala** — A : remplacée par la version RecipeTin Eats (l’ancienne manquait de goût), à retester. 4 personnes (source : 4 à 5) ; huile de la sauce ramenée à 3 c. à s. françaises (source : 65 ml) ; gingembre (1 + 2 c. à s. râpé) converti en 6 cm ; eau de la sauce à 10 cl par personne (400 ml pour 4) ; cardamome facultative ; riz basmati ajouté à la liste. ? Recette riche (80 g de beurre) : réduire le beurre ? La photo est celle de l’ancienne version.
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
- **Soupe poireaux pommes de terre** — A : 6 personnes (source : 5 à 8) ; 1,5 L de bouillon « pauvre en sel » remplacé par 3 cubes de volaille (25 cl d’eau par personne), donc sel « au goût » au lieu d’1 c. à c. ; crème 18 cl arrondie à 20 cl pour le filet du service ; croûtons au beurre (15 g ajoutés) ; classée en plat.
- **Soupe de butternut** — A : 2½ lb de cubes convertis en 1 grosse butternut (~1,5 kg entière, ~1,1 kg de cubes) ; 5 cups d’eau → 20 cl par personne ; crème 1 cup (24 cl) arrondie à 25 cl ; thym « 1 c. à s. haché » noté « quelques brins » ; curry en alternative dans l’étape, absent de la liste ; origine « Américain » (source américaine) ; classée en plat, mois d’octobre à février.
- **Velouté de potimarron** — A : potimarron non épluché (la source le pèle) ; sachet de gaze remplacé par une boule à thé ; « 5 grains de poivre » notés dans la ligne Poivre ; ciboulette « 6 brins » notée « quelques brins » ; classé en plat, mois de septembre à février.
- **Curry de crevettes au lait de coco** — A : huile végétale (ou ghee) notée huile de tournesol ; riz basmati ajouté à la liste (300 g, comme le poulet au curry) ; origine « Indien » ; toute l’année.
- **Tagliatelles au saumon à la sauce au citron** — A : cuisson du saumon réduite (source : 10 min puis 5 min dans la sauce, donc saumon sec) à 3-4 min saisi puis 2-3 min dans la sauce, d’où 15 min de cuisson au lieu de 20 ; zeste de citron ajouté, d’où 1 citron entier au lieu de 2 c. à s. de jus ; parmesan (cité dans la source mais pas listé) ajouté en facultatif ; origine « Italien ».
- **Nigiri au saumon** — A : cuisson du riz reprise des makis (trempage 30 min, 13 cl d’eau pour 100 g, 15 min de cuisson + 15 min de repos) au lieu de la source (sans trempage, 15 cl d’eau, 20 + 5 min) ; assaisonnement de la source gardé mais chauffé au micro-ondes comme les makis ; 1 g de sel noté 1 pincée ; wasabi en tube au lieu de la poudre ; sauce soja et gingembre mariné ajoutés pour le service ; riz façonné tiède. ? Source en anglais (école de cuisine montréalaise).
- **Wok de nouilles sautées sauce cacahuètes** — A : « 1 tête d’ail » de la box notée 2 gousses ; 1,2 oignon nouveau arrondi à 1 ; origine « Chinois » (non précisée par la source) ; 25 min réparties en 15 min de préparation et 10 min de cuisson. Sauce augmentée d’environ 1,5 fois, car les avis trouvent le plat sec : beurre de cacahuète à 45 g (les « 2 tubes » de la source sont estimés à ~30 g d’après les valeurs nutritionnelles), sauce soja 2,5 cl au lieu de 2, eau de cuisson ⅓ de louche par personne au lieu de ¼. ? Pas de protéine : ajouter du tofu fumé ou un œuf ?
- **Rougail saucisse** — A : recette Papounet adaptée à la métropole selon ses propres conseils : saucisses de Montbéliard ou de Morteau au lieu des saucisses pays, d’où l’ail (3 gousses), le gingembre (10 g) et le thym ajoutés ; zeste de citron vert à la place du combava ; 4 personnes et 700 g de saucisses (la source ne donne ni portions ni poids, « 8 saucisses pays ») ; réduction sans eau ; riz basmati pour fusionner avec les autres recettes ; origine « Réunionnais » rattachée au drapeau français.
- **Orzotto aux crevettes à la toscane** — A : contenus des « paquets » et « sachets » de la box estimés : crevettes 160 g (comme l’orzo ail-citron), tomates semi-séchées 50 g, épinards 100 g, copeaux de grana padano 20 g (recoupé avec les valeurs nutritionnelles) ; « épices italiennes » pimentées (recette classée « Épicé ») remplacées par 1 c. à s. d’herbes italiennes et 1 pincée de piment concassé par personne, répartis en deux fois ; 400 ml de bouillon → 1 cube, 27 cl d’eau pour 100 g d’orzo ; 2 c. à c. de beurre → 10 g ; 15 min de préparation et 25 min de cuisson (source : 40 min au total).
- **Nouilles au bœuf haché façon dan dan** — A : contenus de la box estimés comme pour le wok de nouilles : bœuf haché 240 g (« 1 paquet », cohérent avec les valeurs nutritionnelles), beurre de cacahuète 30 g (« 2 pots »), cacahuètes 20 g ; sauce soja 3 cl (« 1 sachet », estimé d’après le sel des valeurs nutritionnelles : 3,5 g par portion, contre 2,4 g pour le wok à 2 cl) ; « 1 tête d’ail » notée 2 gousses ; ⅔ sachet de coriandre moulue noté 1 c. à c. ; 15 min de préparation et 10 min de cuisson (source incohérente : 25 min de préparation pour 20 min au total) ; difficulté « moyen » reprise de la source. ? Version très éloignée du dan dan sichuanais (ni poivre du Sichuan, ni huile pimentée, ni légumes salés) : garder « façon dan dan » ?
- **Riz sauté au broccolini & champignons** — A : contenus de la box estimés et recoupés avec les valeurs nutritionnelles (696 kcal, 30 g de lipides par portion) : broccolini 150 g (« 1 sachet »), huile de sésame 1 cl (« 1 sachet »), cacahuètes 20 g ; sauce soja 2 cl (10 ml par personne dans l’étape) ; « sauce asiatique sucrée » remplacée par 2 c. à s. de kecap manis (plat végétarien, donc pas de sauce d’huître) ; sriracha 2 c. à c. (« 1 sachet ») ; oignon nouveau 25 g → 1 pièce ; « vinaigre balsamique blanc / riz » noté vinaigre de riz ; 10 min de préparation et 25 min de cuisson (source incohérente : 35 min de préparation pour 30 min au total) ; difficulté « moyen » reprise de la source ; toute l’année (broccolini disponible en continu).
- **Mijoté de porc aux petits pois & paprika fumé** — A : contenus de la box estimés et recoupés avec les valeurs nutritionnelles (784 kcal, 34 g de lipides, 39 g de protéines par portion) : porc 250 g (« 1 paquet »), petits pois 1 boîte de 400 g (280 g égouttés), crème liquide 20 cl (« 1 paquet », comme le mijoté aux abricots), concentré de tomates 35 g (« ½ sachet », comme le mafé) ; paprika fumé et herbes de Provence 1 c. à c. chacun (« ½ sachet ») ; persil « quelques brins » ; riz jasmin gardé (précisé par la source, cuisson par absorption 15 cl par personne → 20 cl pour 100 g), donc ne fusionne pas avec le riz basmati ; 10 min de préparation et 25 min de cuisson (source : 25 min au total, mais le riz seul prend 25 min avec le repos) ; cassonade en c. à c. (en c. à s. dans les autres recettes, ne fusionne pas) ; porc « mariné à la mexicaine » de la box remplacé par des émincés nature dorés avec ½ c. à c. d’épices mexicaines par personne ; crème « légère de préférence » (les lipides de la source ne collent qu’avec une crème à 15 %).

### Desserts

- **Crêpes** — ? Pas de source ; sucre en poudre sans quantité ; l’étape 6 ajoute « un peu de lait » au-delà des 70 cl. A : classées en dessert ; 15 crêpes estimées d’après une pâte de référence (200 g de farine, 70 g de cassonade, 2 œufs, 35 cl de lait → 7 crêpes), au poids total de pâte.
- **Brioche perdue** — ? « Sachet de sucre vanillé » en 50 g (environ 7 sachets) : sucre vanillé en vrac ? Ne fusionne pas avec les sachets des autres recettes.
- **Cookies** — ? 4 personnes, mais combien de cookies, pour compter en pièces (`servingsUnit`) ?
- **Brownies aux noix** — ? Vérifier que 100 g de noix suffisent : quantité estimée (la source dit « 1 grosse poignée »).
- **Gâteau au yaourt** — A : huile d’olive de la source remplacée par de l’huile de tournesol ; « pots » convertis en grammes (sucre 200 g, farine 210 g, huile 6 cl, levure 5 g pour ½ sachet) ; moule 22-24 cm et vérification au couteau dès 30 min ajoutés.
- **Crème brûlée** — ? 50 g de sucre gardés comme dans la source, à goûter : fourchette basse des recettes comparées (40 à 100 g pour 50 cl de liquide, médiane vers 75-80 g ; Pierre Hermé ~90 g, Norbert Tarayre 60 g) ; un commentaire de la source passe à 70 g, bon compromis si la crème manque de sucre. ? Cuisson 25 min adaptée à des ramequins peu profonds : ajouter le repère « bords pris, centre encore tremblotant » ? ? Les 6 blancs restent inutilisés. A : 6 œufs entiers dans la liste de courses (jaunes seuls dans la recette) ; difficulté « moyen » (bain-marie, chalumeau) ; les 4 h de réfrigération comptent dans la durée totale.
- **Cannelés bordelais** — A : recette de la source divisée par deux, 12 cannelés (source : 25 gros, donc 12,5) ; beurre de cacao des moules remplacé par du beurre fondu, 20 g ajoutés à la liste pour les moules ; rhum ambré 80 g → 4 cl ; « une nuit » de repos comptée 12 h dans la durée ; four à chaleur tournante 200 °C / 45 min (gros cannelés, moule silicone dans la source).
