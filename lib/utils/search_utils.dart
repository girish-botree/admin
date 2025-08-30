import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';

/// Highly optimized search utilities with advanced features
/// Provides performance improvements, fuzzy search, caching, and smart suggestions
class SearchUtils {
  
  // Cache for search results to improve performance
  static final Map<String, List<dynamic>> _searchCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 100;
  
  // Search index for faster lookups
  static final Map<String, Set<int>> _searchIndex = {};
  static final Map<String, List<String>> _normalizedData = {};
  
  // Performance monitoring
  static final List<Duration> _searchTimes = [];
  static const int _maxSearchTimeHistory = 50;
  
  /// Optimized prefix search for single string field
  /// Returns true if the target starts with query (case-insensitive)
  /// Falls back to contains search if no prefix match found and fallbackToContains is true
  static bool matchesQuery(String target, String query, {bool fallbackToContains = true}) {
    if (query.isEmpty) return true;
    if (target.isEmpty) return false;
    
    final lowerTarget = target.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    // Primary: Check if target starts with query (prefix search)
    if (lowerTarget.startsWith(lowerQuery)) {
      return true;
    }
    
    // Fallback: Contains search if enabled
    if (fallbackToContains) {
      return lowerTarget.contains(lowerQuery);
    }
    
    return false;
  }
  
  /// Optimized prefix search for multiple string fields
  /// Prioritizes prefix matches over contains matches
  static bool matchesAnyField(List<String> fields, String query, {bool fallbackToContains = true}) {
    if (query.isEmpty) return true;
    if (fields.isEmpty) return false;
    
    final lowerQuery = query.toLowerCase();
    
    // Phase 1: Check for prefix matches (highest priority)
    for (final field in fields) {
      if (field.isNotEmpty && field.toLowerCase().startsWith(lowerQuery)) {
        return true;
      }
    }
    
    // Phase 2: Check for contains matches if fallback enabled
    if (fallbackToContains) {
      for (final field in fields) {
        if (field.isNotEmpty && field.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Fuzzy search using Levenshtein distance for typo tolerance
  static bool fuzzyMatches(String target, String query, {int maxDistance = 2}) {
    if (query.isEmpty) return true;
    if (target.isEmpty) return false;
    
    final lowerTarget = target.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    // First try exact matches for performance
    if (lowerTarget.contains(lowerQuery)) return true;
    
    // Calculate Levenshtein distance for fuzzy matching
    return _levenshteinDistance(lowerTarget, lowerQuery) <= maxDistance;
  }
  
  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );
    
    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce(min);
      }
    }
    
    return matrix[s1.length][s2.length];
  }
  
  /// Advanced search with weighted scoring for better relevance
  /// Returns a score from 0-100 (higher = better match)
  static int getSearchScore(List<String> fields, String query) {
    if (query.isEmpty) return 100;
    if (fields.isEmpty) return 0;
    
    final lowerQuery = query.toLowerCase();
    int maxScore = 0;
    
    for (final field in fields) {
      if (field.isEmpty) continue;
      
      final lowerField = field.toLowerCase();
      int fieldScore = 0;
      
      // Exact match: 100 points
      if (lowerField == lowerQuery) {
        fieldScore = 100;
      }
      // Starts with query: 80-90 points based on length ratio
      else if (lowerField.startsWith(lowerQuery)) {
        final ratio = lowerQuery.length / lowerField.length;
        fieldScore = (80 + (ratio * 10)).round();
      }
      // Contains query: 20-60 points based on position and length
      else if (lowerField.contains(lowerQuery)) {
        final position = lowerField.indexOf(lowerQuery);
        final ratio = lowerQuery.length / lowerField.length;
        // Earlier position and longer match ratio = higher score
        fieldScore = (20 + (ratio * 20) + ((lowerField.length - position) / lowerField.length * 20)).round();
      }
      // Fuzzy match: 10-30 points based on distance
      else {
        final distance = _levenshteinDistance(lowerField, lowerQuery);
        if (distance <= 2) {
          fieldScore = max(10, 30 - (distance * 10));
        }
      }
      
      maxScore = max(maxScore, fieldScore);
    }
    
    return maxScore;
  }
  
