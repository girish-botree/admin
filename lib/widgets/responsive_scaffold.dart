import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// A responsive scaffold that maintains a consistent UI across mobile, web, and tablet platforms.
/// 
/// This widget adapts the layout based on screen size while keeping the same mobile widgets
/// for all platforms. It's designed to create a unified experience across different devices.
class ResponsiveScaffold extends StatelessWidget {
  /// The app bar to display at the top of the scaffold.
  final PreferredSizeWidget? appBar;

  /// The primary content of the scaffold.
  final Widget body;

  /// Optional drawer that can be opened from the left edge.
  final Widget? drawer;

  /// Optional drawer that can be opened from the right edge.
  final Widget? endDrawer;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Optional floating action button location.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Background color of the scaffold.
  final Color? backgroundColor;

  /// Whether to show the drawer alongside the body on larger screens.
  final bool showDrawerOnWideScreen;

  /// Width of the drawer when shown alongside the body.
  final double drawerWidth;

  /// Whether to keep the drawer open on wide screens.
  final bool keepDrawerOpen;

  /// Background color of the drawer when shown alongside the body.
  final Color? drawerBackgroundColor;

  /// Width of the content area on web.
  final double? webContentMaxWidth;

  /// Whether to center the content on web.
  final bool centerWebContent;

  /// Padding around the body content.
  final EdgeInsets? bodyPadding;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.showDrawerOnWideScreen = true,
    this.drawerWidth = 280,
    this.keepDrawerOpen = false,
    this.drawerBackgroundColor,
    this.webContentMaxWidth,
    this.centerWebContent = true,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = Responsive.isWeb(context) ||
        Responsive.isTablet(context);

    // For wide screens with drawer, we'll show a different layout
    if (isWideScreen && drawer != null && showDrawerOnWideScreen) {
      return _buildWideScreenWithDrawer(context);
    }

    // Use standard mobile scaffold with some responsive tweaks
    return _buildMobileScaffold(context, isWideScreen);
  }

  Widget _buildMobileScaffold(BuildContext context, bool isWideScreen) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      body: isWideScreen ? _wrapWebContent(context, body) : _wrapWithPadding(
          body),
    );
  }

  Widget _buildWideScreenWithDrawer(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // Always-visible drawer (no need to open it)
          Container(
            width: drawerWidth,
            color: drawerBackgroundColor ?? Theme
                .of(context)
                .drawerTheme
                .backgroundColor,
            child: drawer,
          ),
          // Main content
          Expanded(
            child: _wrapWebContent(context, _wrapWithPadding(body)),
          ),
        ],
      ),
    );
  }

  Widget _wrapWithPadding(Widget content) {
    return bodyPadding != null
        ? Padding(padding: bodyPadding!, child: content)
        : content;
  }

  Widget _wrapWebContent(BuildContext context, Widget content) {
    // On web, we often want to center the content and limit its width
    if (Responsive.isWeb(context) && centerWebContent) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: webContentMaxWidth ?? 1200,
          ),
          child: content,
        ),
      );
    }
    return content;
  }
}

/// A responsive page that maintains a consistent layout across different screen sizes.
class ResponsivePage extends StatelessWidget {
  /// The title of the page, displayed in the app bar.
  final String title;

  /// The primary content of the page.
  final Widget body;

  /// Actions to display in the app bar.
  final List<Widget>? actions;

  /// Whether to show a back button in the app bar.
  final bool showBackButton;

  /// Optional drawer that can be opened from the left edge.
  final Widget? drawer;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Whether to use a scrollable body.
  final bool scrollable;

  /// Padding around the body content.
  final EdgeInsets? bodyPadding;

  /// Background color of the scaffold.
  final Color? backgroundColor;

  const ResponsivePage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.scrollable = true,
    this.bodyPadding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: showBackButton,
      ),
      body: scrollable
          ? SingleChildScrollView(child: body)
          : body,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      bodyPadding: bodyPadding ?? const EdgeInsets.all(16),
      backgroundColor: backgroundColor,
    );
  }
}