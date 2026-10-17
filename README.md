<div align="center"><img align="center" src="./assets/app_icon/app_icon.png" width="100" alt="Logo de l'application"/></div>
<h1 align="center">Yumly</h1>

<br/>

Application mobile française (iOS et Android) pour découvrir des recettes,
ajuster les quantités selon le nombre de convives, garder ses favoris et
préparer une liste de courses consolidée.

Entièrement **hors ligne** : aucun compte, aucun backend, aucune API. Le
catalogue et les photos sont intégrés à la compilation ; favoris, liste de
courses et cases cochées restent sur l'appareil.

Référence produit : [`assets/INITIAL_SPEC.md`](assets/INITIAL_SPEC.md). Charte graphique :
[`assets/charte_graphique.png`](assets/charte_graphique.png).

## Prérequis

- Flutter **stable 3.47** ou plus récent (Dart 3.13), testé avec Flutter 3.47.7.
- Android : Android SDK (via Android Studio) et un émulateur ou appareil.
- iOS : macOS avec Xcode et CocoaPods.

Vérifier l'environnement avec `flutter doctor`.

## Installation et lancement

```bash
flutter pub get
flutter run                     # appareil / émulateur par défaut
flutter run -d <id-appareil>    # liste des appareils : flutter devices
```

Builds :

```bash
flutter build apk --release     # Android
flutter build ios --release     # iOS (sur macOS)
```

## Qualité

```bash
dart format .                   # formatage
flutter analyze                 # analyse statique
flutter test                    # tests unitaires, widgets et parcours (sans appareil)
flutter test integration_test   # parcours essentiel sur appareil / émulateur
```

| Dossier                | Contenu                                                              |
| ---------------------- | -------------------------------------------------------------------- |
| `test/unit/`           | Catalogue, recherche, filtres, formatage, conversions, fusion, texte copié, persistance |
| `test/widget/`         | Catalogue, filtres, fiche, portions, favoris, liste, ingrédients, copie, texte ×2 |
| `test/integration/`    | Parcours essentiel complet, exécuté par `flutter test` sans appareil |
| `integration_test/`    | Même parcours sur appareil réel (`journey.dart` partagé)             |

## Architecture

```
lib/
  app/            application, routes (go_router), coque de navigation, thème
  core/           formatage (quantités, texte), stockage local, widgets communs
  features/
    recipes/      catalogue : chargement/validation, modèles, filtres, écrans
    favorites/    favoris persistés
    shopping_list/ liste active, consolidation des ingrédients, cases cochées
    settings/     informations
```

Choix techniques :

- **Riverpod 3** (`flutter_riverpod`) : catalogue, filtres, favoris, liste
  active, ingrédients consolidés et cases cochées sont des providers ; les
  calculs (filtres, agrégation, formatage) sont des fonctions pures testées
  sans interface.
- **go_router** (`StatefulShellRoute`) : quatre onglets avec une pile de
  navigation propre à chacun ; la fiche recette s'ouvre dans l'onglet
  courant et le retour système revient à l'écran précédent.
- **shared_preferences** : chaque état (favoris, liste active, cases cochées)
  est stocké séparément en JSON dans une enveloppe versionnée. Une donnée
  corrompue ou d'une version inconnue réinitialise uniquement l'état
  concerné, avec un message à l'utilisateur.
- **Aucune duplication** : la liste active ne stocke que `recipeId` +
  portions ; les ingrédients sont recalculés depuis le catalogue. Les cases
  cochées sont indexées par `ingredientId|dimension` et les clés orphelines
  sont supprimées dès qu'un ingrédient disparaît.
- Presse-papiers via l'API Flutter standard (`Clipboard`), sans permission.
- Interface en français (`flutter_localizations`, locale `fr_FR`).

## Catalogue, recettes et photos

- Catalogue : `assets/data/recipes.json` — format complet, unités,
  catégories et conventions d'identifiants dans
  [`docs/FORMAT_RECETTES.md`](docs/FORMAT_RECETTES.md).
- Photos : `assets/recipes/` (dossier déjà déclaré dans `pubspec.yaml`).

Le catalogue intégré contient les recettes personnelles. Les 8 recettes de démonstration servent uniquement aux tests
(`test/helpers/demo_catalog.dart`).

### Ajouter une recette

1. Choisir un `id` unique et stable (ex. `soupe-poireaux-009`).
2. Renseigner les métadonnées et les temps.
3. Associer chaque ingrédient à un `ingredientId` canonique (réutiliser
   ceux qui existent déjà : `oignon`, `ail`, `huile-olive`…).
4. Utiliser uniquement les unités normalisées.
5. Définir les étapes avec des `order` uniques.
6. Ajouter la photo (voir ci-dessous) et renseigner `imageAsset`.
7. Valider : `flutter test test/unit/catalog_parser_test.dart`.
8. Lancer l'application et vérifier la fiche.

### Ajouter une image

1. Déposer le fichier dans `assets/recipes/` (JPEG 16:10, ~1600 × 1000 px,
   < 300 Ko, droits vérifiés).
2. Référencer son chemin dans `imageAsset` (ex.
   `assets/recipes/soupe-poireaux.jpg`).
3. Relancer la compilation (`flutter run`) : aucune autre déclaration n'est
   nécessaire. Une image absente est remplacée par un placeholder et
   signalée dans la console (`[Yumly] Catalogue : …`).

## Limites connues et éléments à fournir

- **Logo et icône** : intégrés (logo horizontal dans l'en-tête, icônes iOS
  et Android adaptative générées par `dart run flutter_launcher_icons`). Voir
  [`assets/branding/README.md`](assets/branding/README.md) et
  [`assets/app_icon/README.md`](assets/app_icon/README.md).
- **Écran de lancement** : fond crème et logo, généré par
  `dart run flutter_native_splash:create` (voir `assets/app_icon/README.md`).
- **Logo vectoriel** : les SVG fournis n'embarquent que des PNG ; un vrai SVG
  ou un PNG plus grand améliorerait la netteté de l'en-tête.
- **Polices** : Fredoka et Inter intégrées (OFL 1.1), voir
  [`assets/fonts/README.md`](assets/fonts/README.md).
- **Photos des recettes** : aucune ; placeholder aux couleurs de la charte.
  Liste attendue dans [`assets/recipes/README.md`](assets/recipes/README.md).
- **Catalogue réel** : à fournir ; le catalogue actuel est fictif.
- **Couleurs** : codes lus sur l'image de charte, à confirmer avec les
  fichiers sources. Un vert assombri (`#0B4D3A`) est utilisé pour le texte
  sur Jaune Soleil, le Vert Forêt `#0F5D46` n'atteignant que 4,4:1 de
  contraste (seuil WCAG AA : 4,5:1).
- Ajouter depuis une **carte** une recette déjà présente conserve ses
  portions (aucun nombre n'est choisi sur la carte) ; depuis la **fiche**,
  les portions sont mises à jour avec la valeur affichée.
- La version affichée dans Paramètres (`lib/app/app_info.dart`) est à
  garder synchronisée avec `pubspec.yaml`.
