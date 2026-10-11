# Icône d'application

Sources des icônes (ce dossier n'est **pas** embarqué dans l'application) :

- `app_icon.png` — icône fournie (`1024x1024.png`), 1024 × 1024, fond
  crème `#FAF7EF`, sans transparence. Utilisée pour iOS et pour l'icône
  Android classique.
- `app_icon_foreground.png` — même dessin avec le fond rendu transparent :
  premier plan de l'icône adaptative Android (fond `#FAF7EF`). La marge de
  16 % ajoutée par le générateur place le dessin dans la zone de sécurité
  des masques ronds.
- `splash_logo.png` — logo vertical, centré sur fond crème `#FFF8EF` dans
  l'écran de lancement (Android < 12 et iOS).
- `splash_android12.png` — dessin de l'icône réduit pour tenir dans le
  cercle visible de l'écran de lancement système d'Android 12+.

Régénérer après modification :

```bash
dart run flutter_launcher_icons        # icônes
dart run flutter_native_splash:create  # écran de lancement
```

Configuration : sections `flutter_launcher_icons:` et
`flutter_native_splash:` de `pubspec.yaml`.
