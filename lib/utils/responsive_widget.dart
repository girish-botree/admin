import 'package:flutter/material.dart';
import 'responsive.dart';

/// A base widget that ensures consistent UI across mobile, web, and tablet platforms.
/// 
/// This widget uses the same mobile widgets for all platforms but adjusts layout
/// and positioning based on screen size. It's designed to create a unified experience
/// while optimizing for different form factors.
class ResponsiveWidget extends StatelessWidget {
  /// The mobile UI implementation that will be adapted for other platforms
  final Widget mobileUI;

  /// Optional customizations for layout parameters based on platform
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? webPadding;

  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? webSpacing;

  final Axis mobileDirection;
  final Axis? tabletDirection;
  final Axis? webDirection;

  final CrossAxisAlignment mobileCrossAlignment;
  final CrossAxisAlignment? tabletCrossAlignment;
  final CrossAxisAlignment? webCrossAlignment;

  final MainAxisAlignment mobileMainAlignment;
  final MainAxisAlignment? tabletMainAlignment;
  final MainAxisAlignment? webMainAlignment;

  final MainAxisSize mobileMainAxisSize;
  final MainAxisSize? tabletMainAxisSize;
  final MainAxisSize? webMainAxisSize;

  final int? gridColumns;
  final bool useGrid;

  const ResponsiveWidget({
    super.key,
    required this.mobileUI,
    this.mobilePadding = const EdgeInsets.all(16.0),
    this.tabletPadding,
    this.webPadding,
    this.mobileSpacing = 16.0,
    this.tabletSpacing,
    this.webSpacing,
    this.mobileDirection = Axis.vertical,
    this.tabletDirection,
    this.webDirection,
    this.mobileCrossAlignment = CrossAxisAlignment.start,
    this.tabletCrossAlignment,
    this.webCrossAlignment,
    this.mobileMainAlignment = MainAxisAlignment.start,
    this.tabletMainAlignment,
    this.webMainAlignment,
    this.mobileMainAxisSize = MainAxisSize.max,
    this.tabletMainAxisSize,
    this.webMainAxisSize,
    this.gridColumns,
    this.useGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine device type
    final isTablet = Responsive.isTablet(context);
    final isWeb = Responsive.isWeb(context);

    // Get layout parameters for current device
    final padding = isWeb
        ? webPadding ?? tabletPadding ?? mobilePadding
        : isTablet
        ? tabletPadding ?? mobilePadding
        : mobilePadding;

    final spacing = isWeb
        ? webSpacing ?? tabletSpacing ?? mobileSpacing
        : isTablet
        ? tabletSpacing ?? mobileSpacing
        : mobileSpacing;

    final direction = isWeb
        ? webDirection ?? tabletDirection ?? mobileDirection
        : isTablet
        ? tabletDirection ?? mobileDirection
        : mobileDirection;

    final crossAlignment = isWeb
        ? webCrossAlignment ?? tabletCrossAlignment ?? mobileCrossAlignment
        : isTablet
        ? tabletCrossAlignment ?? mobileCrossAlignment
        : mobileCrossAlignment;

    final mainAlignment = isWeb
        ? webMainAlignment ?? tabletMainAlignment ?? mobileMainAlignment
        : isTablet
        ? tabletMainAlignment ?? mobileMainAlignment
        : mobileMainAlignment;

    final mainAxisSize = isWeb
        ? webMainAxisSize ?? tabletMainAxisSize ?? mobileMainAxisSize
        : isTablet
        ? tabletMainAxisSize ?? mobileMainAxisSize
        : mobileMainAxisSize;

    // Determine if we should use a grid layout based on device and configuration
    final shouldUseGrid = useGrid ||
        (gridColumns != null && (isTablet || isWeb));

    // Apply the appropriate layout
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: shouldUseGrid
          ? _buildGridLayout(context, isTablet, isWeb)
          : _buildFlexLayout(
        direction: direction,
        crossAlignment: crossAlignment,
        mainAlignment: mainAlignment,
        mainAxisSize: mainAxisSize,
        spacing: spacing,
      ),
    );
  }

  Widget _buildFlexLayout({
    required Axis direction,
    required CrossAxisAlignment crossAlignment,
    required MainAxisAlignment mainAlignment,
    required MainAxisSize mainAxisSize,
    required double? spacing,
  }) {
    return Flex(
      direction: direction,
      crossAxisAlignment: crossAlignment,
      mainAxisAlignment: mainAlignment,
      mainAxisSize: mainAxisSize,
      children: [mobileUI],
    );
  }

