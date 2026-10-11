# Yumly --- Spécification fonctionnelle et technique

**Version :** 1.0\
**Langue de l'application et de la documentation :** français\
**Plateformes cibles :** iOS et Android\
**Technologie principale :** Flutter / Dart\
**Mode de fonctionnement :** hors ligne, sans compte, sans backend

------------------------------------------------------------------------

## 0. Instructions à Claude Code

Tu dois utiliser ce document comme référence produit pour concevoir et
implémenter Yumly.

### Règles de travail

1.  Commence par inspecter le dépôt existant : fichiers, dépendances,
    conventions, tests et éventuel code déjà présent. Ne remplace pas
    aveuglément une architecture existante.
2.  Si le dépôt est vide, initialise une application Flutter stable pour
    iOS et Android.
3.  Avant toute implémentation importante, présente brièvement le plan
    et les éventuelles décisions techniques qui changent le périmètre.
4.  Respecte les règles fonctionnelles, le modèle de données et la
    charte graphique définis ici. Si un détail reste incertain, utilise
    les hypothèses indiquées dans la section 15 et documente ton choix.
5.  Développe par étapes petites et testables. Exécute les tests et les
    analyseurs après chaque étape importante.
6.  Ne crée ni compte utilisateur, ni backend, ni API, ni base de
    données distante. Le catalogue est intégré à l'application.
7.  Ne télécharge pas d'images de recettes depuis Internet et n'invente
    pas de fichiers de logo. Utilise uniquement les assets présents dans
    le dépôt ou fournis par le propriétaire. Si un asset manque, crée un
    emplacement documenté et utilise un placeholder cohérent avec la
    charte.
8.  Ne considère pas une fonctionnalité comme terminée tant que ses
    critères d'acceptation ne sont pas satisfaits.
9.  Toutes les chaînes visibles par l'utilisateur doivent être en
    français.
10. Mets à jour le README avec les commandes d'installation, de test et
    de lancement.

### Livrables attendus

-   Application Flutter compilable sur iOS et Android.
-   Code organisé, maintenable et commenté lorsque cela apporte une
    réelle valeur.
-   Catalogue de démonstration local clairement identifié comme données
    d'exemple si aucun véritable catalogue n'est fourni.
-   Tests unitaires, tests de widgets et, pour les parcours essentiels,
    tests d'intégration.
-   README et documentation du format des recettes.
-   Rapport final indiquant ce qui est réalisé, les tests exécutés, les
    limites et les assets manquants.

------------------------------------------------------------------------

## 1. Vision du produit

Yumly est une application mobile française qui aide à découvrir des
recettes, les consulter, ajuster les quantités selon le nombre de
convives, choisir des recettes favorites et préparer une liste de
courses.

Principes : - Une seule base de code Flutter pour iOS et Android. -
Utilisation hors ligne après installation. - Aucun compte, serveur ou
service distant. - Catalogue de recettes et photos intégrés à
l'application au moment de la compilation. - Favoris, liste de courses
et état de la liste conservés localement sur l'appareil. - Interface
chaleureuse, gourmande, simple et accessible. - Interface uniquement en
français pour la première version.

### Hors périmètre de la première version

-   Synchronisation entre appareils.
-   Connexion et profils utilisateur.
-   Backend, API et base de données distante.
-   Import de recettes CSV ou JSON depuis l'interface.
-   Téléchargement d'images ou de recettes.
-   Partage social intégré, commentaires et notation des recettes.
-   Création ou modification de recettes depuis l'application.
-   Planification de menus sur un calendrier, sauf ajout ultérieur
    explicite.
-   Comptes, paiements et publicité.

------------------------------------------------------------------------

## 2. Plateformes et contraintes générales

-   Flutter stable et version de Dart compatible avec le SDK Flutter
    choisi.
-   Cibles iOS et Android.
-   Interface adaptée aux tailles d'écran courantes, aux zones de
    sécurité et aux claviers virtuels.
-   Aucun besoin de connexion Internet pour consulter le catalogue ou
    gérer la liste de courses.
-   L'application ne doit pas dépendre d'un service distant pour
    démarrer.
-   Respecter les conventions de navigation et de retour propres à
    chaque plateforme.
-   Les permissions doivent être minimales. Aucun accès à la
    localisation, aux contacts, à la caméra ou aux photos n'est
    nécessaire pour le périmètre initial.
-   Gérer les états de chargement, listes vides, erreurs et contenus
    manquants sans écran bloqué.
-   Respecter les tailles de texte système lorsque c'est possible et
    assurer un contraste lisible.

------------------------------------------------------------------------

## 3. Charte graphique Yumly

La référence est l'image de charte graphique fournie dans la
conversation. Aucun lien externe n'a été communiqué : la valeur « xxxx »
est un placeholder et ne doit pas être présentée comme une URL valide.

### 3.1 Identité

-   Logo illustré : toque jaune souriante, détails verts, lettrage «
    Yumly » vert.
-   Univers visuel : gourmand, bienveillant, frais, énergique, simple et
    convivial.
-   Préférer les surfaces crème, les grands visuels culinaires, les
    coins arrondis et une hiérarchie visuelle aérée.
-   Éviter les interfaces froides, trop techniques, surchargées ou
    enfantines.
-   Les photos des recettes sont importantes et doivent rester
    visuellement dominantes dans les cartes et fiches.

### 3.2 Palette de référence

