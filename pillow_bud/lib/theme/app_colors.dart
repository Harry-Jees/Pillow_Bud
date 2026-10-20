import 'package:flutter/material.dart';

/// Design System Colors – ChatGPT Monochrome Dark & Soft Light Themes
class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFFC4A8F8); // Primary Lavender
  static const Color secondary = Color(0xFF89C4F8); // Secondary Teal
  static const Color tertiary = Color(0xFFA8D8A8); // Tertiary Sage

  // ChatGPT Monochrome Dark Mode
  static const Color darkBackground = Color(0xFF212121);
  static const Color darkHeaderBackground = Color(0xFF171717);
  static const Color cardBackground = Color(0xFF2F2F2F);
  static const Color cardDark = cardBackground;

  static const Color surfaceOverlay = Color(0xFF303030);
  static const Color darkAccent = Color(0xFFBDBDBD);

  // Text Colors (ChatGPT Monochrome Dark Mode)
  static const Color textPrimaryDark = Color(0xFFECECF1);
  static const Color textSecondaryDark = Color(0xFFB4B4B4);
  static const Color textTertiaryDark = Color(0xFF8E8E93);
  static const Color textMutedDark = Color(0xFF6E6E73);

  // Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF1A1225);
  static const Color textSecondaryLight = Color(0xA61A1225); // 0.65 opacity
  static const Color textTertiaryLight = Color(0x661A1225); // 0.40 opacity

  // Semantic Colors
  static const Color success = Color(0xFF10A37F); // ChatGPT Emerald Accent
  static const Color warning = Color(0xFFFAC775);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color borderSubtle = Color(0xFF383838);
  static const Color lightBackground = Color(0xFFF8F6FF);
}
