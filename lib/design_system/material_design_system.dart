import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive Material Design System
/// Provides consistent design tokens, components, and utilities
class MaterialDesignSystem {
  // MARK: - Color System
  static const Color primaryBlue = Color(0xFF006591);
  static const Color primaryBlueLight = Color(0xFF009CDE);
  static const Color primaryBlueDark = Color(0xFF004C6E);
  
  static const Color secondaryTeal = Color(0xFF00B4D8);
  static const Color secondaryTealLight = Color(0xFF48CAE4);
  static const Color secondaryTealDark = Color(0xFF0077B6);
  
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentOrangeLight = Color(0xFFFF8A65);
  static const Color accentOrangeDark = Color(0xFFE64A19);
  
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // MARK: - Typography
  static const String fontFamily = 'Poppins';
  static const String fontFamilyMono = 'Roboto Mono';
  
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // MARK: - Spacing System
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;
  
  // MARK: - Border Radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius28 = 28.0;
  static const double radius32 = 32.0;
  static const double radius40 = 40.0;
  
  // MARK: - Elevation & Shadows
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // MARK: - Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // MARK: - Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // MARK: - Component Heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonHeightXLarge = 56.0;
  
  static const double inputHeightSmall = 36.0;
  static const double inputHeightMedium = 44.0;
  static const double inputHeightLarge = 52.0;
  
  static const double cardHeightSmall = 80.0;
  static const double cardHeightMedium = 120.0;
  static const double cardHeightLarge = 160.0;
  
  // MARK: - Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;
  static const double iconSizeXXLarge = 48.0;
}

/// Material Design Theme Extensions
extension MaterialDesignTheme on ThemeData {
  // MARK: - Color Extensions
  Color get surfaceContainer => colorScheme.surfaceContainer;
  Color get surfaceContainerLow => colorScheme.surfaceContainerLow;
  Color get surfaceContainerHigh => colorScheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => colorScheme.surfaceContainerHighest;
  Color get surfaceContainerLowest => colorScheme.surfaceContainerLowest;
  
  // MARK: - Text Style Extensions
  TextStyle get displayLarge => textTheme.displayLarge!;
  TextStyle get displayMedium => textTheme.displayMedium!;
  TextStyle get displaySmall => textTheme.displaySmall!;
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;
  
  // MARK: - Spacing Extensions
  EdgeInsets get paddingSmall => const EdgeInsets.all(MaterialDesignSystem.spacing8);
  EdgeInsets get paddingMedium => const EdgeInsets.all(MaterialDesignSystem.spacing16);
  EdgeInsets get paddingLarge => const EdgeInsets.all(MaterialDesignSystem.spacing24);
  
  EdgeInsets get paddingHorizontalSmall => const EdgeInsets.symmetric(horizontal: MaterialDesignSystem.spacing8);
  EdgeInsets get paddingHorizontalMedium => const EdgeInsets.symmetric(horizontal: MaterialDesignSystem.spacing16);
  EdgeInsets get paddingHorizontalLarge => const EdgeInsets.symmetric(horizontal: MaterialDesignSystem.spacing24);
  
  EdgeInsets get paddingVerticalSmall => const EdgeInsets.symmetric(vertical: MaterialDesignSystem.spacing8);
  EdgeInsets get paddingVerticalMedium => const EdgeInsets.symmetric(vertical: MaterialDesignSystem.spacing16);
  EdgeInsets get paddingVerticalLarge => const EdgeInsets.symmetric(vertical: MaterialDesignSystem.spacing24);
  
  // MARK: - Border Radius Extensions
  BorderRadius get radiusSmall => BorderRadius.circular(MaterialDesignSystem.radius8);
  BorderRadius get radiusMedium => BorderRadius.circular(MaterialDesignSystem.radius12);
  BorderRadius get radiusLarge => BorderRadius.circular(MaterialDesignSystem.radius16);
  BorderRadius get radiusXLarge => BorderRadius.circular(MaterialDesignSystem.radius24);
  
