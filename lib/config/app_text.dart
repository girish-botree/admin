import 'package:admin/config/app_colors.dart';
import 'package:admin/config/theme_controller.dart';
import 'package:admin/language/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const kFontFamily = 'PoppinsRegular';

class AppText extends StatelessWidget {
  final String? text;
  final num size;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isItalic;
  final bool isUnderline;
  final bool isLineThrough;
  final double? height;
  final double letterSpacing;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final TextBaseline? baseLine;
  final String? fontFamily;

  const AppText(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.fontWeight = FontWeight.normal,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  });

  const AppText.thin(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w100;

  const AppText.extraLight(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w200;

  const AppText.light(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w300;

  const AppText.regular(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w400;

  const AppText.medium(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w500;

  const AppText.semiBold(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w600;

  const AppText.bold(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w700;

  const AppText.extraBold(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w800;

  const AppText.black(
    this.text, {
    this.size = 14,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : fontWeight = FontWeight.w900;

  // Predefined text styles for common use cases
  const AppText.h1(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 32,
       fontWeight = FontWeight.w700;

  const AppText.h2(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 28,
       fontWeight = FontWeight.w600;

  const AppText.h3(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 24,
       fontWeight = FontWeight.w600;

  const AppText.h4(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 20,
       fontWeight = FontWeight.w600;

  const AppText.h5(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 18,
       fontWeight = FontWeight.w600;

  const AppText.h6(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 16,
       fontWeight = FontWeight.w600;

  const AppText.subtitle1(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 16,
       fontWeight = FontWeight.w400;

  const AppText.subtitle2(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 14,
       fontWeight = FontWeight.w400;

  const AppText.body1(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 16,
       fontWeight = FontWeight.w400;

  const AppText.body2(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 14,
       fontWeight = FontWeight.w400;

  const AppText.caption(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 12,
       fontWeight = FontWeight.w400;

  const AppText.button(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 0.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 14,
       fontWeight = FontWeight.w500;

  const AppText.overline(
    this.text, {
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isItalic = false,
    this.isUnderline = false,
    this.isLineThrough = false,
    this.height,
    this.letterSpacing = 1.5,
    this.padding,
    this.baseLine,
    this.fontFamily,
    super.key,
  }) : size = 10,
       fontWeight = FontWeight.w400;

  @override
  Widget build(BuildContext context) {
    final widget = Text(
      text ?? '',
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow,
      maxLines: maxLines,
      style: style,
      textHeightBehavior: const TextHeightBehavior(applyHeightToLastDescent: false),
    );

    return padding != null ? Padding(padding: padding!, child: widget) : widget;
  }

  TextStyle get style {
    // Get font size multiplier from theme controller if available
    double fontSizeMultiplier = 1.0;
    try {
      final themeController = Get.find<ThemeController>();
      fontSizeMultiplier = themeController.fontSizeMultiplier;
    } catch (e) {
      // If theme controller is not available, use default multiplier
    }

    return TextStyle(
      color: color ?? AppColor.black,
      decorationColor: color ?? AppColor.black,
      fontSize: (size * fontSizeMultiplier).toDouble(),
      fontStyle: isItalic ? FontStyle.italic : null,
      decoration: isUnderline
          ? TextDecoration.underline
          : (isLineThrough ? TextDecoration.lineThrough : TextDecoration.none),
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      textBaseline: baseLine,
      fontFamily: fontFamily ?? kFontFamily,
    );
  }

  // Helper methods for common text styling
  AppText copyWith({
    String? text,
    num? size,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? isItalic,
    bool? isUnderline,
    bool? isLineThrough,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    TextBaseline? baseLine,
    String? fontFamily,
  }) {
    return AppText(
      text ?? this.text,
      size: size ?? this.size,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
      overflow: overflow ?? this.overflow,
      maxLines: maxLines ?? this.maxLines,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isLineThrough: isLineThrough ?? this.isLineThrough,
      height: height ?? this.height,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontWeight: fontWeight ?? this.fontWeight,
      padding: padding ?? this.padding,
      baseLine: baseLine ?? this.baseLine,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  static Widget tr(String key, {
    num size = 14,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool isItalic = false,
    bool isUnderline = false,
    bool isLineThrough = false,
    double? height,
    double letterSpacing = 0.5,
    FontWeight fontWeight = FontWeight.normal,
    EdgeInsetsGeometry? padding,
    TextBaseline? baseLine,
    String? fontFamily,
  }) {
    return Obx(() =>
        AppText(
          key.tr,
          size: size,
          color: color,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          isItalic: isItalic,
          isUnderline: isUnderline,
          isLineThrough: isLineThrough,
          height: height,
          letterSpacing: letterSpacing,
          fontWeight: fontWeight,
          padding: padding,
          baseLine: baseLine,
          fontFamily: fontFamily,
        ));
  }
}

// Rich text widget for mixed styling
class AppRichText extends StatelessWidget {
  final List<TextSpan> textSpans;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final EdgeInsetsGeometry? padding;

  const AppRichText({
    required this.textSpans,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final widget = RichText(
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow ?? TextOverflow.clip,
      maxLines: maxLines,
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(
          fontFamily: kFontFamily,
          color: AppColor.black,
        ),
      ),
    );

    return padding != null ? Padding(padding: padding!, child: widget) : widget;
  }
}

// Helper class for creating text spans
class AppTextSpan {
  static TextSpan create(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    TextDecoration? decoration,
    bool isItalic = false,
    double letterSpacing = 0.5,
    String? fontFamily,
  }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color ?? AppColor.black,
        fontWeight: fontWeight ?? FontWeight.w400,
        fontSize: fontSize ?? 14,
        decoration: decoration ?? TextDecoration.none,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: letterSpacing,
        fontFamily: fontFamily ?? kFontFamily,
      ),
    );
  }
}