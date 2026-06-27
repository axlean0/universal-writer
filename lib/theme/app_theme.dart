import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from DESIGN.md and code.html Tailwind config.
class AppColors {
  // Primary (Ink)
  static const primary = Color(0xFF162839);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2C3E50);
  static const onPrimaryContainer = Color(0xFF96A9BE);
  static const primaryFixed = Color(0xFFD1E4FB);
  static const primaryFixedDim = Color(0xFFB5C8DF);
  static const onPrimaryFixed = Color(0xFF091D2E);
  static const onPrimaryFixedVariant = Color(0xFF36485B);
  static const inversePrimary = Color(0xFFB5C8DF);

  // Secondary (Sage)
  static const secondary = Color(0xFF496800);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFC8F17A);
  static const onSecondaryContainer = Color(0xFF4E6E00);
  static const secondaryFixed = Color(0xFFC8F17A);
  static const secondaryFixedDim = Color(0xFFADD461);
  static const onSecondaryFixed = Color(0xFF131F00);
  static const onSecondaryFixedVariant = Color(0xFF364E00);

  // Tertiary
  static const tertiary = Color(0xFF362308);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF4E381C);
  static const onTertiaryContainer = Color(0xFFC1A17D);
  static const tertiaryFixed = Color(0xFFFFDDB7);
  static const tertiaryFixedDim = Color(0xFFE3C19B);
  static const onTertiaryFixed = Color(0xFF291802);
  static const onTertiaryFixedVariant = Color(0xFF5A4225);

  // Surface / Background (Parchment)
  static const background = Color(0xFFFAF9F7);
  static const onBackground = Color(0xFF1A1C1B);
  static const surface = Color(0xFFFAF9F7);
  static const onSurface = Color(0xFF1A1C1B);
  static const surfaceDim = Color(0xFFDADAD8);
  static const surfaceBright = Color(0xFFFAF9F7);
  static const surfaceVariant = Color(0xFFE3E2E0);
  static const onSurfaceVariant = Color(0xFF43474C);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F3F1);
  static const surfaceContainer = Color(0xFFEFEEEC);
  static const surfaceContainerHigh = Color(0xFFE9E8E6);
  static const surfaceContainerHighest = Color(0xFFE3E2E0);
  static const surfaceTint = Color(0xFF4E6073);
  static const inverseSurface = Color(0xFF2F3130);
  static const inverseOnSurface = Color(0xFFF1F1EF);

  // Outline
  static const outline = Color(0xFF74777D);
  static const outlineVariant = Color(0xFFC4C6CD);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

class AppSpacing {
  static const double sidebarWidth = 260.0;
  static const double safePadding = 32.0;
  static const double gridGutter = 24.0;
  static const double sectionMargin = 48.0;
  static const double stackSm = 8.0;
  static const double stackMd = 16.0;
  static const double containerMaxWidth = 1200.0;
}

class AppRadius {
  static const double sm = 2.0;
  static const double normal = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double pill = 999.0;
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    inversePrimary: AppColors.inversePrimary,
    onInverseSurface: AppColors.inverseOnSurface,
  );

  final textTheme = GoogleFonts.manropeTextTheme().copyWith(
    displayLarge: GoogleFonts.manrope(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 48 / 40,
      letterSpacing: -0.02 * 40,
      color: AppColors.onBackground,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 36 / 28,
      color: AppColors.onBackground,
    ),
    headlineSmall: GoogleFonts.manrope(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      color: AppColors.onBackground,
    ),
    bodyLarge: GoogleFonts.manrope(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 24 / 15,
      color: AppColors.onSurface,
    ),
    bodyMedium: GoogleFonts.sourceSerif4(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 30 / 18,
      color: AppColors.onSurface,
    ),
    labelLarge: GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      letterSpacing: 0.05 * 12,
      color: AppColors.outline,
    ),
    titleMedium: GoogleFonts.manrope(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 24 / 15,
      color: AppColors.onSurface,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.outlineVariant,
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.manrope(
        fontSize: 15,
        color: AppColors.outline,
      ),
    ),
  );
}
