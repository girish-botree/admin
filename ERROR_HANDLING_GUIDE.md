# Error Handling System with Deduplication

## Overview

This guide explains the new error handling system that prevents multiple snackbars and toasts from appearing simultaneously, especially during login expiration scenarios.

## Problem Solved

**Before**: When login expired, multiple API calls would fail simultaneously, each showing its own snackbar/toast, resulting in a cluttered UI with multiple notifications.

**After**: The system now deduplicates error messages, ensuring only one notification is shown at a time, providing a cleaner user experience.

## Key Components

### 1. CustomDisplays Class (Enhanced)

The `CustomDisplays` class now includes deduplication mechanisms:

```dart
// Static variables for deduplication
static String? _lastToastMessage;
static String? _lastInfoBarMessage;
static DateTime? _lastToastTime;
static DateTime? _lastInfoBarTime;
static const Duration _deduplicationWindow = Duration(seconds: 2);
static bool _isShowingToast = false;
static bool _isShowingInfoBar = false;
```

**Features:**
- **Message Deduplication**: Prevents the same message from showing multiple times within a 2-second window
- **Simultaneous Prevention**: Prevents multiple toasts/info bars from showing at the same time
- **Configurable**: `allowDuplicate` parameter allows bypassing deduplication when needed

### 2. ErrorHandlingService

A centralized service that provides consistent error handling across the app:

```dart
// Handle API errors with deduplication
ErrorHandlingService.handleApiError(error, customMessage: 'Custom message');

// Handle DioException specifically
ErrorHandlingService.handleDioError(dioError);

// Handle login errors specifically
ErrorHandlingService.handleLoginError(error);
```

**Benefits:**
- **Consistent Error Messages**: Standardized error handling across the app
- **Automatic Deduplication**: Built-in deduplication for common error types
- **Type-Specific Handling**: Different handling for network, session, and general errors

## Usage Examples

### Basic Error Handling

```dart
try {
  final response = await apiCall();
  // Handle success
} catch (e) {
  ErrorHandlingService.handleApiError(e);
}
```

### Custom Error Messages

```dart
try {
  final response = await apiCall();
  // Handle success
} catch (e) {
  ErrorHandlingService.handleApiError(
    e, 
    customMessage: 'Failed to load data. Please try again.'
  );
}
```

### Success Messages

```dart
// Show success message with deduplication
ErrorHandlingService.showSuccessMessage('Data saved successfully!');
```

### Warning Messages

```dart
// Show warning message with deduplication
ErrorHandlingService.showWarningMessage('Please select at least one item');
```

### Direct Toast Usage (with deduplication)

```dart
// Show toast with deduplication (default)
CustomDisplays.showToast(
  message: 'Operation completed',
  type: MessageType.success,
  allowDuplicate: false, // Default behavior
);

// Show toast without deduplication (when needed)
CustomDisplays.showToast(
  message: 'Operation completed',
  type: MessageType.success,
  allowDuplicate: true, // Bypass deduplication
);
```

## Deduplication Logic

### Toast Deduplication

1. **Message Comparison**: Compares the new message with the last shown message
2. **Time Window**: Only deduplicates within a 2-second window
3. **Simultaneous Prevention**: Prevents multiple toasts from showing at the same time

### InfoBar Deduplication

1. **Message Comparison**: Compares the new message with the last shown info bar message
2. **Time Window**: Only deduplicates within a 2-second window
3. **Simultaneous Prevention**: Prevents multiple info bars from showing at the same time

## Special Error Types

### Session Expired

```dart
// Automatically handled by ErrorHandlingService
ErrorHandlingService.handleApiError(error);
// If error is 401 or contains "session expired", shows deduplicated message
```

### Network Errors

```dart
// Automatically handled by ErrorHandlingService
ErrorHandlingService.handleApiError(error);
// If error is network-related, shows deduplicated network error message
```

## Migration Guide

### Before (Old Code)

```dart
try {
  final response = await apiCall();
} catch (e) {
  CustomDisplays.showToast(
    message: 'Failed to load data',
    type: MessageType.error,
  );
}
```

### After (New Code)

```dart
try {
  final response = await apiCall();
} catch (e) {
  ErrorHandlingService.handleApiError(e, customMessage: 'Failed to load data');
}
```

### Before (Old Code)

```dart
CustomDisplays.showToast(
  message: 'Success!',
  type: MessageType.success,
);
```

### After (New Code)

```dart
ErrorHandlingService.showSuccessMessage('Success!');
```

## Best Practices

### 1. Use ErrorHandlingService for API Errors

```dart
// ✅ Good
ErrorHandlingService.handleApiError(error);

// ❌ Avoid
CustomDisplays.showToast(message: 'Error', type: MessageType.error);
```

### 2. Use Deduplicated Methods for Common Messages

```dart
// ✅ Good
ErrorHandlingService.showSuccessMessage('Data saved!');
ErrorHandlingService.showWarningMessage('Please select an item');

// ❌ Avoid
CustomDisplays.showToast(message: 'Data saved!', type: MessageType.success);
```

### 3. Clear Notifications When Needed

```dart
// Clear all notifications (useful for cleanup)
ErrorHandlingService.clearAllNotifications();
```

### 4. Allow Duplicates When Necessary

```dart
// When you need to show the same message multiple times
CustomDisplays.showToast(
  message: 'Processing...',
  type: MessageType.info,
  allowDuplicate: true,
);
```

## Testing

The system includes comprehensive tests to verify deduplication works correctly:

```bash
flutter test test/error_handling_test.dart
```

## Configuration

### Deduplication Window

The deduplication window can be adjusted in `CustomDisplays`:

```dart
static const Duration _deduplicationWindow = Duration(seconds: 2);
```

### Custom Error Messages

You can customize error messages in `AppStringConfig`:

```dart
static const String sessionExpired = "Your session has expired, please log in again";
static const String noInternetConnection = "No Internet Connection";
```

## Troubleshooting

### Multiple Messages Still Showing

1. Check if you're using `allowDuplicate: true` unnecessarily
2. Verify you're using `ErrorHandlingService` instead of direct `CustomDisplays` calls
3. Ensure error messages are exactly the same for deduplication to work

### No Messages Showing

1. Check if deduplication is too aggressive
2. Verify the error is being caught properly
3. Check if `CustomDisplays` is properly imported

### Session Expired Not Working

1. Ensure the error contains "session expired" or is a 401 status code
2. Verify `ErrorHandlingService.handleApiError()` is being called
3. Check if the network interceptor is properly configured

## Benefits

1. **Cleaner UI**: No more multiple snackbars cluttering the interface
2. **Better UX**: Users see only relevant, non-repetitive messages
3. **Consistent Error Handling**: Standardized approach across the app
4. **Reduced Code Duplication**: Centralized error handling logic
5. **Easier Maintenance**: Single place to update error handling logic
