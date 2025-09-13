import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/utils/responsive.dart';
import 'package:admin/config/app_config.dart' show AppText;

class DashboardCards {
/// Delivery Management Card
static Widget buildDeliveryManagementCard(BuildContext context) {
return ResponsiveGridItem(
child: Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLow,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: InkWell(
borderRadius: BorderRadius.circular(16),
onTap: () {
// Navigate to delivery management
// Get.toNamed('/delivery-management');
},
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header with icon
Row(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
  color: context.theme.colorScheme.secondary.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
Icons.local_shipping_outlined,
  color: context.theme.colorScheme.secondary,
size: 28,
),
),
const SizedBox(width: 16),
Expanded(
child: AppText.semiBold(
'Delivery Management',
size: 18,
color: context.theme.colorScheme.onSurface,
),
),
Icon(
Icons.arrow_forward_ios,
color: context.theme.colorScheme.onSurfaceVariant,
size: 16,
),
],
),
const SizedBox(height: 24),

// Statistics Row
Row(
children: [
_buildStatItem(
context,
'Pending',
'12',
Icons.pending_outlined,
  context.theme.colorScheme.secondary,
),
Container(
height: 40,
width: 1,
color: context.theme.colorScheme.outlineVariant,
),
_buildStatItem(
context,
'In Transit',
'8',
Icons.directions_car_outlined,
  context.theme.colorScheme.secondary,
),
Container(
height: 40,
width: 1,
color: context.theme.colorScheme.outlineVariant,
),
_buildStatItem(
context,
'Delivered',
'45',
Icons.check_circle_outline,
  context.theme.colorScheme.secondary,
),
],
),
const SizedBox(height: 24),

// Description
AppText(
'Manage deliveries, assign drivers, and track delivery status in real-time.',
size: 14,
color: context.theme.colorScheme.onSurfaceVariant,
),
],
),
),
),
),
);
}

/// Add Admin Card
static Widget buildAddAdminCard(BuildContext context) {
return ResponsiveGridItem(
child: Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLow,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: InkWell(
borderRadius: BorderRadius.circular(16),
onTap: () {
// Navigate to add admin
Get.toNamed('/admins/create');
},
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header with icon
Row(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: context.theme.colorScheme.tertiary.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
Icons.admin_panel_settings_outlined,
color: context.theme.colorScheme.tertiary,
size: 28,
),
),
const SizedBox(width: 16),
Expanded(
child: AppText.semiBold(
'Add Administrator',
size: 18,
color: context.theme.colorScheme.onSurface,
),
),
Icon(
Icons.arrow_forward_ios,
color: context.theme.colorScheme.onSurfaceVariant,
size: 16,
),
],
),
const SizedBox(height: 24),

// Quick actions
Row(
children: [
Expanded(
child: _buildQuickActionButton(
context,
'Add Admin',
Icons.person_add_outlined,
context.theme.colorScheme.tertiary,
() {
// Navigate to add admin
Get.toNamed('/admins/create');
},
),
),
const SizedBox(width: 12),
Expanded(
child: _buildQuickActionButton(
context,
'Add Delivery Person',
Icons.delivery_dining_outlined,
context.theme.colorScheme.tertiary,
() {
// Function to add delivery person
},
),
),
],
),
const SizedBox(height: 24),

// Description
AppText(
'Register new administrators and delivery personnel with role-based access control.',
size: 14,
color: context.theme.colorScheme.onSurfaceVariant,
),
],
),
),
),
),
);
}

/// Reports Card
static Widget buildReportsCard(BuildContext context) {
return ResponsiveGridItem(
child: Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLow,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: InkWell(
borderRadius: BorderRadius.circular(16),
onTap: () {
// Navigate to reports
Get.toNamed('/reports');
},
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header with icon
Row(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: context.theme.colorScheme.secondary.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
Icons.analytics_outlined,
color: context.theme.colorScheme.secondary,
size: 28,
),
),
const SizedBox(width: 16),
Expanded(
child: AppText.semiBold(
'Delivery Reports',
size: 18,
color: context.theme.colorScheme.onSurface,
),
),
Icon(
Icons.arrow_forward_ios,
color: context.theme.colorScheme.onSurfaceVariant,
size: 16,
),
],
),
const SizedBox(height: 24),

// Chart/Graph placeholder
Container(
height: 100,
decoration: BoxDecoration(
color: context.theme.colorScheme.surfaceContainerLowest,
borderRadius: BorderRadius.circular(12),
),
child: Center(
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
_buildChartBar(context, 0.3, 'Mon', Colors.blue),
_buildChartBar(context, 0.5, 'Tue', Colors.blue),
_buildChartBar(context, 0.7, 'Wed', Colors.blue),
_buildChartBar(context, 0.4, 'Thu', Colors.blue),
_buildChartBar(context, 0.6, 'Fri', Colors.blue),
_buildChartBar(context, 0.2, 'Sat', Colors.blue),
_buildChartBar(context, 0.1, 'Sun', Colors.blue),
],
),
),
),
const SizedBox(height: 24),

// Description
AppText(
'Generate and download comprehensive delivery reports and analytics.',
size: 14,
color: context.theme.colorScheme.onSurfaceVariant,
),
],
),
),
),
),
);
}

/// Helper method to build stat item
static Widget _buildStatItem(
BuildContext context,
String label,
String value,
IconData icon,
Color color,
) {
return Expanded(
child: Column(
children: [
Icon(icon, color: color, size: 20),
const SizedBox(height: 8),
AppText.bold(value, color: color, size: 16),
const SizedBox(height: 4),
AppText(label, color: context.theme.colorScheme.onSurfaceVariant, size: 12),
],
),
);
}

/// Helper method to build quick action button
static Widget _buildQuickActionButton(
BuildContext context,
String label,
IconData icon,
Color color,
VoidCallback onTap,
) {
return InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(12),
child: Container(
padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
decoration: BoxDecoration(
color: color.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: color.withOpacity(0.3), width: 1),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(icon, color: color, size: 20),
const SizedBox(width: 8),
Flexible(
child: AppText.semiBold(
label,
color: color,
size: 14,
overflow: TextOverflow.ellipsis,
),
),
],
),
),
);
}

/// Helper method to build chart bar
static Widget _buildChartBar(
BuildContext context,
double height,
String label,
Color color,
) {
return Column(
mainAxisAlignment: MainAxisAlignment.end,
children: [
Container(
width: 8,
height: 60 * height,
decoration: BoxDecoration(
color: color.withOpacity(0.7),
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 4),
AppText(label, size: 10, color: context.theme.colorScheme.onSurfaceVariant),
],
);
}
}

/// Responsive grid item for better layout across different screen sizes
class ResponsiveGridItem extends StatelessWidget {
final Widget child;

const ResponsiveGridItem({Key? key, required this.child}) : super(key: key);

@override
Widget build(BuildContext context) {
// On mobile: full width
// On tablet: half width
// On web: one-third width
return Responsive(
mobile: Padding(
padding: const EdgeInsets.only(bottom: 16),
child: child,
),
tablet: Padding(
padding: const EdgeInsets.all(8),
child: SizedBox(
width: (Responsive.screenWidth(context) - 48) / 2,
child: child,
),
),
web: Padding(
padding: const EdgeInsets.all(8),
child: SizedBox(
width: (Responsive.screenWidth(context) - 64) / 3,
child: child,
),
),
);
}
}