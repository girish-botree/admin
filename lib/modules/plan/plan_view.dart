import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/app_colors.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import '../../widgets/custom_displays.dart';
import 'plan_controller.dart';
import 'plan_constants.dart';
import 'meal_plan_assignment_model.dart';
import 'widgets/meal_plan_form_dialog.dart';
import 'widgets/meal_plan_loading.dart';
import 'widgets/meal_section.dart';
import 'widgets/plan_statistics_widget.dart';

class PlanView extends GetView<PlanController> {
  const PlanView({super.key});

  // Constants for better maintainability
  static const double _defaultPadding = 16.0;
  static const double _cardBorderRadius = 12.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 24.0;
  static const double _emptyStateIconSize = 48.0;

  @override
  Widget build(BuildContext context) {
    // Remove this line - controller should be initialized elsewhere
    // Get.put(PlanController());
    return Scaffold(
      appBar: AppBar(
        title: AppText.semiBold(
          PlanConstants.mealPlans,
          color: context.theme.colorScheme.onSurface,
          size: Responsive.getTitleTextSize(context),
        ),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              controller.getMealPlans();
              controller.getMealPlansByDate();
            },
            icon: Icon(Icons.refresh, color: context.theme.colorScheme.onSurface),
            tooltip: 'Refresh',
          ),
          // SettingsWidget(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const MealPlanLoading();
        }


        return RefreshIndicator(
          onRefresh: () async {
            await controller.getMealPlans();
            await controller.getMealPlansByDate();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_defaultPadding),
            child: Column(
              children: [
                // Calendar Widget
                _buildCalendarWidget(context),
                const SizedBox(height: _spacingLarge),
                
                // Selected Date Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText.semiBold(
                        'Meal Plans for ${_formatDate(
                            controller.selectedCalendarDate.value)}',
                        color: context.theme.colorScheme.onSurface,
                        size: Responsive.getSubtitleTextSize(context),
                      ),
                    ),
                    if (!_hasNoMealsForDay())
                      IconButton(
                        onPressed: () => _showDeleteAllConfirmation(context),
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: Colors.red,
                          size: 24,
                        ),
                        tooltip: 'Delete all meals for this day',
                      ),
                  ],
                ),
                const SizedBox(height: _spacingMedium),
                
                // Check if any meals exist for the day
                _hasNoMealsForDay()
                    ? EmptyStateWidget(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'No meal plans found',
                  subtitle: 'Create your first meal plan for this date',
                  action: ElevatedButton.icon(
                    onPressed: () => _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Meal Plan'),
                  ),
                )
                    : Column(
                  children: [
                    // Meal Sections
                    MealSection(
                      title: 'Breakfast',
                      icon: Icons.wb_sunny,
                      mealPlans: controller.getMealPlansForPeriod(
                          MealPeriod.breakfast),
                      borderColor: Colors.orange,
                    ),
                    MealSection(
                      title: 'Lunch',
                      icon: Icons.lunch_dining,
                      mealPlans: controller.getMealPlansForPeriod(
                          MealPeriod.lunch),
                      borderColor: Colors.green,
                    ),
                    MealSection(
                      title: 'Dinner',
                      icon: Icons.dinner_dining,
                      mealPlans: controller.getMealPlansForPeriod(
                          MealPeriod.dinner),
                      borderColor: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: _spacingLarge),
                const PlanStatisticsWidget(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: context.theme.colorScheme.onSurface,
        child: const Icon(Icons.add, color: AppColor.white),
      ),
    );
  }

  Widget _buildCalendarWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: TableCalendar<DateTime>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) {
          return isSameDay(controller.selectedCalendarDate.value, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          controller.updateSelectedDate(selectedDay);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: context.theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: context.theme.colorScheme.onSurface,
            fontSize: Responsive.getSubtitleTextSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    controller.clearForm();
    Get.dialog<void>(const MealPlanFormDialog());
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('Delete All Meals'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all meals for ${_formatDate(
              controller.selectedCalendarDate
                  .value)}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog first
              await controller.deleteAllMealPlansForDate(
                  controller.selectedCalendarDate.value);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  bool _hasNoMealsForDay() {
    final breakfastPlans = controller.getMealPlansForPeriod(
        MealPeriod.breakfast);
    final lunchPlans = controller.getMealPlansForPeriod(MealPeriod.lunch);
    final dinnerPlans = controller.getMealPlansForPeriod(MealPeriod.dinner);
    return breakfastPlans.isEmpty && lunchPlans.isEmpty && dinnerPlans.isEmpty;
  }
}