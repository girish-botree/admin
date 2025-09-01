import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/search_utils.dart';

/// Enhanced search controller with advanced optimizations
/// Provides caching, fuzzy search, suggestions, and performance monitoring
class EnhancedSearchController<T> extends GetxController {
  // Search state
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final searchResults = <T>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  
  // Suggestions
  final suggestions = <String>[].obs;
  final showSuggestions = false.obs;
  
  // Performance monitoring
  final searchStats = Rx<Map<String, dynamic>>({});
  final lastSearchTime = Rx<Duration>(Duration.zero);
  
  // Configuration
  final List<T> allItems;
  final List<String> Function(T item) getSearchFields;
  final String searchId;
  final bool enableFuzzySearch;
  final bool enableSuggestions;
  final bool enableCaching;
  final Duration debounceDelay;
  final int minScore;
  
  // Internal state
  Timer? _debounceTimer;
  bool _isIndexBuilt = false;
  
  EnhancedSearchController({
    required this.allItems,
    required this.getSearchFields,
    required this.searchId,
    this.enableFuzzySearch = true,
    this.enableSuggestions = true,
    this.enableCaching = true,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.minScore = 0,
  });
  
  @override
  void onInit() {
    super.onInit();
    _initializeSearch();
    _setupSearchListener();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
  
  /// Initialize search with indexing and initial results
  void _initializeSearch() {
    // Build search index for faster lookups
    if (enableCaching && !_isIndexBuilt) {
      SearchUtils.buildSearchIndex(allItems, getSearchFields, searchId);
      _isIndexBuilt = true;
    }
    
    // Set initial results
    searchResults.value = allItems;
    
    // Update performance stats
    _updatePerformanceStats();
  }
  
  /// Setup search listener with debouncing
  void _setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text;
      searchQuery.value = query;
      
      // Cancel previous debounce timer
      _debounceTimer?.cancel();
      
      // Start new debounce timer
      _debounceTimer = Timer(debounceDelay, () {
        _performSearch(query);
      });
    });
  }
  
  /// Perform the actual search operation
  Future<void> _performSearch(String query) async {
    // Check if controller is still active by checking if searchQuery is still observable
    try {
      searchQuery.value; // This will throw if controller is disposed
    } catch (e) {
      return; // Controller is disposed, exit early
    }
    
    try {
      isLoading.value = true;
      error.value = '';
      
      final startTime = DateTime.now();
      
      List<T> results;
      
      // Use indexed search if available and query is simple
      if (enableCaching && _isIndexBuilt && query.split(' ').length == 1) {
        results = SearchUtils.indexedSearch(allItems, query, searchId);
      } else {
        // Use enhanced search with all features
        results = SearchUtils.filterAndSort(
          allItems,
          query,
          getSearchFields,
          fallbackToContains: true,
          minScore: minScore,
          useCache: enableCaching,
          enableFuzzySearch: enableFuzzySearch,
        );
      }
      
      searchResults.value = results;
      lastSearchTime.value = DateTime.now().difference(startTime);
      
      // Update suggestions if enabled
      if (enableSuggestions && query.isNotEmpty) {
        _updateSuggestions(query);
      } else {
        suggestions.clear();
        showSuggestions.value = false;
      }
      
      // Update performance stats
      _updatePerformanceStats();
      
    } catch (e) {
      error.value = 'Search failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update search suggestions based on current query
  void _updateSuggestions(String query) {
    if (query.length < 2) {
      suggestions.clear();
      showSuggestions.value = false;
      return;
    }
    
    // Get all searchable fields from current results
    final allFields = <String>{};
    for (final item in searchResults) {
      allFields.addAll(getSearchFields(item));
    }
    
    // Get suggestions
    final newSuggestions = SearchUtils.getSearchSuggestions(
      query,
      allFields.toList(),
      maxSuggestions: 5,
      minQueryLength: 2,
    );
    
    suggestions.value = newSuggestions;
    showSuggestions.value = newSuggestions.isNotEmpty;
  }
  
  /// Update performance statistics
  void _updatePerformanceStats() {
    final stats = SearchUtils.getPerformanceStats();
    searchStats.value = {
      ...stats,
      'totalItems': allItems.length,
      'currentResults': searchResults.length,
      'lastSearchTime': lastSearchTime.value,
    };
  }
  
  /// Clear search and reset to all items
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.value = allItems;
    suggestions.clear();
    showSuggestions.value = false;
    error.value = '';
  }
  
  /// Select a suggestion
  void selectSuggestion(String suggestion) {
    searchController.text = suggestion;
    searchQuery.value = suggestion;
    showSuggestions.value = false;
    _performSearch(suggestion);
  }
  
  /// Refresh search results (useful when data changes)
  void refreshSearch() {
    _isIndexBuilt = false;
    _initializeSearch();
    if (searchQuery.value.isNotEmpty) {
      _performSearch(searchQuery.value);
    }
  }
  
  /// Get search performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return searchStats.value;
  }
  
  /// Clear search cache
  void clearCache() {
    SearchUtils.clearCache();
    _isIndexBuilt = false;
    _updatePerformanceStats();
  }
  
  /// Check if search is optimized for current data size
  bool get isOptimized {
    final stats = searchStats.value;
    final avgTime = stats['averageTime'] as Duration? ?? Duration.zero;
    return avgTime.inMilliseconds < 100; // Consider optimized if under 100ms
  }
}

/// Mixin for widgets that need enhanced search functionality
mixin EnhancedSearchMixin<T> {
  EnhancedSearchController<T>? _searchController;
  
  EnhancedSearchController<T> get searchController => _searchController!;
  
  void initializeSearch({
    required List<T> items,
    required List<String> Function(T item) getSearchFields,
    required String searchId,
    bool enableFuzzySearch = true,
    bool enableSuggestions = true,
    bool enableCaching = true,
    Duration debounceDelay = const Duration(milliseconds: 300),
    int minScore = 0,
  }) {
    _searchController = EnhancedSearchController<T>(
      allItems: items,
      getSearchFields: getSearchFields,
      searchId: searchId,
      enableFuzzySearch: enableFuzzySearch,
      enableSuggestions: enableSuggestions,
      enableCaching: enableCaching,
      debounceDelay: debounceDelay,
      minScore: minScore,
    );
  }
  
  void disposeSearch() {
    _searchController?.dispose();
    _searchController = null;
  }
}

/// Widget for displaying search suggestions
class SearchSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;
  final bool showSuggestions;
  
  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
    required this.showSuggestions,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!showSuggestions || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.search,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              suggestion,
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () => onSuggestionSelected(suggestion),
          );
        },
      ),
    );
  }
}

/// Performance monitoring widget for search
class SearchPerformanceWidget extends StatelessWidget {
  final Map<String, dynamic> performanceStats;
  final bool showDetails;
  
  const SearchPerformanceWidget({
    super.key,
    required this.performanceStats,
    this.showDetails = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!showDetails) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final avgTime = performanceStats['averageTime'] as Duration? ?? Duration.zero;
    final totalSearches = performanceStats['totalSearches'] as int? ?? 0;
    final cacheSize = performanceStats['cacheSize'] as int? ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Performance',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatItem('Searches', totalSearches.toString()),
              const SizedBox(width: 16),
              _buildStatItem('Avg Time', '${avgTime.inMilliseconds}ms'),
              const SizedBox(width: 16),
              _buildStatItem('Cache', cacheSize.toString()),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
