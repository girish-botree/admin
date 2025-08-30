import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/responsive.dart';
import 'dropdown_utils.dart';
import 'loading_widgets.dart';

/// A responsive text field that maintains consistent UI across different screen sizes.
class ResponsiveTextField extends StatelessWidget {
  /// Controller for the text field.
  final TextEditingController? controller;

  /// Label text for the text field.
  final String? labelText;

  /// Hint text for the text field.
  final String? hintText;

  /// Helper text displayed below the text field.
  final String? helperText;

  /// Error text displayed below the text field.
  final String? errorText;

  /// Whether the text field is disabled.
  final bool enabled;

  /// Whether the text field is required.
  final bool required;

  /// Keyboard type for the text field.
  final TextInputType keyboardType;

  /// Text input action for the text field.
  final TextInputAction textInputAction;

  /// Maximum length of input text.
  final int? maxLength;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// Callback when the text field value changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the text field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node for the text field.
  final FocusNode? focusNode;

  /// Validator function for the text field.
  final String? Function(String?)? validator;

  /// Prefix icon for the text field.
  final Widget? prefixIcon;

  /// Suffix icon for the text field.
  final Widget? suffixIcon;

  /// Whether to auto-validate the text field.
  final bool autovalidate;

  /// Content padding for the text field.
  final EdgeInsetsGeometry? contentPadding;

  /// Border radius for the text field.
  final double? borderRadius;

  /// Text style for the text field.
  final TextStyle? textStyle;

  const ResponsiveTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLength,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.autovalidate = false,
    this.contentPadding,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive values based on screen size
    final responsivePadding = contentPadding ??
        Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          web: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        );

    final responsiveBorderRadius = borderRadius ??
        Responsive.responsiveValue<double>(
            context, mobile: 8.0, tablet: 10.0, web: 12.0);

    final responsiveTextStyle = textStyle ??
        TextStyle(
          fontSize: Responsive.responsiveValue(
              context, mobile: 14.0, tablet: 15.0, web: 16.0) ?? 14.0,
        );

    // Create the text field with responsive properties
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator ?? (required ? _requiredValidator : null),
      autovalidateMode: autovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      inputFormatters: inputFormatters,
      style: responsiveTextStyle,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: responsivePadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsiveBorderRadius),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}

/// A responsive dropdown that maintains consistent UI across different screen sizes.
class ResponsiveDropdown<T> extends StatelessWidget {
  /// The currently selected value.
  final T? value;

  /// Callback when the selected value changes.
  final ValueChanged<T?>? onChanged;

  /// List of dropdown items.
  final List<DropdownMenuItem<T>> items;

  /// Label text for the dropdown.
  final String? labelText;

  /// Hint text for the dropdown.
  final String? hintText;

  /// Helper text displayed below the dropdown.
  final String? helperText;

  /// Error text displayed below the dropdown.
  final String? errorText;

  /// Whether the dropdown is disabled.
  final bool enabled;

  /// Whether the dropdown is required.
  final bool required;

  /// Validator function for the dropdown.
  final String? Function(T?)? validator;

  /// Icon for the dropdown.
  final Widget? icon;

  /// Whether to auto-validate the dropdown.
  final bool autovalidate;

  /// Content padding for the dropdown.
  final EdgeInsetsGeometry? contentPadding;

  /// Border radius for the dropdown.
  final double? borderRadius;

  /// Text style for the dropdown.
  final TextStyle? textStyle;

  const ResponsiveDropdown({
    super.key,
    this.value,
    this.onChanged,
    required this.items,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.icon,
    this.autovalidate = false,
    this.contentPadding,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive values based on screen size
    final responsivePadding = contentPadding ??
        Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          web: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        );

    final responsiveBorderRadius = borderRadius ??
        Responsive.responsiveValue<double>(
            context, mobile: 8.0, tablet: 10.0, web: 12.0);

    final responsiveTextStyle = textStyle ??
        TextStyle(
          fontSize: Responsive.responsiveValue(
              context, mobile: 14.0, tablet: 15.0, web: 16.0) ?? 14.0,
        );

    // Create the enhanced dropdown with responsive properties and improved UX
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: enabled ? onChanged : null,
        items: items.withCheckmarks(
          context: context,
          selectedValue: value,
        ),
        validator: validator ?? (required ? _requiredValidator : null),
        autovalidateMode: autovalidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        icon: icon,
        style: responsiveTextStyle,
        isExpanded: true,
        menuMaxHeight: 400, // Enhanced: Larger menu size
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          contentPadding: responsivePadding,
          filled: true,
          fillColor: enabled
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(T? value) {
    if (value == null) {
      return 'This field is required';
    }
    return null;
  }
}

/// A responsive button that maintains consistent UI across different screen sizes.
class ResponsiveButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Icon displayed on the button.
  final Widget? icon;

