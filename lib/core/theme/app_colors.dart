import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF111125);
  static const Color surfaceContainerLowest = Color(0xFF0C0C1F);
  static const Color surfaceContainerLow = Color(0xFF1A1A2E);
  static const Color surfaceContainer = Color(0xFF1E1E32);
  static const Color surfaceContainerHigh = Color(0xFF28283D);
  static const Color surfaceContainerHighest = Color(0xFF333348);

  // Brand
  static const Color primaryRed = Color(0xFFFC584B);
  static const Color primaryFixed = Color(0xFFFFB4AA);
  static const Color secondary = Color(0xFFBEC2FF);
  static const Color secondaryContainer = Color(0xFF353E9F);
  static const Color tertiaryContainer = Color(0xFF8590B3);

  // Text
  static const Color onSurface = Color(0xFFE2E0FC);
  static const Color onSurfaceVariant = Color(0xFFE3BEB9);
  static const Color muted = Color(0xFFA0A0B0);

  // Semantic
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, secondary],
    stops: [0.0, 1.0],
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [primaryRed, secondary],
  );
}
