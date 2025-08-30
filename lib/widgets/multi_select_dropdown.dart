import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/dropdown_data.dart';
import '../utils/search_utils.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<DropdownItem> items;
  final List<dynamic> selectedValues;
  final String? hint;
  final String? label;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final void Function(List<dynamic>)? onChanged;
  final Widget? prefixIcon;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool showSearch;
  final bool showDescriptions;
  final bool showIcons;
  final int? maxSelections;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedValues,
    this.hint,
    this.label,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.maxHeight = 500, // Increased default size for better usability
    this.contentPadding,
    this.border,
    this.fillColor,
    this.showSearch = true,
    this.showDescriptions = true,
    this.showIcons = false,
    this.maxSelections,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown>
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
  String _lastQuery = ''; // Track search query
  bool _isOpen = false;
  List<DropdownItem> _selectedItems = [];
  
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

    // Cache items for performance
    _filteredItems = widget.items;
    _updateSelectedItems();
  }

  @override
  void didUpdateWidget(MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
    if (oldWidget.selectedValues != widget.selectedValues) {
      _updateSelectedItems();
    }
  }

  void _updateSelectedItems() {
    _selectedItems = widget.items
        .where((item) => widget.selectedValues.contains(item.value))
        .toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    SearchUtils.cancelDebouncedSearch(); // Cancel any pending searches
    
    // Close dropdown without setState to avoid lifecycle issues
    _closeDropdownSilently();
    
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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

    _overlayEntry = _createOverlayEntry(size, offset);
    Overlay.of(context).insert(_overlayEntry!);

    if (mounted) setState(() => _isOpen = true);
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

    _searchFocusNode.unfocus();
    
    // Check if widget is still mounted before calling setState
    if (mounted) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _closeDropdownSilently() {
    if (!_isOpen) return;

    _searchFocusNode.unfocus();
    _isOpen = false;

    // Remove overlay without animation during disposal
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(Size size, Offset offset) {
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenSize.height - keyboardHeight - 100; // Leave some margin
    
    // Calculate dropdown dimensions
    final dropdownWidth = size.width.clamp(300.0, screenSize.width * 0.9);
    final dropdownHeight = (widget.maxHeight ?? 500.0).clamp(300.0, availableHeight);
    
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
                      child: child,
                    ),
                  ),
                  child: _DropdownMenu(
                    items: _filteredItems,
                    selectedValues: widget.selectedValues,
                    onItemToggle: _toggleItem,
                    onClearAll: _clearAll,
                    onClose: _closeDropdown,
                    onSearch: _filterItems,
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    showSearch: widget.showSearch,
                    showDescriptions: widget.showDescriptions,
                    showIcons: widget.showIcons,
                    maxHeight: dropdownHeight,
                    maxSelections: widget.maxSelections,
                    selectedItems: _selectedItems,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterItems(String query) {
    // Performance optimization: Skip if query hasn't changed
    if (query == _lastQuery) return;
    
    _lastQuery = query;
    
    // Use optimized debounced search
    SearchUtils.debounceSearch(
      query,
      (debouncedQuery) {
        if (!mounted) return;
        
        final filtered = DropdownDataManager.searchItems(widget.items, debouncedQuery);
        
        if (mounted) {
          _filteredItems = filtered;
          
          // Rebuild the overlay with filtered items
          if (_isOpen) {
            _overlayEntry?.markNeedsBuild();
          }
        }
      },
      delay: const Duration(milliseconds: 150),
    );
  }

  void _toggleItem(DropdownItem item) {
    HapticFeedback.selectionClick();

    final newSelectedValues = List<dynamic>.from(widget.selectedValues);
    if (newSelectedValues.contains(item.value)) {
      newSelectedValues.remove(item.value);
    } else {
      if (widget.maxSelections == null ||
          newSelectedValues.length < widget.maxSelections!) {
        newSelectedValues.add(item.value);
      }
    }

    // Update the local selected items state for immediate visual feedback
    if (mounted) {
      setState(() {
        _selectedItems = widget.items
            .where((item) => newSelectedValues.contains(item.value))
            .toList();
      });
    }

    // Notify parent about the selection change
    widget.onChanged?.call(newSelectedValues);
  }

  void _clearAll() {
    HapticFeedback.selectionClick();

    // Update local state for immediate visual feedback
    if (mounted) {
      setState(() {
        _selectedItems = [];
      });
    }

    // Notify parent about the clear action
    widget.onChanged?.call([]);
  }

  String _getDisplayText() {
    if (_selectedItems.isEmpty) {
      return widget.hint ?? 'Select items';
    }

    if (_selectedItems.length == 1) {
      return _selectedItems.first.label;
    } else if (_selectedItems.length <= 2) {
      return _selectedItems.map((item) => item.label).join(', ');
    } else {
      return '${_selectedItems.length} items selected';
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                enabled: false,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: widget.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                ),
                decoration: InputDecoration(
                  labelText: widget.isRequired ? '${widget.label} *' : widget
                      .label,
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
                          : theme.colorScheme.surfaceContainerLowest
                          .withOpacity(0.5)),
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
                  text: _getDisplayText(),
                ),
              ),

              // Selected items chips - Optimized with ListView for better performance
              if (_selectedItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 100), // Limit height
                  child: _selectedItems.length > 6 
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selectedItems.take(6).map((item) => 
                              _buildSelectedChip(item, theme)).toList() +
                            [if (_selectedItems.length > 6)
                              Chip(
                                label: Text('+${_selectedItems.length - 6} more'),
                                backgroundColor: theme.colorScheme.secondaryContainer,
                              )
                            ],
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedItems.map((item) => 
                            _buildSelectedChip(item, theme)).toList(),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Performance optimization: Extract chip building to reduce rebuilds
  Widget _buildSelectedChip(DropdownItem item, ThemeData theme) {
    return Chip(
      label: Text(
        item.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      avatar: widget.showIcons ? Text(
        item.icon,
        style: const TextStyle(fontSize: 14),
      ) : null,
      onDeleted: widget.enabled ? () {
        final newValues = List<dynamic>.from(widget.selectedValues);
        newValues.remove(item.value);
        widget.onChanged?.call(newValues);
      } : null,
      deleteIcon: Icon(
        Icons.close,
        size: 16,
        color: theme.colorScheme.onPrimaryContainer,
      ),
      backgroundColor: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// Separate stateful widget for the dropdown menu to handle its own state
class _DropdownMenu extends StatefulWidget {
  final List<DropdownItem> items;
  final List<dynamic> selectedValues;
  final void Function(DropdownItem) onItemToggle;
  final VoidCallback onClearAll;
  final VoidCallback onClose;
  final void Function(String) onSearch;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool showSearch;
  final bool showDescriptions;
  final bool showIcons;
  final double maxHeight;
  final int? maxSelections;
  final List<DropdownItem> selectedItems;

  const _DropdownMenu({
    required this.items,
    required this.selectedValues,
    required this.onItemToggle,
    required this.onClearAll,
    required this.onClose,
    required this.onSearch,
    required this.searchController,
    required this.searchFocusNode,
    required this.showSearch,
    required this.showDescriptions,
    required this.showIcons,
    required this.maxHeight,
    this.maxSelections,
    required this.selectedItems,
  });

  @override
  State<_DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<_DropdownMenu> {
  late List<dynamic> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List<dynamic>.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(_DropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure local selection reflects parent changes
    if (oldWidget.selectedValues != widget.selectedValues) {
      if (mounted) {
        setState(() {
          _selectedValues = List<dynamic>.from(widget.selectedValues);
        });
      }
    }
  }

  void _handleItemToggle(DropdownItem item) {
    HapticFeedback.selectionClick();

    if (mounted) {
      setState(() {
        if (_selectedValues.contains(item.value)) {
          _selectedValues.remove(item.value);
        } else {
          if (widget.maxSelections == null ||
              _selectedValues.length < widget.maxSelections!) {
            _selectedValues.add(item.value);
          }
        }
      });
    }
    // Call the parent's onChanged callback with the updated values
    widget.onItemToggle(item);
  }

  void _handleClearAll() {
    if (mounted) {
      setState(() {
        _selectedValues.clear();
      });
    }
    widget.onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        children: [
          _buildHeader(theme),
          if (widget.showSearch) _buildSearchField(theme),
          Expanded(
            child: _buildItemsList(theme),
          ),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
              '${_selectedValues.length} selected',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedValues.isNotEmpty)
                TextButton.icon(
                  onPressed: _handleClearAll,
                  icon: Icon(
                      Icons.clear_all, size: 16, color: theme.colorScheme.error),
                  label: Text(
                    'Clear All',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (_selectedValues.isNotEmpty) const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onClose,
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
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: TextField(
        controller: widget.searchController,
        focusNode: widget.searchFocusNode,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.searchController,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  widget.searchController.clear();
                  widget.onSearch('');
                },
                icon: Icon(
                  Icons.clear,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 18,
                ),
              )
                  : const SizedBox.shrink();
            },
          ),
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
        onChanged: widget.onSearch,
      ),
    );
  }

  Widget _buildItemsList(ThemeData theme) {
    if (widget.items.isEmpty) {
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
      itemCount: widget.items.length,
      cacheExtent: 600, // Cache more items for smoother scrolling
      physics: const BouncingScrollPhysics(), // Better scrolling feel
      itemBuilder: (context, index) {
        if (index >= widget.items.length) return const SizedBox.shrink();
        return _buildDropdownItem(widget.items[index], theme);
      },
    );
  }

  Widget _buildDropdownItem(DropdownItem item, ThemeData theme) {
    final isSelected = _selectedValues.contains(item.value);
    final canSelect = widget.maxSelections == null ||
        _selectedValues.length < widget.maxSelections! ||
        isSelected;

    return InkWell(
      onTap: canSelect ? () => _handleItemToggle(item) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: canSelect ? (_) => _handleItemToggle(item) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            if (widget.showIcons) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(
                          0.5,
                        ),
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
              child: Opacity(
                opacity: canSelect ? 1.0 : 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
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
            ),
            if (!canSelect && !isSelected)
              Icon(
                Icons.block,
                color: theme.colorScheme.error.withOpacity(0.6),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final selectedCount = _selectedValues.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (widget.maxSelections != null)
            Text(
              '$selectedCount items selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          else
            Text(
              '$selectedCount items selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: widget.onClose,
            child: Text('Done'),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Convenience widget for specific multi-select dropdown types
class TypedMultiSelectDropdown extends StatelessWidget {
  final DropdownType dropdownType;
  final List<dynamic> selectedValues;
  final String? hint;
  final String? label;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final void Function(List<dynamic>)? onChanged;
  final Widget? prefixIcon;
  final bool showSearch;
  final bool showDescriptions;
  final bool showIcons;
  final int? maxSelections;

  const TypedMultiSelectDropdown({
    super.key,
    required this.dropdownType,
    required this.selectedValues,
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
    this.maxSelections,
  });

  @override
  Widget build(BuildContext context) {
    final items = DropdownDataManager.getDropdownItems(dropdownType);

    return MultiSelectDropdown(
      items: items,
      selectedValues: selectedValues,
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
      maxSelections: maxSelections,
    );
  }
}