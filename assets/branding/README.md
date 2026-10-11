# Assets de marque

Fichiers fournis avec la charte :

- `logo_horizontal.png` — logo horizontal (toque à gauche du lettrage, fond
  transparent, 724 × 230 px). Affiché dans l'en-tête de l'accueil
  (`lib/core/widgets/brand_title.dart`).
- `logo.png` — logo vertical (fond transparent, 418 × 355 px). Non affiché
  dans l'application ; sa copie `assets/app_icon/splash_logo.png` sert à
  l'écran de lancement.

L'icône d'application est dans `assets/app_icon/` (hors bundle, voir son
README).

Les fichiers fournis `logo.svg` et `logo_horizontal.svg` ne sont pas
utilisés : ils ne contiennent que des PNG embarqués (418 × 355, et 298 × 180
+ 314 × 125), sans tracés vectoriels, donc pas plus nets que les PNG.
Souhaitable : un vrai SVG vectoriel ou un PNG du logo horizontal d'au moins
~1 500 px de large (à 40 px de haut sur un écran 3×, l'affichage utilise
~380 × 120 px).
