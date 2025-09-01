import 'package:flutter/material.dart';
import '../design_system/material_design_system.dart';

/// Enhanced Base Widgets
/// Provides consistent Material Design styling and improved UX
class EnhancedBaseWidgets {
  // MARK: - Enhanced Scaffold
  static Widget enhancedScaffold({
    required BuildContext context,
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? drawer,
    Widget? endDrawer,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surfaceContainerLowest,
              theme.colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(MaterialDesignSystem.spacing16),
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
  
  // MARK: - Enhanced App Bar
  static PreferredSizeWidget enhancedAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: MaterialDesignSystem.fontWeightSemiBold,
        ),
      ),
      actions: actions,
      leading: leading ?? (showBackButton ? IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: MaterialDesignSystem.iconSizeMedium,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ) : null),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
    );
  }
  
  // MARK: - Enhanced Container
  static Widget enhancedContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
  
  // MARK: - Enhanced Card
  static Widget enhancedCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
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
            color: Colors.black.withValues(alpha: 0.08),
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
            borderRadius: (borderRadius ?? BorderRadius.circular(MaterialDesignSystem.radius16)) as BorderRadius?,
            child: card,
          )
        : card;
  }
  
  // MARK: - Enhanced List View
  static Widget enhancedListView({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    bool primary = true,
    bool reverse = false,
  }) {
    return ListView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const BouncingScrollPhysics(),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      primary: primary,
      reverse: reverse,
      children: children,
    );
  }
  
  // MARK: - Enhanced Grid View
  static Widget enhancedGridView({
    required List<Widget> children,
    required int crossAxisCount,
    double crossAxisSpacing = 16.0,
    double mainAxisSpacing = 16.0,
    double childAspectRatio = 1.0,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    bool primary = true,
    bool reverse = false,
  }) {
    return GridView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const BouncingScrollPhysics(),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      primary: primary,
      reverse: reverse,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      children: children,
    );
  }
  
  // MARK: - Enhanced Column
  static Widget enhancedColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    EdgeInsetsGeometry? padding,
  }) {
    Widget column = Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
    
    if (padding != null) {
      column = Padding(padding: padding, child: column);
    }
    
    return column;
  }
  
  // MARK: - Enhanced Row
  static Widget enhancedRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    EdgeInsetsGeometry? padding,
  }) {
    Widget row = Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
    
    if (padding != null) {
      row = Padding(padding: padding, child: row);
    }
    
    return row;
  }
  
  // MARK: - Enhanced Text
  static Widget enhancedText({
    required String text,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool softWrap = true,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    Widget textWidget = Text(
      text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
    
    if (padding != null) {
      textWidget = Padding(padding: padding, child: textWidget);
    }
    
    return textWidget;
  }
  
  // MARK: - Enhanced Icon
  static Widget enhancedIcon({
    required IconData icon,
    double? size,
    Color? color,
    EdgeInsetsGeometry? padding,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: size ?? MaterialDesignSystem.iconSizeMedium,
      color: color,
    );
    
    if (padding != null) {
      iconWidget = Padding(padding: padding, child: iconWidget);
    }
    
    return iconWidget;
  }
  
  // MARK: - Enhanced Divider
  static Widget enhancedDivider({
    double? height,
    double? thickness,
    double? indent,
    double? endIndent,
    Color? color,
    EdgeInsetsGeometry? margin,
  }) {
    Widget divider = Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
    
    if (margin != null) {
      divider = Padding(padding: margin, child: divider);
    }
    
    return divider;
  }
  
  // MARK: - Enhanced Spacer
  static Widget enhancedSpacer({int flex = 1}) {
    return Spacer(flex: flex);
  }
  
  // MARK: - Enhanced SizedBox
  static Widget enhancedSizedBox({
    double? width,
    double? height,
    Widget? child,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
  
  // MARK: - Enhanced Center
  static Widget enhancedCenter({required Widget child}) {
    return Center(child: child);
  }
  
  // MARK: - Enhanced Expanded
  static Widget enhancedExpanded({
    required Widget child,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
  
  // MARK: - Enhanced Flexible
  static Widget enhancedFlexible({
    required Widget child,
    int flex = 1,
    FlexFit fit = FlexFit.loose,
  }) {
    return Flexible(
      flex: flex,
      fit: fit,
      child: child,
    );
  }
  
  // MARK: - Enhanced Wrap
  static Widget enhancedWrap({
    required List<Widget> children,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    EdgeInsetsGeometry? padding,
  }) {
    Widget wrap = Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: children,
    );
    
    if (padding != null) {
      wrap = Padding(padding: padding, child: wrap);
    }
    
    return wrap;
  }
  
  // MARK: - Enhanced Stack
  static Widget enhancedStack({
    required List<Widget> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    EdgeInsetsGeometry? padding,
  }) {
    Widget stack = Stack(
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      children: children,
    );
    
    if (padding != null) {
      stack = Padding(padding: padding, child: stack);
    }
    
    return stack;
  }
  
  // MARK: - Enhanced Animated Container
  static Widget enhancedAnimatedContainer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
  
  // MARK: - Enhanced Animated Builder
  static Widget enhancedAnimatedBuilder({
    required Animation<double> animation,
    required Widget Function(BuildContext context, Widget? child) builder,
    Widget? child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
  
  // MARK: - Enhanced Future Builder
  static Widget enhancedFutureBuilder<T>({
    required Future<T> future,
    required Widget Function(BuildContext context, AsyncSnapshot<T> snapshot) builder,
    T? initialData,
  }) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: builder,
    );
  }
  
  // MARK: - Enhanced Stream Builder
  static Widget enhancedStreamBuilder<T>({
    required Stream<T> stream,
    required Widget Function(BuildContext context, AsyncSnapshot<T> snapshot) builder,
    T? initialData,
  }) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: builder,
    );
  }
  
  // MARK: - Enhanced Visibility
  static Widget enhancedVisibility({
    required Widget child,
    bool visible = true,
    bool maintainState = false,
    bool maintainAnimation = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
  }) {
    return Visibility(
      visible: visible,
      maintainState: maintainState,
      maintainAnimation: maintainAnimation,
      maintainSize: maintainSize,
      maintainSemantics: maintainSemantics,
      maintainInteractivity: maintainInteractivity,
      child: child,
    );
  }
  
  // MARK: - Enhanced Opacity
  static Widget enhancedOpacity({
    required Widget child,
    double opacity = 1.0,
    bool alwaysIncludeSemantics = false,
  }) {
    return Opacity(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }
  
  // MARK: - Enhanced Transform
  static Widget enhancedTransform({
    required Widget child,
    Matrix4? transform,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) {
    return Transform(
      transform: transform ?? Matrix4.identity(),
      origin: origin,
      alignment: alignment,
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      child: child,
    );
  }
  
  // MARK: - Enhanced ClipRRect
  static Widget enhancedClipRRect({
    required Widget child,
    BorderRadiusGeometry? borderRadius,
    CustomClipper<RRect>? clipper,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      clipper: clipper,
      child: child,
    );
  }
  
  // MARK: - Enhanced ClipOval
  static Widget enhancedClipOval({
    required Widget child,
    CustomClipper<Rect>? clipper,
  }) {
    return ClipOval(
      clipper: clipper,
      child: child,
    );
  }
  
  // MARK: - Enhanced ClipPath
  static Widget enhancedClipPath({
    required Widget child,
    CustomClipper<Path>? clipper,
  }) {
    return ClipPath(
      clipper: clipper,
      child: child,
    );
  }
  
  // MARK: - Enhanced Gesture Detector
  static Widget enhancedGestureDetector({
    required Widget child,
    GestureTapCallback? onTap,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCancelCallback? onTapCancel,
    GestureLongPressCallback? onLongPress,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onLongPress: onLongPress,
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      child: child,
    );
  }
  
  // MARK: - Enhanced InkWell
  static Widget enhancedInkWell({
    required Widget child,
    GestureTapCallback? onTap,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCancelCallback? onTapCancel,
    GestureLongPressCallback? onLongPress,
    bool excludeFromSemantics = false,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    double? radius,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    bool enableFeedback = true,
    bool canRequestFocus = true,
    ValueChanged<bool>? onFocusChange,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onHighlightChanged,
  }) {
    return InkWell(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onLongPress: onLongPress,
      excludeFromSemantics: excludeFromSemantics,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      radius: radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      enableFeedback: enableFeedback,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      onHover: onHover,
      onHighlightChanged: onHighlightChanged,
      child: child,
    );
  }
}