Les codes ci-dessous sont lus sur la charte fournie et sont à considérer
comme les valeurs de référence de départ. Les faire centraliser dans un
thème, sans valeurs dispersées dans les widgets.

  -----------------------------------------------------------------------
  Nom                     Code                    Utilisation proposée
  ----------------------- ----------------------- -----------------------
  Jaune Soleil            `#FFB51B`               Actions principales,
                                                  accents, icônes de
                                                  recette

  Vert Forêt              `#0F5D46`               Couleur de marque,
                                                  titres, navigation et
                                                  actions secondaires

  Crème                   `#FFF8EF`               Fond chaleureux et
                                                  surfaces douces

  Corail                  `#FF6B5B`               Accent ponctuel,
                                                  alertes non critiques
                                                  ou éléments expressifs

  Vert Sauge              `#A7C557`               Accent secondaire,
                                                  badges saisonniers ou
                                                  végétaux

  Blanc                   `#FFFFFF`               Cartes et surfaces de
                                                  lecture si nécessaire

  Texte foncé             à définir à partir du   Texte principal avec
                          thème                   contraste suffisant

  Texte secondaire        à définir à partir du   Métadonnées, libellés
                          thème                   secondaires
  -----------------------------------------------------------------------

Les valeurs devront être vérifiées contre les fichiers sources de la
charte s'ils sont fournis ultérieurement. Pour la lisibilité, ne pas
utiliser le jaune ou le sauge comme couleur de texte sur un fond clair.

### 3.3 Typographies

-   **Fredoka** : titres, logo textuel éventuel et éléments éditoriaux.
-   **Inter** : textes courants, boutons, libellés, filtres, quantités
    et listes.
-   Les fichiers de police ne sont pas inclus dans l'image de charte. Si
    les fichiers officiels sont absents du dépôt, documenter leur
    emplacement attendu et utiliser une solution temporaire clairement
    signalée. Ne pas prétendre avoir intégré les fichiers officiels sans
    les avoir.
-   Le logo officiel doit être utilisé comme asset image/vectoriel s'il
    est disponible. Ne pas tenter de le reproduire avec une police.

### 3.4 Principes d'interface

-   Cartes de recettes à coins arrondis.
-   Boutons tactiles confortables, idéalement d'au moins 44--48 px de
    hauteur.
-   Titres en Fredoka, contenu en Inter.
-   Utilisation modérée des ombres ; privilégier les surfaces et
    espacements.
-   Photos cadrées proprement, avec une stratégie de repli si elles
    manquent.
-   Icônes simples, cohérentes et issues d'un même système.
-   Couleur, icône et texte peuvent se compléter ; ne jamais communiquer
    une information uniquement par la couleur.
-   Prévoir des états visibles pour les filtres actifs, favoris,
    éléments cochés et actions effectuées.
-   Les écrans doivent être conçus pour téléphone en priorité, avec
    défilement naturel.

### 3.5 Assets

Prévoir une structure telle que : - `assets/branding/` : logo, icône
d'application et assets de marque fournis. - `assets/fonts/` : fichiers
Fredoka et Inter sous licence appropriée. - `assets/recipes/` : photos
des recettes. - `assets/data/recipes.json` : catalogue intégré. -
`assets/placeholders/` : image de repli si nécessaire.

Configurer explicitement les assets dans `pubspec.yaml`. Ne pas inventer
les fichiers réels : si le dépôt ne les contient pas, fournir un
placeholder propre et documenter les éléments attendus.

------------------------------------------------------------------------

## 4. Navigation et structure générale

Prévoir une navigation principale persistante avec quatre destinations
: 1. **Accueil** : découverte et catalogue de recettes. 2. **Favoris** :
recettes marquées comme favorites. 3. **Liste de courses** : recettes
prévues, portions et accès aux ingrédients. 4. **Paramètres** :
informations de l'application et préférences locales simples, si utiles.

Le bouton d'accès à la liste de courses doit être disponible sur les
écrans principaux, y compris le catalogue et le détail d'une recette. La
navigation peut inclure un badge indiquant le nombre de recettes dans la
liste active.

La liste de courses comporte deux vues distinctes : - **Recettes
sélectionnées** : gestion des recettes ajoutées et de leurs portions. -
**Ingrédients à acheter** : ingrédients regroupés par catégories, cases
à cocher et action de copie.

Ne pas confondre la liste de recettes planifiées et la liste consolidée
des produits à acheter.

### Navigation attendue

-   Catalogue → détail d'une recette.
-   Catalogue ou détail → ajout à la liste active.
-   N'importe quel écran principal → liste de courses active.
-   Liste active → écran des ingrédients.
-   Catalogue ou détail → bascule favori.
-   Favoris → détail d'une recette.
-   Retour système → écran précédent sans perdre les modifications
    locales.

------------------------------------------------------------------------

## 5. Écrans et exigences fonctionnelles

### 5.1 Accueil / catalogue

Contenu : - En-tête de marque Yumly. - Barre de recherche textuelle. -
Accès aux filtres. - Affichage des filtres actifs sous forme de
pastilles supprimables. - Liste ou grille adaptative de cartes de
recettes. - Accès rapide aux favoris et à la liste de courses. -
Éventuellement une section éditoriale « De saison » si les données
permettent de la calculer sans inventer de recommandation.

Chaque carte de recette affiche : - Photo. - Titre. - Durée totale,
calculée comme préparation + cuisson + repos. - Difficulté si
renseignée. - Un ou plusieurs badges pertinents, sans surcharger la
carte. - Bouton favori. - Action d'ajout à la liste de courses.

Comportements : - Toucher la carte ouvre le détail. - Toucher le bouton
favori active ou retire le favori, avec retour visuel. - Ajouter une
recette à la liste ajoute la recette au panier de recettes actives ou
met à jour l'entrée existante selon la règle de dédoublonnage de la
section 8. - La recherche se fait localement et met à jour les résultats
sans requête réseau. - Les filtres sont combinables. - Si aucun résultat
ne correspond, afficher un message en français et une action pour
effacer les filtres. - Les listes doivent rester fluides pour un
catalogue de taille raisonnable.

