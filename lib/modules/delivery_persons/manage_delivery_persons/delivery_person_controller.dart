import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/utils/search_utils.dart';
import 'package:admin/widgets/custom_displays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'delivery_person_model.dart';

class DeliveryPersonController extends GetxController {
  // Loading states
  final isLoading = false.obs;
  final isDeleting = false.obs;
  final isUpdating = false.obs;

  // Data
  final deliveryPersons = <DeliveryPerson>[].obs;
  final filteredDeliveryPersons = <DeliveryPerson>[].obs;

  // Search
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Form controllers for editing
  final editFirstNameController = TextEditingController();
  final editLastNameController = TextEditingController();
  final editEmailController = TextEditingController();
  final editPhoneNumberController = TextEditingController();
  final editAddressController = TextEditingController();
  final editIdentificationNumberController = TextEditingController();
  final editVehicleNumberController = TextEditingController();
  final editEmergencyContactController = TextEditingController();
  final editProfilePictureUrlController = TextEditingController();
  final editDocumentsUrlController = TextEditingController();

  // Observables for editing
  final editSelectedVehicleType = 'Car'.obs;
  final editSelectedDateOfBirth = DateTime
      .now()
      .subtract(Duration(days: 18 * 365))
      .obs;

  // Vehicle type options
  final vehicleTypes = ['Car', 'Motorcycle', 'Bicycle', 'Van', 'Truck'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeliveryPersons();

    // Listen to search query changes with debouncing
    searchQuery.listen((query) {
      SearchUtils.debounceSearch(query, filterDeliveryPersons);
    });
  }

  @override
  void onClose() {
    // Cancel any pending debounced searches
    SearchUtils.cancelDebouncedSearch();
    
    // Dispose controllers
    searchController.dispose();
    editFirstNameController.dispose();
    editLastNameController.dispose();
    editEmailController.dispose();
    editPhoneNumberController.dispose();
    editAddressController.dispose();
    editIdentificationNumberController.dispose();
    editVehicleNumberController.dispose();
    editEmergencyContactController.dispose();
    editProfilePictureUrlController.dispose();
    editDocumentsUrlController.dispose();
    
    super.onClose();
  }

  /// Fetch all delivery persons
  Future<void> fetchDeliveryPersons() async {
    try {
      isLoading.value = true;
      final response = await DioNetworkService.getDeliveryPersons(showLoader: false);

      if (response != null && response is List) {
        deliveryPersons.value = response
            .where((json) => json is Map<String, dynamic>)
            .map((json) =>
            DeliveryPerson.fromJson(json as Map<String, dynamic>))
            .toList();
        filteredDeliveryPersons.value = deliveryPersons;
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to load delivery persons');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter delivery persons based on search query with optimized prefix search
  void filterDeliveryPersons(String query) {
    if (query.isEmpty) {
      filteredDeliveryPersons.value = deliveryPersons;
    } else {
      filteredDeliveryPersons.value = SearchUtils.filterAndSort(
        deliveryPersons,
        query,
        (person) => [
          person.firstName,
          person.lastName,
          person.email,
          person.phoneNumber,
        ],
        fallbackToContains: true,
      );
    }
  }

  /// Search delivery persons
  void searchDeliveryPersons(String query) {
    searchQuery.value = query;
  }

  /// Load delivery person data into edit form
  void loadDeliveryPersonForEdit(DeliveryPerson person) {
    editFirstNameController.text = person.firstName;
    editLastNameController.text = person.lastName;
    editEmailController.text = person.email;
    editPhoneNumberController.text = person.phoneNumber;
    editAddressController.text = person.address;
    editIdentificationNumberController.text = person.identificationNumber;
    editVehicleNumberController.text = person.vehicleNumber;
    editEmergencyContactController.text = person.emergencyContact;
    editProfilePictureUrlController.text = person.profilePictureUrl ?? '';
    editDocumentsUrlController.text = person.documentsUrl ?? '';
    editSelectedVehicleType.value = person.vehicleType;
    editSelectedDateOfBirth.value = person.dateOfBirth;
  }

  /// Clear edit form
  void clearEditForm() {
    editFirstNameController.clear();
    editLastNameController.clear();
    editEmailController.clear();
    editPhoneNumberController.clear();
    editAddressController.clear();
    editIdentificationNumberController.clear();
    editVehicleNumberController.clear();
    editEmergencyContactController.clear();
    editProfilePictureUrlController.clear();
    editDocumentsUrlController.clear();
    editSelectedVehicleType.value = 'Car';
    editSelectedDateOfBirth.value =
        DateTime.now().subtract(Duration(days: 18 * 365));
  }

  /// Update delivery person
  Future<void> updateDeliveryPerson(String id) async {
    try {
      isUpdating.value = true;

      final data = {
        'firstName': editFirstNameController.text.trim(),
        'lastName': editLastNameController.text.trim(),
        'email': editEmailController.text.trim(),
        'phoneNumber': editPhoneNumberController.text.trim(),
        'address': editAddressController.text.trim(),
        'identificationNumber': editIdentificationNumberController.text.trim(),
        'vehicleType': editSelectedVehicleType.value,
        'vehicleNumber': editVehicleNumberController.text.trim(),
        'dateOfBirth': editSelectedDateOfBirth.value.toIso8601String(),
        'emergencyContact': editEmergencyContactController.text.trim(),
        'profilePictureUrl': editProfilePictureUrlController.text
            .trim()
            .isEmpty
            ? null
            : editProfilePictureUrlController.text.trim(),
        'documentsUrl': editDocumentsUrlController.text
            .trim()
            .isEmpty
            ? null
            : editDocumentsUrlController.text.trim(),
      };

      final response = await DioNetworkService.updateDeliveryPerson(id, data, showLoader: false);

      if (response != null) {
        // Refresh the list
        await fetchDeliveryPersons();

        Get.back<void>(); // Close edit dialog
        CustomDisplays.showSnackBar(
            message: 'Delivery person updated successfully');
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to update delivery person');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete delivery person
  Future<void> deleteDeliveryPerson(String id) async {
    try {
      isDeleting.value = true;

      final response = await DioNetworkService.deleteDeliveryPerson(id, showLoader: false);

      if (response != null) {
        // Remove from local list
        deliveryPersons.removeWhere((person) => person.id == id);
        filteredDeliveryPersons.removeWhere((person) => person.id == id);

        CustomDisplays.showSnackBar(
            message: 'Delivery person deleted successfully');
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to delete delivery person');
    } finally {
      isDeleting.value = false;
    }
  }

  /// Show delete confirmation
  void showDeleteConfirmation(DeliveryPerson person) {
    Get.dialog<void>(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        title: Text('Delete Delivery Person'),
        content: Text(
            'Are you sure you want to delete ${person.firstName} ${person
                .lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              deleteDeliveryPerson(person.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }


}