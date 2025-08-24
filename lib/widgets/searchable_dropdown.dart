import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/dropdown_data.dart';

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
    this.maxHeight = 300,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.showSearch = true,
    this.showDescriptions = true,
    this.showIcons = true,
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
  bool _isOpen = false;
  DropdownItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

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
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _closeDropdown();
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

    setState(() => _isOpen = true);
    _animationController.forward();

    // Auto-focus search if enabled
    if (widget.showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() => _isOpen = false);
      }
    });
  }

  OverlayEntry _createOverlayEntry(Size size, Offset offset) {
    return OverlayEntry(
      builder: (context) =>
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 4.0),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) =>
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      ),
                  child: _buildDropdownMenu(),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDropdownMenu() {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight!,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSearch) _buildSearchField(theme),
          Flexible(
            child: _buildItemsList(theme),
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
              _filterItems('');
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
        onChanged: _filterItems,
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

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) =>
          _buildDropdownItem(
            _filteredItems[index],
            theme,
          ),
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

  void _filterItems(String query) {
    setState(() {
      _filteredItems = DropdownDataManager.searchItems(widget.items, query);
    });
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
    this.showIcons = true,
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