Recherche : - Insensible à la casse. - Insensible aux accents, par
exemple « creme » doit retrouver « crème ». - Cherche au minimum dans le
titre et la description ; chercher aussi dans les noms d'ingrédients est
recommandé. - Le filtrage doit s'appliquer au catalogue complet et non
seulement aux éléments actuellement visibles.

### 5.2 Filtres

Filtres disponibles, lorsque les données correspondantes existent : -
Régime : végétarien, végan. - Origine / cuisine : indien, mexicain,
etc. - Service / type de plat : entrée, plat, dessert, accompagnement,
etc. - Mois de saisonnalité : janvier à décembre. - Saison : printemps,
été, automne, hiver. - Difficulté : facile, moyen, difficile, ou valeurs
explicitement présentes dans le catalogue. - Temps de cuisson :
intervalle ou seuil défini dans l'interface.

Règles : - Les options sont calculées à partir des valeurs distinctes
présentes dans le catalogue chargé. - Ne pas afficher une option sans
aucune recette correspondante. - Les valeurs sont triées de manière
lisible et stable : ordre naturel pour les mois et les saisons, ordre
alphabétique pour les origines, ordre défini pour les niveaux de
difficulté. - Plusieurs valeurs dans une même famille de filtres sont
combinées en OU, si cela correspond au comportement attendu de
l'interface ; les familles de filtres sont combinées en ET. - Exemple :
« indien OU mexicain » ET « végan » ET « dessert ». - Les options
choisies restent visibles comme filtres actifs. - Effacer un filtre ne
doit pas réinitialiser les autres. - Prévoir une action globale «
Réinitialiser les filtres ». - Le nombre de résultats peut être
affiché. - La valeur « végétarien » ne doit pas être déduite uniquement
de l'absence de viande si les données ne le garantissent pas. Utiliser
les métadonnées du catalogue.

### 5.3 Détail d'une recette

Afficher : - Photo principale. - Titre et description. - Origine,
régime, type de plat, saison, mois, difficulté et autres métadonnées
disponibles. - Durée de préparation. - Durée de cuisson. - Durée de
repos. - Durée totale. - Nombre de personnes sélectionné. - Liste des
ingrédients et quantités ajustées. - Étapes ordonnées. - Équipements
nécessaires. - Action favori. - Action « Ajouter à la liste de courses
». - Accès à la liste de courses.

Sélecteur de portions : - Valeur initiale égale à `defaultServings`. -
Permet d'augmenter ou diminuer le nombre de personnes. - Minimum : 1
personne. - Maximum recommandé : 100 personnes, sauf décision
différente. - Le nombre de personnes est un entier. - Les quantités sont
recalculées immédiatement. - Les quantités affichées sur la fiche ne
doivent pas modifier les données de base du catalogue. - Si
l'utilisateur ajoute la recette à la liste, le nombre de portions
courant devient celui de cette entrée de liste.

Étapes : - Afficher les étapes dans l'ordre défini par `order`. - Ne pas
fusionner ni réordonner les étapes. - Prendre en charge des descriptions
sur plusieurs lignes. - Les durées d'étape et les images d'étape sont
hors périmètre sauf si les données futures les fournissent.

Équipements : - Afficher uniquement les équipements fournis par la
recette. - Masquer la section si la liste est vide.

### 5.4 Favoris

-   L'utilisateur peut marquer une recette comme favorite depuis la
    carte et le détail.
-   Une recette favorite est visible dans l'écran Favoris.
-   Les favoris persistent après redémarrage.
-   Retirer un favori le retire de la liste Favoris mais ne le retire
    pas de la liste de courses.
-   Si un identifiant de recette favori n'existe plus dans le catalogue
    après une mise à jour de l'application, ignorer cet identifiant sans
    faire planter l'écran.
-   État vide : expliquer comment ajouter une recette en favori.

### 5.5 Liste de courses --- recettes sélectionnées

Chaque entrée contient : - Identifiant de recette. - Nombre de personnes
retenu pour cette entrée. - Éventuellement la date d'ajout si utile,
mais aucune date n'est nécessaire au fonctionnement minimal.

Afficher : - Miniature de la recette. - Titre. - Nombre de personnes. -
Contrôle de portions. - Action de suppression. - Bouton principal en bas
: « Voir les ingrédients à acheter ».

Comportements : - Une recette ne peut apparaître qu'une seule fois dans
la liste active. - Ajouter une recette déjà présente ne crée pas de
doublon : conserver son entrée et mettre à jour ses portions avec le
nombre courant choisi sur la fiche, ou afficher un retour clair
permettant de conserver le nombre déjà défini. Pour la première version,
appliquer une règle simple : l'ajout d'une recette déjà présente met à
jour ses portions avec le nombre courant et affiche une confirmation
discrète. - Modifier les portions recalcule la liste consolidée. -
Supprimer une recette met à jour immédiatement la liste. - La liste
persiste après fermeture et redémarrage. - Retirer une recette de la
liste de courses ne retire pas le favori correspondant. - Si la liste
est vide, afficher un état vide avec une action de retour au
catalogue. - Le bouton d'accès à la liste indique éventuellement le
nombre de recettes sélectionnées.

### 5.6 Liste de courses --- ingrédients à acheter

But : présenter les ingrédients consolidés de toutes les recettes
actives, regroupés par catégorie de produits.

Chaque ligne d'ingrédient affiche : - Une case à cocher. - Le nom de
l'ingrédient. - La quantité totale et son unité, si disponibles. - Une
catégorie de produit.

