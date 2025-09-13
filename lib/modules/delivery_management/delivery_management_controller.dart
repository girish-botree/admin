import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DeliveryManagementController extends GetxController {
// Observable variables
final isLoading = false.obs;
final deliveries = <DeliveryModel>[].obs;
final selectedDate = Rx<DateTime?>(null);
final selectedStatus = ''.obs;
final isGridView = false.obs;

// Stats
int get pendingCount => deliveries.where((d) => d.status == 'Pending').length;
int get inTransitCount => deliveries.where((d) => d.status == 'In Transit').length;
int get deliveredCount => deliveries.where((d) => d.status == 'Delivered').length;
int get totalCount => deliveries.length;

// Formatted date
String get formattedDate => selectedDate.value != null
? DateFormat('EEE, MMM d, yyyy').format(selectedDate.value!)
    : 'All Dates';

@override
void onInit() {
super.onInit();
fetchDeliveries();
}

// Toggle between list and grid view
void toggleViewMode() {
isGridView.value = !isGridView.value;
}

// Apply filters
void applyFilters() {
fetchDeliveries(); // In a real app, this would apply the filters
}

// Fetch deliveries (with sample data for now)
void fetchDeliveries() {
isLoading.value = true;

// Simulate API call delay
Future.delayed(const Duration(milliseconds: 800), () {
deliveries.value = _getSampleDeliveries();
isLoading.value = false;
});
}

// Sample data
List<DeliveryModel> _getSampleDeliveries() {
return [
DeliveryModel(
id: '1',
customerName: 'John Smith',
address: '123 Main St, Apartment 4B, New York, NY 10001',
status: 'Delivered',
deliveryDate: DateTime.now().subtract(const Duration(hours: 2)),
),
DeliveryModel(
id: '2',
customerName: 'Emily Johnson',
address: '456 Park Ave, Suite 8, Chicago, IL 60611',
status: 'Pending',
deliveryDate: DateTime.now().add(const Duration(hours: 3)),
),
DeliveryModel(
id: '3',
customerName: 'Michael Brown',
address: '789 Oak St, Houston, TX 77001',
status: 'In Transit',
deliveryDate: DateTime.now().add(const Duration(hours: 1)),
),
DeliveryModel(
id: '4',
customerName: 'Sarah Wilson',
address: '321 Elm St, Los Angeles, CA 90001',
status: 'Pending',
deliveryDate: DateTime.now().add(const Duration(hours: 5)),
),
DeliveryModel(
id: '5',
customerName: 'David Martinez',
address: '654 Pine St, Miami, FL 33101',
status: 'Delivered',
deliveryDate: DateTime.now().subtract(const Duration(hours: 4)),
),
DeliveryModel(
id: '6',
customerName: 'Jessica Taylor',
address: '987 Cedar St, Seattle, WA 98101',
status: 'In Transit',
deliveryDate: DateTime.now().add(const Duration(minutes: 30)),
),
DeliveryModel(
id: '7',
customerName: 'Daniel Anderson',
address: '159 Maple St, Boston, MA 02108',
status: 'Cancelled',
deliveryDate: DateTime.now().add(const Duration(hours: 6)),
),
DeliveryModel(
id: '8',
customerName: 'Olivia Thomas',
address: '753 Birch St, Denver, CO 80201',
status: 'Delivered',
deliveryDate: DateTime.now().subtract(const Duration(hours: 1)),
),
];
}
}

class DeliveryModel {
final String id;
final String customerName;
final String address;
final String status;
final DateTime deliveryDate;

DeliveryModel({
required this.id,
required this.customerName,
required this.address,
required this.status,
required this.deliveryDate,
});
}