import 'package:flutter/material.dart';

/// Semantic color tokens shared by Pillow Bud's light and dark themes.
class AppColors {
  AppColors._();

  // Calm lavender, sky blue and soft sage.
  static const Color primary = Color(0xFF8B78D6);
  static const Color secondary = Color(0xFF76B8E8);
  static const Color tertiary = Color(0xFF8CBFA8);

  // Light surfaces and text.
  static const Color lightBackground = Color(0xFFF7F5FC);
  static const Color lightSurface = Color(0xFFFFFEFF);
  static const Color lightSurfaceTint = Color(0xFFF0ECFA);
  static const Color textPrimaryLight = Color(0xFF29243A);
  static const Color textSecondaryLight = Color(0xFF696478);
  static const Color textTertiaryLight = Color(0xFF898498);

  // Dark surfaces: deep plum rather than flat black/grey.
  static const Color darkBackground = Color(0xFF171521);
  static const Color darkHeaderBackground = Color(0xFF1D1A2A);
  static const Color cardBackground = Color(0xFF252233);
  static const Color cardDark = cardBackground;
  static const Color surfaceOverlay = Color(0xFF302B41);
  static const Color darkAccent = Color(0xFFC3B5FF);
  static const Color textPrimaryDark = Color(0xFFF3F0FC);
  static const Color textSecondaryDark = Color(0xFFC0BACC);
  static const Color textTertiaryDark = Color(0xFF9A93A8);
  static const Color textMutedDark = Color(0xFF7E778D);

  // Semantic status colors; pair with text/icons, never color alone.
  static const Color success = Color(0xFF368A6B);
  static const Color warning = Color(0xFFB87924);
  static const Color danger = Color(0xFFCA4B58);
  static const Color info = Color(0xFF397CC1);

  static const Color borderSubtle = Color(0xFF403A52);
  static const Color lightBorder = Color(0xFFE7E1F0);
}
