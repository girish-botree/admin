import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/dropdown_data.dart';
import '../utils/search_utils.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<DropdownItem> items;
  final T? value;
  final String? hint;
  final String? label;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final void Function(T?)? onChanged;
  final Widget? prefixIcon;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool showSearch;
  final bool showDescriptions;
  final bool showIcons;

  const SearchableDropdown({
    super.key,
    required this.items,
    this.value,
    this.hint,
    this.label,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.maxHeight = 450, // Increased default size for better usability
    this.contentPadding,
    this.border,
    this.fillColor,
    this.showSearch = true,
    this.showDescriptions = true,
    this.showIcons = false,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<DropdownItem> _filteredItems = [];
  String _lastQuery = ''; // Track last search query
  bool _isOpen = false;
  DropdownItem? _selectedItem;
  ThemeData? _cachedTheme; // Cache theme for overlay usage
  
  // Performance optimization: Debounce search
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200), // Faster animation
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Cache items for better performance
    _filteredItems = widget.items;
    _selectedItem =
        DropdownDataManager.findItemByValue(widget.items, widget.value);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
    if (oldWidget.value != widget.value) {
      _selectedItem =
          DropdownDataManager.findItemByValue(widget.items, widget.value);

      // Ensure we have a valid selectedItem by searching by value as string if needed
      if (_selectedItem == null && widget.value != null) {
        // Try finding by string comparison for cases where value types might not match exactly
        final valueStr = widget.value.toString();
        _selectedItem = widget.items.firstWhere(
              (item) => item.value.toString() == valueStr,
          orElse: () =>
              DropdownDataManager.findItemByLabel(widget.items, valueStr),
        );
      }
    }
  }

  @override
  void dispose() {
    // Cancel any pending search debounce
    _searchDebounce?.cancel();
    
    // Close dropdown before disposing anything else
    if (_isOpen) {
      // If open, remove overlay without animation
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    }

    // Dispose controllers and focus nodes safely
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled || _isOpen) return;

    _filteredItems = widget.items;
    _searchController.clear();

    final RenderBox renderBox = _dropdownKey.currentContext!
        .findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _cachedTheme = Theme.of(context); // Cache theme when opening dropdown

    _overlayEntry = _createOverlayEntry(size, offset);
    Overlay.of(context).insert(_overlayEntry!);

    setState(() => _isOpen = true);
    _animationController.forward();

    // Auto-focus search and show keyboard if enabled
    if (widget.showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
        // Explicitly show keyboard
        Future.delayed(const Duration(milliseconds: 50), () {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        });
      });
    }
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    // First remove focus from search field to avoid focus issues
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }

    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    if (mounted) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _cachedTheme = null; // Clear cached theme
        if (mounted) {
          setState(() => _isOpen = false);
        }
      });
    } else {
      // If not mounted, just clean up immediately
      _overlayEntry?.remove();
      _overlayEntry = null;
      _cachedTheme = null; // Clear cached theme
      _isOpen = false;
    }
  }

  OverlayEntry _createOverlayEntry(Size size, Offset offset) {
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenSize.height - keyboardHeight - 100; // Leave some margin
    
    // Calculate dropdown dimensions
    final dropdownWidth = size.width.clamp(300.0, screenSize.width * 0.9);
    final dropdownHeight = (widget.maxHeight ?? 450.0).clamp(200.0, availableHeight);
    
    // Center the dropdown on screen
    final centerX = (screenSize.width - dropdownWidth) / 2;
    final centerY = (screenSize.height - keyboardHeight - dropdownHeight) / 2;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background overlay to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              child: Container(
                color: Colors.black.withOpacity(0.3), // Semi-transparent background
              ),
            ),
          ),
          // Centered dropdown
          Positioned(
            left: centerX,
            top: centerY,
            width: dropdownWidth,
            height: dropdownHeight,
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside dropdown
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: StatefulBuilder(
                        builder: (context, overlaySetState) =>
                            _buildDropdownMenu(overlaySetState),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownMenu([StateSetter? overlaySetState]) {
    final theme = _cachedTheme ?? Theme.of(context);

    return Container(
      height: double.infinity, // Use full available height from positioned container
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme, overlaySetState),
          if (widget.showSearch)
            _buildSearchField(
              _cachedTheme ?? Theme.of(context),
              overlaySetState,
            ),
          Expanded(
            child: _buildItemsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, [StateSetter? overlaySetState]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.label ?? 'Select Item',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _closeDropdown,
            icon: Icon(
              Icons.close,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, [StateSetter? overlaySetState]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              _filterItems('', overlaySetState);
            },
            icon: Icon(
              Icons.clear,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 18,
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          isDense: true,
        ),
        onChanged: (query) => _filterItems(query, overlaySetState),
      ),
    );
  }

  Widget _buildItemsList(ThemeData theme) {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No items found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Performance optimization: Use ListView.builder with caching
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredItems.length,
      cacheExtent: 600, // Cache more items for smoother scrolling
      physics: const BouncingScrollPhysics(), // Better scrolling feel
      itemBuilder: (context, index) {
        if (index >= _filteredItems.length) return const SizedBox.shrink();
        return _buildDropdownItem(
          _filteredItems[index],
          theme,
        );
      },
    );
  }

  Widget _buildDropdownItem(DropdownItem item, ThemeData theme) {
    final isSelected = item.value == widget.value;

    return InkWell(
      onTap: () => _selectItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            if (widget.showIcons) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(
                      0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .w500,
                    ),
                  ),
                  if (widget.showDescriptions &&
                      item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _filterItems(String query, [StateSetter? overlaySetState]) {
    // Performance optimization: Skip filtering if query hasn't changed
    if (query == _lastQuery) return;
    
    _lastQuery = query;
    
    // Use optimized debounced search
    SearchUtils.debounceSearch(
      query,
      (debouncedQuery) {
        if (!mounted) return;
        
        final filtered = DropdownDataManager.searchItems(widget.items, debouncedQuery);
        
        if (mounted) {
          setState(() {
            _filteredItems = filtered;
          });
          
          if (overlaySetState != null) {
            overlaySetState(() {
              _filteredItems = filtered;
            });
          }
        }
      },
      delay: const Duration(milliseconds: 150),
    );
  }

  void _selectItem(DropdownItem item) {
    HapticFeedback.selectionClick();
    widget.onChanged?.call(item.value as T?);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _dropdownKey,
        onTap: _toggleDropdown,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            enabled: false,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.38),
            ),
            decoration: InputDecoration(
              labelText: widget.isRequired ? '${widget.label} *' : widget.label,
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isOpen ? 0.5 : 0.0,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: widget.enabled
                      ? theme.colorScheme.onSurface.withOpacity(0.7)
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
              filled: true,
              fillColor: widget.fillColor ??
                  (widget.enabled
                      ? theme.colorScheme.surfaceContainerLowest
                      : theme.colorScheme.surfaceContainerLowest.withOpacity(
                      0.5)),
              border: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
              enabledBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
              focusedBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              disabledBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            controller: TextEditingController(
              text: _selectedItem?.label ?? '',
            ),
          ),
        ),
      ),
    );
  }
}

// Convenience widget for specific dropdown types
class TypedSearchableDropdown extends StatelessWidget {
  final DropdownType dropdownType;
  final dynamic value;
  final String? hint;
  final String? label;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final void Function(dynamic)? onChanged;
  final Widget? prefixIcon;
  final bool showSearch;
  final bool showDescriptions;
  final bool showIcons;

  const TypedSearchableDropdown({
    super.key,
    required this.dropdownType,
    this.value,
    this.hint,
    this.label,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.showSearch = true,
    this.showDescriptions = true,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = DropdownDataManager.getDropdownItems(dropdownType);

    return SearchableDropdown(
      items: items,
      value: value,
      hint: hint,
      label: label,
      isRequired: isRequired,
      errorText: errorText,
      enabled: enabled,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      showSearch: showSearch,
      showDescriptions: showDescriptions,
      showIcons: showIcons,
    );
  }
}