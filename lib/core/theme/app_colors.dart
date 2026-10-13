import 'package:flutter/material.dart';

class AppColors {
  // Dark Palette
  static const Color darkBackground = Color(0xFF0F1015);
  static const Color darkBackgroundSecondary = Color(0xFF13151B);
  static const Color darkCardSurface = Color(0xFF1C1E26);
  static const Color darkCardSurfaceElevated = Color(0xFF222531);
  static const Color darkCardBorder = Color(0xFF2B2E3D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E92A4);
  static const Color darkTextMuted = Color(0xFF585B6C);
  static const Color darkPowerInactiveOuter = Color(0xFF1A1D27);
  static const Color darkPowerInactiveInner = Color(0xFF222634);

  // Light Palette
  static const Color lightBackground = Color(0xFFF5F7FC);
  static const Color lightBackgroundSecondary = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurfaceElevated = Color(0xFFEEF2F9);
  static const Color lightCardBorder = Color(0xFFE1E6F0);
  static const Color lightTextPrimary = Color(0xFF12151C);
  static const Color lightTextSecondary = Color(0xFF5A6072);
  static const Color lightTextMuted = Color(0xFF9299A9);
  static const Color lightPowerInactiveOuter = Color(0xFFEAF0FA);
  static const Color lightPowerInactiveInner = Color(0xFFFFFFFF);

  // Shared Accents
  static const Color electricBlue = Color(0xFF3E7BFA);
  static const Color emeraldGreen = Color(0xFF00D287);
  static const Color amberGold = Color(0xFFFFB800);
  static const Color crimsonRed = Color(0xFFFF4D4D);

  // Power Glows
  static const Color powerActiveGlow = Color(0x3300D287);
  static const Color powerConnectingGlow = Color(0x333E7BFA);

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

  static LinearGradient premiumGradient(bool isDark) => isDark
      ? const LinearGradient(
          colors: [Color(0xFF2A1F03), Color(0xFF1C1E26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFF7E6), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
}
