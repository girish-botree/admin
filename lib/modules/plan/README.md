# Meal Plan Module

This module implements full CRUD functionality for the Meal Plan API with a modern, responsive UI.

## Files Structure

### Core Files
- `plan_view.dart` - Main screen with responsive grid layout and floating action button
- `plan_controller.dart` - GetX controller with full CRUD operations and form management
- `plan_binding.dart` - Dependency injection binding
- `meal_plan_model.dart` - Data model for meal plans
- `plan_constants.dart` - Text constants and labels

### Widgets
- `widgets/meal_plan_card.dart` - Individual meal plan card with edit/delete actions
- `widgets/meal_plan_form_dialog.dart` - Create/edit form dialog
- `widgets/responsive_meal_plan_grid.dart` - Responsive grid layout
- `widgets/meal_plan_loading.dart` - Skeleton loading animation

## Features

### CRUD Operations
- ✅ **Create** - Add new meal plans via dialog form
- ✅ **Read** - Display meal plans in responsive grid
- ✅ **Update** - Edit existing meal plans via dialog form
- ✅ **Delete** - Delete meal plans with confirmation dialog

### UI Features
- ✅ Modern card-based design
- ✅ Responsive grid layout (1-3 columns based on screen size)
- ✅ Skeleton loading animation
- ✅ Pull-to-refresh functionality
- ✅ Empty state with call-to-action
- ✅ Form validation
- ✅ Status indicators (Active/Inactive)
- ✅ Error handling with snackbar messages

### Technical Features
- ✅ GetX state management
- ✅ Clean architecture pattern
- ✅ Centralized API calls with error handling
- ✅ Form controllers and validation
- ✅ Responsive design utilities
- ✅ Consistent styling with app theme

## API Integration

The module integrates with the following API endpoints:
- `GET /api/admin/AdminMealPlan` - Fetch meal plans
- `POST /api/admin/AdminMealPlan` - Create meal plan
- `PUT /api/admin/AdminMealPlan/{id}` - Update meal plan
- `DELETE /api/admin/AdminMealPlan/{id}` - Delete meal plan

## Usage

1. Navigate to the Plan screen
2. View existing meal plans in a responsive grid
3. Use the floating action button to create new meal plans
4. Click edit button on cards to modify existing meal plans
5. Click delete button with confirmation to remove meal plans
6. Pull down to refresh the list

## Form Fields

- **Name** (required) - Meal plan name
- **Description** (required) - Detailed description
- **Price** (optional) - Meal plan price
- **Image URL** (optional) - Image for the meal plan
- **Active Status** - Toggle active/inactive status