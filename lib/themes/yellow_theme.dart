import 'package:admin/themes/theme_data_extention.dart';
import 'package:flutter/material.dart';


const kFontFamily = "";

class YellowTheme {
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff805610),
      surfaceTint: Color(0xff805610),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffddb4),
      onPrimaryContainer: Color(0xff633f00),
      secondary: Color(0xff904a46),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad7),
      onSecondaryContainer: Color(0xff733330),
      tertiary: Color(0xff52643f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd4eabb),
      onTertiaryContainer: Color(0xff3a4c2a),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f4),
      onSurface: Color(0xff211b13),
      onSurfaceVariant: Color(0xff4f4539),
      outline: Color(0xff817567),
      outlineVariant: Color(0xffd3c4b4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff362f27),
      inversePrimary: Color(0xfff5bd6f),
      primaryFixed: Color(0xffffddb4),
      onPrimaryFixed: Color(0xff291800),
      primaryFixedDim: Color(0xfff5bd6f),
      onPrimaryFixedVariant: Color(0xff633f00),
      secondaryFixed: Color(0xffffdad7),
      onSecondaryFixed: Color(0xff3b0909),
      secondaryFixedDim: Color(0xffffb3ad),
      onSecondaryFixedVariant: Color(0xff733330),
      tertiaryFixed: Color(0xffd4eabb),
      onTertiaryFixed: Color(0xff102003),
      tertiaryFixedDim: Color(0xffb8cda1),
      onTertiaryFixedVariant: Color(0xff3a4c2a),
      surfaceDim: Color(0xffe4d8cc),
      surfaceBright: Color(0xfffff8f4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1e5),
      surfaceContainer: Color(0xfff9ecdf),
      surfaceContainerHigh: Color(0xfff3e6da),
      surfaceContainerHighest: Color(0xffede0d4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff5bd6f),
      surfaceTint: Color(0xfff5bd6f),
      onPrimary: Color(0xff452b00),
      primaryContainer: Color(0xff633f00),
      onPrimaryContainer: Color(0xffffddb4),
      secondary: Color(0xffffb3ad),
      onSecondary: Color(0xff571e1b),
      secondaryContainer: Color(0xff733330),
      onSecondaryContainer: Color(0xffffdad7),
      tertiary: Color(0xffb8cda1),
      onTertiary: Color(0xff253515),
      tertiaryContainer: Color(0xff3a4c2a),
      onTertiaryContainer: Color(0xffd4eabb),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff18120b),
      onSurface: Color(0xffede0d4),
      onSurfaceVariant: Color(0xffd3c4b4),
      outline: Color(0xff9c8f80),
      outlineVariant: Color(0xff4f4539),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffede0d4),
      inversePrimary: Color(0xff805610),
      primaryFixed: Color(0xffffddb4),
      onPrimaryFixed: Color(0xff291800),
      primaryFixedDim: Color(0xfff5bd6f),
      onPrimaryFixedVariant: Color(0xff633f00),
      secondaryFixed: Color(0xffffdad7),
      onSecondaryFixed: Color(0xff3b0909),
      secondaryFixedDim: Color(0xffffb3ad),
      onSecondaryFixedVariant: Color(0xff733330),
      tertiaryFixed: Color(0xffd4eabb),
      onTertiaryFixed: Color(0xff102003),
      tertiaryFixedDim: Color(0xffb8cda1),
      onTertiaryFixedVariant: Color(0xff3a4c2a),
      surfaceDim: Color(0xff18120b),
      surfaceBright: Color(0xff3f3830),
      surfaceContainerLowest: Color(0xff120d07),
      surfaceContainerLow: Color(0xff211b13),
      surfaceContainer: Color(0xff251f17),
      surfaceContainerHigh: Color(0xff302921),
      surfaceContainerHighest: Color(0xff3b342b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    primaryColorDark: colorScheme.primary,
    fontFamily: kFontFamily,
    scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
    cardTheme: ThemeDataExtension.cardTheme(colorScheme),
    dividerTheme: ThemeDataExtension.devidedTheme(colorScheme),
    textTheme: ThemeDataExtension.textThemeData(colorScheme),
    dividerColor: colorScheme.outline,
    elevatedButtonTheme: ThemeDataExtension.elevatedButtonTheme(colorScheme),
    disabledColor: colorScheme.outline,
    hintColor: colorScheme.outline,
    shadowColor: colorScheme.outline.withOpacity(0.5),
    dialogTheme: ThemeDataExtension.dialogTheme(colorScheme),
    bottomSheetTheme: ThemeDataExtension.bottomsheetTheme(colorScheme),
    inputDecorationTheme: ThemeDataExtension.inputDecorationTheme(colorScheme),
    radioTheme: ThemeDataExtension.radioTheme(colorScheme),
    checkboxTheme: ThemeDataExtension.checkboxTheme(colorScheme),
    floatingActionButtonTheme: ThemeDataExtension.floatingActionButtonTheme(colorScheme),
    snackBarTheme: ThemeDataExtension.snackBarTheme(colorScheme),
    appBarTheme: ThemeDataExtension.appBarTheme(colorScheme),
  );
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
