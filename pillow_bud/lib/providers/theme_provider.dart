import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/theme/app_colors.dart';

final themePresets = <String, Map<String, dynamic>>{
  'lavender': {
    'name': 'Lavender Mist',
    'primary': const Color(0xFFC4A8F8),
    'secondary': const Color(0xFF89C4F8),
    'tertiary': const Color(0xFFA8D8A8),
  },
  'ocean': {
    'name': 'Ocean Deep',
    'primary': const Color(0xFF4A90E2),
    'secondary': const Color(0xFF7AC8E8),
    'tertiary': const Color(0xFF6AB8D8),
  },
  'sunset': {
    'name': 'Amber Sunset',
    'primary': const Color(0xFFE8A87C),
    'secondary': const Color(0xFFF0B490),
    'tertiary': const Color(0xFFD89C6C),
  },
  'mint': {
    'name': 'Sage Forest',
    'primary': const Color(0xFF6AC4A8),
    'secondary': const Color(0xFFA8D8C4),
    'tertiary': const Color(0xFF7ED4B8),
  },
  'rose': {
    'name': 'Rose Dawn',
    'primary': const Color(0xFFD8A8C4),
    'secondary': const Color(0xFFE8C4D8),
    'tertiary': const Color(0xFFC898B4),
  },
  'matcha': {
    'name': 'Matcha Zen',
    'primary': const Color(0xFF8BA888),
    'secondary': const Color(0xFFC2D8B9),
    'tertiary': const Color(0xFFE0ECE4),
  },
  'nordic': {
    'name': 'Nordic Frost',
    'primary': const Color(0xFF7FB3D5),
    'secondary': const Color(0xFFA9CCE3),
    'tertiary': const Color(0xFFD4E6F1),
  },
  'terracotta': {
    'name': 'Warm Terracotta',
    'primary': const Color(0xFFD35400),
    'secondary': const Color(0xFFE59866),
    'tertiary': const Color(0xFFEDBB99),
  },
  'obsidian': {
    'name': 'Obsidian Dark',
    'primary': const Color(0xFF9E9E9E),
    'secondary': const Color(0xFFE0E0E0),
    'tertiary': const Color(0xFF757575),
  },
  'aurora': {
    'name': 'Aurora Borealis',
    'primary': const Color(0xFF48C9B0),
    'secondary': const Color(0xFF5DADE2),
    'tertiary': const Color(0xFFAF7AC5),
  },
};

final themeProvider = StateProvider<String>((ref) => 'lavender');

final primaryColorProvider = Provider<Color>((ref) {
  final current = ref.watch(currentThemeProvider);
  return current['primary']!;
});

final secondaryColorProvider = Provider<Color>((ref) {
  final current = ref.watch(currentThemeProvider);
  return current['secondary']!;
});

final currentThemeProvider = Provider<Map<String, Color>>((ref) {
  if (ref.watch(isDarkModeProvider)) {
    return {
      'primary': AppColors.darkAccent,
      'secondary': AppColors.textSecondaryDark,
      'tertiary': AppColors.textTertiaryDark,
    };
  }

  final themeKey = ref.watch(themeProvider);
  final preset = themePresets[themeKey] ?? themePresets['lavender']!;
  return {
    'primary': preset['primary'] as Color,
    'secondary': preset['secondary'] as Color,
    'tertiary': preset['tertiary'] as Color,
  };
});
