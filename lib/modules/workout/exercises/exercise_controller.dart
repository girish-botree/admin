import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../network_service/dio_network_service.dart';
import '../../../utils/search_utils.dart';

class ExerciseController extends GetxController {
  // Exercise state
  final exercises = <dynamic>[].obs;
  final filteredExercises = <dynamic>[].obs;
  final selectedExercise = Rxn<dynamic>();

  // Search state
  final exerciseSearchController = TextEditingController();
  final exerciseSearchQuery = ''.obs;

  // Sort state
  final exerciseSortBy = 'name'.obs; // name, difficulty, muscleGroup
  final sortAscending = true.obs;

  // Filter state
  final selectedMuscleGroup = 'All'.obs;
  final selectedEquipment = 'All'.obs;
  final difficultyRange = const RangeValues(1, 5).obs;

  // Filter visibility
  final showFilters = false.obs;

  // Loading state
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final error = ''.obs;
  final isImageUploading = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final muscleGroupController = TextEditingController();
  final equipmentController = TextEditingController();
  final difficultyController = TextEditingController();
  final imageUrlController = TextEditingController();
  final videoUrlController = TextEditingController();
  final instructionsController = TextEditingController();

  // Validation errors
  final nameError = RxString('');
  final descriptionError = RxString('');
  final muscleGroupError = RxString('');
  final equipmentError = RxString('');
  final difficultyError = RxString('');
  final instructionsError = RxString('');

  @override
  void onInit() {
    super.onInit();
    fetchExercises();

    // Listen to search query changes with debouncing
    exerciseSearchController.addListener(() {
      SearchUtils.debounceSearch(
        exerciseSearchController.text,
            (query) {
          exerciseSearchQuery.value = query;
          updateFilteredExercises();
        },
      );
    });

    // Setup reactive listeners
    ever(exerciseSearchQuery, (_) => updateFilteredExercises());
    ever(exerciseSortBy, (_) => updateFilteredExercises());
    ever(sortAscending, (_) => updateFilteredExercises());
    ever(selectedMuscleGroup, (_) => updateFilteredExercises());
    ever(selectedEquipment, (_) => updateFilteredExercises());
    ever(difficultyRange, (_) => updateFilteredExercises());
  }

