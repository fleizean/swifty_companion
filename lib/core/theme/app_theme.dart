import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: AppColors.primaryRed,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryRed,
          onPrimaryContainer: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Color(0xFF192185),
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.secondary,
          surface: AppColors.background,
          onSurface: AppColors.onSurface,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          error: AppColors.error,
          onError: Color(0xFF690005),
          errorContainer: AppColors.errorContainer,
          onErrorContainer: Color(0xFFFFDAD6),
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.hankenGroteskTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceContainerLow,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      );
}
