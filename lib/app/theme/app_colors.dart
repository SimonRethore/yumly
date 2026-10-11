import 'package:flutter/painting.dart';

/// Palette de la charte Yumly. Aucune autre couleur ne doit être codée en
/// dur dans les widgets : passer par le thème ou par ces constantes.
abstract final class AppColors {
  static const Color jauneSoleil = Color(0xFFFFB51B);
  static const Color vertForet = Color(0xFF0F5D46);
  static const Color creme = Color(0xFFFFF8EF);
  static const Color corail = Color(0xFFFF6B5B);
  static const Color vertSauge = Color(0xFFA7C557);
  static const Color blanc = Color(0xFFFFFFFF);

  /// Vert Forêt assombri pour le texte sur Jaune Soleil : #0F5D46 n'atteint
  /// que 4,4:1 sur #FFB51B, cette variante atteint 5,6:1 (WCAG AA).
  static const Color vertForetSurJaune = Color(0xFF0B4D3A);

  /// Texte principal : vert très foncé, contraste ≈ 14:1 sur Crème.
  static const Color texteFonce = Color(0xFF1E2B25);

  /// Texte secondaire : contraste ≈ 6:1 sur Crème et sur Blanc.
  static const Color texteSecondaire = Color(0xFF55615B);

  /// Variantes douces dérivées de la palette (fonds de pastilles, bordures).
  static const Color jauneClair = Color(0xFFFFE9B8);
  static const Color saugeClair = Color(0xFFE6EFCF);
  static const Color bordure = Color(0xFFEDE3D3);

  /// Corail assombri pour un texte d'erreur lisible sur fond clair.
  static const Color corailFonce = Color(0xFFB3352A);
}
