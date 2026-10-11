# Polices de la charte

Polices intégrées (SIL Open Font License 1.1, licences jointes) :

- **Fredoka** (titres) : `Fredoka-Regular`, `-Medium`, `-SemiBold`, `-Bold`.
  Licence : `OFL-Fredoka.txt`.
- **Inter** (texte courant) : version statique « 18pt » (taille optique adaptée
  au texte courant), renommée `Inter-Regular`, `-Medium`, `-SemiBold`, `-Bold`.
  Licence : `OFL-Inter.txt`.

Source : fichiers de polices fournis avec la charte. Les familles sont déclarées
dans la section `fonts:` de `pubspec.yaml` et utilisées par
`lib/app/theme/app_typography.dart`. Les licences sont affichées dans
Paramètres → « Licences des composants ».

Pour ajouter une graisse, copier le fichier statique correspondant puis le
déclarer avec son `weight` dans `pubspec.yaml`.
