import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_config.dart' show AppText;
import '../../../routes/app_routes.dart';
import '../../../widgets/settings_widget.dart';
import '../../../utils/image_utils.dart';
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
            context.theme.colorScheme.surfaceContainerLowest,
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.7),
            context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                flex: 1,
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

              const SizedBox(width: 16),

              // Reports Card
              Expanded(
                flex: 1,
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
                    imageUrl: '',
                    assetImagePath: 'assets/images/recipe.jpg',
                    gradientColors: [
                      context.theme.colorScheme.primary,
                      context.theme.colorScheme.primary.withOpacity(0.7),
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
                    imageUrl: '',
                    assetImagePath: 'assets/images/ingredients.jpg',
                    gradientColors: [
                      context.theme.colorScheme.tertiary,
                      context.theme.colorScheme.tertiary.withOpacity(0.7),
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
                    imageUrl: '',
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
                width: currentIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: currentIndex == index
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.primary.withAlpha(77),
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

  Widget _buildDeliveryManagementCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: context.theme.colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => Get.toNamed<void>(AppRoutes.deliveryPersons),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: context.theme.colorScheme.onSurface,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                      color: context.theme.colorScheme.onSurface
                          .withOpacity(0.8),
                      size: 14,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: context.theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCard({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPrimary = false,
  }) {
    final colorScheme = context.theme.colorScheme;
    final containerColor = isPrimary
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHigh;
    final iconColor = isPrimary
        ? colorScheme.primary
        : colorScheme.primary;
    final textColor = colorScheme.onSurface;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: containerColor,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1, // Make it perfectly square
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                AppText.semiBold(
                  title,
                  color: textColor,
                  size: 16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: AppText(
                    subtitle,
                    color: textColor.withOpacity(0.7),
                    size: 13,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
  final String? assetImagePath;
  final List<Color> gradientColors;
  final IconData icon;

  const _MD3Card({
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.assetImagePath,
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
                child: assetImagePath != null
                    ? Image.asset(
                  assetImagePath!,
                  fit: BoxFit.cover,
                )
                    : (imageUrl.isNotEmpty
                    ? SafeImageLoader.loadImage(
                  imageUrl: imageUrl,
                  placeholderWidget: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  ),
                  memCacheWidth: 800,
                  maxHeightDiskCache: 1000,
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
                              color: context.theme.colorScheme
                                  .surfaceContainerLowest.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: context.theme.colorScheme
                                    .surfaceContainerLowest.withOpacity(0.3),
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
                            color: Colors.white.withOpacity(0.8),
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
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                subtitle,
                                style: context.textTheme.bodyMedium?.copyWith(
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
