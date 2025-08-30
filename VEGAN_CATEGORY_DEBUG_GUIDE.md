# Vegan Category Debug Guide

## Issue
When creating a vegan meal, it's showing up as vegetarian category instead of vegan.

## Debugging Added

I've added comprehensive debugging to help identify where the issue occurs in the meal creation flow:

### 1. Enum Value Verification
- Added `_debugEnumValues()` method that runs on controller initialization
- Verifies that `MealCategory.vegan.index = 0` and `MealCategory.vegetarian.index = 1`

### 2. Diet Type Selection Debugging
- Added logging in `proceedToMealSelection()` method
- Shows selected diet type and its index value
- Traces how `selectedDietType.value` gets converted to `selectedCategory.value`

### 3. Meal Creation Debugging
- Added logging in `createMealPlan()` method
- Shows the exact data being sent to the server
- Displays category index being transmitted

### 4. Server Response Debugging
- Added logging for server responses
- Shows what the backend returns after meal creation

### 5. Data Retrieval Debugging
- Added logging in `getMealPlansByDate()` method
- Shows raw data retrieved from server
- Shows parsed meal plan assignments and their categories

### 6. Manual Debug Method
- Added `debugCurrentState()` method
- Can be called anytime to check current selection state

## How to Use the Debugging

### Step 1: Check Console Output
When you run the app, look for these debug messages in the console:

```
🧪 Debugging MealCategory enum values:
  MealCategory.vegan.index = 0
  MealCategory.vegetarian.index = 1
  ...
```

### Step 2: Create a Vegan Meal
1. Select "Vegan" diet type
2. Proceed to meal selection
3. Select a recipe and create the meal
4. Watch console for these messages:

```
📍 proceedToMealSelection:
  selectedDietType.value: MealCategory.vegan
  selectedCategory.value.index: 0

🍽️ Creating single meal plan:
  selectedCategory.value: MealCategory.vegan
  selectedCategory.value.index: 0
  mealPlanData: {recipeId: ..., category: 0, ...}

📨 Server response: {...}
```

### Step 3: Check Retrieved Data
After creation, the app will fetch updated meal plans:

```
📅 Retrieved meal plans for date 2024-XX-XX:
  Raw data: {id: ..., category: 0, ...}
  Category value: 0 (type: int)

📋 Parsed meal plan assignments:
  Assignment category: MealCategory.vegan (index: 0)
```

## Expected Behavior vs. Issue

### Expected Flow (Correct):
1. User selects "Vegan" → `MealCategory.vegan` (index 0)
2. App sends `category: 0` to server
3. Server stores and returns `category: 0`
4. App parses `0` → `MealCategory.vegan`
5. Displays as "Vegan"

### If Issue Occurs:
The debugging will show where the flow breaks:
- **Issue A**: Wrong value sent to server (app bug)
- **Issue B**: Server returns wrong value (backend bug)
- **Issue C**: Wrong parsing of returned value (app bug)

## Quick Manual Test

To manually check the current state at any time, you can add this to your code temporarily:

```dart
final controller = Get.find<PlanController>();
controller.debugCurrentState();
```

## Enum Reference

```dart
enum MealCategory {
  vegan,        // 0
  vegetarian,   // 1
  eggitarian,   // 2
  nonVegetarian,// 3
  other,        // 4
}
```

## Additional Notes

- The `MealPlanAssignment.fromJson()` method already has print statements that show category parsing
- Look for messages like: "Backend returned 0, mapping to MealCategory.vegan"
- If you see "Backend returned 1, mapping to MealCategory.vegetarian" when creating vegan meals, that indicates a backend issue

## Next Steps

1. Run the app and create a vegan meal
2. Check the console output for the debug messages
3. Identify where in the flow the category changes from vegan (0) to vegetarian (1)
4. Based on findings, fix either:
   - Frontend code (if wrong value being sent/parsed)
   - Backend code (if wrong value being returned/stored)

The debugging will pinpoint exactly where the issue occurs in the data flow.