  /// Enhanced filter and sort with caching and parallel processing
  static List<T> filterAndSort<T>(
    List<T> items,
    String query,
    List<String> Function(T item) getSearchFields, {
    bool fallbackToContains = true,
    int minScore = 0,
    bool useCache = true,
    bool enableFuzzySearch = true,
  }) {
    if (query.isEmpty) return items;
    
    // Check cache first
    final cacheKey = '${items.length}_${query}_$minScore';
    if (useCache && _isCacheValid(cacheKey)) {
      return _searchCache[cacheKey]!.cast<T>();
    }
    
    final startTime = DateTime.now();
    
    final results = <({T item, int score})>[];
    
    // Sequential processing for all datasets
    for (final item in items) {
      final fields = getSearchFields(item);
      
      bool matches = false;
      if (fallbackToContains) {
        matches = matchesAnyField(fields, query) || 
                 (enableFuzzySearch && fields.any((field) => fuzzyMatches(field, query)));
      } else {
        matches = fields.any((field) => field.toLowerCase().startsWith(query.toLowerCase()));
      }
      
      if (matches) {
        final score = getSearchScore(fields, query);
        if (score >= minScore) {
          results.add((item: item, score: score));
        }
      }
    }
    
    // Sort by score (highest first), then by alphabetical order of first field
    results.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;
      
      final aFirstField = getSearchFields(a.item).isNotEmpty ? getSearchFields(a.item).first : '';
      final bFirstField = getSearchFields(b.item).isNotEmpty ? getSearchFields(b.item).first : '';
      return aFirstField.toLowerCase().compareTo(bFirstField.toLowerCase());
    });
    
    final result = results.map((r) => r.item).toList();
    
    // Cache the result
    if (useCache) {
      _cacheResult(cacheKey, result);
    }
    
    // Log performance metrics
    final searchTime = DateTime.now().difference(startTime);
    _logSearchPerformance(query, items.length, result.length, searchTime);
    
    return result;
  }
  

  
  /// Quick prefix-only filter for performance-critical scenarios
  /// Only returns items that start with the query
  static List<T> prefixFilter<T>(
    List<T> items,
    String query,
    List<String> Function(T item) getSearchFields,
  ) {
    if (query.isEmpty) return items;
    
    final lowerQuery = query.toLowerCase();
    
    return items.where((item) {
      final fields = getSearchFields(item);
      return fields.any((field) => 
        field.isNotEmpty && field.toLowerCase().startsWith(lowerQuery)
      );
    }).toList();
  }
  
  /// Smart search suggestions based on user input and data patterns
  static List<String> getSearchSuggestions(
    String query,
    List<String> allFields, {
    int maxSuggestions = 5,
    int minQueryLength = 2,
  }) {
    if (query.length < minQueryLength) return [];
    
    final suggestions = <String>[];
    final lowerQuery = query.toLowerCase();
    
    // Find fields that start with the query
    for (final field in allFields) {
      if (field.toLowerCase().startsWith(lowerQuery) && 
          !suggestions.contains(field)) {
        suggestions.add(field);
        if (suggestions.length >= maxSuggestions) break;
      }
    }
    
    // If not enough prefix matches, add contains matches
    if (suggestions.length < maxSuggestions) {
      for (final field in allFields) {
        if (field.toLowerCase().contains(lowerQuery) && 
            !field.toLowerCase().startsWith(lowerQuery) &&
            !suggestions.contains(field)) {
          suggestions.add(field);
          if (suggestions.length >= maxSuggestions) break;
        }
      }
    }
    
    return suggestions;
  }
  
  /// Build search index for faster lookups
  static void buildSearchIndex<T>(
    List<T> items,
    List<String> Function(T item) getSearchFields,
    String indexKey,
  ) {
    _searchIndex.clear();
    _normalizedData.clear();
    
    for (int i = 0; i < items.length; i++) {
      final fields = getSearchFields(items[i]);
      final normalizedFields = fields.map((field) => field.toLowerCase()).toList();
      _normalizedData[indexKey] = normalizedFields;
      
      for (final field in normalizedFields) {
        final words = field.split(' ');
        for (final word in words) {
          if (word.isNotEmpty) {
            _searchIndex.putIfAbsent(word, () => <int>{}).add(i);
          }
        }
      }
    }
  }
  
  /// Search using pre-built index for faster results
  static List<T> indexedSearch<T>(
    List<T> items,
    String query,
    String indexKey,
  ) {
    if (query.isEmpty) return items;
    
    final words = query.toLowerCase().split(' ');
    final matchingIndices = <int>{};
    
    for (final word in words) {
      if (word.isNotEmpty && _searchIndex.containsKey(word)) {
        if (matchingIndices.isEmpty) {
          matchingIndices.addAll(_searchIndex[word]!);
        } else {
          matchingIndices.intersection(_searchIndex[word]!);
        }
      }
    }
    
    return matchingIndices.map((index) => items[index]).toList();
  }
  
  /// Cache management methods
  static void _cacheResult(String key, List<dynamic> result) {
    // Remove oldest entries if cache is full
    if (_searchCache.length >= _maxCacheSize) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _searchCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
    
    _searchCache[key] = result;
    _cacheTimestamps[key] = DateTime.now();
  }
  
  static bool _isCacheValid(String key) {
    if (!_searchCache.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }
  
  /// Clear all caches
  static void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    _searchIndex.clear();
    _normalizedData.clear();
  }
  
  /// Performance monitoring
  static void _logSearchPerformance(String query, int totalItems, int resultCount, Duration searchTime) {
    _searchTimes.add(searchTime);
    if (_searchTimes.length > _maxSearchTimeHistory) {
      _searchTimes.removeAt(0);
    }
    
    // Log performance metrics in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      final avgTime = _searchTimes.isEmpty 
          ? Duration.zero 
          : Duration(
              microseconds: _searchTimes
                  .map((d) => d.inMicroseconds)
                  .reduce((a, b) => a + b) ~/ _searchTimes.length
            );
      
      debugPrint('Search Performance: Query="$query" | Items=$totalItems | Results=$resultCount | Time=${searchTime.inMicroseconds}μs | Avg=${avgTime.inMicroseconds}μs');
    }
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    if (_searchTimes.isEmpty) {
      return {
        'totalSearches': 0,
        'averageTime': Duration.zero,
        'cacheSize': _searchCache.length,
        'indexSize': _searchIndex.length,
      };
    }
    
    final totalTime = _searchTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    return {
      'totalSearches': _searchTimes.length,
      'averageTime': Duration(microseconds: totalTime ~/ _searchTimes.length),
      'cacheSize': _searchCache.length,
      'indexSize': _searchIndex.length,
    };
  }
  
  /// Debounced search helper for real-time search implementations
  static Timer? _debounceTimer;
  
  static void debounceSearch(
    String query,
    void Function(String) onSearch, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () => onSearch(query));
  }
  
  /// Cancel any pending debounced search
  static void cancelDebouncedSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
  
  /// Highlight matching text for UI display
  /// Returns a list of TextSpan objects with highlighted matches
  static List<TextSpan> highlightMatches(
    String text,
    String query, {
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    if (query.isEmpty || text.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }
    
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    
    int currentIndex = 0;
    int matchIndex = lowerText.indexOf(lowerQuery);
    
    while (matchIndex != -1 && currentIndex < text.length) {
      // Add text before the match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: normalStyle,
        ));
      }
      
      // Add the highlighted match
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: highlightStyle,
      ));
      
      currentIndex = matchIndex + query.length;
      matchIndex = lowerText.indexOf(lowerQuery, currentIndex);
    }
    
    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: normalStyle,
      ));
    }
    
    return spans;
  }
}