  /// Whether to show the icon before or after the text.
  final bool iconAfterText;

  /// Whether the button is loading.
  final bool isLoading;

  /// The button type (primary, secondary, outlined, etc.).
  final ResponsiveButtonType buttonType;

  /// The button size.
  final ResponsiveButtonSize buttonSize;

  /// The button shape.
  final ResponsiveButtonShape buttonShape;

  /// The button width (can be expanded to fill available space).
  final ResponsiveButtonWidth buttonWidth;

  /// Custom width for the button.
  final double? width;

  /// Custom height for the button.
  final double? height;

  /// Custom padding for the button.
  final EdgeInsetsGeometry? padding;

  /// Border radius for the button.
  final double? borderRadius;

  /// Text style for the button.
  final TextStyle? textStyle;

  /// Loading indicator color.
  final Color? loadingColor;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.iconAfterText = false,
    this.isLoading = false,
    this.buttonType = ResponsiveButtonType.primary,
    this.buttonSize = ResponsiveButtonSize.medium,
    this.buttonShape = ResponsiveButtonShape.rounded,
    this.buttonWidth = ResponsiveButtonWidth.auto,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive dimensions based on screen size and button size
    final responsiveHeight = height ?? _getButtonHeight(context);
    final responsivePadding = padding ?? _getButtonPadding(context);
    final responsiveBorderRadius = borderRadius ??
        _getButtonBorderRadius(context);
    final responsiveTextStyle = textStyle ?? _getButtonTextStyle(context);

    // Calculate button width based on buttonWidth enum
    final effectiveWidth = width ?? (
        buttonWidth == ResponsiveButtonWidth.expanded
            ? double.infinity
            : null
    );