Catégories de départ recommandées : - Fruits et légumes. - Épicerie
sèche. - Produits frais. - Produits laitiers et alternatives
végétales. - Viandes et poissons. - Boulangerie. - Épices et
condiments. - Surgelés. - Boissons. - Autres.

Les catégories ne sont pas obligatoirement toutes affichées : ne montrer
que celles contenant au moins un ingrédient. L'ordre des catégories doit
être défini de façon stable.

Regroupement : - Fusionner les ingrédients uniquement si leur identité
normalisée est la même et que leurs unités sont compatibles. - Utiliser
`ingredientId` comme identifiant de regroupement prioritaire. Si deux
ingrédients ont le même nom mais des identifiants distincts, ne pas les
fusionner automatiquement. - La normalisation des noms sert à la
recherche et au repli, pas à remplacer les identifiants. - Ne jamais
additionner directement des quantités en grammes et en millilitres, ni
des unités incompatibles. - Les conversions ne doivent être appliquées
que pour des unités de même dimension et selon des règles explicites. -
Les ingrédients sans quantité ou sans unité restent affichés sans
inventer de valeur. - Les quantités sont calculées à partir des portions
de chaque entrée de recette. - Les ingrédients provenant de recettes
différentes mais partageant le même `ingredientId` et une unité
compatible sont fusionnés. - Le nom affiché provient du libellé
canonique de l'ingrédient dans les données.

Cases à cocher : - Cocher un produit indique qu'il a été acheté. -
L'état coché persiste localement. - Si la liste consolidée change, les
ingrédients qui existent toujours doivent conserver leur état coché
lorsqu'ils restent identifiables par la même clé d'ingrédient et
d'unité. - Si un ingrédient disparaît parce qu'une recette est retirée,
sa ligne disparaît. S'il réapparaît plus tard, l'état antérieur peut
être réinitialisé ; la priorité est de ne pas conserver un état obsolète
de manière surprenante. - Fournir une action « Tout décocher » ou
équivalent. - Le texte copié doit contenir tous les ingrédients ou, si
une option explicite est ajoutée plus tard, uniquement les ingrédients
non cochés. Pour la première version, copier tous les ingrédients et
leurs quantités, avec leur catégorie.

Copie : - Bouton « Copier la liste ». - Texte structuré en français,
catégories en titres et ingrédients en puces. - Utiliser les quantités
formatées de manière lisible. - Après copie, afficher une confirmation
non intrusive. - Gérer une erreur éventuelle du presse-papiers avec un
message compréhensible. - Ne pas demander une permission de
presse-papiers inutile.

### 5.7 Paramètres et informations

Écran minimal : - Nom et version de l'application. - Éventuellement
crédits/licences des images et polices. - Pas d'options d'import de
catalogue dans la version initiale. - Pas de compte, de profil distant
ou de paramètres de synchronisation. - Éviter d'ajouter des fonctions
sans besoin produit explicite.

------------------------------------------------------------------------

## 6. Modèle de données

Le catalogue est intégré à l'application sous forme de JSON versionné,
accompagné de photos locales.

### 6.1 Exemple de catalogue JSON

``` json
{
  "schemaVersion": 1,
  "recipes": [
    {
      "id": "curry-lentilles-001",
      "title": "Curry de lentilles corail",
      "description": "Un plat parfumé et réconfortant.",
      "imageAsset": "assets/recipes/curry-lentilles.jpg",
      "dietTypes": ["vegan", "vegetarian"],
      "origin": "Indien",
      "course": "plat",
      "seasons": ["automne", "hiver"],
      "months": [10, 11, 12, 1, 2, 3],
      "difficulty": "facile",
      "prepTimeMinutes": 15,
      "cookTimeMinutes": 30,
      "restTimeMinutes": 0,
      "defaultServings": 4,
      "ingredients": [
        {
          "ingredientId": "lentilles-corail",
          "name": "Lentilles corail",
          "quantity": 250,
          "unit": "g",
          "category": "epicerie_seche"
        },
        {
          "ingredientId": "lait-coco",
          "name": "Lait de coco",
          "quantity": 400,
          "unit": "ml",
          "category": "epicerie_seche"
        },
        {
          "ingredientId": "oignon",
          "name": "Oignon",
          "quantity": 1,
          "unit": "piece",
          "category": "fruits_legumes"
        }
      ],
      "steps": [
        {
          "order": 1,
          "text": "Émincer l’oignon."
        },
        {
          "order": 2,
          "text": "Ajouter les ingrédients et laisser mijoter jusqu’à cuisson."
        }
      ],
      "equipment": ["Casserole", "Couteau", "Planche à découper"]
    }
  ]
}
```

Les quantités et descriptions de cet exemple sont fictives et
illustratives.

### 6.2 Définition des champs

#### Recette

-   `id` : chaîne obligatoire, unique et stable.
-   `title` : chaîne obligatoire.
-   `description` : chaîne facultative.
-   `imageAsset` : chemin vers une image locale déclarée dans les
    assets.
-   `dietTypes` : tableau de valeurs normalisées, par exemple
    `vegetarian`, `vegan`.
-   `origin` : valeur affichée en français, par exemple `Indien`,
    `Mexicain`.
-   `course` : valeur normalisée, par exemple `entree`, `plat`,
    `dessert`, `accompagnement`.
-   `seasons` : tableau parmi `printemps`, `ete`, `automne`, `hiver`.
-   `months` : tableau d'entiers de 1 à 12.
-   `difficulty` : valeur normalisée parmi `facile`, `moyen`,
    `difficile`, ou valeur contrôlée documentée.
