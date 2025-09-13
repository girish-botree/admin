import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../exercise_controller.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_shimmer.dart';
import '../widgets/exercise_dialogs.dart';
import '../../../meal/shared/widgets/common_widgets.dart';
import 'exercise_detail_screen.dart';

class ExercisesView extends GetView<ExerciseController> {
  const ExercisesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Search bar
            ModernSearchBar(
              controller: controller.exerciseSearchController,
              hintText: 'Search exercises, muscle groups...',
              onChanged: (value) {
                // Explicitly update the search query
                controller.exerciseSearchQuery.value = value;
                controller.updateFilteredExercises();
              },
              onClear: () {
                controller.exerciseSearchController.clear();
                controller.exerciseSearchQuery.value = '';
                controller.updateFilteredExercises();
              },
            ),

            // Sort and filter bar
            Obx(() =>
                SortFilterBar(
                  sortBy: controller.exerciseSortBy.value,
                  sortAscending: controller.sortAscending.value,
                  sortOptions: const ['name', 'difficulty', 'muscleGroup'],
                  sortLabels: const {
                    'name': 'Name',
                    'difficulty': 'Difficulty',
                    'muscleGroup': 'Muscle Group',
                  },
                  onFilterTap: () => controller.toggleFilterVisibility(),
                  onSortChanged: (value) =>
                  controller.exerciseSortBy.value = value,
                  onSortOrderToggle: () =>
                  controller.sortAscending.value =
                  !controller.sortAscending.value,
                  hasActiveFilters: _hasActiveFilters(),
                )),

            // Filter panel
            Obx(() => _buildFilterPanel()),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshData();
                },
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerLoading(context);
                  }

                  if (controller.error.value.isNotEmpty) {
                    return _buildErrorState(context);
                  }

                  if (controller.exercises.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  if (controller.filteredExercises.isEmpty) {
                    return _buildNoResultsState(context);
                  }

                  return _buildExerciseGrid(context);
                }),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildModernFAB(context),
      ),
    );
  }

  bool _hasActiveFilters() {
    return controller.selectedMuscleGroup.value != 'All' ||
        controller.selectedEquipment.value != 'All' ||
        controller.difficultyRange.value.start != 1 ||
        controller.difficultyRange.value.end != 5;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() =>
          StandardAppBar.withCount(
            title: 'Exercises',
            itemCount: controller.filteredExercises.length,
            itemLabel: 'exercises',
            showDeleteAll: true,
            onDeleteAll: () =>
                ExerciseDialogs.showDeleteAllConfirmation(context, controller),
            showRefresh: true,
            isLoading: controller.isLoading.value,
            onRefresh: () async {
              await controller.refreshData();
            },
          )),
    );
  }

  Widget _buildFilterPanel() {
    if (!controller.showFilters.value) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Get.context!.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Get.context!.theme.colorScheme.shadow.withValues(
                alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: controller.resetFilters,
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: Get.context!.theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Muscle Group filter
          Text(
            'Muscle Group',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Get.context!.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableMuscleGroups.map((group) {
              final isSelected = group == controller.selectedMuscleGroup.value;
              return FilterChip(
                label: Text(group),
                selected: isSelected,
                onSelected: (_) => controller.selectedMuscleGroup.value = group,
                selectedColor: Get.context!.theme.colorScheme.primary
                    .withValues(alpha: 0.2),
                checkmarkColor: Get.context!.theme.colorScheme.primary,
                backgroundColor: Get.context!.theme.colorScheme
                    .surfaceContainer,
                side: BorderSide(
                  color: isSelected
                      ? Get.context!.theme.colorScheme.primary.withValues(
                      alpha: 0.3)
                      : Get.context!.theme.colorScheme.outline.withValues(
                      alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Equipment filter
          Text(
            'Equipment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Get.context!.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableEquipment.map((equipment) {
              final isSelected = equipment ==
                  controller.selectedEquipment.value;
              return FilterChip(
                label: Text(equipment),
                selected: isSelected,
                onSelected: (_) =>
                controller.selectedEquipment.value = equipment,
                selectedColor: Get.context!.theme.colorScheme.primary
                    .withValues(alpha: 0.2),
                checkmarkColor: Get.context!.theme.colorScheme.primary,
                backgroundColor: Get.context!.theme.colorScheme
                    .surfaceContainer,
                side: BorderSide(
                  color: isSelected
                      ? Get.context!.theme.colorScheme.primary.withValues(
                      alpha: 0.3)
                      : Get.context!.theme.colorScheme.outline.withValues(
                      alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Difficulty range
          Obx(() =>
              Text(
                'Difficulty: ${controller.difficultyRange.value.start
                    .round()} - ${controller.difficultyRange.value.end
                    .round()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Get.context!.theme.colorScheme.onSurface,
                ),
              )),
          Obx(() =>
              RangeSlider(
                values: controller.difficultyRange.value,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (values) =>
                controller.difficultyRange.value = values,
                activeColor: Get.context!.theme.colorScheme.primary,
                inactiveColor: Get.context!.theme.colorScheme.outline
                    .withValues(alpha: 0.3),
              )),
        ],
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return ModernFAB(
      label: 'Add Exercise',
      onPressed: () =>
          ExerciseDialogs.showAddExerciseDialog(context, controller),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ErrorStateWidget(
      title: 'Something went wrong',
      subtitle: 'Unable to load exercises. Please try again.',
      onRetry: () => controller.refreshData(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      title: 'No exercises yet',
      subtitle: 'Start building your exercise library\nby adding your first exercise',
      icon: Icons.fitness_center_rounded,
      buttonLabel: 'Add First Exercise',
      onButtonPressed: () =>
          ExerciseDialogs.showAddExerciseDialog(context, controller),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return NoResultsWidget(
      title: 'No exercises found',
      subtitle: 'Try adjusting your search or filters\nto find what you\'re looking for',
      icon: Icons.search_rounded,
      onReset: () {
        controller.exerciseSearchController.clear();
        controller.exerciseSearchQuery.value = '';
        controller.resetFilters();
        controller.updateFilteredExercises();
      },
    );
  }

  Widget _buildExerciseGrid(BuildContext context) {
    final exerciseCards = controller.filteredExercises.map((exercise) =>
        ExerciseCard(
          exercise: exercise,
          onTap: () =>
              Get.to<void>(
                    () => ExerciseDetailScreen(exercise: exercise),
                transition: Transition.cupertino,
                duration: const Duration(milliseconds: 300),
              ),
          onEdit: () =>
              ExerciseDialogs.showEditExerciseDialog(
                  context, controller, exercise),
          onDelete: () =>
              ExerciseDialogs.showDeleteConfirmation(
                  context, exercise, controller),
        )
    ).toList();

    return ResponsiveGrid(
      getCrossAxisCount: _getCrossAxisCount,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: exerciseCards,
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 7;
    if (width > 900) return 5;
    if (width > 700) return 4;
    if (width > 500) return 3;
    if (width > 300) return 2;
    return 1;
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ExerciseShimmerGrid(
      getCrossAxisCount: _getCrossAxisCount,
    );
  }
}