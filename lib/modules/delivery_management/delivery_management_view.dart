import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/config/app_config.dart' show AppText;
import 'package:admin/utils/responsive.dart';
import 'delivery_management_controller.dart';

class DeliveryManagementView extends StatelessWidget {
const DeliveryManagementView({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
return GetBuilder<DeliveryManagementController>(
init: DeliveryManagementController(),
builder: (controller) {
return Scaffold(
appBar: AppBar(
title: AppText.bold(
'Delivery Management',
color: context.theme.colorScheme.onSurface,
size: 20,
),
backgroundColor: context.theme.colorScheme.surface,
elevation: 0,
foregroundColor: context.theme.colorScheme.onSurface,
centerTitle: false,
leading: IconButton(
icon: const Icon(Icons.arrow_back),
onPressed: () => Get.back(),
),
actions: [
IconButton(
icon: const Icon(Icons.refresh),
tooltip: 'Refresh Data',
onPressed: () {
// Refresh delivery data
controller.fetchDeliveries();
},
),
const SizedBox(width: 8),
],
),
body: Obx(() {
if (controller.isLoading.value) {
return const Center(child: CircularProgressIndicator());
}

return SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Stats Card
_buildStatsCard(context, controller),
const SizedBox(height: 24),

// Filters Section
_buildFiltersSection(context, controller),
const SizedBox(height: 24),

// Deliveries List/Grid
_buildDeliveriesSection(context, controller),
],
),
);
}),
floatingActionButton: FloatingActionButton(
onPressed: () {
// Add new delivery
},
backgroundColor: context.theme.colorScheme.primary,
foregroundColor: context.theme.colorScheme.onPrimary,
child: const Icon(Icons.add),
),
);
},
);
}

Widget _buildStatsCard(BuildContext context, DeliveryManagementController controller) {
return Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLow,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
AppText.semiBold(
'Delivery Statistics',
size: 18,
color: context.theme.colorScheme.onSurface,
),
const SizedBox(height: 20),
Responsive(
mobile: Column(
children: [
_buildStatRow(context, controller),
],
),
tablet: _buildStatRow(context, controller),
web: _buildStatRow(context, controller),
),
],
),
),
);
}

Widget _buildStatRow(BuildContext context, DeliveryManagementController controller) {
return Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
_buildStatItem(
context,
'Pending',
'${controller.pendingCount}',
Icons.pending_outlined,
Colors.orange,
),
_buildStatItem(
context,
'In Transit',
'${controller.inTransitCount}',
Icons.directions_car_outlined,
Colors.blue,
),
_buildStatItem(
context,
'Delivered',
'${controller.deliveredCount}',
Icons.check_circle_outline,
Colors.green,
),
_buildStatItem(
context,
'Total',
'${controller.totalCount}',
Icons.analytics_outlined,
context.theme.colorScheme.primary,
),
],
);
}

Widget _buildStatItem(
BuildContext context,
String label,
String value,
IconData icon,
Color color,
) {
return Expanded(
child: Column(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: color.withOpacity(0.1),
shape: BoxShape.circle,
),
child: Icon(icon, color: color, size: 24),
),
const SizedBox(height: 8),
AppText.bold(value, color: color, size: 20),
const SizedBox(height: 4),
AppText(label, color: context.theme.colorScheme.onSurfaceVariant, size: 14),
],
),
);
}

Widget _buildFiltersSection(BuildContext context, DeliveryManagementController controller) {
return Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLow,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
AppText.semiBold(
'Filter Deliveries',
size: 18,
color: context.theme.colorScheme.onSurface,
),
const SizedBox(height: 20),
Responsive(
mobile: Column(
children: [
// Date Filter
_buildDateFilter(context, controller),
const SizedBox(height: 16),
// Status Filter
_buildStatusFilter(context, controller),
const SizedBox(height: 16),
// Apply Button
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: () => controller.applyFilters(),
style: ElevatedButton.styleFrom(
backgroundColor: context.theme.colorScheme.primary,
foregroundColor: context.theme.colorScheme.onPrimary,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
icon: const Icon(Icons.filter_list),
label: AppText.semiBold('Apply Filters', size: 16),
),
),
],
),
tablet: Row(
children: [
// Date Filter
Expanded(
flex: 2,
child: _buildDateFilter(context, controller),
),
const SizedBox(width: 16),
// Status Filter
Expanded(
flex: 2,
child: _buildStatusFilter(context, controller),
),
const SizedBox(width: 16),
// Apply Button
Expanded(
flex: 1,
child: ElevatedButton.icon(
onPressed: () => controller.applyFilters(),
style: ElevatedButton.styleFrom(
backgroundColor: context.theme.colorScheme.primary,
foregroundColor: context.theme.colorScheme.onPrimary,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
icon: const Icon(Icons.filter_list),
label: AppText.semiBold('Apply', size: 16),
),
),
],
),
web: Row(
children: [
// Date Filter
Expanded(
flex: 2,
child: _buildDateFilter(context, controller),
),
const SizedBox(width: 16),
// Status Filter
Expanded(
flex: 2,
child: _buildStatusFilter(context, controller),
),
const SizedBox(width: 16),
// Apply Button
Expanded(
flex: 1,
child: ElevatedButton.icon(
onPressed: () => controller.applyFilters(),
style: ElevatedButton.styleFrom(
backgroundColor: context.theme.colorScheme.primary,
foregroundColor: context.theme.colorScheme.onPrimary,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
icon: const Icon(Icons.filter_list),
label: AppText.semiBold('Apply Filters', size: 16),
),
),
],
),
),
],
),
),
);
}