-   `prepTimeMinutes`, `cookTimeMinutes`, `restTimeMinutes` : entiers
    positifs ou nuls.
-   `defaultServings` : entier strictement positif.
-   `ingredients` : liste ordonnée d'ingrédients.
-   `steps` : liste d'étapes.
-   `equipment` : liste de chaînes.

#### Ingrédient de recette

-   `ingredientId` : identifiant canonique et stable utilisé pour le
    regroupement.
-   `name` : libellé français.
-   `quantity` : nombre positif ou nul, facultatif si la quantité n'est
    pas définie.
-   `unit` : identifiant normalisé d'unité, facultatif si la quantité
    n'est pas définie.
-   `category` : identifiant de catégorie produit.
-   Les quantités numériques doivent être décimales ou entières, jamais
    encodées sous forme de texte libre.
-   Pour les quantités « au goût », « une pincée » ou autres cas non
    numériques, prévoir ultérieurement un champ séparé tel que
    `quantityNote`, plutôt que détourner `quantity`.

#### Étape

-   `order` : entier positif et unique dans la recette.
-   `text` : texte obligatoire.

### 6.3 Unités normalisées

Prévoir au minimum : - Masse : `g`, `kg`. - Volume : `ml`, `cl`, `l`. -
Comptage : `piece`. - Unités de cuisine si nécessaire : `c_a_c`,
`c_a_s`, `pincee`, à utiliser seulement si les données le nécessitent et
avec des règles de compatibilité explicites.

Règles : - `g` et `kg` sont convertibles. - `ml`, `cl` et `l` sont
convertibles. - Les unités de comptage ne sont pas fusionnées avec les
unités de masse ou de volume. - Ne pas convertir un volume en masse sans
densité spécifique de l'ingrédient. - Les unités de cuillères ne doivent
pas être converties en grammes sans règle spécifique. - Les valeurs de
quantité sont conservées avec une précision suffisante en interne ;
l'arrondi se fait uniquement pour l'affichage.

### 6.4 Catégories et valeurs contrôlées

Centraliser les identifiants normalisés et leurs libellés français dans
le code ou dans un fichier de configuration local. Ne pas utiliser le
texte affiché comme identifiant métier.

Exemples : - `fruits_legumes` → Fruits et légumes. - `epicerie_seche` →
Épicerie sèche. - `produits_frais` → Produits frais. -
`produits_laitiers_alternatives` → Produits laitiers et alternatives
végétales. - `viandes_poissons` → Viandes et poissons. - `boulangerie` →
Boulangerie. - `epices_condiments` → Épices et condiments. - `surgeles`
→ Surgelés. - `boissons` → Boissons. - `autres` → Autres.

### 6.5 Versionnement

-   `schemaVersion` est obligatoire.
-   Toute modification incompatible du schéma nécessite une nouvelle
    version et une stratégie de migration ou de rejet documentée.
-   Un catalogue intégré invalide ne doit pas conduire à un plantage
    silencieux.
-   Le catalogue est validé au démarrage ou dans les tests, pas à chaque
    rendu de widget.

------------------------------------------------------------------------

## 7. Calcul des portions et des quantités

Pour une recette dont la quantité de base est prévue pour
`defaultServings` personnes, le coefficient de mise à l'échelle est :

`coefficient = portionsSelectionnees / defaultServings`

`quantiteAffichee = quantiteDeBase × coefficient`

Règles : - Les données du catalogue sont immuables durant l'exécution. -
Les quantités sont calculées à partir de la quantité originale, jamais à
partir d'une valeur déjà arrondie. - Une portion ne peut pas être
inférieure à 1. - Les portions sont des nombres entiers. - Afficher les
décimales utiles selon l'unité ; éviter les zéros inutiles. - Ne pas
arrondir automatiquement les quantités de manière à modifier
significativement la recette. - Si la quantité de base est absente,
afficher le nom et l'éventuelle note de quantité sans calcul. - La liste
de courses calcule chaque ingrédient avec les portions propres à
l'entrée de recette correspondante avant de regrouper les ingrédients
compatibles.

------------------------------------------------------------------------

## 8. Fusion et persistance des ingrédients de courses

### 8.1 Clé de regroupement

La clé de regroupement doit être stable et fondée sur : -
`ingredientId`, - unité canonique après conversion compatible, -
catégorie canonique si la catégorie fait partie des contraintes de
présentation.

Ne pas fusionner uniquement parce que deux chaînes de noms se
ressemblent.

### 8.2 Conversion

-   Convertir les masses vers une unité canonique de masse (par exemple
    grammes) et les volumes vers une unité canonique de volume (par
    exemple millilitres) pour additionner.
-   Choisir une unité d'affichage adaptée au total, par exemple
    `1 200 g` peut s'afficher `1,2 kg` si la règle de formatage est
    définie.
-   Garder `piece` séparé.
-   Les ingrédients dont les unités ne sont pas compatibles restent sur
    des lignes distinctes.
-   Ne jamais inventer de conversion densité/volume.
-   Écrire des tests pour les conversions et les arrondis.

### 8.3 État coché

La clé d'état de case à cocher doit être stable, par exemple
`ingredientId + dimension d’unité`, après normalisation. La liste
consolidée est dérivée des recettes actives ; les cases cochées sont un
état local séparé.

Lors d'une modification de la liste : - Conserver l'état coché des
lignes toujours présentes avec la même clé. - Supprimer les états
devenus orphelins si l'ingrédient ne figure plus dans la liste. - Si le
même ingrédient revient après avoir disparu, son état peut repartir à
décoché.

### 8.4 Éviter la duplication d'état

-   Le catalogue est la source de vérité des recettes.
-   La liste active stocke les identifiants de recette et les portions
    choisies, pas une copie complète des ingrédients.
