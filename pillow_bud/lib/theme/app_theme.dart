import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme({
    required Color primary,
    required Color secondary,
  }) {
    final base = _baseTheme(primary: primary, secondary: secondary);
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F6FF),
    );
  }

  static ThemeData darkTheme({
    required Color primary,
    required Color secondary,
  }) {
    final base = _baseTheme(primary: primary, secondary: secondary);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1225),
    );
  }

  static ThemeData _baseTheme({
    required Color primary,
    required Color secondary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'DM Sans',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}

