import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/app_colors.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import '../../widgets/custom_displays.dart';
import '../../routes/app_routes.dart';
import 'plan_controller.dart';
import 'plan_constants.dart';
import 'meal_plan_model.dart';
import 'meal_plan_assignment_model.dart';
import 'widgets/meal_plan_form_dialog.dart';
import 'widgets/meal_plan_loading.dart';

class PlanView extends GetView<PlanController> {
  const PlanView({super.key});

  // Constants for better maintainability
  static const double _defaultPadding = 16.0;
  static const double _cardBorderRadius = 12.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 24.0;


  @override
  Widget build(BuildContext context) {
    // Remove this line - controller should be initialized elsewhere
    // Get.put(PlanController());
    return Scaffold(
      appBar: AppBar(
        title: AppText.bold(
          PlanConstants.mealPlans,
          color: context.theme.colorScheme.onSurface,
          size: 20,
        ),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              // Force refresh with cache clearing
              controller.clearCaches();
              await controller.getMealPlans();
              await controller.getMealPlansByDate();
            },
            icon: Icon(Icons.refresh, color: context.theme.colorScheme.onSurface),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.planStatistics);
            },
            icon: Icon(
                Icons.bar_chart, color: context.theme.colorScheme.onSurface),
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const MealPlanLoading();
        }


        return RefreshIndicator(
          onRefresh: () async {
            controller.clearCaches();
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
                    ? const EmptyStateWidget(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'No meal plans found',
                  subtitle: 'Create your first meal plan for this date',
                )
                    : _buildMealPlanCard(context),
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

  Widget _buildMealPlanCard(BuildContext context) {
    // Calculate total meals for the day
    final breakfastPlans = controller.getMealPlansForPeriod(MealPeriod.breakfast);
    final lunchPlans = controller.getMealPlansForPeriod(MealPeriod.lunch);
    final dinnerPlans = controller.getMealPlansForPeriod(MealPeriod.dinner);
    final snackPlans = controller.getMealPlansForPeriod(MealPeriod.snack);
    
    final totalMeals = breakfastPlans.length + lunchPlans.length + dinnerPlans.length + snackPlans.length;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.primary.withValues(alpha: 0.1),
            context.theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: context.theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.mealPlanDetail, arguments: controller.selectedCalendarDate.value);
          },
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: context.theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bold(
                        'View Meal Plans',
                        color: context.theme.colorScheme.onSurface,
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      AppText.medium(
                        '$totalMeals ${totalMeals == 1 ? 'meal' : 'meals'} planned for today',
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(height: 8),
                      
                      // Meal period indicators
                      Row(
                        children: [
                          if (breakfastPlans.isNotEmpty)
                            _buildMealPeriodIndicator('Breakfast', breakfastPlans.length, const Color(0xFFFF9800)),
                          if (lunchPlans.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _buildMealPeriodIndicator('Lunch', lunchPlans.length, const Color(0xFF4CAF50)),
                          ],
                          if (dinnerPlans.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _buildMealPeriodIndicator('Dinner', dinnerPlans.length, const Color(0xFF2196F3)),
                          ],
                          if (snackPlans.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _buildMealPeriodIndicator('Snack', snackPlans.length, const Color(0xFF9C27B0)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealPeriodIndicator(String period, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTimePeriodIconFromString(period),
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          AppText.caption(
            '$count',
            color: color,
          ),
        ],
      ),
    );
  }

  IconData _getTimePeriodIconFromString(String period) {
    switch (period) {
      case 'Breakfast':
        return Icons.wb_sunny;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.restaurant_menu;
    }
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
                              onPressed: () => Get.back<void>(),
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
              Get.back<void>(); // Close dialog first
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
    final breakfastPlans = controller.getMealPlansForPeriod(MealPeriod.breakfast);
    final lunchPlans = controller.getMealPlansForPeriod(MealPeriod.lunch);
    final dinnerPlans = controller.getMealPlansForPeriod(MealPeriod.dinner);
    final snackPlans = controller.getMealPlansForPeriod(MealPeriod.snack);
    return breakfastPlans.isEmpty && lunchPlans.isEmpty && dinnerPlans.isEmpty && snackPlans.isEmpty;
  }








}