-   La liste consolidée est calculée depuis le catalogue et la liste
    active.
-   Les favoris stockent uniquement les identifiants de recettes.
-   Les cases cochées sont persistées séparément.
-   Ne pas stocker simultanément la même donnée métier dans plusieurs
    endroits si elle peut être dérivée de manière fiable.

------------------------------------------------------------------------

## 9. Architecture Flutter

Utiliser une architecture simple, modulaire et testable. Ne pas
introduire de complexité sans nécessité.

### 9.1 Organisation suggérée

``` text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
  core/
    formatting/
      quantity_formatter.dart
      text_normalizer.dart
    storage/
      local_storage.dart
    widgets/
      empty_state.dart
      error_state.dart
      recipe_image.dart
  features/
    recipes/
      data/
        recipe_catalog_loader.dart
        recipe_repository.dart
      domain/
        recipe.dart
        ingredient.dart
        recipe_step.dart
        recipe_filters.dart
      presentation/
        recipe_list_screen.dart
        recipe_detail_screen.dart
        recipe_card.dart
        recipe_filter_sheet.dart
        recipes_controller.dart
    favorites/
      data/
      presentation/
        favorites_screen.dart
        favorites_controller.dart
    shopping_list/
      domain/
        shopping_list_entry.dart
        shopping_ingredient.dart
        ingredient_aggregator.dart
      data/
        shopping_list_repository.dart
      presentation/
        shopping_list_screen.dart
        shopping_ingredients_screen.dart
        shopping_list_controller.dart
    settings/
      presentation/
        settings_screen.dart
assets/
  data/
    recipes.json
  recipes/
  branding/
  fonts/
test/
  unit/
  widget/
  integration/
```

Cette organisation est indicative : adapter les noms sans perdre la
séparation entre données, logique métier et présentation.

### 9.2 Gestion d'état

Riverpod est recommandé pour séparer l'état des écrans et la logique
métier. Utiliser des providers pour : - le catalogue chargé ; - la
requête de recherche et les filtres actifs ; - les favoris ; - la liste
active ; - les ingrédients consolidés ; - les cases cochées.

Ne pas placer la logique de calcul dans les widgets. Les calculs
d'ingrédients et les filtres doivent être testables sans lancer
l'interface.

### 9.3 Navigation

`go_router` est recommandé si cela simplifie les routes et les retours.
Une navigation Flutter standard peut être retenue si le projet reste
petit ; documenter la décision.

### 9.4 Stockage local

Utiliser un mécanisme de persistance léger pour les petits états : -
`shared_preferences` peut convenir pour les identifiants favoris,
entrées de liste, portions et cases cochées, sérialisés en JSON. - Si
les données persistées deviennent plus complexes, utiliser un stockage
local structuré tel que Hive ou Isar, mais ne pas ajouter une base de
données locale sans justification. - Aucune base distante n'est
autorisée par le périmètre. - Gérer les erreurs de lecture/écriture et
les anciennes versions de données. - En cas de données persistées
corrompues, tenter une récupération contrôlée et afficher un message ou
réinitialiser uniquement l'état affecté, sans effacer le catalogue
intégré.

### 9.5 Dépendances

Choisir des versions stables compatibles avec le SDK Flutter utilisé et
vérifier leur maintenance. Limiter les packages. Dépendances probables
: - `flutter_riverpod` ou `riverpod`. - `go_router` si retenu. -
`shared_preferences` pour la persistance simple. - `flutter_lints` pour
l'analyse statique. - Package de presse-papiers seulement si l'API
Flutter standard ne suffit pas. - Package de tests Flutter standard.

Ne pas ajouter un package uniquement par habitude si une API Flutter
intégrée suffit.

------------------------------------------------------------------------

## 10. Chargement du catalogue intégré

### 10.1 Source

Le catalogue est fourni dans `assets/data/recipes.json` et les images
dans `assets/recipes/`. Il est intégré à la compilation et accessible
hors ligne.

### 10.2 Chargement

-   Charger le JSON depuis les assets.
-   Désérialiser vers des modèles typés.
-   Valider la version du schéma et les champs requis.
-   Vérifier l'unicité des identifiants.
-   Vérifier les références d'assets d'images.
-   Vérifier la cohérence des portions, durées, unités et étapes.
-   En cas d'erreur de catalogue, afficher une erreur contrôlée et
    exploitable en développement ; ne pas laisser l'application planter
    sans explication.

### 10.3 Pas d'import dans la première version

La version initiale ne contient pas de fonctionnalité d'import CSV/JSON.
Le catalogue est exclusivement intégré à la compilation. Le format JSON
reste documenté pour faciliter l'édition et l'ajout de recettes par le
développeur avant une nouvelle compilation.

Si l'import utilisateur est ajouté dans une version ultérieure, il devra
faire l'objet d'une spécification complémentaire : choix du fichier,
validation complète, gestion des images, stratégie de
remplacement/fusion, retour arrière et persistance. Ne pas implémenter
ces éléments dans le périmètre actuel.

------------------------------------------------------------------------

## 11. Accessibilité, qualité et robustesse

-   Contraste texte/fond suffisant ; vérifier les couleurs sur les fonds
    réels.
-   Tailles tactiles confortables.
-   Libellés sémantiques pour les icônes sans texte.
-   Les contrôles de portions doivent être accessibles et explicites.
-   Ne pas transmettre une information uniquement par la couleur.
-   Les textes longs et les noms d'ingrédients doivent pouvoir passer à
    la ligne.
-   L'interface doit rester utilisable avec une taille de texte système
    augmentée.
