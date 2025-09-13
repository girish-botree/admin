# Using the CircularBackButton Widget

The `CircularBackButton` is a consistent, reusable back button widget that should be used across all
screens in the application. This ensures a consistent user experience and makes it easy to modify
the look and feel of back buttons throughout the app in one place.

## Basic Usage

To use the CircularBackButton in your screens, import it from the widgets package:

```dart
import '../widgets/circular_back_button.dart';
```

### Option 1: Direct use in AppBar

```dart
AppBar(
  leading: CircularBackButton(),
  title: Text('Screen Title'),
  // ... other AppBar properties
)
```

### Option 2: Using the AppBar extension method

For easier implementation, use the provided extension method:

```dart
AppBarWithCircularBackButton.withCircularBackButton(
  context: context,
  title: Text('Screen Title'),
  actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
  // ... other AppBar properties
)
```

### Option 3: Using in AppBar with margin

If you need a specific margin for the back button:

```dart
AppBar(
  leading: CircularBackButton().asAppBarLeading(),
  title: Text('Screen Title'),
  // ... other AppBar properties
)
```

## Customization

The CircularBackButton accepts several parameters for customization:

```dart
CircularBackButton(
  onPressed: () => Get.to(SomeScreen()), // Custom navigation logic
  size: 40.0, // Custom size
  icon: Icons.close, // Different icon
  backgroundColor: Colors.red, // Custom background color
  iconColor: Colors.white, // Custom icon color
  showBorder: false, // Hide border
  borderColor: Colors.black, // Custom border color
  borderWidth: 2.0, // Custom border width
)
```

## Best Practices

1. Always use CircularBackButton for back navigation across the app
2. Maintain consistent sizing and styling of back buttons
3. For modals and dialogs, consider using the same button with a close icon
4. For special cases where standard back functionality isn't appropriate, customize the onPressed
   callback

## Responsive Behavior

The CircularBackButton is already responsive and will adjust its size based on the device:

- Mobile: 34.0 pixels
- Tablet: 38.0 pixels
- Web: 42.0 pixels