  // MARK: - Shadow Extensions
  List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: colorScheme.shadow.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: colorScheme.shadow.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: colorScheme.shadow.withOpacity(0.16),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  List<BoxShadow> get shadowXLarge => [
    BoxShadow(
      color: colorScheme.shadow.withOpacity(0.20),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Material Design Component Builders
class MaterialComponents {
  // MARK: - Button Builders
  static Widget elevatedButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    double height = MaterialDesignSystem.buttonHeightMedium,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: MaterialDesignSystem.spacing24,
            vertical: MaterialDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
          ),
          elevation: MaterialDesignSystem.elevation2,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon,
                    const SizedBox(width: MaterialDesignSystem.spacing8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
  
  static Widget outlinedButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    double height = MaterialDesignSystem.buttonHeightMedium,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    Color? foregroundColor,
    BorderRadius? borderRadius,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: MaterialDesignSystem.spacing24,
            vertical: MaterialDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
          ),
          side: BorderSide(
            color: foregroundColor ?? Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.grey.shade600,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon,
                    const SizedBox(width: MaterialDesignSystem.spacing8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
  
  static Widget textButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    double height = MaterialDesignSystem.buttonHeightMedium,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    Color? foregroundColor,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: MaterialDesignSystem.spacing16,
            vertical: MaterialDesignSystem.spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MaterialDesignSystem.radius8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.grey.shade600,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon,
                    const SizedBox(width: MaterialDesignSystem.spacing8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
  
  // MARK: - Input Builders
  static Widget textField({
    required TextEditingController controller,
    String? hintText,
    String? labelText,
    String? errorText,
    bool isPassword = false,
    bool isMultiline = false,
    int? maxLines,
    int? maxLength,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? prefixIcon,
    Widget? suffixIcon,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool readOnly = false,
    double height = MaterialDesignSystem.inputHeightMedium,
    EdgeInsetsGeometry? contentPadding,
    BorderRadius? borderRadius,
    Color? fillColor,
  }) {
    return SizedBox(
      height: isMultiline ? null : height,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        maxLines: isMultiline ? (maxLines ?? 4) : 1,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: fillColor != null,
          fillColor: fillColor,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: MaterialDesignSystem.spacing16,
            vertical: MaterialDesignSystem.spacing12,
          ),
          border: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
            borderSide: const BorderSide(width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
            borderSide: const BorderSide(color: MaterialDesignSystem.errorRed),
          ),
        ),
      ),
    );
  }
  
  // MARK: - Card Builders
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
    bool isElevated = true,
  }) {
    final card = Container(
      margin: margin ?? const EdgeInsets.all(MaterialDesignSystem.spacing8),
      padding: padding ?? const EdgeInsets.all(MaterialDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius16),
        boxShadow: isElevated ? (boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]) : null,
      ),
      child: child,
    );
    
    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius16),
            child: card,
          )
        : card;
  }
  
  // MARK: - List Tile Builders
  static Widget listTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSelected = false,
    EdgeInsetsGeometry? contentPadding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MaterialDesignSystem.spacing8,
        vertical: MaterialDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: MaterialDesignSystem.spacing16,
          vertical: MaterialDesignSystem.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
        ),
      ),
    );
  }
  
  // MARK: - Dialog Builders
  static Future<T?> showMaterialDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    BorderRadius? borderRadius,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius20),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop();
              },
              child: Text(cancelText),
            ),
          if (confirmText != null)
            ElevatedButton(
              onPressed: () {
                onConfirm?.call();
                Navigator.of(context).pop();
              },
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }
  
  // MARK: - Snackbar Builders
  static void showMaterialSnackBar({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: foregroundColor),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MaterialDesignSystem.radius12),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
                textColor: foregroundColor,
              )
            : null,
      ),
    );
  }
  
  // MARK: - Loading Builders
  static Widget loadingIndicator({
    double size = 24.0,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }
  
  static Widget shimmerLoading({
    double height = 100.0,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius12),
      ),
    );
  }
}

/// Responsive Design Utilities
class ResponsiveDesign {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < MaterialDesignSystem.mobileBreakpoint;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= MaterialDesignSystem.mobileBreakpoint &&
      MediaQuery.of(context).size.width < MaterialDesignSystem.tabletBreakpoint;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= MaterialDesignSystem.desktopBreakpoint;
  
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  static double responsiveSpacing(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: MaterialDesignSystem.spacing16,
      tablet: MaterialDesignSystem.spacing24,
      desktop: MaterialDesignSystem.spacing32,
    );
  }
  
  static double responsivePadding(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: MaterialDesignSystem.spacing16,
      tablet: MaterialDesignSystem.spacing24,
      desktop: MaterialDesignSystem.spacing32,
    );
  }
  
  static double responsiveRadius(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: MaterialDesignSystem.radius12,
      tablet: MaterialDesignSystem.radius16,
      desktop: MaterialDesignSystem.radius20,
    );
  }
}

/// Animation Utilities
class MaterialAnimations {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Duration defaultDuration = Duration(milliseconds: 300);
  
  static Widget fadeIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: child,
    );
  }
  
  static Widget slideIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) => Transform.translate(
        offset: value,
        child: child,
      ),
      child: child,
    );
  }
  
  static Widget scaleIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: child,
    );
  }
}