-   Les images doivent avoir un ratio stable et un placeholder.
-   Aucun écran ne doit dépendre d'un accès réseau.
-   Les erreurs de persistance ou de presse-papiers doivent être
    traitées.
-   Les listes vides doivent présenter un message et une action utile.
-   Les données utilisateurs locales ne doivent pas être envoyées
    ailleurs.

------------------------------------------------------------------------

## 12. Stratégie de tests

### 12.1 Tests unitaires

Tester au minimum : - Désérialisation du JSON valide. - Rejet contrôlé
d'un schéma invalide. - Détection d'identifiants de recette dupliqués. -
Normalisation des accents et de la casse pour la recherche. -
Combinaison des filtres. - Génération dynamique des options de
filtres. - Calcul de portions. - Formatage des quantités. - Conversion
`kg` ↔ `g`, `l` ↔ `ml` et `cl` ↔ `ml`. - Absence de conversion entre
dimensions incompatibles. - Fusion des ingrédients compatibles. -
Non-fusion des ingrédients avec identifiants différents. - Génération du
texte copié, avec catégories et quantités. - Persistance et restauration
des favoris. - Persistance et restauration de la liste active. -
Persistance des cases cochées. - Nettoyage des états cochés devenus
orphelins.

### 12.2 Tests de widgets

Tester : - Affichage des cartes de recettes. - Recherche et filtres
visibles. - État vide de recherche. - Ouverture du détail. - Changement
du nombre de personnes. - Bascule des favoris. - Ajout, modification et
suppression d'une recette de la liste. - Accès à l'écran des
ingrédients. - Affichage des catégories. - Cases à cocher. -
Confirmation de copie ou gestion d'erreur.

### 12.3 Tests d'intégration

Parcours essentiels : 1. Lancer l'application hors ligne et afficher le
catalogue. 2. Rechercher une recette et filtrer les résultats. 3. Ouvrir
le détail et changer le nombre de personnes. 4. Ajouter la recette à la
liste de courses. 5. Ajouter une deuxième recette avec un ingrédient
partagé et vérifier la fusion correcte. 6. Modifier les portions depuis
la liste active. 7. Ouvrir les ingrédients, cocher un produit et copier
la liste. 8. Fermer puis relancer l'application et vérifier la
persistance. 9. Retirer une recette et vérifier le recalcul des
ingrédients. 10. Ajouter/retirer un favori et vérifier son écran.

### 12.4 Contrôles avant livraison

Exécuter et documenter : - `flutter pub get` - `dart format .` -
`flutter analyze` - `flutter test` - Compilation ou vérification de
build pour Android. - Vérification de build iOS sur macOS avec
l'environnement Xcode disponible.

Ne pas affirmer qu'un build iOS a été validé si l'environnement ne
permet pas de l'exécuter.

------------------------------------------------------------------------

## 13. Critères d'acceptation

La version initiale est considérée comme acceptable si :

1.  L'application démarre sur iOS et Android sans réseau.
2.  Le catalogue local et les photos intégrées sont accessibles.
3.  La recherche ignore la casse et les accents.
4.  Les filtres sont issus des valeurs présentes dans les recettes et se
    combinent correctement.
5.  Le détail présente ingrédients, étapes, critères, durées et
    équipements.
6.  Le changement de portions recalcule correctement les quantités.
7.  Les favoris sont persistants.
8.  Une recette peut être ajoutée depuis le catalogue et le détail.
9.  Une recette déjà ajoutée ne crée pas de doublon.
10. Les portions d'une entrée de liste peuvent être modifiées
    indépendamment des autres.
11. Les ingrédients identiques sont fusionnés uniquement si leurs
    identifiants et unités sont compatibles.
12. Les catégories vides ne sont pas affichées.
13. Les cases cochées persistent et restent cohérentes après
    modification de la liste.
14. Le texte copié est structuré, en français, avec catégories et
    quantités.
15. La fermeture puis la réouverture de l'application ne perdent ni
    favoris ni liste active.
16. Les erreurs de données sont gérées sans plantage non contrôlé.
17. L'interface respecte les principes et couleurs de la charte Yumly.
18. Les tests et l'analyse statique passent, ou les échecs restants sont
    documentés précisément.

------------------------------------------------------------------------

## 14. Plan de développement proposé

### Étape 1 --- Inspection et fondations

-   Inspecter le dépôt et le SDK disponible.
-   Créer ou confirmer la structure Flutter.
-   Configurer thème, typographies disponibles, routes et analyse
    statique.
-   Créer les composants de base et les états vides/erreurs.
-   Vérifier les builds de base.

**Validation :** application qui démarre, thème Yumly centralisé et
navigation de base.

### Étape 2 --- Modèles et catalogue

-   Définir les modèles typés.
-   Ajouter le JSON local et quelques recettes de démonstration
    clairement identifiées si le catalogue réel n'est pas fourni.
-   Charger et valider le catalogue.
-   Ajouter les images locales disponibles et les placeholders.
-   Écrire les tests du modèle et du chargement.

**Validation :** catalogue chargé hors ligne, erreurs de données
contrôlées.

### Étape 3 --- Catalogue, recherche et filtres

-   Construire les cartes de recettes.
-   Ajouter la recherche normalisée.
-   Générer les filtres à partir du catalogue.
-   Gérer les filtres actifs et les états vides.

**Validation :** tests unitaires des filtres et tests de widgets.

### Étape 4 --- Détail et portions

-   Construire l'écran de détail.
-   Ajouter les métadonnées, étapes et équipements.
-   Implémenter le sélecteur de portions et le formatage des quantités.

**Validation :** calculs corrects pour plusieurs portions et unités.

### Étape 5 --- Favoris et persistance

