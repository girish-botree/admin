import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import 'plan_controller.dart';
import 'widgets/plan_statistics_widget.dart';

class PlanStatisticsView extends GetView<PlanController> {
  const PlanStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.bold(
          'Meal Plan Statistics',
          color: context.theme.colorScheme.onSurface,
          size: 20,
        ),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Force refresh with cache clearing
              controller.clearCaches();
              await controller.getMealPlans();
              await controller.getMealPlansByDate();
            },
            icon: Icon(
                Icons.refresh, color: context.theme.colorScheme.onSurface),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.clearCaches();
          await controller.getMealPlans();
          await controller.getMealPlansByDate();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.theme.colorScheme.primary.withValues(alpha: 0.1),
                      context.theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: context.theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.bold(
                                'Comprehensive Analytics',
                                color: context.theme.colorScheme.onSurface,
                                size: Responsive.getSubtitleTextSize(context),
                              ),
                              const SizedBox(height: 4),
                              AppText.medium(
                                'Insights into your meal planning patterns and distributions',
                                color: context.theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics content
              const PlanStatisticsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}