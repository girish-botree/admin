# Flutter Admin App - New Notification System Guide

## Overview

This guide explains the new notification system that replaces the old Snackbar-based approach with
more appropriate UI patterns for different types of user feedback.

## New Components

### 1. Toast (Quick Notifications)

**Purpose**: Replace Snackbar for temporary, quick feedback messages.

**Usage**:

```dart
// Success message
CustomDisplays.showToast(
  message: 'Data saved successfully!',
  type: MessageType.success,
);

// Error message
CustomDisplays.showToast(
  message: 'Failed to save data',
  type: MessageType.error,
);

// Warning message
CustomDisplays.showToast(
  message: 'Please select at least one item',
  type: MessageType.warning,
);

// Info message
CustomDisplays.showToast(
  message: 'Processing your request...',
  type: MessageType.info,
);
```

### 2. InfoBar (Persistent Issues)

**Purpose**: Show persistent issues like network connectivity problems with action buttons.

**Usage**:

```dart
// Network error with retry action
CustomDisplays.showInfoBar(
  message: 'No internet connection. Please check your network.',
  type: InfoBarType.networkError,
  actionText: 'Retry',
  onAction: () {
    CustomDisplays.dismissInfoBar();
    retryOperation();
  },
);

// General error
CustomDisplays.showInfoBar(
  message: 'Server maintenance in progress',
  type: InfoBarType.generalError,
  persistent: true,
);

// Dismiss info bar
CustomDisplays.dismissInfoBar();
```

### 3. InlineMessage (Form Validation & Contextual Feedback)

**Purpose**: Show validation messages and contextual feedback directly near relevant UI elements.

**Usage**:

```dart
// Error validation message
InlineMessage(
  message: 'Please enter a valid email address',
  type: MessageType.error,
)

// Success validation message
InlineMessage(
  message: 'Password meets all requirements',
  type: MessageType.success,
)

// Warning message
InlineMessage(
  message: 'Missing: One uppercase letter, One number',
  type: MessageType.warning,
)

// Info message
InlineMessage(
  message: 'Click "Send OTP" to receive verification code',
  type: MessageType.info,
)
```

### 4. EmptyStateWidget (No Data Found)

**Purpose**: Replace "No data found" Snackbars with proper empty state UI.

**Usage**:

```dart
// Basic empty state
EmptyStateWidget(
  icon: Icons.restaurant_menu_outlined,
  title: 'No meal plans found',
  subtitle: 'Create your first meal plan for this date',
)

// With action button
EmptyStateWidget(
  icon: Icons.error_outline,
  title: 'Error Loading Data',
  subtitle: 'Failed to load content. Please try again.',
  action: ElevatedButton(
    onPressed: () => retryLoading(),
    child: Text('Retry'),
  ),
)

// Customizable
EmptyStateWidget(
  icon: Icons.search_off,
  title: 'No results found',
  subtitle: 'Try adjusting your search criteria',
  iconSize: 64.0,
  padding: EdgeInsets.all(40),
)
```

## Migration Guide

### Replace Snackbar Usage

**Old Pattern**:

```dart
// ❌ Old way - using Snackbar
CustomDisplays.showSnackBar(message: 'Operation successful');
Get.snackbar('Error', 'Something went wrong');
ScaffoldMessenger.of(context).showSnackBar(SnackBar(...));
```

**New Pattern**:

```dart
// ✅ New way - using appropriate component
CustomDisplays.showToast(
  message: 'Operation successful',
  type: MessageType.success,
);
```

### Network Error Handling

**Old Pattern**:

```dart
// ❌ Old way
CustomDisplays.showSnackBar(message: 'Network error occurred');
```

**New Pattern**:

```dart
// ✅ New way
CustomDisplays.showInfoBar(
  message: 'Network connection lost. Please check your internet.',
  type: InfoBarType.networkError,
  actionText: 'Retry',
  onAction: () {
    CustomDisplays.dismissInfoBar();
    retryNetworkRequest();
  },
);
```

### Form Validation

**Old Pattern**:

```dart
// ❌ Old way
TextFormField(
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value!)) {
      return 'Invalid email format';
    }
    return null;
  },
)
```

**New Pattern**:

