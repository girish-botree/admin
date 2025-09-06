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

  // Data - now supporting both delivery persons and delivery agents
  final deliveryPersons = <DeliveryPerson>[].obs;
  final deliveryAgents = <DeliveryAgent>[].obs;
  final filteredDeliveryPersons = <DeliveryPerson>[].obs;
  final filteredDeliveryAgents = <DeliveryAgent>[].obs;
  final isShowingAgents = true.obs; // Flag to determine which data to show

  // Expandable card states
  final expandedPersonCards = <int>{}.obs;
  final expandedAgentCards = <int>{}.obs;

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

  // Form controllers for editing delivery agents
  final editAgentNameController = TextEditingController();
  final editAgentPhoneController = TextEditingController();
  final editAgentMaxCapacityController = TextEditingController();
  final editAgentCoveredPincodesController = TextEditingController();

  // Observables for editing
  final editSelectedVehicleType = 'Car'.obs;
  final editSelectedDateOfBirth = DateTime
      .now()
      .subtract(Duration(days: 18 * 365))
      .obs;

  // Observables for editing delivery agents
  final editSelectedAvailabilityStatus = 'ACTIVE'.obs;

  // Vehicle type options
  final vehicleTypes = ['Car', 'Motorcycle', 'Bicycle', 'Van', 'Truck'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeliveryAgents(); // Fetch delivery agents by default

    // Listen to search query changes with debouncing
    searchQuery.listen((query) {
      if (isShowingAgents.value) {
        SearchUtils.debounceSearch(query, filterDeliveryAgents);
      } else {
        SearchUtils.debounceSearch(query, filterDeliveryPersons);
      }
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
    editAgentNameController.dispose();
    editAgentPhoneController.dispose();
    editAgentMaxCapacityController.dispose();
    editAgentCoveredPincodesController.dispose();
    
    super.onClose();
  }

  /// Fetch delivery agents using admin API
  Future<void> fetchDeliveryAgents() async {
    try {
      isLoading.value = true;
      isShowingAgents.value = true;

      final response = await DioNetworkService.getAllDeliveryAgents(
          showLoader: false);

      if (response != null && response['data'] != null &&
          response['data'] is List) {
        deliveryAgents.value = (response['data'] as List)
            .where((json) => json is Map<String, dynamic>)
            .map((json) => DeliveryAgent.fromJson(json as Map<String, dynamic>))
            .toList();
        filteredDeliveryAgents.value = deliveryAgents;
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to load delivery agents');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all delivery persons (keeping existing functionality)
  Future<void> fetchDeliveryPersons() async {
    try {
      isLoading.value = true;
      isShowingAgents.value = false;

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

  /// Filter delivery agents based on search query
  void filterDeliveryAgents(String query) {
    if (query.isEmpty) {
      filteredDeliveryAgents.value = deliveryAgents;
    } else {
      filteredDeliveryAgents.value = SearchUtils.filterAndSort(
        deliveryAgents,
        query,
            (agent) =>
        [
          agent.name,
          agent.phoneNumber,
          agent.availabilityStatus,
          agent.coveredPincodes.join(' '),
        ],
        fallbackToContains: true,
      );
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

  /// Search function - works for both agents and persons
  void searchDeliveryPersons(String query) {
    searchQuery.value = query;
  }

  /// Delete delivery agent
  Future<void> deleteDeliveryAgent(String id) async {
    try {
      isDeleting.value = true;

      final response = await DioNetworkService.deleteDeliveryAgent(
          id, showLoader: false);

      if (response != null) {
        // Remove from local list
        deliveryAgents.removeWhere((agent) => agent.id == id);
        filteredDeliveryAgents.removeWhere((agent) => agent.id == id);

        CustomDisplays.showSnackBar(
            message: 'Delivery agent deleted successfully');
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to delete delivery agent');
    } finally {
      isDeleting.value = false;
    }
  }

  /// Show delete confirmation for delivery agent
  void showDeleteConfirmationForAgent(DeliveryAgent agent) {
    Get.dialog<void>(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        title: Text('Delete Delivery Agent'),
        content: Text(
            'Are you sure you want to delete ${agent.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              deleteDeliveryAgent(agent.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
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

  /// Load delivery agent data into edit form
  void loadDeliveryAgentForEdit(DeliveryAgent agent) {
    editAgentNameController.text = agent.name;
    editAgentPhoneController.text = agent.phoneNumber;
    editAgentMaxCapacityController.text = agent.maxCapacity.toString();
    editAgentCoveredPincodesController.text = '';
    editSelectedAvailabilityStatus.value = agent.availabilityStatus;
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

  /// Clear delivery agent edit form
  void clearAgentEditForm() {
    editAgentPhoneController.clear();
    editAgentMaxCapacityController.clear();
    editSelectedAvailabilityStatus.value = 'ACTIVE';
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

  /// Update delivery agent
  Future<void> updateDeliveryAgent(String id) async {
    try {
      isUpdating.value = true;

      final data = {
        'phoneNumber': editAgentPhoneController.text.trim(),
        'maxCapacity': int.parse(editAgentMaxCapacityController.text.trim()),
        'availabilityStatus': editSelectedAvailabilityStatus.value,
      };

      final response = await DioNetworkService.updateDeliveryAgent(
          id, data, showLoader: false);

      if (response != null) {
        // Refresh the list
        await fetchDeliveryAgents();

        Get.back<void>(); // Close edit dialog
        CustomDisplays.showSnackBar(
            message: 'Delivery agent updated successfully');
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Failed to update delivery agent');
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

  /// Toggle delivery person card expansion
  void togglePersonCardExpansion(int index) {
    if (expandedPersonCards.contains(index)) {
      expandedPersonCards.remove(index);
    } else {
      expandedPersonCards.add(index);
    }
    update(['person_$index']);
  }

  /// Toggle delivery agent card expansion
  void toggleAgentCardExpansion(int index) {
    if (expandedAgentCards.contains(index)) {
      expandedAgentCards.remove(index);
    } else {
      expandedAgentCards.add(index);
    }
    update(['agent_$index']);
  }
}