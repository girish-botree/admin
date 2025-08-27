# Responsive UI Guide

## Overview

This guide explains how to ensure consistent UI across mobile, web, and tablet platforms throughout
the application. The approach focuses on using the same mobile widgets for all platforms while
adjusting only the layout and positioning as needed for each form factor.

## Key Principles

1. **Mobile-First Approach**: Design for mobile first, then adapt for larger screens (tablet and
   web).
2. **Consistent Widgets**: Use the same widgets across all platforms.
3. **Responsive Layouts**: Adjust only the layout, spacing, and positioning for different screen
   sizes.
4. **Single Codebase**: Maintain a single codebase for all platforms.

## Responsive Components

The following responsive components have been created to ensure consistency across all platforms:

### 1. ResponsiveWidget

A base widget that adapts layout parameters based on screen size while maintaining the same core UI
elements.

```dart
ResponsiveWidget(
  mobileUI: YourMobileWidget(),
  mobileDirection: Axis.vertical,
  tabletDirection: Axis.horizontal,
  mobilePadding: EdgeInsets.all(16),
  tabletPadding: EdgeInsets.all(24),
  webPadding: EdgeInsets.all(32),
)
```

### 2. ResponsiveScaffold

A scaffold that adapts its layout based on screen size, with special handling for drawers on larger
screens.

```dart
ResponsiveScaffold(
  appBar: AppBar(title: Text('My App')),
  body: YourPageContent(),
  drawer: AppDrawer(),
  showDrawerOnWideScreen: true,
  keepDrawerOpen: true,
)
```

### 3. ResponsiveContainer

A container with width constraints that adapt based on screen size.

```dart
ResponsiveContainer(
  mobileMaxWidth: double.infinity,
  tabletMaxWidth: 600,
  webMaxWidth: 1200,
  child: YourContent(),
)
```

### 4. ResponsiveRow

A row that displays elements horizontally on tablet/web and vertically on mobile.

```dart
ResponsiveRow(
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
  spacing: 16,
  equalFlexWidths: true,
)
```

### 5. Form Components

Responsive form components maintain consistent styling across platforms while adapting to different
screen sizes:

- `ResponsiveTextField`: A text field with responsive styling.
- `ResponsiveDropdown`: A dropdown with responsive styling.
- `ResponsiveButton`: A button with responsive styling.
- `ResponsiveFormGroup`: A form group with responsive spacing.
- `ResponsiveFormRow`: A form row that displays fields horizontally on larger screens.

```dart
ResponsiveFormGroup(
  children: [
    ResponsiveTextField(
      labelText: 'Name',
      hintText: 'Enter your name',
    ),
    ResponsiveFormRow(
      children: [
        ResponsiveTextField(labelText: 'Email'),
        ResponsiveTextField(labelText: 'Phone'),
      ],
    ),
    ResponsiveButton(
      text: 'Submit',
      onPressed: () {},
      buttonType: ResponsiveButtonType.primary,
    ),
  ],
)
```

## Utility Classes

### 1. Responsive

The core utility class that provides methods for determining screen size and getting responsive
values.

```dart
// Check screen type
if (Responsive.isMobile(context)) {
  // Mobile layout
} else if (Responsive.isTablet(context)) {
  // Tablet layout
} else {
  // Web layout
}

// Get responsive value
final fontSize = Responsive.responsiveValue(
  context,
  mobile: 14.0,
  tablet: 16.0,
  web: 18.0,
);
```

### 2. ResponsiveUtils

Additional utility methods for responsive design.

```dart
// Get responsive padding
final padding = ResponsiveUtils.getPadding(context);

// Get responsive spacing
final spacing = ResponsiveUtils.getSpacing(context);

// Add responsive gap
ResponsiveUtils.gap(context, direction: Axis.vertical)
```

## Best Practices

1. **Always Use Responsive Components**: Use the provided responsive components instead of raw
   Flutter widgets when building UI.

2. **Avoid Platform-Specific Code**: Instead of using platform checks (`kIsWeb`, `Platform.isIOS`,
   etc.), use responsive breakpoints based on screen size.

3. **Consistent Spacing**: Use the spacing utilities to maintain consistent spacing across all
   platforms.

4. **Single Widget Tree**: Create a single widget tree that adapts to different screen sizes rather
   than separate widgets for each platform.

5. **Testing**: Test your UI on multiple screen sizes during development.

## Example: Creating a Responsive Page

```dart
import 'package:flutter/material.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/responsive_form.dart';
import '../utils/responsive.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      title: 'User Profile',
      body: ResponsiveContainer(
        child: ResponsiveFormGroup(
          children: [
            Text('Personal Information', 
              style: TextStyle(fontSize: Responsive.getTitleTextSize(context))),
            
            ResponsiveFormRow(
              children: [
                ResponsiveTextField(labelText: 'First Name'),
                ResponsiveTextField(labelText: 'Last Name'),
              ],
            ),
            
            ResponsiveTextField(labelText: 'Email'),
            
            ResponsiveButton(
              text: 'Save Changes',
              buttonType: ResponsiveButtonType.primary,
              buttonWidth: ResponsiveButtonWidth.expanded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

## Layout Adaptation Guidelines

| Screen Size | Layout Adaptation |
|-------------|-------------------|
| Mobile      | Single column layout, full width components, stacked elements |
| Tablet      | Two-column layout for forms, side-by-side elements where appropriate, constrained width containers |
| Web         | Multi-column layout, constrained width containers, horizontal navigation |

## Conclusion

By following this guide and using the provided responsive components, you can ensure a consistent UI
experience across mobile, web, and tablet platforms while maintaining a single codebase and reusing
the same widgets across all platforms.