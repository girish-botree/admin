import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'enhanced_search_controller.dart';

/// Enhanced search bar with advanced features
/// Includes suggestions, performance monitoring, and modern UI
class EnhancedSearchBar extends StatefulWidget {
  final EnhancedSearchController searchController;
  final String hintText;
  final String? label;
  final bool showPerformanceStats;
  final bool showSuggestions;
  final bool enableVoiceSearch;
  final VoidCallback? onClear;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final InputBorder? border;
  final Color? fillColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  
  const EnhancedSearchBar({
    super.key,
    required this.searchController,
    required this.hintText,
    this.label,
    this.showPerformanceStats = false,
    this.showSuggestions = true,
    this.enableVoiceSearch = false,
    this.onClear,
    this.onChanged,
    this.margin,
    this.height,
    this.border,
    this.fillColor,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Main search bar
        Container(
          margin: widget.margin ?? const EdgeInsets.all(16),
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: widget.searchController.searchController,
            focusNode: _focusNode,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              labelText: widget.label,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              prefixIcon: widget.prefixIcon ?? Icon(
                Icons.search_rounded,
                color: _isFocused 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
              suffixIcon: _buildSuffixIcon(theme),
              border: widget.border ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _isFocused 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: _isFocused ? 2 : 1,
                ),
              ),
              enabledBorder: widget.border ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: widget.border ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.fillColor ?? theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
            },
            onSubmitted: (value) {
              _focusNode.unfocus();
            },
            textInputAction: TextInputAction.search,
          ),
        ),
        
        // Search suggestions
        if (widget.showSuggestions)
          Obx(() => SearchSuggestionsWidget(
            suggestions: widget.searchController.suggestions,
            onSuggestionSelected: (suggestion) {
              widget.searchController.selectSuggestion(suggestion);
              _focusNode.unfocus();
            },
            showSuggestions: widget.searchController.showSuggestions.value,
          )),
        
        // Performance stats
        if (widget.showPerformanceStats)
          Obx(() => SearchPerformanceWidget(
            performanceStats: widget.searchController.searchStats.value,
            showDetails: true,
          )),
        
        // Loading indicator
        Obx(() => widget.searchController.isLoading.value
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        
        // Error message
        Obx(() => widget.searchController.error.value.isNotEmpty
            ? Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.searchController.error.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildSuffixIcon(ThemeData theme) {
    return Obx(() {
      final hasText = widget.searchController.searchController.text.isNotEmpty;
      final isLoading = widget.searchController.isLoading.value;
      
      if (isLoading) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }
      
      if (hasText) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice search button (if enabled)
            if (widget.enableVoiceSearch)
              IconButton(
                onPressed: _startVoiceSearch,
                icon: Icon(
                  Icons.mic,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'Voice Search',
              ),
            
            // Clear button
            IconButton(
              onPressed: () {
                widget.searchController.clearSearch();
                widget.onClear?.call();
                _focusNode.requestFocus();
              },
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              tooltip: 'Clear Search',
            ),
          ],
        );
      }
      
      // Default suffix icon
      if (widget.suffixIcon != null) {
        return widget.suffixIcon!;
      }
      
      if (widget.enableVoiceSearch) {
        return IconButton(
          onPressed: _startVoiceSearch,
          icon: Icon(
            Icons.mic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          tooltip: 'Voice Search',
        );
      }
      
      return const SizedBox.shrink();
    });
  }

  void _startVoiceSearch() {
    // TODO: Implement voice search functionality
    // This would integrate with speech recognition APIs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Compact search bar for use in app bars or tight spaces
class CompactSearchBar extends StatelessWidget {
  final EnhancedSearchController searchController;
  final String hintText;
  final bool showSuggestions;
  final VoidCallback? onClear;
  final Function(String)? onChanged;
  
  const CompactSearchBar({
    super.key,
    required this.searchController,
    required this.hintText,
    this.showSuggestions = true,
    this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: searchController.searchController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixIcon: Obx(() => searchController.searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clearSearch();
                        onClear?.call();
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6),
                      ),
                    )
                  : const SizedBox.shrink()),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
          ),
        ),
        
        if (showSuggestions)
          Obx(() => SearchSuggestionsWidget(
            suggestions: searchController.suggestions,
            onSuggestionSelected: (suggestion) {
              searchController.selectSuggestion(suggestion);
            },
            showSuggestions: searchController.showSuggestions.value,
          )),
      ],
    );
  }
}

/// Search bar with advanced filters
class FilteredSearchBar extends StatefulWidget {
  final EnhancedSearchController searchController;
  final String hintText;
  final List<Widget> filterWidgets;
  final bool showFilters;
  final VoidCallback? onToggleFilters;
  
  const FilteredSearchBar({
    super.key,
    required this.searchController,
    required this.hintText,
    required this.filterWidgets,
    this.showFilters = false,
    this.onToggleFilters,
  });

  @override
  State<FilteredSearchBar> createState() => _FilteredSearchBarState();
}

class _FilteredSearchBarState extends State<FilteredSearchBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Search bar with filter toggle
        Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: EnhancedSearchBar(
                  searchController: widget.searchController,
                  hintText: widget.hintText,
                  showSuggestions: false,
                  showPerformanceStats: false,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onToggleFilters,
                icon: Icon(
                  widget.showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                  color: widget.showFilters 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                tooltip: 'Toggle Filters',
              ),
            ],
          ),
        ),
        
        // Filter widgets
        if (widget.showFilters)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.filterWidgets,
              ],
            ),
          ),
      ],
    );
  }
}
