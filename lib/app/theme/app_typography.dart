import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typographies de la charte : Fredoka (titres) et Inter (texte courant),
/// intégrées dans `assets/fonts/` et déclarées dans `pubspec.yaml`.
abstract final class AppTypography {
  static const String titleFamily = 'Fredoka';
  static const String bodyFamily = 'Inter';

  static TextTheme textTheme() {
    const title = TextStyle(
      fontFamily: titleFamily,
      color: AppColors.vertForet,
      fontWeight: FontWeight.w600,
    );
    const body = TextStyle(fontFamily: bodyFamily, color: AppColors.texteFonce);
    return TextTheme(
      displaySmall: title.copyWith(fontSize: 34, height: 1.15),
      headlineMedium: title.copyWith(fontSize: 28, height: 1.2),
      headlineSmall: title.copyWith(fontSize: 24, height: 1.2),
      titleLarge: title.copyWith(fontSize: 21, height: 1.25),
      titleMedium: title.copyWith(fontSize: 18, height: 1.25),
      titleSmall: body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: body.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: body.copyWith(fontSize: 14, height: 1.4),
      bodySmall: body.copyWith(
        fontSize: 13,
        height: 1.35,
        color: AppColors.texteSecondaire,
      ),
      labelLarge: body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: body.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}
