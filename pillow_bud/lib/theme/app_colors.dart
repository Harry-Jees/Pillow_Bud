import 'package:flutter/material.dart';

/// Design System Colors as specified in COMPLETE_ULTRA_DETAILED_MASTER_PROMPT.md
class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFFC4A8F8); // Primary Lavender
  static const Color secondary = Color(0xFF89C4F8); // Secondary Teal
  static const Color tertiary = Color(0xFFA8D8A8); // Tertiary Sage

  // Dark Mode (Default)
  static const Color darkBackground = Color(0xFF1A1225);
  static const Color cardBackground = Color(0xFF2D1F4A);
  // Backwards-compatible naming used across screens
  static const Color cardDark = cardBackground;

  static const Color surfaceOverlay = Color(0x802D1F4A); // 0.5 opacity

  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF0E8FF);
  static Color textSecondaryDark = const Color(0xFFF0E8FF).withOpacity(0.65);
  static Color textTertiaryDark = const Color(0xFFF0E8FF).withOpacity(0.40);
  static Color textMutedDark = const Color(0xFFF0E8FF).withOpacity(0.25);

  // Semantic Colors
  static const Color success = Color(0xFF7ACF8E);
  static const Color warning = Color(0xFFFAC775);
  static const Color danger = Color(0xFFF09595);
  static const Color info = Color(0xFF89C4F8);

  static Color borderSubtle = const Color(0xFFFFFFFF).withOpacity(0.07);
}