import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: context.theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        onPressed: () => Get.back<void>(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount $itemLabel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        if (showDeleteAll && itemCount > 0)
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 12,
            color: context.theme.colorScheme.surface,
            onSelected: (value) {
              if (value == 'delete_all' && onDeleteAll != null) {
                onDeleteAll!();
              }
            },
            itemBuilder: (context) =>
            [
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
          ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ModernFAB extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const ModernFAB({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: context.theme.colorScheme.primary,
      foregroundColor: context.theme.colorScheme.onPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    this.subtitle = 'Unable to load data. Please try again.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.errorContainer.withValues(
              alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.theme.colorScheme.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: context.theme.colorScheme.error,
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
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    required this.onButtonPressed,
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
                    context.theme.colorScheme.primary.withValues(alpha: 0.2),
                    context.theme.colorScheme.primary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
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
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onButtonPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
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