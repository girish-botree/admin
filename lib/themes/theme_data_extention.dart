

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'blue_theme.dart';

class ThemeDataExtension {

  static TextTheme textThemeData(ColorScheme colorScheme) => const TextTheme(
    titleSmall: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    titleMedium: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    titleLarge: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),

    bodySmall: TextStyle( fontFamily: kFontFamily, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    bodyLarge: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),

    labelSmall: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    labelMedium: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    labelLarge: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),

    displaySmall: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    displayMedium: TextStyle( fontFamily: kFontFamily, letterSpacing: 0.5),
    displayLarge: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),

    headlineSmall: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    headlineMedium: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
    headlineLarge: TextStyle(fontFamily: kFontFamily, letterSpacing: 0.5),
  );

  static CardThemeData cardTheme(ColorScheme colorScheme) => CardThemeData(
    elevation: 16,
    shadowColor: colorScheme.primary.withValues(alpha: 0.5),
    clipBehavior: Clip.hardEdge,
    color: colorScheme.primary,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.zero,
  );

  static DividerThemeData devidedTheme(ColorScheme colorScheme) => DividerThemeData(
      color: colorScheme.primary, space: 1, thickness: 1);

  static BottomSheetThemeData bottomsheetTheme(ColorScheme colorScheme) => BottomSheetThemeData(
    backgroundColor: colorScheme.surfaceContainerLowest,
    clipBehavior: Clip.hardEdge,
    elevation: 8,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    modalElevation: 8,
    modalBackgroundColor: colorScheme.surfaceContainerLowest,
  );

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) =>  InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.primaryFixedDim,
    contentPadding:
    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    hintStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        fontFamily: kFontFamily),
    errorStyle: TextStyle(
        color: colorScheme.error,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        fontFamily: kFontFamily),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(250),
      borderSide:
      BorderSide(color: colorScheme.primaryFixedDim, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(250),
      borderSide:
      BorderSide(color: colorScheme.primaryFixedDim, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(250),
      borderSide:
      BorderSide(color: colorScheme.primaryFixedDim, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.error),
      borderRadius: BorderRadius.circular(250),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.error),
      borderRadius: BorderRadius.circular(250),
    ),
  );

  static RadioThemeData radioTheme(ColorScheme colorScheme) => RadioThemeData(
    fillColor: WidgetStateProperty.all(colorScheme.onSecondaryContainer),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static CheckboxThemeData checkboxTheme(ColorScheme colorScheme) => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primary;
      }
      return Colors.transparent;
    }),
    side: WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return BorderSide.none;
      }
      return BorderSide(color: colorScheme.outline, width: 2);
    }),
    checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static FloatingActionButtonThemeData floatingActionButtonTheme(ColorScheme colorScheme) => FloatingActionButtonThemeData(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.surfaceContainerLowest,
  );

  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) =>   SnackBarThemeData(
    backgroundColor: colorScheme.surfaceContainerLowest,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    actionTextColor: colorScheme.primary,
    elevation: 6,
    contentTextStyle: TextStyle(
      color: colorScheme.primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: kFontFamily,
    ),
  );

  static AppBarTheme appBarTheme(ColorScheme colorScheme) => AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: colorScheme.surfaceContainerLowest,
      statusBarIconBrightness: Brightness.light,
    ),
    backgroundColor: colorScheme.surfaceContainerLowest,
    elevation: 0,
    centerTitle: false,
    shadowColor: Colors.transparent,
    foregroundColor: colorScheme.primary,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: kFontFamily,
      color: Colors.white,
      fontVariations: [
        FontVariation.weight(FontWeight.w700.value.toDouble())
      ],
    ),
  );

  static  DialogThemeData dialogTheme(ColorScheme colorScheme) => DialogThemeData(
    elevation: 16,
    backgroundColor: colorScheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static ElevatedButtonThemeData elevatedButtonTheme (ColorScheme colorScheme) => ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return 4;
        return 0;
      }),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      minimumSize: WidgetStateProperty.all(const Size(120, 42)),
      // textStyle: WidgetStateProperty.all(AppText.regular('',
      //     color: colorScheme.surfaceContainerLowest, size: 28)
      //     .style),
      padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12)),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.surfaceDim.withAlpha(150);
        }
        return colorScheme.primary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.surfaceContainerLowest.withValues(alpha: 0.2);
        } else if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return colorScheme.surfaceContainerLowest.withValues(alpha: 0.1);
        } else {
          return colorScheme.surfaceContainerLowest.withValues(alpha: 0);
        }
      }),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      )),
    ),
  );

}