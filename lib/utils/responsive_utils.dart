import 'package:flutter/material.dart';
import 'responsive.dart';

/// A utility class for responsive design helpers.
/// 
/// This class provides utility methods for creating responsive UIs
/// that maintain consistency across mobile, web, and tablet platforms.
class ResponsiveUtils {
  /// Get responsive grid parameters based on screen size
  static int getGridCrossAxisCount(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int web = 3,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      web: web,
    );
  }

  /// Get responsive grid aspect ratio based on screen size
  static double getGridAspectRatio(BuildContext context, {
    double mobile = 1.0,
    double tablet = 1.2,
    double web = 1.5,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      web: web,
    );
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getPadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? web,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile ?? const EdgeInsets.all(16.0),
      tablet: tablet ?? const EdgeInsets.all(24.0),
      web: web ?? const EdgeInsets.all(32.0),
    );
  }

  /// Get responsive spacing based on screen size
  static double getSpacing(BuildContext context, {
    double? mobile,
    double? tablet,
    double? web,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile ?? 16.0,
      tablet: tablet ?? 24.0,
      web: web ?? 32.0,
    );
  }

  /// Get responsive font size based on screen size
  static double getFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? web,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? (mobile + 1),
      web: web ?? (mobile + 2),
    );
  }

  /// Get responsive icon size based on screen size
  static double getIconSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? web,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile ?? 24.0,
      tablet: tablet ?? 28.0,
      web: web ?? 32.0,
    );
  }

  /// Get responsive button height based on screen size
  static double getButtonHeight(BuildContext context, {
    double? mobile,
    double? tablet,
    double? web,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile ?? 44.0,
      tablet: tablet ?? 48.0,
      web: web ?? 52.0,
    );
  }

  /// Get responsive width constraint based on screen size
  static double getMaxWidth(BuildContext context, {
    double? mobile,
    double? tablet,
    double? web,
  }) {
    return Responsive.responsiveValue(
      context,
      mobile: mobile ?? double.infinity,
      tablet: tablet ?? 600.0,
      web: web ?? 1200.0,
    );
  }

  /// Wrap a widget with responsive max width constraints
  static Widget wrapWithMaxWidth(BuildContext context, Widget child, {
    double? mobileMaxWidth,
    double? tabletMaxWidth,
    double? webMaxWidth,
    Alignment alignment = Alignment.center,
  }) {
    final maxWidth = getMaxWidth(
      context,
      mobile: mobileMaxWidth,
      tablet: tabletMaxWidth,
      web: webMaxWidth,
    );

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      alignment: alignment,
      child: child,
    );
  }

  /// Get responsive container height based on screen size and content
  static double getContainerHeight(BuildContext context, {
    required double contentHeight,
    double mobileMultiplier = 1.0,
    double tabletMultiplier = 0.8,
    double webMultiplier = 0.7,
  }) {
    final multiplier = Responsive.responsiveValue(
      context,
      mobile: mobileMultiplier,
      tablet: tabletMultiplier,
      web: webMultiplier,
    );

    return contentHeight * multiplier;
  }

  /// Get responsive gap based on screen size
  static Widget gap(BuildContext context, {
    double? mobile,
    double? tablet,
    double? web,
    Axis direction = Axis.vertical,
  }) {
    final size = getSpacing(
      context,
      mobile: mobile,
      tablet: tablet,
      web: web,
    );

    return direction == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }

  /// Determine if a dialog should be full screen based on screen size
  static bool shouldUseFullScreenDialog(BuildContext context) {
    return Responsive.isMobile(context) &&
        MediaQuery
            .of(context)
            .orientation == Orientation.portrait;
  }

  /// Get responsive dialog width based on screen size
  static double getDialogWidth(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MediaQuery
          .of(context)
          .size
          .width * 0.9;
    } else if (Responsive.isTablet(context)) {
      return MediaQuery
          .of(context)
          .size
          .width * 0.7;
    } else {
      return MediaQuery
          .of(context)
          .size
          .width * 0.5;
    }
  }

  /// Get responsive dialog constraints based on screen size
  static BoxConstraints getDialogConstraints(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return BoxConstraints(
        maxWidth: MediaQuery
            .of(context)
            .size
            .width * 0.9,
        maxHeight: MediaQuery
            .of(context)
            .size
            .height * 0.8,
      );
    } else if (Responsive.isTablet(context)) {
      return BoxConstraints(
        maxWidth: 500,
        maxHeight: MediaQuery
            .of(context)
            .size
            .height * 0.8,
      );
    } else {
      return const BoxConstraints(
        maxWidth: 600,
        maxHeight: 700,
      );
    }
  }
}