```dart
// ✅ New way
Column(
  children: [
    TextFormField(
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Email is required';
        }
        return null; // Let inline message handle detailed validation
      },
      onChanged: (value) => updateEmailValidation(value),
    ),
    
    // Inline validation feedback
    Obx(() {
      final email = emailController.text;
      if (email.isNotEmpty && !GetUtils.isEmail(email)) {
        return InlineMessage(
          message: 'Please enter a valid email address',
          type: MessageType.error,
        );
      }
      return SizedBox.shrink();
    }),
  ],
)
```

### Empty States

**Old Pattern**:

```dart
// ❌ Old way
if (items.isEmpty) {
  CustomDisplays.showSnackBar(message: 'No items found');
  return SizedBox.shrink();
}
```

**New Pattern**:

```dart
// ✅ New way
if (items.isEmpty) {
  return EmptyStateWidget(
    icon: Icons.inbox_outlined,
    title: 'No items available',
    subtitle: 'Add your first item to get started',
    action: ElevatedButton.icon(
      onPressed: () => showAddItemDialog(),
      icon: Icon(Icons.add),
      label: Text('Add Item'),
    ),
  );
}
```

## Message Types

### MessageType Enum

- `MessageType.success` - Green, check icon
- `MessageType.error` - Red, error icon
- `MessageType.warning` - Orange, warning icon
- `MessageType.info` - Blue, info icon

### InfoBarType Enum

- `InfoBarType.networkError` - For connectivity issues, uses wifi-off icon
- `InfoBarType.generalError` - For general errors, uses error icon
- `InfoBarType.warning` - For warnings, uses warning icon
- `InfoBarType.info` - For informational messages, uses info icon

## Best Practices

### When to Use Each Component

1. **Toast**:
    - Quick feedback for user actions
    - Success/failure notifications
    - Non-blocking temporary messages
    - Duration: 2-5 seconds

2. **InfoBar**:
    - Network connectivity issues
    - Persistent system-level problems
    - Messages requiring user action
    - Can be persistent until manually dismissed

3. **InlineMessage**:
    - Form field validation
    - Contextual help text
    - Real-time validation feedback
    - Always visible until condition changes

4. **EmptyStateWidget**:
    - When lists/collections are empty
    - Error states with retry options
    - Onboarding guidance
    - Search results with no matches

### Error Handling Pattern

```dart
try {
  final result = await apiCall();
  CustomDisplays.showToast(
    message: 'Operation completed successfully',
    type: MessageType.success,
  );
} catch (e) {
  if (e.toString().toLowerCase().contains('network') ||
      e.toString().toLowerCase().contains('connection')) {
    // Network issues -> InfoBar with retry
    CustomDisplays.showInfoBar(
      message: 'Connection failed. Please check your internet.',
      type: InfoBarType.networkError,
      actionText: 'Retry',
      onAction: () {
        CustomDisplays.dismissInfoBar();
        retryOperation();
      },
    );
  } else {
    // Other errors -> Toast
    CustomDisplays.showToast(
      message: 'Operation failed: ${e.toString()}',
      type: MessageType.error,
    );
  }
}
```

### Responsive Design

All components are designed to be responsive and adapt to different screen sizes. The
`EmptyStateWidget` includes responsive sizing and padding options.

### Accessibility

- All components include proper semantic labels
- Icons have appropriate meanings
- Color coding follows accessibility standards
- Screen reader friendly

### Migration Checklist

- [ ] Replace all `Get.snackbar()` calls with appropriate new components
- [ ] Replace `CustomDisplays.showSnackBar()` with `CustomDisplays.showToast()`
- [ ] Convert network error handling to use `InfoBar`
- [ ] Add inline validation messages to forms
- [ ] Replace empty data Snackbars with `EmptyStateWidget`
- [ ] Update error handling patterns throughout the app
- [ ] Test all notification scenarios
- [ ] Verify responsive behavior on different screen sizes

## Import Statements

```dart
// Required imports
import 'package:admin/widgets/custom_displays.dart';

// Available classes and enums:
// - CustomDisplays
// - InlineMessage  
// - EmptyStateWidget
// - MessageType
// - InfoBarType
```

## Backward Compatibility

The old `showSnackBar` method is marked as `@Deprecated` but still available during migration. It
now internally uses the new Toast system.

```dart
// This still works but is deprecated
CustomDisplays.showSnackBar(message: 'Legacy message');
// Internally calls: CustomDisplays.showToast(message: 'Legacy message')
```