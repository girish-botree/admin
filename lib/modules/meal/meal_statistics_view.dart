import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_text.dart';
import '../../utils/responsive.dart';
import 'meal_controller.dart';
import 'components/meal_statistics_widget.dart';

class MealStatisticsView extends GetView<MealController> {
  const MealStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.bold(
          'Meal Statistics',
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
              // Force refresh
              await controller.fetchRecipes();
              await controller.fetchIngredients();
            },
            icon: Icon(
                Icons.refresh, color: context.theme.colorScheme.onSurface),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchRecipes();
          await controller.fetchIngredients();
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
                                'Recipe & Ingredient Analytics',
                                color: context.theme.colorScheme.onSurface,
                                size: Responsive.getSubtitleTextSize(context),
                              ),
                              const SizedBox(height: 4),
                              AppText.medium(
                                'Comprehensive insights into your recipes, ingredients, and nutritional data',
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
              const MealStatisticsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}