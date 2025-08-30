import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Optimized search utilities for prefix-based searching
/// Provides performance improvements over basic string contains operations
class SearchUtils {
  
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
      
      maxScore = max(maxScore, fieldScore);
    }
    
    return maxScore;
  }
  
  /// Filter and sort a list using prefix search with scoring
  /// Returns items sorted by relevance (best matches first)
  static List<T> filterAndSort<T>(
    List<T> items,
    String query,
    List<String> Function(T item) getSearchFields, {
    bool fallbackToContains = true,
    int minScore = 0,
  }) {
    if (query.isEmpty) return items;
    
    final results = <({T item, int score})>[];
    
    for (final item in items) {
      final fields = getSearchFields(item);
      
      if (fallbackToContains) {
        if (matchesAnyField(fields, query)) {
          final score = getSearchScore(fields, query);
          if (score >= minScore) {
            results.add((item: item, score: score));
          }
        }
      } else {
        // Prefix-only search
        final score = getSearchScore(fields, query);
        if (score >= 80) { // Only prefix matches (score 80+)
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
    
    return results.map((r) => r.item).toList();
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
