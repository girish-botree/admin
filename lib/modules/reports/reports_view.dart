import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../config/app_config.dart' show AppText;
import '../../utils/responsive.dart';
import 'reports_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportsController>(
      init: ReportsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: AppText.bold(
              'Delivery Reports',
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
                  controller.fetchAvailableDates();
                  if (controller.selectedDate.value != null) {
                    controller.loadReportData();
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Obx(() {
            if (controller.isLoadingDates.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.availableDates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: context.theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    AppText.semiBold(
                      'No delivery dates available',
                      color: context.theme.colorScheme.onSurface,
                      size: 18,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Try again later',
                      color: context.theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Meal Period Selection
                  _buildDateAndPeriodSection(context, controller),
                  const SizedBox(height: 24),

                  // Generate Excel Report Button
                  _buildGenerateReportButton(context, controller),
                  const SizedBox(height: 24),

                  // Report Data Section
                  _buildReportDataSection(context, controller),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDateAndPeriodSection(BuildContext context,
      ReportsController controller) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.semiBold(
              'Select Delivery Date & Meal Period',
              color: context.theme.colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(height: 20),

            // Date Selection
            Obx(() {
              final selectedDate = controller.selectedDate.value;
              final formattedDate = selectedDate != null
                  ? DateFormat('EEE, MMM d, yyyy').format(selectedDate)
                  : 'Select a date';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                title: const AppText('Delivery Date', size: 14),
                subtitle: AppText.semiBold(
                  formattedDate,
                  size: 16,
                  color: context.theme.colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: context.theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                onTap: () => _showDatePicker(context, controller),
              );
            }),

            const SizedBox(height: 16),

            // Meal Period Selection
            Obx(() {
              final mealPeriods = {0: 'Breakfast', 1: 'Lunch', 2: 'Dinner'};
              final selectedPeriod = controller.selectedMealPeriod.value;
              final mealPeriodText = mealPeriods[selectedPeriod] ??
                  'Select meal period';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: context.theme.colorScheme.secondary,
                  ),
                ),
                title: const AppText('Meal Period', size: 14),
                subtitle: AppText.semiBold(
                  mealPeriodText,
                  size: 16,
                  color: context.theme.colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: context.theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                onTap: () => _showMealPeriodPicker(context, controller),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, ReportsController controller) {
    final dates = controller.availableDates.map((dateStr) =>
        DateTime.parse(dateStr)).toList();

    if (dates.isEmpty) return;

    // Convert dates to a Set for easier lookup
    final availableDatesSet = Set<DateTime>.from(
        dates.map((date) => DateTime(date.year, date.month, date.day))
    );

    // Find the earliest and latest dates for initial display
    final DateTime firstDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime lastDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Set initial date to either the currently selected date (if it exists)
    // or the first available date
    final initialDate = controller.selectedDate.value != null
        ? controller.selectedDate.value!
        : dates.first;

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate.subtract(const Duration(days: 30)),
      // Allow scrolling to previous month
      lastDate: lastDate.add(const Duration(days: 30)),
      // Allow scrolling to next month
      selectableDayPredicate: (DateTime day) {
        // Only enable dates that are in our available dates list
        final dayWithoutTime = DateTime(day.year, day.month, day.day);
        return availableDatesSet.contains(dayWithoutTime);
      },
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
    ).then((selectedDate) {
      if (selectedDate != null) {
        controller.selectedDate.value = selectedDate;
        // Load report data when date is selected
        controller.loadReportData();
      }
    });
  }

  void _showMealPeriodPicker(BuildContext context,
      ReportsController controller) {
    final mealPeriods = {0: 'Breakfast', 1: 'Lunch', 2: 'Dinner'};

    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.semiBold(
                  'Select Meal Period',
                  size: 18,
                  color: context.theme.colorScheme.onSurface,
                ),
                const SizedBox(height: 16),
                ...mealPeriods.entries.map((entry) {
                  final period = entry.key;
                  final name = entry.value;

                  return ListTile(
                    title: AppText.semiBold(
                      name,
                      color: controller.selectedMealPeriod.value == period
                          ? context.theme.colorScheme.primary
                          : context.theme.colorScheme.onSurface,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: controller.selectedMealPeriod.value == period
                            ? context.theme.colorScheme.primary.withOpacity(0.1)
                            : context.theme.colorScheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: controller.selectedMealPeriod.value == period
                          ? Icon(
                        Icons.check_circle,
                        color: context.theme.colorScheme.primary,
                      )
                          : Icon(
                        Icons.restaurant,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      controller.selectedMealPeriod.value = period;
                      Get.back();
                    },
                  );
                }),
              ],
            ),
          ),
    );
  }

  void _showExcelDownloadSuccess(BuildContext context, String filePath,
      ReportsController controller) {
    // Format the selected date for display
    final dateStr = controller.selectedDate.value != null
        ? DateFormat('MMM d, yyyy').format(controller.selectedDate.value!)
        : '';

    // Get the meal period name
    final mealPeriods = {0: 'Breakfast', 1: 'Lunch', 2: 'Dinner'};
    final mealPeriodStr = mealPeriods[controller.selectedMealPeriod.value] ??
        '';

    // Check if this is a demo file (starting with /downloads/)
    final bool isDemoFile = filePath.startsWith('/downloads/');
    final String fileName = filePath
        .split('/')
        .last;

    // Store the file path in the controller for later use
    controller.lastDownloadedFilePath.value = filePath;
  }

  Widget _buildGenerateReportButton(BuildContext context,
      ReportsController controller) {
    return Obx(() {
      final isLoading = controller.isGeneratingExcel.value;
      final canGenerate = controller.selectedDate.value != null;
      final hasDownloadedFile = controller.lastDownloadedFilePath.value
          .isNotEmpty;

      return Card(
        elevation: 0,
        color: context.theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.tertiary.withOpacity(
                          0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.file_download,
                      color: context.theme.colorScheme.tertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppText.semiBold(
                      'Excel Report',
                      size: 18,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppText(
                'Download a comprehensive Excel report with all delivery details for the selected date and meal period.',
                size: 14,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: !canGenerate || isLoading
                          ? null
                          : () async {
                        final result = await controller.generateExcelReport();
                        if (result != null && result.success &&
                            result.filePath != null) {
                          _showExcelDownloadSuccess(
                              context, result.filePath!, controller);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme.tertiary,
                        foregroundColor: context.theme.colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: context.theme.colorScheme
                            .tertiary
                            .withOpacity(0.3),
                        disabledForegroundColor: context.theme.colorScheme
                            .onTertiary.withOpacity(0.5),
                      ),
                      icon: isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.theme.colorScheme.onTertiary,
                        ),
                      )
                          : const Icon(Icons.file_download),
                      label: AppText.semiBold(
                        isLoading ? 'Generating...' : 'Generate Excel Report',
                        size: 16,
                      ),
                    ),
                  ),
                  if (hasDownloadedFile) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.openExcelFile(
                            controller.lastDownloadedFilePath.value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme
                            .primaryContainer,
                        foregroundColor: context.theme.colorScheme
                            .onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: const AppText.semiBold(
                        'View Excel',
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildReportDataSection(BuildContext context,
      ReportsController controller) {
    return Obx(() {
      if (controller.isLoadingReportData.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.reportData.isEmpty) {
        return Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics,
                  size: 48,
                  color: context.theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                AppText.semiBold(
                  'View Report Data',
                  color: context.theme.colorScheme.onSurface,
                  size: 18,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Select a date and meal period, then tap the button below to view detailed report data',
                  color: context.theme.colorScheme.onSurfaceVariant,
                  size: 14,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.selectedDate.value == null
                        ? null
                        : () => controller.loadReportData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.colorScheme
                          .primaryContainer,
                      foregroundColor: context.theme.colorScheme
                          .onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.visibility),
                    label: const AppText.semiBold(
                      'View Report Data',
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // If we have report data, display it with a more modern layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.semiBold(
            'Report Summary',
            color: context.theme.colorScheme.onSurface,
            size: 20,
          ),
          const SizedBox(height: 16),

          // Summary Card with a modern design
          _buildSummaryCard(context, controller),
          const SizedBox(height: 24),

          // Detailed Report Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.semiBold(
                'Delivery Details',
                color: context.theme.colorScheme.onSurface,
                size: 20,
              ),
              // View toggle (list/grid)
              Obx(() =>
                  IconButton(
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

          // Detailed Report content
          _buildDeliveryDetailsList(context, controller),
        ],
      );
    });
  }

  Widget _buildSummaryCard(BuildContext context, ReportsController controller) {
    final summary = controller.reportSummary;

    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Responsive(
          mobile: Column(
            children: [
              _buildSummaryItem(
                context,
                'Total Deliveries',
                summary.totalDeliveries.toString(),
                Icons.delivery_dining,
                context.theme.colorScheme.primary,
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Delivered',
                      summary.delivered.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Pending',
                      summary.pending.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildSummaryItem(
                context,
                'Customized Meals',
                summary.customizedMeals.toString(),
                Icons.restaurant,
                context.theme.colorScheme.tertiary,
              ),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSummaryItem(
                  context,
                  'Total Deliveries',
                  summary.totalDeliveries.toString(),
                  Icons.delivery_dining,
                  context.theme.colorScheme.primary,
                ),
              ),
              const VerticalDivider(width: 32),
              Expanded(
                flex: 1,
                child: _buildSummaryItem(
                  context,
                  'Delivered',
                  summary.delivered.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const VerticalDivider(width: 32),
              Expanded(
                flex: 1,
                child: _buildSummaryItem(
                  context,
                  'Pending',
                  summary.pending.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const VerticalDivider(width: 32),
              Expanded(
                flex: 1,
                child: _buildSummaryItem(
                  context,
                  'Customized',
                  summary.customizedMeals.toString(),
                  Icons.restaurant,
                  context.theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          web: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSummaryItem(
                  context,
                  'Total Deliveries',
                  summary.totalDeliveries.toString(),
                  Icons.delivery_dining,
                  context.theme.colorScheme.primary,
                ),
              ),
              const VerticalDivider(width: 32),
              Expanded(
                flex: 1,
                child: _buildSummaryItem(
                  context,
                  'Delivered',
                  summary.delivered.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const VerticalDivider(width: 32),
              Expanded(
                flex: 1,
                child: _buildSummaryItem(
                  context,
                  'Pending',
                  summary.pending.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const VerticalDivider(width: 32),
              Expanded(
                flex: 1,
                child: _buildSummaryItem(
                  context,
                  'Customized',
                  summary.customizedMeals.toString(),
                  Icons.restaurant,
                  context.theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        AppText.bold(
          value,
          color: context.theme.colorScheme.onSurface,
          size: 24,
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          color: context.theme.colorScheme.onSurfaceVariant,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildDeliveryDetailsList(BuildContext context,
      ReportsController controller) {
    final deliveries = controller.deliveries;

    if (deliveries.isEmpty) {
      return Card(
        elevation: 0,
        color: context.theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 32,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                AppText(
                  'No delivery details available',
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Obx(() =>
    controller.isGridView.value
        ? _buildDeliveryDetailsGrid(context, controller)
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];

              return Card(
                elevation: 0,
                color: context.theme.colorScheme.surfaceContainerLowest,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    colorScheme: ColorScheme.light(
                      primary: context.theme.colorScheme.primary,
                    ),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(delivery.status).withOpacity(
                            0.1),
                        borderRadius: BorderRadius.circular(8),
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
                    subtitle: AppText(
                      'Status: ${delivery.status}',
                      color: context.theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Details Section
                      _buildExpandedSectionContent(context, delivery),
                    ],
                  ),
                ),
              );
            },
    ));
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            AppText.semiBold(
              title,
              color: context.theme.colorScheme.primary,
              size: 16,
            ),
          ],
        ),
        Divider(
          color: context.theme.colorScheme.primary.withOpacity(0.2),
          thickness: 1,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNutritionInfo(BuildContext context, DeliveryDetail delivery) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.semiBold('Nutrition Information', size: 14),
          const SizedBox(height: 8),
          Responsive(
            mobile: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildNutritionItem(
                        context, 'Calories', '${delivery.recipeCalories} kcal',
                        Colors.orange)),
                    Expanded(child: _buildNutritionItem(
                        context, 'Protein', '${delivery.recipeProtein}g',
                        Colors.red)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildNutritionItem(
                        context, 'Carbs', '${delivery.recipeCarbohydrates}g',
                        Colors.green)),
                    Expanded(child: _buildNutritionItem(
                        context, 'Fat', '${delivery.recipeFat}g', Colors.blue)),
                  ],
                ),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(child: _buildNutritionItem(
                    context, 'Calories', '${delivery.recipeCalories} kcal',
                    Colors.orange)),
                Expanded(child: _buildNutritionItem(
                    context, 'Protein', '${delivery.recipeProtein}g',
                    Colors.red)),
                Expanded(child: _buildNutritionItem(
                    context, 'Carbs', '${delivery.recipeCarbohydrates}g',
                    Colors.green)),
                Expanded(child: _buildNutritionItem(
                    context, 'Fat', '${delivery.recipeFat}g', Colors.blue)),
              ],
            ),
            web: Row(
              children: [
                Expanded(child: _buildNutritionItem(
                    context, 'Calories', '${delivery.recipeCalories} kcal',
                    Colors.orange)),
                Expanded(child: _buildNutritionItem(
                    context, 'Protein', '${delivery.recipeProtein}g',
                    Colors.red)),
                Expanded(child: _buildNutritionItem(
                    context, 'Carbs', '${delivery.recipeCarbohydrates}g',
                    Colors.green)),
                Expanded(child: _buildNutritionItem(
                    context, 'Fat', '${delivery.recipeFat}g', Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(BuildContext context, String label, String value,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          AppText(label, size: 12,
              color: context.theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          AppText.semiBold(value, size: 14, color: color),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Responsive(
            mobile: AppText.semiBold(
              '$label: ',
              size: 14,
            ),
            tablet: SizedBox(
              width: 120,
              child: AppText.semiBold(
                label,
                size: 14,
              ),
            ),
            web: SizedBox(
              width: 150,
              child: AppText.semiBold(
                label,
                size: 14,
              ),
            ),
          ),
          Expanded(
            child: AppText(
              value,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildDeliveryDetailsGrid(BuildContext context,
      ReportsController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isWeb(context) ? 3 : (Responsive.isTablet(
            context) ? 2 : 1),
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.deliveries.length,
      itemBuilder: (context, index) {
        final delivery = controller.deliveries[index];
        return Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Show detailed view of this delivery
              _showDeliveryDetails(context, delivery);
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
                          color: _getStatusColor(delivery.status).withOpacity(
                              0.1),
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGridInfoRow(context, 'Status', delivery.status),
                        const SizedBox(height: 4),
                        _buildGridInfoRow(
                            context, 'Address', delivery.deliveryAddress,
                            maxLines: 1),
                        const SizedBox(height: 4),
                        _buildGridInfoRow(
                            context, 'Recipe', delivery.recipeName,
                            maxLines: 1),
                        const SizedBox(height: 4),
                        _buildGridInfoRow(
                            context, 'Meal Period', delivery.mealPeriod),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const AppText('Details', size: 12),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        _showDeliveryDetails(context, delivery);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeliveryDetails(BuildContext context, DeliveryDetail delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.semiBold(
                          'Delivery Details',
                          size: 20,
                          color: context.theme.colorScheme.onSurface,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: _buildExpandedSectionContent(context, delivery),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildExpandedSectionContent(BuildContext context,
      DeliveryDetail delivery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Details Section
        _buildSectionHeader(context, 'User Details'),
        _buildDetailItem('Name', delivery.userName),
        _buildDetailItem('Email', delivery.userEmail),
        _buildDetailItem('Phone', delivery.userPhone),
        const SizedBox(height: 20),

        // Delivery Address Section
        _buildSectionHeader(context, 'Delivery Address'),
        _buildDetailItem('Address', delivery.deliveryAddress),
        _buildDetailItem('City', delivery.city),
        _buildDetailItem('State', delivery.state),
        _buildDetailItem('Postal Code', delivery.postalCode),
        if (delivery.landmark.isNotEmpty) _buildDetailItem(
            'Landmark', delivery.landmark),
        if (delivery.deliveryInstructions.isNotEmpty)
          _buildDetailItem('Instructions', delivery.deliveryInstructions),
        const SizedBox(height: 20),

        // Subscription & Meal Plan Section
        _buildSectionHeader(context, 'Subscription & Meal Plan'),
        _buildDetailItem('Subscription Plan', delivery.subscriptionPlanName),
        _buildDetailItem('Plan Type', delivery.subscriptionPlanType),
        _buildDetailItem('Meal Period', delivery.mealPeriod),
        _buildDetailItem('Original Category', delivery.originalCategory),
        _buildDetailItem('Current Category', delivery.currentCategory),
        if (delivery.isCustomized)
          _buildDetailItem(
              'Customization Reason', delivery.customizationReason),
        const SizedBox(height: 20),

        // Recipe Details Section
        _buildSectionHeader(context, 'Recipe Details'),
        _buildDetailItem('Recipe', delivery.recipeName),
        _buildDetailItem('Description', delivery.recipeDescription),
        _buildDetailItem('Cuisine', delivery.recipeCuisine),
        _buildDetailItem('Servings', delivery.recipeServings.toString()),
        _buildNutritionInfo(context, delivery),
        const SizedBox(height: 20),

        // Delivery Status Section
        _buildSectionHeader(context, 'Delivery Status'),
        _buildDetailItem('Status', delivery.status),
        if (delivery.isDelivered && delivery.deliveredAt != null)
          _buildDetailItem('Delivered At', delivery.deliveredAt!),
        if (delivery.isDelivered && delivery.deliveredBy.isNotEmpty)
          _buildDetailItem('Delivered By', delivery.deliveredBy),
      ],
    );
  }

  Widget _buildGridInfoRow(BuildContext context, String label, String value,
      {int maxLines = 2}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '$label: ',
          size: 12,
          color: context.theme.colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: AppText(
            value,
            size: 12,
            color: context.theme.colorScheme.onSurface,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}