  // Exercise CRUD operations
  Future<void> fetchExercises() async {
    isLoading.value = true;
    error.value = '';

    try {
      final response = await DioNetworkService.getExercises(showLoader: false);
      if (response is Map<String, dynamic> && response['data'] != null) {
        exercises.value =
            (response['data'] as List<dynamic>? ?? []).cast<dynamic>();
        updateFilteredExercises();
      } else {
        exercises.value = [];
        filteredExercises.value = [];
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createExercise(Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';

    try {
      print('Creating exercise with data: $data');

      // Validate that required fields are not empty
      if (data['name'] == null || data['name']
          .toString()
          .isEmpty) {
        print('Error: Exercise name is required');
        error.value = 'Exercise name is required';
        return false;
      }

      final response = await DioNetworkService.createExercise(
          data, showLoader: false);
      print('Create exercise response: $response');

      // Refresh the exercises list
      await fetchExercises();
      return true;
    } catch (e) {
      print('Error creating exercise: $e');
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExercise(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';

    try {
      await DioNetworkService.updateExercise(id, data, showLoader: false);
      await fetchExercises();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteExercise(String id) async {
    isLoading.value = true;
    error.value = '';

    try {
      await DioNetworkService.deleteExercise(id, showLoader: false);
      await fetchExercises();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Validation methods
  bool validateName(String value) {
    if (value.isEmpty) {
      nameError.value = 'Exercise name is required';
      return false;
    } else if (value.length < 2) {
      nameError.value = 'Name must be at least 2 characters';
      return false;
    }
    nameError.value = '';
    return true;
  }

  bool validateDescription(String value) {
    if (value.isEmpty) {
      descriptionError.value = 'Description is required';
      return false;
    }
    descriptionError.value = '';
    return true;
  }

  bool validateMuscleGroup(String value) {
    if (value.isEmpty) {
      muscleGroupError.value = 'Muscle group is required';
      return false;
    }
    muscleGroupError.value = '';
    return true;
  }

  bool validateEquipment(String value) {
    if (value.isEmpty) {
      equipmentError.value = 'Equipment type is required';
      return false;
    }
    equipmentError.value = '';
    return true;
  }

  bool validateDifficulty(String value) {
    if (value.isEmpty) {
      difficultyError.value = 'Difficulty level is required';
      return false;
    }
    try {
      final difficulty = int.parse(value);
      if (difficulty < 1 || difficulty > 5) {
        difficultyError.value = 'Difficulty must be between 1 and 5';
        return false;
      }
    } catch (e) {
      difficultyError.value = 'Please enter a valid difficulty level';
      return false;
    }
    difficultyError.value = '';
    return true;
  }

  bool validateInstructions(String value) {
    if (value.isEmpty) {
      instructionsError.value = 'Instructions are required';
      return false;
    }
    instructionsError.value = '';
    return true;
  }

  // Form handling methods
  void resetFormErrors() {
    nameError.value = '';
    descriptionError.value = '';
    muscleGroupError.value = '';
    equipmentError.value = '';
    difficultyError.value = '';
    instructionsError.value = '';
  }

  void clearExerciseForm() {
    nameController.clear();
    descriptionController.clear();
    muscleGroupController.clear();
    equipmentController.clear();
    difficultyController.clear();
    imageUrlController.clear();
    videoUrlController.clear();
    instructionsController.clear();
    resetFormErrors();
  }

  void setupExerciseForm(dynamic exercise) {
    if (exercise == null) {
      clearExerciseForm();
      return;
    }

    nameController.text = (exercise['name'] as String?) ?? '';
    descriptionController.text = (exercise['description'] as String?) ?? '';
    muscleGroupController.text = (exercise['muscleGroup'] as String?) ?? '';
    equipmentController.text = (exercise['equipment'] as String?) ?? '';
    difficultyController.text = (exercise['difficulty']?.toString()) ?? '1';
    imageUrlController.text = (exercise['imageUrl'] as String?) ?? '';
    videoUrlController.text = (exercise['videoUrl'] as String?) ?? '';

    // Format instruction data
    final instructionData = exercise['instructionData'];
    String instructions = '';
    if (instructionData != null) {
      if (instructionData is Map<String, dynamic>) {
        instructions = instructionData.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join('\n');
      } else if (instructionData is String) {
        instructions = instructionData;
      }
    }
    instructionsController.text = instructions;
  }

  bool validateExerciseForm() {
    bool isValid = true;

    if (!validateName(nameController.text)) isValid = false;
    if (!validateDescription(descriptionController.text)) isValid = false;
    if (!validateMuscleGroup(muscleGroupController.text)) isValid = false;
    if (!validateEquipment(equipmentController.text)) isValid = false;
    if (!validateDifficulty(difficultyController.text)) isValid = false;
    if (!validateInstructions(instructionsController.text)) isValid = false;

    return isValid;
  }

  Map<String, dynamic> createExerciseData({String? uploadedImageUrl}) {
    // Parse instructions into structured data
    Map<String, String> instructionData = {};
    final instructionLines = instructionsController.text.split('\n');
    for (int i = 0; i < instructionLines.length; i++) {
      final line = instructionLines[i].trim();
      if (line.isNotEmpty) {
        instructionData['Step${i + 1}'] = line;
      }
    }

    // Prioritize the uploadedImageUrl parameter, then the controller's imageUrl field
    final String imageUrl = uploadedImageUrl != null &&
        uploadedImageUrl.isNotEmpty
        ? uploadedImageUrl
        : imageUrlController.text.trim();

    print('Creating exercise data with image URL: $imageUrl');
    print('- uploadedImageUrl parameter: $uploadedImageUrl');
    print('- imageUrlController value: ${imageUrlController.text}');

    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'muscleGroup': muscleGroupController.text.trim(),
      'equipment': equipmentController.text.trim(),
      'difficulty': int.tryParse(difficultyController.text) ?? 1,
      'instructionData': instructionData,
      'imageUrl': imageUrl,
      'videoUrl': videoUrlController.text.trim(),
    };
  }

  void updateFilteredExercises() {
    List<dynamic> filtered = exercises.toList();

    // Apply search filter
    if (exerciseSearchQuery.value.isNotEmpty) {
      filtered = SearchUtils.filterAndSort(
        filtered,
        exerciseSearchQuery.value,
            (exercise) =>
        [
          exercise['name'] as String? ?? '',
          exercise['description'] as String? ?? '',
          exercise['muscleGroup'] as String? ?? '',
          exercise['equipment'] as String? ?? '',
        ],
        fallbackToContains: true,
      );
    }

    // Apply muscle group filter
    if (selectedMuscleGroup.value != 'All') {
      filtered = filtered.where((exercise) {
        final muscleGroup = exercise['muscleGroup'] as String? ?? '';
        return muscleGroup.toLowerCase() ==
            selectedMuscleGroup.value.toLowerCase();
      }).toList();
    }

    // Apply equipment filter
    if (selectedEquipment.value != 'All') {
      filtered = filtered.where((exercise) {
        final equipment = exercise['equipment'] as String? ?? '';
        return equipment.toLowerCase() == selectedEquipment.value.toLowerCase();
      }).toList();
    }

    // Apply difficulty range filter
    filtered = filtered.where((exercise) {
      final difficulty = (exercise['difficulty'] as num?)?.toDouble() ?? 1.0;
      return difficulty >= difficultyRange.value.start &&
          difficulty <= difficultyRange.value.end;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (exerciseSortBy.value) {
        case 'name':
          comparison = (a['name'] as String? ?? '').compareTo(
              b['name'] as String? ?? '');
          break;
        case 'difficulty':
          comparison = ((a['difficulty'] as num?) ?? 0).compareTo(
              (b['difficulty'] as num?) ?? 0);
          break;
        case 'muscleGroup':
          comparison = (a['muscleGroup'] as String? ?? '').compareTo(
              b['muscleGroup'] as String? ?? '');
          break;
      }

      return sortAscending.value ? comparison : -comparison;
    });

    filteredExercises.value = filtered;
  }

  // Helper methods for getting filter options
  List<String> get availableMuscleGroups {
    final groups = exercises
        .map((exercise) => exercise['muscleGroup'] as String? ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();
    return ['All', ...groups];
  }

  List<String> get availableEquipment {
    final equipment = exercises
        .map((exercise) => exercise['equipment'] as String? ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    equipment.sort();
    return ['All', ...equipment];
  }

  // Search and filter control methods
  void clearSearch() {
    exerciseSearchController.clear();
    exerciseSearchQuery.value = '';
    updateFilteredExercises();
  }

  void resetFilters() {
    selectedMuscleGroup.value = 'All';
    selectedEquipment.value = 'All';
    difficultyRange.value = const RangeValues(1, 5);
  }

  void toggleFilterVisibility() {
    showFilters.value = !showFilters.value;
  }

  // Refresh method
  Future<void> refreshData() async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;
    error.value = '';

    try {
      await fetchExercises();
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isRefreshing.value = false;
    }
  }

  // Wait for image upload to complete
  Future<bool> waitForImageUpload() async {
    // If image is not currently uploading, return true immediately
    if (!isImageUploading.value) {
      return true;
    }

    // Wait for up to 30 seconds for the upload to complete
    int attempts = 0;
    const maxAttempts = 60; // 30 seconds (500ms * 60)

    while (isImageUploading.value && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    // Return true if upload completed successfully (no longer uploading)
    return !isImageUploading.value;
  }

  @override
  void onClose() {
    // Cancel any pending debounced searches
    SearchUtils.cancelDebouncedSearch();

    // Dispose controllers
    exerciseSearchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    muscleGroupController.dispose();
    equipmentController.dispose();
    difficultyController.dispose();
    imageUrlController.dispose();
    videoUrlController.dispose();
    instructionsController.dispose();
    super.onClose();
  }
}