import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/app_colors.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import 'plan_controller.dart';
import 'plan_constants.dart';
import 'meal_plan_assignment_model.dart';
import 'widgets/meal_plan_form_dialog.dart';
import 'widgets/meal_plan_loading.dart';
import 'widgets/meal_section.dart';
import 'widgets/plan_statistics_widget.dart';

class PlanView extends GetView<PlanController> {
  const PlanView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PlanController());
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Calendar Widget
                Container(
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
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
                        color: context.theme.colorScheme.primary.withValues(alpha:0.5),
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
                ),
                const SizedBox(height: 24),
                
                // Selected Date Display
                AppText.semiBold(
                  'Meal Plans for ${_formatDate(controller.selectedCalendarDate.value)}',
                  color: context.theme.colorScheme.onSurface,
                  size: Responsive.getSubtitleTextSize(context),
                ),
                const SizedBox(height: 16),
                
                // Check if any meals exist for the day
                if (_hasNoMealsForDay())
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.no_meals,
                            size: 48,
                            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          AppText.semiBold(
                            'Nothing planned for this date',
                            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            size: Responsive.getBodyTextSize(context),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Meal Sections
                  MealSection(
                    title: 'Breakfast',
                    icon: Icons.wb_sunny,
                    mealPlans: controller.getMealPlansForPeriod(MealPeriod.breakfast),
                    borderColor: Colors.orange,
                  ),
                  MealSection(
                    title: 'Lunch',
                    icon: Icons.lunch_dining,
                    mealPlans: controller.getMealPlansForPeriod(MealPeriod.lunch),
                    borderColor: Colors.green,
                  ),
                  MealSection(
                    title: 'Dinner',
                    icon: Icons.dinner_dining,
                    mealPlans: controller.getMealPlansForPeriod(MealPeriod.dinner),
                    borderColor: Colors.blue,
                  ),
                ],
                const SizedBox(height: 24),
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
  
  void _showCreateDialog() {
    controller.clearForm();
    Get.dialog<void>(const MealPlanFormDialog());
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