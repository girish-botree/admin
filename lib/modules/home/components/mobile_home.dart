import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../config/app_config.dart' show AppText;
import '../../../routes/app_routes.dart';
import '../../../widgets/settings_widget.dart';
import '../../admins/create_admins/create_admin_view.dart';
import '../../meal/ingredients/ingredients_view.dart';
import '../../meal/receipe/receipes_view.dart';
import '../../meal/meal_controller.dart';
import '../../workout/exercises/screens/exercises_view.dart';
import '../../workout/exercises/exercise_controller.dart';
import '../../workout/exercises/exercise_binding.dart';
import '../home_controller.dart';

class MobileHome extends GetView<HomeController> {
  const MobileHome({super.key});

  // Material Design 3 Constants
  static const double _cardHeight = 200.0;
  static const double _cardSpacing = 16.0;
  static const double _sectionSpacing = 32.0;
  static const double _cardBorderRadius = 28.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.3),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.2),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildMobileAppBar(context),
        body: _buildMobileBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: SettingsWidget(),
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Management Section
          const SizedBox(height: 24),
          AppText.semiBold(
            'Management',
            size: 20,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          // Delivery Management Card - Full Width
          _buildDeliveryManagementCard(context),

          const SizedBox(height: 16),

          // Admin and Reports Cards in a Row
          Row(
            children: [
              // Admin Management Card
              Expanded(
                child: _buildSquareCard(
                  context: context,
                  onTap: () =>
                      AdminBottomSheets.showAdminOptionsBottomSheet(context),
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Management',
                  subtitle: 'Manage system administrators',
                  isPrimary: true,
                ),
              ),

              const SizedBox(width: 12),

              // Reports Card
              Expanded(
                child: _buildSquareCard(
                  context: context,
                  onTap: () => Get.toNamed<void>(AppRoutes.reports),
                  icon: Icons.assessment_outlined,
                  title: 'Reports',
                  subtitle: 'View reports',
                ),
              ),
            ],
          ),

          const SizedBox(height: _sectionSpacing),

          // Quick Actions Section
          AppText.semiBold(
            'Quick Actions',
            size: 20,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 20),
          _buildMealActionCards(context),
          const SizedBox(height: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _MD3Card(
                    onTap: () => _navigateToRecipes(context),
                    title: 'Recipes',
                    subtitle: 'Discover & manage your cooking recipes',
                    imageUrl: 'https://images.unsplash.com/photo-1466637574441-749b8f19452f?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                    gradientColors: [
                      context.theme.colorScheme.primary,
                      context.theme.colorScheme.primaryContainer,
                    ],
                    icon: Icons.restaurant_menu_rounded,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _MD3Card(
                    onTap: () => _navigateToIngredients(context),
                    title: 'Ingredients',
                    subtitle: 'Track & organize your food ingredients',
                    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                    gradientColors: [
                      context.theme.colorScheme.tertiary,
                      context.theme.colorScheme.tertiaryContainer,
                    ],
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _MD3Card(
                    onTap: () => _navigateToExercises(context),
                    title: 'Exercises',
                    subtitle: 'Manage your workout exercises library',
                    imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                    gradientColors: [
                      context.theme.colorScheme.secondary,
                      context.theme.colorScheme.secondaryContainer,
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
                width: currentIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
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

  Widget _buildSquareCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 136,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      borderRadius: 12,
      blur: 20,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
        stops: const [
          0.1,
          1,
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.theme.colorScheme.onSurface.withOpacity(0.7),
          context.theme.colorScheme.onSurface.withOpacity(0.2),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: context.theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 9),
                  AppText.semiBold(
                    title,
                    color: context.theme.colorScheme.onSurface,
                    size: 14,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    subtitle,
                    color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.7),
                    size: 12,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryManagementCard(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      borderRadius: 12,
      blur: 20,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
        stops: const [
          0.1,
          1,
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.theme.colorScheme.onSurface.withOpacity(0.7),
          context.theme.colorScheme.onSurface.withOpacity(0.2),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: context.theme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => Get.toNamed<void>(AppRoutes.deliveryPersons),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText.semiBold(
                        'Delivery Management',
                        color: context.theme.colorScheme.onSurface,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Manage delivery personnel',
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              // Removed add button as requested
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
  final String imageUrl;
  final List<Color> gradientColors;
  final IconData icon;

  const _MD3Card({
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradientColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MobileHome._cardHeight,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MobileHome._cardBorderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MobileHome._cardBorderRadius),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                      fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors.map((c) =>
                              c.withValues(alpha: 0.8)).toList(),
                        ),
                      ),
                    );
                  },
                    )
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors.map((c) =>
                          c.withValues(alpha: 0.8)).toList(),
                    ),
                  ),
                    ),
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
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top section with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: context.textTheme.headlineSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    const Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                subtitle,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shadows: [
                                    const Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black45,
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
