import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../design_system/material_design_system.dart';
import '../utils/responsive.dart';

/// Circular Back Button
/// A reusable widget that displays a back button in a circular container.
/// Can be used consistently across all screens in the app.
class CircularBackButton extends StatelessWidget {

  const CircularBackButton({
    super.key,
    this.onPressed,
    this.size,
    this.icon = Icons.arrow_back_ios_new,
    this.backgroundColor,
    this.iconColor,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 1.0,
  });
  /// The callback that is called when the button is tapped.
  /// If not provided, will use Get.back() by default.
  final VoidCallback? onPressed;

  /// The size of the circular container.
  /// This will be responsive based on the device size.
  final double? size;

  /// The icon to display inside the circular container.
  /// Defaults to arrow_back_ios_new.
  final IconData icon;

  /// The color of the circular container.
  /// If not provided, will use theme's surfaceContainerLowest.
  final Color? backgroundColor;

  /// The color of the icon.
  /// If not provided, will use theme's onSurface.
  final Color? iconColor;

  /// Whether to show border outline around the button.
  final bool showBorder;

  /// The color of the border outline.
  /// If not provided, will use theme's outline.
  final Color? borderColor;

  /// The width of the border outline.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Determine the responsive size
    final double buttonSize = size ?? Responsive.responsiveValue(
      context,
      mobile: 34.0,
      tablet: 38.0,
      web: 42.0,
    );

    // Determine the responsive icon size
    final iconSize = Responsive.responsiveValue(
      context,
      mobile: 18.0,
      tablet: 20.0,
      web: 22.0,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => Get.back<void>(),
        borderRadius: BorderRadius.circular((buttonSize) / 2),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: showBorder ? Border.all(
              color: borderColor ?? theme.colorScheme.outline,
              width: borderWidth,
            ) : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension method to make it easier to use CircularBackButton
/// in AppBar leading slot
extension CircularBackButtonExtension on CircularBackButton {
  /// Wraps the CircularBackButton in a Container with appropriate padding
  /// for use in AppBar leading slot
  Widget asAppBarLeading() {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      child: this,
    );
  }
}

/// Extension method to easily add CircularBackButton to AppBar
extension AppBarWithCircularBackButton on AppBar {
  /// Creates a new AppBar with CircularBackButton as leading widget
  static AppBar withCircularBackButton({
    required BuildContext context,
    required Widget title,
    List<Widget>? actions,
    Color? backgroundColor,
    double? elevation,
    bool centerTitle = false,
    double? toolbarHeight,
    PreferredSizeWidget? bottom,
    Color? iconColor,
  }) {
    return AppBar(
      leading: CircularBackButton(iconColor: iconColor),
      title: title,
      actions: actions,
      backgroundColor: backgroundColor ??
          context.theme.colorScheme.surfaceContainerLowest,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
    );
  }
}