    // Create the button with the appropriate style based on buttonType
    Widget button;
    switch (buttonType) {
      case ResponsiveButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: responsivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
            ),
            minimumSize: Size(0, responsiveHeight),
          ),
          child: _buildButtonContent(context, responsiveTextStyle),
        );
        break;
      case ResponsiveButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: responsivePadding,
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .secondaryContainer,
            foregroundColor: Theme
                .of(context)
                .colorScheme
                .onSecondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
            ),
            minimumSize: Size(0, responsiveHeight),
          ),
          child: _buildButtonContent(context, responsiveTextStyle),
        );
        break;
      case ResponsiveButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: responsivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
            ),
            minimumSize: Size(0, responsiveHeight),
          ),
          child: _buildButtonContent(context, responsiveTextStyle),
        );
        break;
      case ResponsiveButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: responsivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
            ),
            minimumSize: Size(0, responsiveHeight),
          ),
          child: _buildButtonContent(context, responsiveTextStyle),
        );
        break;
    }

    // Apply width constraints if needed
    if (effectiveWidth != null) {
      return SizedBox(width: effectiveWidth, child: button);
    }

    return button;
  }

  Widget _buildButtonContent(BuildContext context, TextStyle textStyle) {
    // Show shimmer loading indicator if isLoading is true
    if (isLoading) {
      return StandardLoadingWidget.circular(
        size: 20,
      );
    }

    // If there's no icon, just return the text
    if (icon == null) {
      return Text(text, style: textStyle);
    }

    // If there's an icon, arrange it with the text based on iconAfterText
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAfterText
          ? [
        Text(text, style: textStyle),
        const SizedBox(width: 8),
        icon!,
      ]
          : [
        icon!,
        const SizedBox(width: 8),
        Text(text, style: textStyle),
      ],
    );
  }

  double _getButtonHeight(BuildContext context) {
    switch (buttonSize) {
      case ResponsiveButtonSize.small:
        return Responsive.responsiveValue(
            context, mobile: 32, tablet: 36, web: 40) ?? 32.0;
      case ResponsiveButtonSize.medium:
        return Responsive.responsiveValue(
            context, mobile: 40, tablet: 44, web: 48) ?? 40.0;
      case ResponsiveButtonSize.large:
        return Responsive.responsiveValue(
            context, mobile: 48, tablet: 52, web: 56) ?? 48.0;
    }
  }

  EdgeInsetsGeometry _getButtonPadding(BuildContext context) {
    switch (buttonSize) {
      case ResponsiveButtonSize.small:
        return Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          tablet: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          web: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ) ?? EdgeInsets.zero;
      case ResponsiveButtonSize.medium:
        return Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          tablet: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          web: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ) ?? EdgeInsets.zero;
      case ResponsiveButtonSize.large:
        return Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tablet: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          web: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ) ?? EdgeInsets.zero;
    }
  }

  double _getButtonBorderRadius(BuildContext context) {
    final baseRadius = Responsive.responsiveValue(
        context, mobile: 8.0, tablet: 10.0, web: 12.0);

    switch (buttonShape) {
      case ResponsiveButtonShape.rounded:
        return baseRadius;
      case ResponsiveButtonShape.pill:
        return 100.0; // Very large radius for pill shape
      case ResponsiveButtonShape.square:
        return 4.0; // Small radius for near-square corners
    }
  }

  TextStyle _getButtonTextStyle(BuildContext context) {
    final baseFontSize = _getButtonFontSize(context);

    return TextStyle(
      fontSize: baseFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  double _getButtonFontSize(BuildContext context) {
    switch (buttonSize) {
      case ResponsiveButtonSize.small:
        return Responsive.responsiveValue(
            context, mobile: 12, tablet: 13, web: 14) ?? 12.0;
      case ResponsiveButtonSize.medium:
        return Responsive.responsiveValue(
            context, mobile: 14, tablet: 15, web: 16) ?? 14.0;
      case ResponsiveButtonSize.large:
        return Responsive.responsiveValue(
            context, mobile: 16, tablet: 17, web: 18) ?? 16.0;
    }
  }
}

/// Enum for button types.
enum ResponsiveButtonType {
  primary,
  secondary,
  outlined,
  text,
}

/// Enum for button sizes.
enum ResponsiveButtonSize {
  small,
  medium,
  large,
}

/// Enum for button shapes.
enum ResponsiveButtonShape {
  rounded,
  pill,
  square,
}

/// Enum for button widths.
enum ResponsiveButtonWidth {
  auto,
  expanded,
}

/// A form group component that arranges form fields with consistent spacing.
class ResponsiveFormGroup extends StatelessWidget {
  /// The form fields to display.
  final List<Widget> children;

  /// Spacing between form fields.
  final double? spacing;

  /// Padding around the form group.
  final EdgeInsets? padding;

  const ResponsiveFormGroup({
    super.key,
    required this.children,
    this.spacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = spacing ??
        Responsive.responsiveValue(
            context, mobile: 16.0, tablet: 20.0, web: 24.0) ?? 16.0;

    // Create a column with the form fields and appropriate spacing
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _addSpacingBetweenWidgets(children, responsiveSpacing),
      ),
    );
  }

  List<Widget> _addSpacingBetweenWidgets(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}

/// A responsive form row that displays multiple form fields in a row on larger screens.
class ResponsiveFormRow extends StatelessWidget {
  /// The form fields to display.
  final List<Widget> children;

  /// Spacing between form fields.
  final double? spacing;

  /// Padding around the form row.
  final EdgeInsets? padding;

  /// Whether to make the children equal width.
  final bool equalWidth;

  /// Custom flex factors for each child.
  final List<int>? flexFactors;

  /// The breakpoint at which to switch from vertical to horizontal layout.
  final double breakpoint;

  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing,
    this.padding,
    this.equalWidth = true,
    this.flexFactors,
    this.breakpoint = Responsive.mobileBreakpoint,
  }) : assert(flexFactors == null || flexFactors.length == children.length);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final responsiveSpacing = spacing ??
        Responsive.responsiveValue(
            context, mobile: 16.0, tablet: 20.0, web: 24.0) ?? 16.0;

    // Display horizontally if screen width is greater than breakpoint, otherwise vertically
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: screenWidth >= breakpoint
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildRowChildren(responsiveSpacing),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildColumnChildren(responsiveSpacing),
      ),
    );
  }

  List<Widget> _buildRowChildren(double spacing) {
    // Create a row with the form fields and appropriate spacing and flex factors
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      // Apply flex if equalWidth is true or flexFactors is provided
      if (equalWidth || (flexFactors != null)) {
        final flex = flexFactors != null ? flexFactors![i] : 1;
        result.add(Expanded(flex: flex, child: children[i]));
      } else {
        result.add(children[i]);
      }

      // Add spacing between fields except for the last one
      if (i < children.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }

    return result;
  }

  List<Widget> _buildColumnChildren(double spacing) {
    // Create a column with the form fields and appropriate spacing
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }

    return result;
  }
}