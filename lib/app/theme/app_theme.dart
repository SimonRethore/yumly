import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Rayons et espacements partagés.
abstract final class AppRadius {
  static const double card = 20;
  static const double chip = 14;
  static const double button = 16;
}

abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.jauneSoleil,
      onPrimary: AppColors.vertForetSurJaune,
      primaryContainer: AppColors.jauneClair,
      onPrimaryContainer: AppColors.vertForet,
      secondary: AppColors.vertForet,
      onSecondary: AppColors.blanc,
      secondaryContainer: AppColors.saugeClair,
      onSecondaryContainer: AppColors.vertForet,
      tertiary: AppColors.corail,
      onTertiary: AppColors.texteFonce,
      error: AppColors.corailFonce,
      onError: AppColors.blanc,
      surface: AppColors.creme,
      onSurface: AppColors.texteFonce,
      onSurfaceVariant: AppColors.texteSecondaire,
      surfaceContainerLowest: AppColors.blanc,
      surfaceContainerLow: AppColors.blanc,
      surfaceContainer: AppColors.blanc,
      surfaceContainerHigh: AppColors.blanc,
      surfaceContainerHighest: AppColors.bordure,
      outline: AppColors.texteSecondaire,
      outlineVariant: AppColors.bordure,
    );
    final textTheme = AppTypography.textTheme();
    const minButtonSize = Size(48, 48);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTypography.bodyFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.creme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creme,
        foregroundColor: AppColors.vertForet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.blanc,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.bordure),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.jauneSoleil,
          foregroundColor: AppColors.vertForetSurJaune,
          minimumSize: minButtonSize,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vertForet,
          minimumSize: minButtonSize,
          shape: buttonShape,
          side: const BorderSide(color: AppColors.vertForet),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vertForet,
          minimumSize: minButtonSize,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.vertForet,
          minimumSize: minButtonSize,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanc,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.texteSecondaire,
        ),
        prefixIconColor: AppColors.vertForet,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.bordure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.bordure),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.vertForet, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.blanc,
        selectedColor: AppColors.jauneClair,
        checkmarkColor: AppColors.vertForet,
        deleteIconColor: AppColors.vertForet,
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.vertForet),
        side: const BorderSide(color: AppColors.bordure),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.vertForet
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.blanc),
        side: const BorderSide(color: AppColors.vertForet, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.blanc,
        indicatorColor: AppColors.jauneClair,
        surfaceTintColor: Colors.transparent,
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.vertForet),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: AppColors.vertForet,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.corail,
        textColor: AppColors.texteFonce,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.vertForet,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.blanc,
        ),
        actionTextColor: AppColors.jauneClair,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.creme,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.bordure),
    );
  }
}
