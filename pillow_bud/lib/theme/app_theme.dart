import 'package:flutter/material.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme({
    required Color primary,
    required Color secondary,
    Color? tertiary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
      tertiary: tertiary,
      brightness: Brightness.light,
      surface: const Color(0xFFFBF9FE),
    );

    return _buildTheme(colorScheme, isDark: false);
  }

  static ThemeData darkTheme({
    required Color primary,
    required Color secondary,
    Color? tertiary,
  }) {
    // Dark mode is intentionally neutral regardless of the selected light
    // theme preset. This keeps the dark UI monochrome instead of violet/teal.
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.darkAccent,
      onPrimary: Color(0xFF171717),
      secondary: Color(0xFFB4B4B4),
      onSecondary: Color(0xFF171717),
      tertiary: Color(0xFF8E8E93),
      onTertiary: Color(0xFF171717),
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimaryDark,
    );

    return _buildTheme(colorScheme, isDark: true);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, {required bool isDark}) {
    final scaffoldBg = isDark ? AppColors.darkBackground : const Color(0xFFF9F7FD);
    final cardBg = isDark ? AppColors.cardBackground : Colors.white;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: 'DM Sans',

      // Material 3 Typography
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600),
        headlineLarge: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600),
        headlineMedium: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w500),
        titleLarge: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
        titleSmall: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(fontFamily: 'DM Sans', fontSize: 16),
        bodyMedium: const TextStyle(fontFamily: 'DM Sans', fontSize: 14),
        bodySmall: const TextStyle(fontFamily: 'DM Sans', fontSize: 12),
        labelLarge: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
      ),

      // Material 3 Card Theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.borderSubtle : const Color(0x12000000),
          ),
        ),
      ),

      // Material 3 AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Lora',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),

      // Material 3 Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkHeaderBackground : Colors.white,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            size: 24,
          );
        }),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
