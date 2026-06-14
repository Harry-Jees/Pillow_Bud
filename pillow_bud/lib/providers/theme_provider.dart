import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final primaryColorProvider = StateProvider<Color>((ref) {
  return const Color(0xFFC4A8F8);
});

final secondaryColorProvider = StateProvider<Color>((ref) {
  return const Color(0xFF89C4F8);
});

final themeProvider = StateProvider<String>((ref) => 'lavender');

final currentThemeProvider = StateProvider<Map<String, Color>>((ref) {
  final theme = ref.watch(themeProvider);
  final themeMap = {
    'lavender': {
      'primary': const Color(0xFFC4A8F8),
      'secondary': const Color(0xFF89C4F8),
    },
    'ocean': {
      'primary': const Color(0xFF4A90E2),
      'secondary': const Color(0xFF7AC8E8),
    },
    'sunset': {
      'primary': const Color(0xFFE8A87C),
      'secondary': const Color(0xFFF0B490),
    },
    'mint': {
      'primary': const Color(0xFF6AC4A8),
      'secondary': const Color(0xFFA8D8C4),
    },
    'rose': {
      'primary': const Color(0xFFD8A8C4),
      'secondary': const Color(0xFFE8C4D8),
    },
  };

  return themeMap[theme] ?? themeMap['lavender']!;
});