-   Ajouter la bascule favori.
-   Construire l'écran Favoris.
-   Persister et restaurer les identifiants favoris.

**Validation :** favoris conservés après redémarrage.

### Étape 6 --- Liste de recettes active

-   Ajouter une recette à la liste.
-   Gérer l'absence de doublons.
-   Modifier les portions et supprimer des entrées.
-   Persister la liste active.

**Validation :** état conservé après redémarrage et modifications
répercutées.

### Étape 7 --- Consolidation des ingrédients

-   Implémenter le moteur de regroupement.
-   Gérer les conversions d'unités compatibles.
-   Construire les catégories et cases à cocher.
-   Persister l'état des cases.
-   Générer et copier le texte de la liste.

**Validation :** tests unitaires de regroupement, conversions et texte
copié.

### Étape 8 --- Finitions et qualité

-   Appliquer les détails de la charte aux différents écrans.
-   Vérifier tailles d'écran, accessibilité, erreurs et états vides.
-   Exécuter tests, analyse et builds disponibles.
-   Documenter l'ajout de recettes et d'images dans le catalogue.
-   Mettre à jour le README.

**Validation :** tous les critères d'acceptation sont vérifiés ou les
écarts sont explicitement documentés.

------------------------------------------------------------------------

## 15. Hypothèses restantes et décisions à confirmer

Les points suivants ne sont pas définis par le brief initial. Utiliser
les valeurs proposées par défaut, sans prétendre qu'elles ont été
confirmées par le propriétaire.

1.  **Catalogue réel :** aucun fichier de recettes complet n'a encore
    été fourni. Utiliser quelques recettes fictives clairement
    identifiées pour le développement, sans les présenter comme le
    catalogue final.
2.  **Logo et polices :** l'image de charte est fournie, mais les
    fichiers originaux du logo et les fichiers de polices ne sont pas
    disponibles séparément. Ne pas inventer leur emplacement réel ni
    leur disponibilité.
3.  **Lien de charte :** la chaîne `xxxx` n'est pas une URL exploitable.
    La référence actuelle est l'image fournie dans la conversation.
4.  **Données nutritionnelles et allergènes :** non demandés dans le
    périmètre initial ; ne pas inventer de valeurs.
5.  **Recherche :** recherche dans le titre, la description et les noms
    d'ingrédients recommandée.
6.  **Portions :** entier de 1 à 100, avec `defaultServings` comme
    valeur initiale.
7.  **Ajout d'une recette déjà présente :** mettre à jour les portions
    de l'entrée existante et afficher une confirmation discrète.
8.  **Saisons :** utiliser les saisons usuelles de France métropolitaine
    ; les mois et saisons sont fournis dans les données, pas inférés
    automatiquement à partir d'ingrédients.
9.  **Ingrédients sans quantité :** les afficher sans inventer de
    quantité et ne pas les fusionner avec une quantité numérique si le
    résultat n'est pas fiable.
10. **Unités de cuisine :** les conversions avancées (cuillères,
    pincées, tailles de pièces, densités) restent limitées tant qu'elles
    ne sont pas spécifiées.
11. **Cases cochées :** copier tous les ingrédients dans la première
    version, qu'ils soient cochés ou non.
12. **Données persistées corrompues :** privilégier une récupération
    contrôlée de l'état concerné et ne jamais rendre le catalogue
    inutilisable.
13. **Identifiant d'ingrédient :** le propriétaire du catalogue devra
    maintenir les mêmes identifiants pour les ingrédients équivalents
    entre recettes afin de permettre une fusion correcte.

Si une de ces hypothèses est modifiée, mettre à jour ce document et les
tests correspondants.

------------------------------------------------------------------------

## 16. Documentation développeur attendue

Le README doit expliquer : - La version de Flutter requise. -
L'installation des dépendances. - Le lancement sur simulateur/émulateur
et appareil. - Les commandes de formatage, analyse et test. -
L'emplacement du JSON et des photos. - La procédure d'ajout d'une
recette. - La procédure d'ajout d'une image. - Les conventions
d'identifiants d'ingrédients. - Les unités autorisées et les
catégories. - Les limites connues et les assets manquants.

### Règle d'ajout d'une recette

Ajouter une recette consiste à : 1. Créer un identifiant de recette
unique et stable. 2. Ajouter les métadonnées et les temps. 3. Associer
les ingrédients à des `ingredientId` canoniques. 4. Utiliser des unités
normalisées. 5. Définir les étapes avec des ordres uniques. 6. Ajouter
la photo locale et déclarer l'asset. 7. Valider le JSON. 8. Lancer les
tests et vérifier l'affichage de la recette.

------------------------------------------------------------------------

## 17. Consigne finale d'implémentation à Claude Code

Implémente Yumly selon ce document en priorisant la justesse des règles
métier, la simplicité de l'architecture et la cohérence visuelle.

Ne commence pas par une maquette statique si une application
fonctionnelle peut être construite directement. Ne réalise pas tous les
écrans en un seul gros changement. Procède étape par étape, écris les
tests des calculs et du regroupement des ingrédients avant ou en même
temps que leur interface, et vérifie les critères d'acceptation à chaque
étape.

Quand le catalogue, le logo, les polices ou les photos définitives sont
absents, utilise des données de démonstration clairement identifiées et
des placeholders propres. Liste les éléments attendus dans le rapport
final.

À la fin, fournis : - un résumé des fonctionnalités réalisées ; - les
choix techniques effectivement retenus ; - les commandes exécutées et
leurs résultats ; - les tests réussis et ceux qui restent à faire ; -
les écarts par rapport à cette spécification ; - la liste des assets ou
données métier à fournir pour finaliser le produit.
