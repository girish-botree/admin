/// Dietary Preference Constants and Helper Functions
/// 
/// This file contains all dietary preference-related constants and utilities
/// used throughout the application.

class DietaryPreferences {
  // Dietary Preference Constants
  static const int vegan = 0;
  static const int vegetarian = 1;
  static const int eggitarian = 2;
  static const int nonVegetarian = 3;
  static const int other = 4;

  // Dietary Preference Labels
  static const String veganLabel = 'Vegan';
  static const String vegetarianLabel = 'Vegetarian';
  static const String eggitarianLabel = 'Eggitarian';
  static const String nonVegetarianLabel = 'Non-Vegetarian';
  static const String otherLabel = 'Other';

  // Dietary Preference Descriptions
  static const String veganDescription = 'Completely plant-based';
  static const String vegetarianDescription = 'Plant-based with dairy';
  static const String eggitarianDescription = 'Plant-based with dairy and eggs';
  static const String nonVegetarianDescription = 'Includes meat, poultry, and seafood';
  static const String otherDescription = 'Other dietary preferences';

  /// Get dietary preference label by index
  static String getLabelByIndex(int index) {
    switch (index) {
      case vegan:
        return veganLabel;
      case vegetarian:
        return vegetarianLabel;
      case eggitarian:
        return eggitarianLabel;
      case nonVegetarian:
        return nonVegetarianLabel;
      case other:
        return otherLabel;
      default:
        return 'Unknown';
    }
  }

  /// Get dietary preference description by index
  static String getDescriptionByIndex(int index) {
    switch (index) {
      case vegan:
        return veganDescription;
      case vegetarian:
        return vegetarianDescription;
      case eggitarian:
        return eggitarianDescription;
      case nonVegetarian:
        return nonVegetarianDescription;
      case other:
        return otherDescription;
      default:
        return 'Standard dietary preference';
    }
  }

  /// Get dietary preference index by label
  static int? getIndexByLabel(String label) {
    switch (label.toLowerCase()) {
      case 'vegan':
        return vegan;
      case 'vegetarian':
        return vegetarian;
      case 'eggitarian':
        return eggitarian;
      case 'non-vegetarian':
      case 'nonvegetarian':
      case 'non_vegetarian':
        return nonVegetarian;
      case 'other':
        return other;
      default:
        return null;
    }
  }

  /// Check if the given index is a valid dietary preference
  static bool isValidIndex(int index) {
    return index >= vegan && index <= other;
  }

  /// Get all dietary preference indices
  static List<int> getAllIndices() {
    return [vegan, vegetarian, eggitarian, nonVegetarian, other];
  }

  /// Get all dietary preference labels
  static List<String> getAllLabels() {
    return [
      veganLabel,
      vegetarianLabel,
      eggitarianLabel,
      nonVegetarianLabel,
      otherLabel
    ];
  }

  /// Get dietary preference map (index -> label)
  static Map<int, String> getLabelMap() {
    return {
      vegan: veganLabel,
      vegetarian: vegetarianLabel,
      eggitarian: eggitarianLabel,
      nonVegetarian: nonVegetarianLabel,
      other: otherLabel,
    };
  }

  /// Get dietary preference description map (index -> description)
  static Map<int, String> getDescriptionMap() {
    return {
      vegan: veganDescription,
      vegetarian: vegetarianDescription,
      eggitarian: eggitarianDescription,
      nonVegetarian: nonVegetarianDescription,
      other: otherDescription,
    };
  }
}