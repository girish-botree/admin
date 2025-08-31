# Recipe Category Mapping Implementation

## Overview

This document outlines the implementation of recipe category mapping in the Meal Plan module to ensure that the API response categories are correctly mapped to dietary categories in the dropdown.

## Category Mapping

The API response uses integer values for the `dietaryCategory` field, which are mapped to dietary categories as follows:

| API Value | Dietary Category | Description |
|-----------|------------------|-------------|
| 0 | VEGAN | Completely plant-based meals |
| 1 | VEGETARIAN | Plant-based meals with dairy |
| 2 | EGGITARIAN | Plant-based with dairy and eggs |
| 3 | NON_VEGETARIAN | Includes meat, poultry, and seafood |
| 4 | OTHER | Other dietary preferences |

## Implementation Details

### 1. Category Enum Definition

The `MealCategory` enum in `meal_plan_assignment_model.dart` defines the mapping:

```dart
enum MealCategory {
  vegan, // 0
  vegetarian, // 1
  eggitarian, // 2
  nonVegetarian, // 3
  other, // 4
}
```

### 2. Enhanced Recipe Filtering

The `getFilteredRecipes()` method in `plan_controller.dart` has been enhanced to:

- **Primary Method**: Match recipes by `category` field (integer)
- **Fallback Method**: Match recipes by `foodType` field (string)
- **Enhanced Debugging**: Comprehensive logging for troubleshooting
- **Range Validation**: Ensures category indices are within valid range

### 3. Category Display in Dropdown

The recipe dropdown in `meal_plan_form_dialog.dart` now displays:

- **Recipe Name**: Primary identifier
- **Enhanced Description**: Original description + category information
- **Category Label**: Clear dietary category indication

Example dropdown item:
```
Fruite
salada • VEGETARIAN
```

### 4. Category Label Helper

The `_getCategoryLabelFromValue()` method handles both integer and string category values:

```dart
String _getCategoryLabelFromValue(dynamic categoryValue) {
  if (categoryValue is int) {
    switch (categoryValue) {
      case 0: return 'VEGAN';
      case 1: return 'VEGETARIAN';
      case 2: return 'EGGITARIAN';
      case 3: return 'NON_VEGETARIAN';
      case 4: return 'OTHER';
      default: return 'UNKNOWN';
    }
  }
  // ... string handling
}
```

## Debugging Tools

### 1. Debug All Recipes

Use the debug button in the app bar to see all recipes with their category information:

```dart
controller.debugAllRecipes();
```

This shows:
- Category mapping reference
- All recipes with their category values and mapped names
- Food type information

### 2. Test Category Filtering

Use the filter button to test filtering for specific categories:

```dart
controller.testFilterForCategory(1); // Test vegetarian category
```

This shows:
- Filtered recipes for the specified category
- Detailed matching information
- Category validation

### 3. Enhanced Logging

The filtering process now includes comprehensive logging:

- Recipe checking with category and foodType values
- Category index validation
- Matching results with success/failure indicators
- Filtered recipe summaries

## API Response Example

Given this API response:

```json
{
  "recipeId": "726f8513-d0d6-481d-958b-04a16658a894",
  "name": "Vegetarian Quinoa Bowl",
  "description": "Protein-rich quinoa bowl with eggs and vegetables",
  "imageUrl": null,
  "dietaryCategory": 1,
  "cuisine": "Mediterranean",
  "servings": 2
}
```

The system will:
1. Extract `dietaryCategory: 1`
2. Map it to `MealCategory.vegetarian`
3. Display "VEGETARIAN" in the dropdown description
4. Filter recipes correctly when vegetarian diet is selected

## Verification Steps

1. **Load Recipes**: Ensure recipes are loaded with category information
2. **Select Diet Type**: Choose a dietary category (e.g., Vegetarian)
3. **Check Dropdown**: Verify recipes show category labels
4. **Test Filtering**: Confirm only matching recipes appear
5. **Debug Output**: Use debug tools to verify mapping

## Troubleshooting

### Common Issues

1. **No Recipes Showing**: Check if category values are within valid range (0-4)
2. **Wrong Categories**: Verify API response uses correct integer values
3. **Missing Categories**: Ensure all dietary preferences are covered

### Debug Commands

```dart
// Show all recipes with categories
controller.debugAllRecipes();

// Test specific category filtering
controller.testFilterForCategory(1); // Vegetarian

// Clear caches for fresh data
controller.clearCaches();
```

## Future Enhancements

1. **Visual Indicators**: Add color coding for different categories
2. **Category Icons**: Include dietary icons in dropdown
3. **Advanced Filtering**: Support multiple category selection
4. **Category Statistics**: Show category distribution in recipes

## Files Modified

1. `lib/modules/plan/plan_controller.dart`
   - Enhanced `getFilteredRecipes()` method
   - Improved debugging methods
   - Added category validation

2. `lib/modules/plan/widgets/meal_plan_form_dialog.dart`
   - Added category display in dropdown
   - Implemented `_getCategoryLabelFromValue()` helper
   - Enhanced recipe item descriptions

3. `lib/modules/plan/meal_plan_assignment_model.dart`
   - Category enum mapping (already correct)
   - Parsing methods for API responses

This implementation ensures that the recipe dropdown consistently reflects the correct dietary category mapping without leaving out any category.
