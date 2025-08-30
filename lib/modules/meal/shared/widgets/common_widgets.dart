import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/responsive.dart';

/// Standardized app bar component used throughout the application
/// Provides consistent styling, behavior, and performance optimizations
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showRefresh;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? subtitle;
  final Widget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottomWidget;

  const StandardAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.showRefresh = false,
    this.isLoading = false,
    this.onRefresh,
    this.subtitle,
    this.bottom,
    this.elevation,
    this.backgroundColor,
    this.centerTitle = false,
    this.titleStyle,
    this.flexibleSpace,
    this.bottomWidget,
  });

  /// Factory constructor for section app bars (like meal management, plan management)
  factory StandardAppBar.section({
    Key? key,
    required String title,
    String? subtitle,
    bool showRefresh = true,
    bool isLoading = false,
    VoidCallback? onRefresh,
    List<Widget>? additionalActions,
    Widget? leading,
    bool showBackButton = false,
  }) {
    final List<Widget> defaultActions = [];
    
    if (showRefresh) {
      defaultActions.add(
        _RefreshButton(
          isLoading: isLoading,
          onRefresh: onRefresh,
        ),
      );
    }
    
    if (additionalActions != null) {
      defaultActions.addAll(additionalActions);
    }

    return StandardAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      actions: defaultActions.isNotEmpty ? defaultActions : null,
      leading: leading,
      showBackButton: showBackButton,
    );
  }

  /// Factory constructor for detail screens (like create/edit screens)
  factory StandardAppBar.detail({
    Key? key,
    required String title,
    String? subtitle,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return StandardAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
      actions: actions,
      centerTitle: false,
    );
  }

  /// Factory constructor for count-based app bars
  factory StandardAppBar.withCount({
    Key? key,
    required String title,
    required int itemCount,
    required String itemLabel,
    bool showDeleteAll = false,
    VoidCallback? onDeleteAll,
    bool showRefresh = true,
    bool isLoading = false,
    VoidCallback? onRefresh,
    VoidCallback? onBackPressed,
  }) {
    final List<Widget> actions = [];
    
    // Add count badge
    actions.add(
      _CountBadge(count: itemCount, label: itemLabel),
    );
    
    // Add refresh button
    if (showRefresh) {
      actions.add(
        _RefreshButton(
          isLoading: isLoading,
          onRefresh: onRefresh,
        ),
      );
    }
    
    // Add delete all option
    if (showDeleteAll && itemCount > 0) {
      actions.add(
        _DeleteAllButton(
          title: title,
          onDeleteAll: onDeleteAll,
        ),
      );
    }
    
    return StandardAppBar(
      key: key,
      title: title,
      actions: actions,
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    // Responsive title size
    final titleFontSize = Responsive.responsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      web: 28.0,
    );
    
    Widget? resolvedLeading;
    if (leading != null) {
      resolvedLeading = leading;
    } else if (showBackButton) {
      resolvedLeading = _BackButton(
        onPressed: onBackPressed ?? () => Get.back<void>(),
      );
    }

    return AppBar(
      elevation: elevation ?? 0,
      backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: resolvedLeading,
      title: _buildTitle(context, titleFontSize),
      actions: actions != null ? [...actions!, const SizedBox(width: 8)] : null,
      flexibleSpace: flexibleSpace,
      bottom: bottomWidget,
    );
  }

  Widget _buildTitle(BuildContext context, double fontSize) {
    final theme = context.theme;
    
    final titleWidget = Text(
      title,
      style: titleStyle ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
            height: 1.2,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (subtitle == null) {
      return titleWidget;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        titleWidget,
        Text(
          subtitle!,
          style: TextStyle(
            fontSize: fontSize * 0.6,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: -0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (subtitle != null) {
      height += 4; // Extra space for subtitle
    }
    if (bottomWidget != null) {
      height += bottomWidget!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

/// Optimized back button widget with consistent styling
class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const _BackButton({required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: Responsive.responsiveValue(
            context,
            mobile: 16.0,
            tablet: 18.0,
            web: 20.0,
          ),
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Optimized refresh button with loading state
class _RefreshButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onRefresh;
  
  const _RefreshButton({
    required this.isLoading,
    this.onRefresh,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: isLoading ? null : onRefresh,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Icon(
                Icons.refresh_rounded,
                color: theme.colorScheme.primary,
                size: Responsive.responsiveValue(
                  context,
                  mobile: 22.0,
                  tablet: 24.0,
                  web: 26.0,
                ),
              ),
        tooltip: 'Refresh',
      ),
    );
  }
}

/// Count badge widget for displaying item counts
class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  
  const _CountBadge({
    required this.count,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$count $label',
          style: TextStyle(
            fontSize: Responsive.responsiveValue(
              context,
              mobile: 11.0,
              tablet: 12.0,
              web: 13.0,
            ),
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Delete all button with confirmation
class _DeleteAllButton extends StatelessWidget {
  final String title;
  final VoidCallback? onDeleteAll;
  
  const _DeleteAllButton({
    required this.title,
    this.onDeleteAll,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: theme.colorScheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 12,
      color: theme.colorScheme.surface,
      onSelected: (value) {
        if (value == 'delete_all' && onDeleteAll != null) {
          _showDeleteConfirmation(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete_all',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  size: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete All $title',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Delete',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all $title? This action cannot be undone.',
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Get.back<void>();
              onDeleteAll?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility wrapper - deprecated, use StandardAppBar instead
@Deprecated('Use StandardAppBar.withCount() instead')
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int itemCount;
  final String itemLabel;
  final bool showDeleteAll;
  final VoidCallback? onDeleteAll;

  const ModernAppBar({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemLabel,
    this.showDeleteAll = false,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return StandardAppBar.withCount(
      title: title,
      itemCount: itemCount,
      itemLabel: itemLabel,
      showDeleteAll: showDeleteAll,
      onDeleteAll: onDeleteAll,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Enhanced FAB with consistent styling and responsive design
class ModernFAB extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool isExtended;
  final String? tooltip;
  final bool enabled;

  const ModernFAB({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.isExtended = true,
    this.tooltip,
    this.enabled = true,
  });

  /// Factory for regular FAB
  factory ModernFAB.regular({
    Key? key,
    required VoidCallback onPressed,
    IconData icon = Icons.add_rounded,
    String? tooltip,
    bool enabled = true,
  }) {
    return ModernFAB(
      key: key,
      label: '',
      onPressed: onPressed,
      icon: icon,
      isExtended: false,
      tooltip: tooltip,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    if (!isExtended) {
      return FloatingActionButton(
        onPressed: enabled ? onPressed : null,
        backgroundColor: enabled 
            ? theme.colorScheme.primary 
            : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: enabled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withOpacity(0.4),
        elevation: enabled ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tooltip: tooltip,
        child: Icon(
          icon,
          size: Responsive.responsiveValue(
            context,
            mobile: 24.0,
            tablet: 26.0,
            web: 28.0,
          ),
        ),
      );
    }

    return FloatingActionButton.extended(
      onPressed: enabled ? onPressed : null,
      backgroundColor: enabled 
          ? theme.colorScheme.primary 
          : theme.colorScheme.surfaceContainerHighest,
      foregroundColor: enabled
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.onSurface.withOpacity(0.4),
      elevation: enabled ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tooltip: tooltip,
      icon: Icon(
        icon,
        size: Responsive.responsiveValue(
          context,
          mobile: 20.0,
          tablet: 22.0,
          web: 24.0,
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: Responsive.responsiveValue(
            context,
            mobile: 14.0,
            tablet: 15.0,
            web: 16.0,
          ),
        ),
      ),
    );
  }
}

/// Enhanced error state widget with consistent styling and responsive design
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final IconData? icon;
  final Widget? customAction;
  final EdgeInsets? margin;
  final bool isFullScreen;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    this.subtitle = 'Unable to load data. Please try again.',
    required this.onRetry,
    this.icon,
    this.customAction,
    this.margin,
    this.isFullScreen = true,
  });

  /// Factory for network errors
  factory ErrorStateWidget.network({
    Key? key,
    required VoidCallback onRetry,
    String? title,
    String? subtitle,
  }) {
    return ErrorStateWidget(
      key: key,
      title: title ?? 'Connection Error',
      subtitle: subtitle ?? 'Please check your internet connection and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off_rounded,
    );
  }

  /// Factory for data loading errors
  factory ErrorStateWidget.loading({
    Key? key,
    required VoidCallback onRetry,
    String? title,
    String? subtitle,
  }) {
    return ErrorStateWidget(
      key: key,
      title: title ?? 'Failed to Load',
      subtitle: subtitle ?? 'We couldn\'t load the data. Please try again.',
      onRetry: onRetry,
      icon: Icons.refresh_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    final responsiveMargin = Responsive.responsiveValue(
      context,
      mobile: const EdgeInsets.all(24),
      tablet: const EdgeInsets.all(40),
      web: const EdgeInsets.all(48),
    );
    
    final responsivePadding = Responsive.responsiveValue(
      context,
      mobile: const EdgeInsets.all(24),
      tablet: const EdgeInsets.all(32),
      web: const EdgeInsets.all(40),
    );
    
    final widget = Container(
      margin: margin ?? responsiveMargin,
      padding: responsivePadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(
              Responsive.responsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                web: 24.0,
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline_rounded,
              size: Responsive.responsiveValue(
                context,
                mobile: 40.0,
                tablet: 48.0,
                web: 56.0,
              ),
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(
            height: Responsive.responsiveValue(
              context,
              mobile: 20.0,
              tablet: 24.0,
              web: 28.0,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.responsiveValue(
                context,
                mobile: 18.0,
                tablet: 20.0,
                web: 24.0,
              ),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: Responsive.responsiveValue(
                context,
                mobile: 14.0,
                tablet: 16.0,
                web: 18.0,
              ),
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          customAction ??
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.responsiveValue(
                      context,
                      mobile: 20.0,
                      tablet: 24.0,
                      web: 28.0,
                    ),
                    vertical: Responsive.responsiveValue(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      web: 16.0,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
        ],
      ),
    );
    
    return isFullScreen ? Center(child: widget) : widget;
  }
}

/// Enhanced empty state widget with multiple variations and responsive design
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Widget? customAction;
  final EdgeInsets? margin;
  final bool isFullScreen;
  final Color? iconColor;
  final bool showGradient;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonLabel,
    this.onButtonPressed,
    this.customAction,
    this.margin,
    this.isFullScreen = true,
    this.iconColor,
    this.showGradient = true,
  });

  /// Factory for list empty states
  factory EmptyStateWidget.list({
    Key? key,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
    IconData icon = Icons.inbox_rounded,
  }) {
    return EmptyStateWidget(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      buttonLabel: buttonLabel,
      onButtonPressed: onButtonPressed,
    );
  }

  /// Factory for search empty states
  factory EmptyStateWidget.search({
    Key? key,
    String? title,
    String? subtitle,
    VoidCallback? onClear,
  }) {
    return EmptyStateWidget(
      key: key,
      title: title ?? 'No results found',
      subtitle: subtitle ?? 'Try adjusting your search or filters',
      icon: Icons.search_off_rounded,
      buttonLabel: onClear != null ? 'Clear Search' : null,
      onButtonPressed: onClear,
      showGradient: false,
    );
  }

  /// Factory for feature empty states
  factory EmptyStateWidget.feature({
    Key? key,
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? customAction,
  }) {
    return EmptyStateWidget(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      customAction: customAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    final responsiveMargin = Responsive.responsiveValue(
      context,
      mobile: const EdgeInsets.all(24),
      tablet: const EdgeInsets.all(40),
      web: const EdgeInsets.all(48),
    );
    
    final responsivePadding = Responsive.responsiveValue(
      context,
      mobile: const EdgeInsets.all(24),
      tablet: const EdgeInsets.all(32),
      web: const EdgeInsets.all(40),
    );
    
    final widget = Container(
      margin: margin ?? responsiveMargin,
      padding: responsivePadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(
              Responsive.responsiveValue(
                context,
                mobile: 20.0,
                tablet: 24.0,
                web: 28.0,
              ),
            ),
            decoration: BoxDecoration(
              gradient: showGradient
                  ? LinearGradient(
                      colors: [
                        (iconColor ?? theme.colorScheme.primary).withOpacity(0.2),
                        (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: !showGradient
                  ? (iconColor ?? theme.colorScheme.onSurface).withOpacity(0.1)
                  : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: Responsive.responsiveValue(
                context,
                mobile: 48.0,
                tablet: 56.0,
                web: 64.0,
              ),
              color: iconColor ?? 
                  (showGradient 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          SizedBox(
            height: Responsive.responsiveValue(
              context,
              mobile: 20.0,
              tablet: 24.0,
              web: 28.0,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.responsiveValue(
                context,
                mobile: 20.0,
                tablet: 24.0,
                web: 28.0,
              ),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: Responsive.responsiveValue(
                context,
                mobile: 14.0,
                tablet: 16.0,
                web: 18.0,
              ),
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (customAction != null || (buttonLabel != null && onButtonPressed != null)) ...[
            const SizedBox(height: 28),
            customAction ??
                FilledButton.icon(
                  onPressed: onButtonPressed,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(buttonLabel!),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.responsiveValue(
                        context,
                        mobile: 20.0,
                        tablet: 24.0,
                        web: 28.0,
                      ),
                      vertical: Responsive.responsiveValue(
                        context,
                        mobile: 14.0,
                        tablet: 16.0,
                        web: 18.0,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
    
    return isFullScreen ? Center(child: widget) : widget;
  }
}

class NoResultsWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onReset;

  const NoResultsWidget({
    super.key,
    this.title = 'No results found',
    this.subtitle = 'Try adjusting your filters or search query',
    this.icon = Icons.search_off_rounded,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onReset != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ModernSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final Duration animationDuration;
  final Color? accentColor;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onClear,
    this.onChanged,
    this.animationDuration = const Duration(milliseconds: 200),
    this.accentColor,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusAnimationController;
  late Animation<double> _focusAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  // Store the controller listener as a field so it can be properly removed
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _focusAnimationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_handleFocusChange);

    // Define the listener as a named function
    _controllerListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _focusAnimationController.dispose();
    widget.controller.removeListener(
        _controllerListener); // Properly remove the named listener
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _focusAnimationController.forward();
    } else {
      _focusAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? context.theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Color.lerp(
                context.theme.colorScheme.surfaceContainerLow,
                accentColor,
                _focusAnimation.value * 0.7,
              )!,
              width: 1.5 + (_focusAnimation.value * 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: context.theme.colorScheme.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        style: TextStyle(
          color: context.theme.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: context.theme.colorScheme.onSurfaceVariant,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search_rounded,
              color: _isFocused ? accentColor : context.theme.colorScheme
                  .onSurfaceVariant,
              size: 22,
            ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceVariant.withOpacity(
                  0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.onClear,
              icon: Icon(
                Icons.close_rounded,
                color: context.theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
              iconSize: 18,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                foregroundColor: context.theme.colorScheme
                    .onSurfaceVariant,
                backgroundColor: Colors.transparent,
              ),
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18),
          filled: true,
          fillColor: context.theme.colorScheme.surfaceContainerLow,
        ),
        cursorColor: accentColor,
        cursorWidth: 2,
        cursorRadius: const Radius.circular(4),
        cursorHeight: 20,
      ),
    );
  }
}

class SortFilterBar extends StatelessWidget {
  final String sortBy;
  final bool sortAscending;
  final List<String> sortOptions;
  final Map<String, String> sortLabels;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onSortOrderToggle;
  final bool hasActiveFilters;

  const SortFilterBar({
    super.key,
    required this.sortBy,
    required this.sortAscending,
    required this.sortOptions,
    required this.sortLabels,
    required this.onFilterTap,
    required this.onSortChanged,
    required this.onSortOrderToggle,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.theme.colorScheme.outline.withValues(
                      alpha: 0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sortBy,
                  isDense: true,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  // Flutter's default dropdown already adapts to available screen space
                  dropdownColor: context.theme.colorScheme.surface,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sortAscending ? Icons.arrow_upward_rounded : Icons
                            .arrow_downward_rounded,
                        size: 16,
                        color: context.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                      ),
                    ],
                  ),
                  items: sortOptions.map((option) {
                    final isSelected = option == sortBy;
                    return DropdownMenuItem(
                      value: option,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sortLabels[option] ?? option,
                              style: TextStyle(
                                color: isSelected 
                                    ? context.theme.colorScheme.primary
                                    : context.theme.colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: context.theme.colorScheme.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      if (value == sortBy) {
                        onSortOrderToggle();
                      } else {
                        onSortChanged(value);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter button
          Container(
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? context.theme.colorScheme.primary.withValues(alpha: 0.1)
                  : context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasActiveFilters
                    ? context.theme.colorScheme.primary.withValues(alpha: 0.3)
                    : context.theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: IconButton(
              onPressed: onFilterTap,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: hasActiveFilters
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.7),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final bool isVisible;
  final List<String> categoryOptions;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final RangeValues calorieRange;
  final ValueChanged<RangeValues> onCalorieRangeChanged;
  final RangeValues? proteinRange;
  final ValueChanged<RangeValues>? onProteinRangeChanged;
  final VoidCallback onReset;

  const FilterPanel({
    super.key,
    required this.isVisible,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.calorieRange,
    required this.onCalorieRangeChanged,
    this.proteinRange,
    this.onProteinRangeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: onReset,
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category filter
          Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categoryOptions.map((category) {
              final isSelected = category == selectedCategory;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => onCategoryChanged(category),
                selectedColor: context.theme.colorScheme.primary.withValues(
                    alpha: 0.2),
                checkmarkColor: context.theme.colorScheme.primary,
                backgroundColor: context.theme.colorScheme.surfaceContainer,
                side: BorderSide(
                  color: isSelected
                      ? context.theme.colorScheme.primary.withValues(alpha: 0.3)
                      : context.theme.colorScheme.outline.withValues(
                      alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Calorie range
          Text(
            'Calories: ${calorieRange.start.round()} - ${calorieRange.end
                .round()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          RangeSlider(
            values: calorieRange,
            min: 0,
            max: 1000,
            divisions: 20,
            onChanged: onCalorieRangeChanged,
            activeColor: context.theme.colorScheme.primary,
            inactiveColor: context.theme.colorScheme.outline.withValues(
                alpha: 0.3),
          ),

          // Protein range (if provided)
          if (proteinRange != null && onProteinRangeChanged != null) ...[
            const SizedBox(height: 16),
            Text(
              'Protein: ${proteinRange!.start.round()}g - ${proteinRange!.end
                  .round()}g',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            RangeSlider(
              values: proteinRange!,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onProteinRangeChanged!,
              activeColor: context.theme.colorScheme.primary,
              inactiveColor: context.theme.colorScheme.outline.withValues(
                  alpha: 0.3),
            ),
          ],
        ],
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int Function(double) getCrossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.getCrossAxisCount,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 121),
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = getCrossAxisCount(
                  constraints.crossAxisExtent);

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                ),
                delegate: SliverChildListDelegate(children),
              );
            },
          ),
        ),
      ],
    );
  }
}