  Widget _buildGridLayout(BuildContext context, bool isTablet, bool isWeb) {
    // Calculate columns based on device type
    final columns = gridColumns ??
        (isWeb ? 3 : isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: webSpacing ?? tabletSpacing ?? mobileSpacing ?? 16.0,
        mainAxisSpacing: webSpacing ?? tabletSpacing ?? mobileSpacing ?? 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: 1,
      itemBuilder: (context, index) => mobileUI,
    );
  }
}

/// A responsive container that adapts its width based on the device type.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? webMaxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth = double.infinity,
    this.tabletMaxWidth,
    this.webMaxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.responsiveValue(
      context,
      mobile: mobileMaxWidth ?? double.infinity,
      tablet: tabletMaxWidth ?? 600.0,
      web: webMaxWidth ?? 1200.0,
    );

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding,
      alignment: alignment,
      child: child,
    );
  }
}

/// A layout component that provides consistent spacing for form fields and UI elements.
class ResponsiveLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool expanded;

  const ResponsiveLayout({
    super.key,
    required this.children,
    this.padding,
    this.spacing = 16.0,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacingValue = Responsive.responsiveValue(
      context,
      mobile: spacing ?? 16.0,
      tablet: spacing ?? 20.0,
      web: spacing ?? 24.0,
    );

    final paddingValue = padding ??
        Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.all(16.0),
          tablet: const EdgeInsets.all(20.0),
          web: const EdgeInsets.all(24.0),
        ) ?? const EdgeInsets.all(16.0);

    Widget content = Padding(
      padding: paddingValue,
      child: Flex(
        direction: direction,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: _addSpacingBetweenWidgets(children, spacingValue),
      ),
    );

    if (expanded) {
      content = Expanded(child: content);
    }

    return content;
  }

  List<Widget> _addSpacingBetweenWidgets(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        final spacer = direction == Axis.vertical
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing);
        result.add(spacer);
      }
    }
    return result;
  }
}

/// A widget that adapts its layout based on screen size.
/// On mobile, displays elements vertically.
/// On tablet and web, displays elements horizontally.
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment horizontalAlignment;
  final CrossAxisAlignment verticalAlignment;
  final EdgeInsets? padding;
  final double spacing;
  final bool equalFlexWidths;
  final List<int>? flexWidths;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.horizontalAlignment = MainAxisAlignment.start,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.padding,
    this.spacing = 16.0,
    this.equalFlexWidths = true,
    this.flexWidths,
  }) : assert(flexWidths == null || flexWidths.length == children.length);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final actualSpacing = Responsive.responsiveValue(
        context,
        mobile: spacing,
        tablet: spacing * 1.25,
        web: spacing * 1.5
    );

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: isMobile
          ? Column(
        crossAxisAlignment: verticalAlignment,
        children: _addVerticalSpacing(children, actualSpacing),
      )
          : Row(
        mainAxisAlignment: horizontalAlignment,
        crossAxisAlignment: verticalAlignment,
        children: _wrapWithFlex(_addHorizontalSpacing(children, actualSpacing)),
      ),
    );
  }

  List<Widget> _addVerticalSpacing(List<Widget> widgets, double spacing) {
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

  List<Widget> _addHorizontalSpacing(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }

  List<Widget> _wrapWithFlex(List<Widget> widgets) {
    if (!equalFlexWidths && flexWidths == null) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      if (widgets[i] is SizedBox) {
        result.add(widgets[i]);
        continue;
      }

      final flex = flexWidths != null ? flexWidths![i] : 1;
      result.add(Flexible(flex: flex, child: widgets[i]));
    }
    return result;
  }
}

/// A card component that adapts to different screen sizes.
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final double? borderRadius;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? webMaxWidth;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.webMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.responsiveValue(
      context,
      mobile: mobileMaxWidth ?? double.infinity,
      tablet: tabletMaxWidth ?? 600.0,
      web: webMaxWidth ?? 1200.0,
    );

    final actualPadding = padding ??
        Responsive.responsiveValue(
          context,
          mobile: const EdgeInsets.all(16.0),
          tablet: const EdgeInsets.all(20.0),
          web: const EdgeInsets.all(24.0),
        ) ?? const EdgeInsets.all(16.0);

    final actualBorderRadius = borderRadius ??
        Responsive.responsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          web: 20.0,
        );

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: margin,
      child: Card(
        color: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(actualBorderRadius ?? 12.0),
        ),
        child: Padding(
          padding: actualPadding,
          child: child,
        ),
      ),
    );
  }
}