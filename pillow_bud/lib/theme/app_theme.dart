import 'package:flutter/cupertino.dart';
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
      primary: primary,
      secondary: secondary,
      tertiary: tertiary ?? AppColors.tertiary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
    ).copyWith(
      onSurface: AppColors.textPrimaryLight,
      outline: AppColors.lightBorder,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.lightSurfaceTint,
    );

    return _buildTheme(colorScheme, isDark: false);
  }

  static ThemeData darkTheme({
    required Color primary,
    required Color secondary,
    Color? tertiary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkAccent,
      primary: AppColors.darkAccent,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      brightness: Brightness.dark,
      surface: AppColors.cardBackground,
    ).copyWith(
      onSurface: AppColors.textPrimaryDark,
      outline: AppColors.borderSubtle,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkHeaderBackground,
    );

    return _buildTheme(colorScheme, isDark: true);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, {required bool isDark}) {
    final scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.cardBackground : AppColors.lightSurface;
    final foreground =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderSubtle : AppColors.lightBorder;

    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: 'DM Sans',
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
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
        bodyLarge: const TextStyle(fontFamily: 'DM Sans', fontSize: 16, height: 1.5),
        bodyMedium: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, height: 1.45),
        bodySmall: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, height: 1.4),
        labelLarge: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
      ).apply(bodyColor: foreground, displayColor: foreground),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Lora',
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        elevation: 0,
        height: 72,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colorScheme.primary : secondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : secondaryText,
            size: 23,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardBg,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 23),
        unselectedIconTheme: IconThemeData(color: secondaryText, size: 22),
        selectedLabelTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: secondaryText,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.surfaceOverlay : AppColors.textPrimaryLight,
        contentTextStyle: TextStyle(
          fontFamily: 'DM Sans',
          color: isDark ? AppColors.textPrimaryDark : Colors.white,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceOverlay : AppColors.lightSurfaceTint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        hintStyle: TextStyle(color: secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }
}