Widget _buildDateFilter(BuildContext context, DeliveryManagementController controller) {
return ListTile(
contentPadding: EdgeInsets.zero,
leading: Icon(
Icons.calendar_today,
color: context.theme.colorScheme.primary,
),
title: AppText('Delivery Date', size: 14),
subtitle: Obx(() => AppText.semiBold(
controller.selectedDate.value != null
? controller.formattedDate
    : 'Select a date',
size: 16,
color: context.theme.colorScheme.onSurface,
)),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
side: BorderSide(
color: context.theme.colorScheme.outlineVariant,
width: 1,
),
),
onTap: () => _showDatePicker(context, controller),
);
}

Widget _buildStatusFilter(BuildContext context, DeliveryManagementController controller) {
return ListTile(
contentPadding: EdgeInsets.zero,
leading: Icon(
Icons.filter_alt,
color: context.theme.colorScheme.primary,
),
title: AppText('Status', size: 14),
subtitle: Obx(() => AppText.semiBold(
controller.selectedStatus.value.isEmpty
? 'All Statuses'
    : controller.selectedStatus.value,
size: 16,
color: context.theme.colorScheme.onSurface,
)),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
side: BorderSide(
color: context.theme.colorScheme.outlineVariant,
width: 1,
),
),
onTap: () => _showStatusPicker(context, controller),
);
}

void _showDatePicker(BuildContext context, DeliveryManagementController controller) async {
final DateTime? picked = await showDatePicker(
context: context,
initialDate: controller.selectedDate.value ?? DateTime.now(),
firstDate: DateTime.now().subtract(const Duration(days: 30)),
lastDate: DateTime.now().add(const Duration(days: 30)),
builder: (context, child) {
return Theme(
data: Theme.of(context).copyWith(
colorScheme: ColorScheme.light(
primary: context.theme.colorScheme.primary,
onPrimary: context.theme.colorScheme.onPrimary,
surface: context.theme.colorScheme.surface,
onSurface: context.theme.colorScheme.onSurface,
),
),
child: child!,
);
},
);
if (picked != null) {
controller.selectedDate.value = picked;
}
}

void _showStatusPicker(BuildContext context, DeliveryManagementController controller) {
final statuses = ['All', 'Pending', 'In Transit', 'Delivered', 'Cancelled'];

showModalBottomSheet(
context: context,
builder: (context) => Container(
padding: const EdgeInsets.all(16),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
AppText.semiBold(
'Select Status',
size: 18,
color: context.theme.colorScheme.onSurface,
),
const SizedBox(height: 16),
...statuses.map((status) {
final isSelected = controller.selectedStatus.value == status ||
(status == 'All' && controller.selectedStatus.value.isEmpty);

return ListTile(
title: AppText.semiBold(
status,
color: isSelected
? context.theme.colorScheme.primary
    : context.theme.colorScheme.onSurface,
),
leading: isSelected
? Icon(
Icons.check_circle,
color: context.theme.colorScheme.primary,
)
    : Icon(
Icons.circle_outlined,
color: context.theme.colorScheme.onSurfaceVariant,
),
onTap: () {
controller.selectedStatus.value = status == 'All' ? '' : status;
Get.back();
},
);
}).toList(),
],
),
),
);
}

