# Technical Documentation

## Architecture Overview

This application is built with Flutter and follows a clean architecture pattern with a focus on
modularity and maintainability. The architecture is based on the GetX state management pattern,
which provides dependency injection, route management, and reactive state management.

### Key Architectural Components

- **Module-based Structure**: The application is organized into feature modules (dashboard, meal,
  plan, delivery management, etc.) each with its own views, controllers, and bindings.
- **GetX Pattern**: Uses GetX for state management, dependency injection, and navigation.
- **Layered Architecture**: Implements a clean separation between UI, business logic, and data
  layers.
- **Repository Pattern**: Data access is abstracted through repository classes.
- **Service-oriented**: Common functionalities are provided as services (network, authentication,
  etc.).

## Technology Stack

- **Framework**: Flutter (Dart) for cross-platform mobile development
- **State Management**: GetX
- **API Communication**: Dio HTTP client with Retrofit
- **Local Storage**: GetStorage and Flutter Secure Storage
- **Backend Integration**: Firebase services
- **Authentication**: JWT token-based authentication with refresh token mechanism
- **UI Components**: Mix of Material Design and custom components
- **Charts and Visualizations**: fl_chart and syncfusion_flutter_charts
- **Internationalization**: Multi-language support via GetX translations
- **Image Handling**: image_picker and path_provider

## Development Guidelines

### Code Organization

- **lib/main.dart**: Application entry point, initializes services and runs the app
- **lib/modules/**: Feature-specific modules (dashboard, meal, plan, etc.)
- **lib/config/**: Configuration files and constants
- **lib/core/**: Core functionalities used across the application
- **lib/network_service/**: API communication layer
- **lib/routes/**: Application routing
- **lib/themes/**: Theme definitions
- **lib/widgets/**: Reusable UI components
- **lib/utils/**: Utility functions
- **lib/services/**: Application-wide services

### Coding Standards

- Use camelCase for variables and functions
- Use PascalCase for classes and enums
- Prefix private members with underscore (_)
- Follow the Flutter style guide for widgets and UI components
- Use const constructors where possible for better performance
- Implement proper error handling for all async operations
- Document public APIs with meaningful comments

## Error Handling Strategy

The application implements a comprehensive error handling strategy:

1. **Network Errors**: Handled centrally in the `DioNetworkService` with automatic retry mechanisms
   for authentication failures
2. **User-facing Errors**: Displayed using toast messages or dialog boxes through the
   `CustomDisplays` class
3. **Authentication Errors**: Special handling for expired tokens with automatic refresh
4. **Logging**: Detailed error logging for debugging purposes
5. **Recovery Mechanisms**: Graceful fallbacks when operations fail

### Error Handling Implementation

```dart
try {
  // Operation that might fail
} on DioException catch (dioError) {
  // Handle network-specific errors
  await ApiErrorHandler.handleError(dioError);
} catch (e) {
  // Handle general errors
  CustomDisplays.showToast(
    message: 'Something went wrong, please try again later',
    type: MessageType.error,
  );
}
```

## Performance Optimization

### UI Performance

- **Widget Optimization**: Use `const` constructors for immutable widgets
- **List Optimization**: Implement virtualized lists with `ListView.builder` for large datasets
- **Image Optimization**: Properly cache and resize images before display
- **Lazy Loading**: Implement pagination for data-heavy screens
- **State Management**: Minimize rebuilds by using targeted state management

### Network Performance

- **Caching**: Implement response caching where appropriate
- **Request Optimization**: Batch requests where possible
- **Connection Pooling**: Reuse HTTP connections
- **Compression**: Enable GZIP compression for API requests/responses

### Memory Management

- **Resource Disposal**: Properly dispose controllers and streams
- **Image Caching**: Limit the memory used for image caching
- **Memory Leaks**: Avoid circular references and properly close streams

## Build and Deployment Instructions

### Development Environment Setup

1. Install Flutter SDK (version specified in `pubspec.yaml`)
2. Install required dependencies: `flutter pub get`
3. Configure Firebase: Ensure Firebase configuration files are in place
4. Set up environment variables if needed

### Build Instructions

#### Android

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Split APKs by ABI for smaller downloads
flutter build apk --split-per-abi --release
```

#### iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Deployment Process

#### Android Play Store

1. Create a signed app bundle: `flutter build appbundle`
2. Upload to Google Play Console
3. Configure release track (internal, alpha, beta, production)
4. Complete store listing and submit for review

#### iOS App Store

1. Build release IPA through Xcode
2. Use Application Loader or Xcode to upload to App Store Connect
3. Configure release information
4. Submit for review

## Testing Strategy

### Unit Testing

- Test individual classes and functions in isolation
- Mock dependencies using GetX's dependency injection
- Focus on business logic and utility functions

### Widget Testing

- Test UI components in isolation
- Verify widget rendering and interactions
- Mock services and controllers

### Integration Testing

- Test interactions between components
- Verify end-to-end user flows
- Use Flutter's integration test framework

### Test Examples

```dart
// Unit test example
void main() {
  group('Network Service', () {
    test('handles authentication errors correctly', () {
      // Test implementation
    });
  });
}

// Widget test example
void main() {
  testWidgets('Login screen shows validation errors', (WidgetTester tester) async {
    // Test implementation
  });
}
```

## Network Connectivity Handling

The application implements robust network connectivity handling:

1. **Connection Monitoring**: Detect network state changes and react accordingly
2. **Offline Mode**: Cache essential data for offline access where appropriate
3. **Auto-Retry**: Automatically retry failed requests when connectivity is restored
4. **User Feedback**: Provide clear feedback about network status to users

### Implementation

```dart
// Monitor connectivity changes
Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  if (result != ConnectivityResult.none) {
    // Connection restored, retry pending operations
  } else {
    // Connection lost, enable offline mode if available
  }
});
```

## Firebase Integration

The application integrates with Firebase for various functionalities:

1. **Authentication**: Firebase Authentication as a backup/alternative auth method
2. **Cloud Messaging**: Push notifications for important events
3. **Analytics**: Track user behavior and app performance
4. **Crashlytics**: Monitor application stability
5. **Remote Config**: Dynamic configuration of app features

### Firebase Initialization

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Responsive UI Implementation

The application is designed to work across different screen sizes and orientations:

1. **Fluid Layouts**: Use of Flex widgets (Row, Column) with appropriate flex factors
2. **MediaQuery**: Adapt layouts based on screen dimensions
3. **LayoutBuilder**: Create responsive widgets that adapt to their container constraints
4. **Orientation Support**: Optimize layouts for both portrait and landscape orientations
5. **Platform Adaptations**: Adjust UI based on platform (iOS/Android)

### Responsive Implementation Example

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)
```

## Image Upload Functionality

The application supports image upload with the following features:

1. **Image Selection**: Pick images from gallery or camera
2. **Image Compression**: Reduce file size before upload
3. **Upload Progress**: Show upload progress to users
4. **Retry Mechanism**: Automatically retry failed uploads
5. **Multi-part Uploads**: Handle file uploads efficiently

### Implementation

```dart
// Example image upload implementation
Future<void> uploadImage(File imageFile) async {
  // Compress image
  final compressedFile = await compressImage(imageFile);
  
  // Upload with progress tracking
  await DioNetworkService.uploadFile(
    compressedFile,
    'api/upload',
    fileName: 'profile_image.jpg',
  );
}
```