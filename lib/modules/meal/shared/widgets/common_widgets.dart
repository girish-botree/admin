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

class ModernSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 16,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.search_rounded,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 24,
                ),
              ),
              suffixIcon: value.text.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(right: 6),
                child: IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.clear_rounded,
                    color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            cursorColor: context.theme.colorScheme.onSurface,
            cursorWidth: 1.5,
            cursorRadius: const Radius.circular(2),
          );
        },
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
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        sortLabels[option] ?? option,
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
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