Widget _buildDeliveriesSection(BuildContext context, DeliveryManagementController controller) {
if (controller.deliveries.isEmpty) {
return _buildEmptyState(context);
}

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
AppText.semiBold(
'Deliveries',
size: 18,
color: context.theme.colorScheme.onSurface,
),
// View toggle (list/grid)
Obx(() => IconButton(
icon: Icon(
controller.isGridView.value
? Icons.view_list
    : Icons.grid_view,
color: context.theme.colorScheme.primary,
),
onPressed: () => controller.toggleViewMode(),
)),
],
),
const SizedBox(height: 16),
// List or Grid view based on selection
Obx(() => controller.isGridView.value
? _buildDeliveriesGrid(context, controller)
    : _buildDeliveriesList(context, controller)),
],
);
}

Widget _buildDeliveriesList(BuildContext context, DeliveryManagementController controller) {
return ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: controller.deliveries.length,
itemBuilder: (context, index) {
final delivery = controller.deliveries[index];
return Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLowest,
margin: const EdgeInsets.only(bottom: 12),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: ListTile(
contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
leading: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: _getStatusColor(delivery.status).withOpacity(0.1),
shape: BoxShape.circle,
),
child: Icon(
_getStatusIcon(delivery.status),
color: _getStatusColor(delivery.status),
),
),
title: AppText.semiBold(
delivery.customerName,
color: context.theme.colorScheme.onSurface,
),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
AppText(
delivery.address,
color: context.theme.colorScheme.onSurfaceVariant,
size: 14,
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
AppText(
'Status: ${delivery.status}',
color: _getStatusColor(delivery.status),
size: 14,
),
],
),
trailing: IconButton(
icon: const Icon(Icons.arrow_forward_ios, size: 16),
onPressed: () {
// Navigate to delivery details
},
),
onTap: () {
// Navigate to delivery details
},
),
);
},
);
}

Widget _buildDeliveriesGrid(BuildContext context, DeliveryManagementController controller) {
return GridView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: Responsive.isWeb(context) ? 3 : (Responsive.isTablet(context) ? 2 : 1),
childAspectRatio: 2.2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
),
itemCount: controller.deliveries.length,
itemBuilder: (context, index) {
final delivery = controller.deliveries[index];
return Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLowest,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: InkWell(
borderRadius: BorderRadius.circular(12),
onTap: () {
// Navigate to delivery details
},
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: _getStatusColor(delivery.status).withOpacity(0.1),
shape: BoxShape.circle,
),
child: Icon(
_getStatusIcon(delivery.status),
color: _getStatusColor(delivery.status),
size: 20,
),
),
const SizedBox(width: 12),
Expanded(
child: AppText.semiBold(
delivery.customerName,
color: context.theme.colorScheme.onSurface,
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
),
],
),
const SizedBox(height: 8),
AppText(
delivery.address,
color: context.theme.colorScheme.onSurfaceVariant,
size: 14,
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
AppText(
'Status: ',
color: context.theme.colorScheme.onSurfaceVariant,
size: 14,
),
AppText.semiBold(
delivery.status,
color: _getStatusColor(delivery.status),
size: 14,
),
],
),
],
),
),
),
);
},
);
}

Widget _buildEmptyState(BuildContext context) {
return Card(
elevation: 0,
color: context.theme.colorScheme.surfaceContainerLow,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: Padding(
padding: const EdgeInsets.all(24),
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.local_shipping_outlined,
size: 64,
color: context.theme.colorScheme.primary.withOpacity(0.5),
),
const SizedBox(height: 16),
AppText.semiBold(
'No Deliveries Found',
color: context.theme.colorScheme.onSurface,
size: 18,
),
const SizedBox(height: 8),
AppText(
'Try adjusting your filters or add new deliveries.',
color: context.theme.colorScheme.onSurfaceVariant,
size: 14,
textAlign: TextAlign.center,
),
const SizedBox(height: 24),
ElevatedButton.icon(
onPressed: () {
// Add new delivery
},
style: ElevatedButton.styleFrom(
backgroundColor: context.theme.colorScheme.primary,
foregroundColor: context.theme.colorScheme.onPrimary,
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
icon: const Icon(Icons.add),
label: AppText.semiBold('Add Delivery', size: 16),
),
],
),
),
),
);
}

Color _getStatusColor(String status) {
switch (status.toLowerCase()) {
case 'delivered':
return Colors.green;
case 'pending':
return Colors.orange;
case 'in transit':
return Colors.blue;
case 'cancelled':
return Colors.red;
default:
return Colors.grey;
}
}

IconData _getStatusIcon(String status) {
switch (status.toLowerCase()) {
case 'delivered':
return Icons.check_circle;
case 'pending':
return Icons.pending;
case 'in transit':
return Icons.local_shipping;
case 'cancelled':
return Icons.cancel;
default:
return Icons.info;
}
}
}