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

class WebHome extends GetView<HomeController> {
  const WebHome({super.key});

  // Material Design 3 Constants for Web
  static const double _cardHeight = 240.0;
  static const double _cardSpacing = 24.0;
  static const double _sectionSpacing = 48.0;
  static const double _cardBorderRadius = 32.0;

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
        appBar: _buildWebAppBar(context),
        body: _buildWebBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Dashboard',
        color: context.theme.colorScheme.onSurface,
        size: 28,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: context.theme.colorScheme.onSurface,
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 24.0),
          child: SettingsWidget(),
        ),
      ],
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Management Section
          const SizedBox(height: 40),
          AppText.semiBold(
            'Management',
            size: 28,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 32),

          // Delivery Management Card - Full Width
          _buildDeliveryManagementCard(context),

          const SizedBox(height: 24),

          // Admin and Reports Cards in a Row
          Row(
            children: [
              // Admin Management Card
              Expanded(
                child: _buildWebCard(
                  context: context,
                  onTap: () => Get.toNamed<void>(AppRoutes.createAdmin),
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Management',
                  subtitle: 'Manage system administrators',
                  isPrimary: true,
                  height: 240, // Make it square by matching height with width
                ),
              ),

              const SizedBox(width: 24),

              // Reports Card
              Expanded(
                child: _buildWebCard(
                  context: context,
                  onTap: () => Get.toNamed<void>(AppRoutes.reports),
                  icon: Icons.assessment_outlined,
                  title: 'Reports',
                  subtitle: 'View and generate delivery reports',
                  height: 240, // Make it square by matching height with width
                ),
              ),
            ],
          ),

          const SizedBox(height: _sectionSpacing),

          // Quick Actions Section
          AppText.semiBold(
            'Quick Actions',
            size: 28,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 32),

          // Meal Action Cards in Row for Web
          Row(
            children: [
              Expanded(
                child: _MD3Card(
                  onTap: () => _navigateToRecipes(context),
                  title: 'Recipes',
                  subtitle: 'Discover & manage your cooking recipes',
                  imageUrl: 'https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=800&h=600&fit=crop&crop=center',
                  gradientColors: [
                    context.theme.colorScheme.primary,
                    context.theme.colorScheme.primaryContainer,
                  ],
                  icon: Icons.restaurant_menu_rounded,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _MD3Card(
                  onTap: () => _navigateToIngredients(context),
                  title: 'Ingredients',
                  subtitle: 'Track & organize your food ingredients',
                  imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=600&fit=crop&crop=center',
                  gradientColors: [
                    context.theme.colorScheme.tertiary,
                    context.theme.colorScheme.tertiaryContainer,
                  ],
                  icon: Icons.inventory_2_rounded,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _MD3Card(
                  onTap: () => _navigateToExercises(context),
                  title: 'Exercises',
                  subtitle: 'Manage your workout exercises library',
                  imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&h=600&fit=crop&crop=center',
                  gradientColors: [
                    context.theme.colorScheme.secondary,
                    context.theme.colorScheme.secondaryContainer,
                  ],
                  icon: Icons.fitness_center_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildWebCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
    double height = 120,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      borderRadius: 20,
      blur: 30,
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: height > 120
                ? _buildSquareCardContent(context, icon, title, subtitle)
                : _buildWideCardContent(context, icon, title, subtitle),
          ),
        ),
      ),
    );
  }

  Widget _buildWideCardContent(BuildContext context, IconData icon,
      String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: context.theme.colorScheme.onSurface,
            size: 32,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.semiBold(
                title,
                color: context.theme.colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(height: 8),
              AppText(
                subtitle,
                color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildSquareCardContent(BuildContext context, IconData icon,
      String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: context.theme.colorScheme.onSurface,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        AppText.semiBold(
          title,
          color: context.theme.colorScheme.onSurface,
          size: 22,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        AppText(
          subtitle,
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 18,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeliveryManagementCard(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      borderRadius: 20,
      blur: 30,
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
          onTap: () => Get.toNamed<void>(AppRoutes.deliveryPersons),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.delivery_dining,
                    color: context.theme.colorScheme.onSurface,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText.semiBold(
                        'Delivery Management',
                        color: context.theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      const SizedBox(height: 10),
                      AppText(
                        'Manage delivery personnel and track deliveries in your system',
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7),
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      AdminBottomSheets.showAdminOptionsBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.add,
                      color: context.theme.colorScheme.surfaceContainerLowest,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
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
      height: WebHome._cardHeight,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WebHome._cardBorderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WebHome._cardBorderRadius),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors.map((c) =>
                              c.withValues(alpha: 0.8)).toList(),
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top section with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: context.textTheme.headlineLarge
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
                            const SizedBox(height: 10),
                            Flexible(
                              child: Text(
                                subtitle,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
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
