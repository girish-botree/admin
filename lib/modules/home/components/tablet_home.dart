import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../config/app_config.dart' show AppText;
import '../../../routes/app_routes.dart';
import '../../../widgets/settings_widget.dart';
import '../../admins/create_admins/create_admin_view.dart';
import '../../workout/exercises/screens/exercises_view.dart';
import '../../workout/exercises/exercise_controller.dart';
import '../../workout/exercises/exercise_binding.dart';
import '../../meal/ingredients/ingredients_view.dart';
import '../../meal/receipe/receipes_view.dart';
import '../../meal/meal_controller.dart';
import '../home_controller.dart';

class TabletHome extends GetView<HomeController> {
  const TabletHome({super.key});

  // Material Design 3 Constants for Tablet
  static const double _cardHeight = 220.0;
  static const double _cardSpacing = 20.0;
  static const double _sectionSpacing = 40.0;
  static const double _cardBorderRadius = 32.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.surfaceContainerLowest,
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.7),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.5),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildTabletAppBar(context),
        body: _buildTabletBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 24,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: SettingsWidget(),
        ),
      ],
    );
  }

  Widget _buildTabletBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Management Section
          const SizedBox(height: 32),
          AppText.semiBold(
            'Management',
            size: 24,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 20),

          // Delivery Management Card - Full Width
          _buildDeliveryManagementCard(context),

          const SizedBox(height: 16),

          // Admin and Reports Cards in a Row
          Row(
            children: [
              // Admin Management Card
              Expanded(
                flex: 1,
                child: _buildTabletCard(
                  context: context,
                  onTap: () => Get.toNamed<void>(AppRoutes.createAdmin),
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Management',
                  subtitle: 'Manage system administrators',
                  isPrimary: true,
                  height: 200,
                  // Make it square by matching height with width
                  isSquare: true,
                ),
              ),

              const SizedBox(width: 20),

              // Reports Card
              Expanded(
                flex: 1,
                child: _buildTabletCard(
                  context: context,
                  onTap: () => Get.toNamed<void>(AppRoutes.reports),
                  icon: Icons.assessment_outlined,
                  title: 'Reports',
                  subtitle: 'View and generate delivery reports',
                  height: 200,
                  // Make it square by matching height with width
                  isSquare: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: _sectionSpacing),

          // Quick Actions Section
          AppText.semiBold(
            'Quick Actions',
            size: 24,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 24),
          _buildMealActionCards(context),
          const SizedBox(height: 24),
          _buildCarouselIndicator(context),
        ],
      ),
    );
  }

  Widget _buildMealActionCards(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        return Obx(() {
          final currentIndex = homeController.currentCarouselIndex.value;

          return Container(
            height: _cardHeight,
            child: PageView(
              onPageChanged: (index) {
                homeController.updateCarouselIndex(index);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _MD3Card(
                    onTap: () => _navigateToRecipes(context),
                    title: 'Recipes',
                    subtitle: 'Discover & manage your cooking recipes',
                    assetImagePath: 'assets/images/recipe.jpg',
                    gradientColors: [
                      context.theme.colorScheme.primary,
                      context.theme.colorScheme.primary.withOpacity(0.7),
                    ],
                    icon: Icons.restaurant_menu_rounded,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _MD3Card(
                    onTap: () => _navigateToIngredients(context),
                    title: 'Ingredients',
                    subtitle: 'Track & organize your food ingredients',
                    assetImagePath: 'assets/images/ingredients.jpg',
                    gradientColors: [
                      context.theme.colorScheme.tertiary,
                      context.theme.colorScheme.tertiary.withOpacity(0.7),
                    ],
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _MD3Card(
                    onTap: () => _navigateToExercises(context),
                    title: 'Exercises',
                    subtitle: 'Manage your workout exercises library',
                    assetImagePath: 'assets/images/exercise.jpg',
                    gradientColors: [
                      context.theme.colorScheme.secondary,
                      context.theme.colorScheme.secondary.withOpacity(0.7),
                    ],
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildCarouselIndicator(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        return Obx(() {
          final currentIndex = homeController.currentCarouselIndex.value;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: currentIndex == index ? 28 : 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: currentIndex == index
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.primary.withValues(
                      alpha: 0.3),
                ),
              );
            }),
          );
        });
      },
    );
  }

  void _navigateToRecipes(BuildContext context) async {
    HapticFeedback.selectionClick();

    try {
      final mealController = Get.find<MealController>();
      if (!mealController.isLoading.value) {
        mealController.fetchRecipes();
      }

      await Get.to<void>(
            () => const ReceipesView(),
        transition: Transition.rightToLeftWithFade,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to navigate to recipes. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void _navigateToExercises(BuildContext context) async {
    HapticFeedback.selectionClick();

    try {
      // Initialize exercise binding and controller
      ExerciseBinding().dependencies();

      final exerciseController = Get.find<ExerciseController>();
      if (!exerciseController.isLoading.value) {
        exerciseController.fetchExercises();
      }

      await Get.to<void>(
            () => const ExercisesView(),
        transition: Transition.rightToLeftWithFade,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to navigate to exercises. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void _navigateToIngredients(BuildContext context) async {
    HapticFeedback.selectionClick();

    try {
      final mealController = Get.find<MealController>();
      if (!mealController.isLoading.value) {
        mealController.fetchIngredients();
      }

      await Get.to<void>(
            () => const IngredientsView(),
        transition: Transition.rightToLeftWithFade,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to navigate to ingredients. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Widget _buildTabletCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
    double height = 100,
    bool isSquare = false,
  }) {
    final colorScheme = context.theme.colorScheme;
    final containerColor = colorScheme.surfaceContainerLowest;
    final iconColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: containerColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: isSquare
            ? AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildSquareCardContent(
                context, icon, title, subtitle, iconColor, textColor),
          ),
        )
            : SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildWideCardContent(
                context, icon, title, subtitle, iconColor, textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCardContent(BuildContext context, IconData icon,
      String title, String subtitle, Color iconColor, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        AppText.semiBold(
          title,
          color: textColor,
          size: 18,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Flexible(
          child: AppText(
            subtitle,
            color: textColor.withOpacity(0.7),
            size: 16,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWideCardContent(BuildContext context, IconData icon,
      String title, String subtitle, Color iconColor, Color textColor) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: context.theme.colorScheme.onSecondary,
            size: 28,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.semiBold(
                title,
                color: textColor,
                size: 18,
              ),
              const SizedBox(height: 6),
              AppText(
                subtitle,
                color: textColor.withOpacity(0.8),
                size: 16,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: textColor.withOpacity(0.5),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildDeliveryManagementCard(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: context.theme.colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => Get.toNamed<void>(AppRoutes.deliveryPersons),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerLowest
                      .withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: context.theme.colorScheme.onSurface,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.semiBold(
                      'Delivery Management',
                      color: context.theme.colorScheme.onSurface,
                      size: 18,
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      'Manage delivery personnel and track deliveries',
                      color: context.theme.colorScheme.onSurface
                          .withOpacity(0.8),
                      size: 14,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: context.theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MD3Card extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? assetImagePath;
  final List<Color> gradientColors;
  final IconData icon;

  const _MD3Card({
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.assetImagePath,
    required this.gradientColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TabletHome._cardHeight,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TabletHome._cardBorderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TabletHome._cardBorderRadius),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: assetImagePath != null
                    ? Image.asset(
                  assetImagePath!,
                  fit: BoxFit.cover,
                )
                    : (imageUrl != null
                    ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gradientColors[0],
                            gradientColors[1],
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gradientColors[0],
                            gradientColors[1],
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                )
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                )),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top section with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme
                                  .surfaceContainerLowest.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.theme.colorScheme
                                    .surfaceContainerLowest.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 26,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                subtitle,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
