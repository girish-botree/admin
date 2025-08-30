import 'package:flutter/material.dart';
import '../design_system/material_design_system.dart';

/// Enhanced Theme Configuration
/// Provides comprehensive theming with Material Design 3 support
class EnhancedThemeConfig {
  // MARK: - Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    fontFamily: MaterialDesignSystem.fontFamily,
    scaffoldBackgroundColor: _lightColorScheme.surfaceContainerLowest,
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: MaterialDesignSystem.fontWeightSemiBold,
        color: _lightColorScheme.onSurface,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      iconTheme: IconThemeData(
        color: _lightColorScheme.onSurface,
        size: MaterialDesignSystem.iconSizeLarge,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: _lightColorScheme.surface,
      elevation: MaterialDesignSystem.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius16),
      ),
      margin: const EdgeInsets.all(MaterialDesignSystem.spacing8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        elevation: MaterialDesignSystem.elevation2,
        padding: const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing24,
          vertical: MaterialDesignSystem.spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: MaterialDesignSystem.fontWeightMedium,
          fontFamily: MaterialDesignSystem.fontFamily,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
        side: BorderSide(
          color: _lightColorScheme.primary,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing24,
          vertical: MaterialDesignSystem.spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: MaterialDesignSystem.fontWeightMedium,
          fontFamily: MaterialDesignSystem.fontFamily,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing16,
          vertical: MaterialDesignSystem.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius8),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: MaterialDesignSystem.fontWeightMedium,
          fontFamily: MaterialDesignSystem.fontFamily,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide(
          color: _lightColorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide(
          color: _lightColorScheme.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: MaterialDesignSystem.spacing16,
        vertical: MaterialDesignSystem.spacing12,
      ),
      hintStyle: TextStyle(
        color: _lightColorScheme.onSurface.withOpacity(0.6),
        fontSize: 16,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      labelStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 16,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      elevation: MaterialDesignSystem.elevation4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius16),
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      selectedItemColor: _lightColorScheme.primary,
      unselectedItemColor: _lightColorScheme.onSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: MaterialDesignSystem.elevation8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: MaterialDesignSystem.fontWeightMedium,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: MaterialDesignSystem.fontWeightRegular,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: _lightColorScheme.surface,
      elevation: MaterialDesignSystem.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius20),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: MaterialDesignSystem.fontWeightSemiBold,
        color: _lightColorScheme.onSurface,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: MaterialDesignSystem.fontWeightRegular,
        color: _lightColorScheme.onSurface,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _lightColorScheme.surface,
      elevation: MaterialDesignSystem.elevation8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MaterialDesignSystem.radius20),
        ),
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _lightColorScheme.surfaceContainerHigh,
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 16,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outline.withOpacity(0.2),
      thickness: 1,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: _lightColorScheme.onSurface,
      size: MaterialDesignSystem.iconSizeMedium,
    ),
    
    // Primary Icon Theme
    primaryIconTheme: IconThemeData(
      color: _lightColorScheme.primary,
      size: MaterialDesignSystem.iconSizeMedium,
    ),
  );
  
  // MARK: - Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    fontFamily: MaterialDesignSystem.fontFamily,
    scaffoldBackgroundColor: _darkColorScheme.surfaceContainerLowest,
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: MaterialDesignSystem.fontWeightSemiBold,
        color: _darkColorScheme.onSurface,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      iconTheme: IconThemeData(
        color: _darkColorScheme.onSurface,
        size: MaterialDesignSystem.iconSizeLarge,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: _darkColorScheme.surface,
      elevation: MaterialDesignSystem.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius16),
      ),
      margin: const EdgeInsets.all(MaterialDesignSystem.spacing8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        elevation: MaterialDesignSystem.elevation2,
        padding: const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing24,
          vertical: MaterialDesignSystem.spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: MaterialDesignSystem.fontWeightMedium,
          fontFamily: MaterialDesignSystem.fontFamily,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkColorScheme.primary,
        side: BorderSide(
          color: _darkColorScheme.primary,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing24,
          vertical: MaterialDesignSystem.spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: MaterialDesignSystem.fontWeightMedium,
          fontFamily: MaterialDesignSystem.fontFamily,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkColorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing16,
          vertical: MaterialDesignSystem.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius8),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: MaterialDesignSystem.fontWeightMedium,
          fontFamily: MaterialDesignSystem.fontFamily,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide(
          color: _darkColorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        borderSide: BorderSide(
          color: _darkColorScheme.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: MaterialDesignSystem.spacing16,
        vertical: MaterialDesignSystem.spacing12,
      ),
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurface.withOpacity(0.6),
        fontSize: 16,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      labelStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 16,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      elevation: MaterialDesignSystem.elevation4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius16),
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkColorScheme.surface,
      selectedItemColor: _darkColorScheme.primary,
      unselectedItemColor: _darkColorScheme.onSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: MaterialDesignSystem.elevation8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: MaterialDesignSystem.fontWeightMedium,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: MaterialDesignSystem.fontWeightRegular,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: _darkColorScheme.surface,
      elevation: MaterialDesignSystem.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius20),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: MaterialDesignSystem.fontWeightSemiBold,
        color: _darkColorScheme.onSurface,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: MaterialDesignSystem.fontWeightRegular,
        color: _darkColorScheme.onSurface,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _darkColorScheme.surface,
      elevation: MaterialDesignSystem.elevation8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MaterialDesignSystem.radius20),
        ),
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkColorScheme.surfaceContainerHigh,
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 16,
        fontFamily: MaterialDesignSystem.fontFamily,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outline.withOpacity(0.2),
      thickness: 1,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: _darkColorScheme.onSurface,
      size: MaterialDesignSystem.iconSizeMedium,
    ),
    
    // Primary Icon Theme
    primaryIconTheme: IconThemeData(
      color: _darkColorScheme.primary,
      size: MaterialDesignSystem.iconSizeMedium,
    ),
  );
  
  // MARK: - Color Schemes
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: MaterialDesignSystem.primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: MaterialDesignSystem.primaryBlueLight,
    onPrimaryContainer: Colors.white,
    secondary: MaterialDesignSystem.secondaryTeal,
    onSecondary: Colors.white,
    secondaryContainer: MaterialDesignSystem.secondaryTealLight,
    onSecondaryContainer: Colors.white,
    tertiary: MaterialDesignSystem.accentOrange,
    onTertiary: Colors.white,
    tertiaryContainer: MaterialDesignSystem.accentOrangeLight,
    onTertiaryContainer: Colors.white,
    error: MaterialDesignSystem.errorRed,
    onError: Colors.white,
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: MaterialDesignSystem.errorRed,
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF424242),
    outline: Color(0xFFE0E0E0),
    outlineVariant: Color(0xFFEEEEEE),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF303030),
    onInverseSurface: Color(0xFFFAFAFA),
    inversePrimary: MaterialDesignSystem.primaryBlueLight,
    surfaceTint: MaterialDesignSystem.primaryBlue,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF8F9FA),
    surfaceContainer: Color(0xFFF1F3F4),
    surfaceContainerHigh: Color(0xFFE8EAED),
    surfaceContainerHighest: Color(0xFFDADCE0),
  );
  
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: MaterialDesignSystem.primaryBlueLight,
    onPrimary: Color(0xFF00344D),
    primaryContainer: MaterialDesignSystem.primaryBlue,
    onPrimaryContainer: Colors.white,
    secondary: MaterialDesignSystem.secondaryTealLight,
    onSecondary: Color(0xFF00344D),
    secondaryContainer: MaterialDesignSystem.secondaryTeal,
    onSecondaryContainer: Colors.white,
    tertiary: MaterialDesignSystem.accentOrangeLight,
    onTertiary: Color(0xFF00344D),
    tertiaryContainer: MaterialDesignSystem.accentOrange,
    onTertiaryContainer: Colors.white,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceVariant: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFBDBDBD),
    outline: Color(0xFF424242),
    outlineVariant: Color(0xFF616161),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE0E0E0),
    onInverseSurface: Color(0xFF121212),
    inversePrimary: MaterialDesignSystem.primaryBlue,
    surfaceTint: MaterialDesignSystem.primaryBlueLight,
    surfaceContainerLowest: Color(0xFF0A0A0A),
    surfaceContainerLow: Color(0xFF1A1A1A),
    surfaceContainer: Color(0xFF1E1E1E),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF303030),
  );
  
  // MARK: - Theme Utilities
  static ThemeData getThemeForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return lightTheme; // Default to light theme
    }
  }
  
  static bool isDarkMode(ThemeMode mode) {
    return mode == ThemeMode.dark;
  }
  
  static ColorScheme getColorSchemeForMode(ThemeMode mode) {
    return getThemeForMode(mode).colorScheme;
  }
}
