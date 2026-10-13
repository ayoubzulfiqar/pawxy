import 'package:flutter/material.dart';

class AppColors {
  // Pawxy Mascot Fox Palette
  static const Color pawxyOrange = Color(0xFFFF8C00); // Fox Mascot Primary Accent
  static const Color pawxyOrangeLight = Color(0xFFFFA000);
  static const Color pawxyGold = Color(0xFFFFC107); // Warm Fox Gold
  static const Color pawxyCoral = Color(0xFFFF5722); // Fox Ear/Nose Coral
  static const Color emeraldGreen = Color(0xFF00D287); // Active Connected Mint
  static const Color crimsonRed = Color(0xFFFF4D4D); // Warning / Error

  // Alias electricBlue to pawxyOrange so existing references match mascot theme seamlessly
  static const Color electricBlue = pawxyOrange;
  static const Color amberGold = pawxyGold;

  // Dark Palette (Warm Charcoal / Midnight)
  static const Color darkBackground = Color(0xFF0E1017);
  static const Color darkBackgroundSecondary = Color(0xFF141720);
  static const Color darkCardSurface = Color(0xFF191C27);
  static const Color darkCardSurfaceElevated = Color(0xFF212534);
  static const Color darkCardBorder = Color(0xFF2C3144);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9096A8);
  static const Color darkTextMuted = Color(0xFF5B6074);
  static const Color darkPowerInactiveOuter = Color(0xFF1B1E2B);
  static const Color darkPowerInactiveInner = Color(0xFF232838);

  // Light Palette (Warm Soft Cream / White)
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightBackgroundSecondary = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurfaceElevated = Color(0xFFEEF2FA);
  static const Color lightCardBorder = Color(0xFFE2E7F0);
  static const Color lightTextPrimary = Color(0xFF12151C);
  static const Color lightTextSecondary = Color(0xFF5A6072);
  static const Color lightTextMuted = Color(0xFF9299A9);
  static const Color lightPowerInactiveOuter = Color(0xFFEBF0F9);
  static const Color lightPowerInactiveInner = Color(0xFFFFFFFF);

  // Power Glows
  static const Color powerActiveGlow = Color(0x3300D287);
  static const Color powerConnectingGlow = Color(0x33FF8C00);

  // Adaptive Helpers based on Brightness
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color backgroundSecondary(bool isDark) =>
      isDark ? darkBackgroundSecondary : lightBackgroundSecondary;

  static Color cardSurface(bool isDark) =>
      isDark ? darkCardSurface : lightCardSurface;

  static Color cardSurfaceElevated(bool isDark) =>
      isDark ? darkCardSurfaceElevated : lightCardSurfaceElevated;

  static Color cardBorder(bool isDark) =>
      isDark ? darkCardBorder : lightCardBorder;

  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color textMuted(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;

  static Color powerInactiveOuter(bool isDark) =>
      isDark ? darkPowerInactiveOuter : lightPowerInactiveOuter;

  static Color powerInactiveInner(bool isDark) =>
      isDark ? darkPowerInactiveInner : lightPowerInactiveInner;
}
