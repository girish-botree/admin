import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/loading_widgets.dart';
import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';
import '../../../routes/app_routes.dart';

class MobileMeal extends GetView<MealController> {
  const MobileMeal({super.key});

  // Constants
  static const double _horizontalPadding = 20.0;
  static const double _verticalPadding = 16.0;
  static const double _cardHeight = 160.0;
  static const double _cardSpacing = 20.0;
  static const double _sectionSpacing = 32.0;
  static const double _cardBorderRadius = 24.0;
  static const double _containerBorderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.colorScheme.surface,
        appBar: _buildMobileAppBar(context),
        body: _buildMobileBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: AppText.bold(
        'Meal Management',
        color: context.theme.colorScheme.onSurface,
        size: 20,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      actions: [
        Obx(() =>
            IconButton(
              onPressed: controller.isLoading.value ? null : _handleRefresh,
              icon: controller.isLoading.value
                  ? StandardLoadingWidget.circular(
                      size: 20,
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      color: context.theme.colorScheme.onSurface,
                    ),
              tooltip: 'Refresh',
            )),
        IconButton(
          onPressed: _navigateToStatistics,
          icon: Icon(
            Icons.bar_chart,
            color: context.theme.colorScheme.onSurface,
          ),
          tooltip: 'Statistics',
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Quick Actions'),
            const SizedBox(height: 16),
            _buildActionCards(context),
            const SizedBox(height: _sectionSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return AppText.semiBold(
      title,
      color: context.theme.colorScheme.onSurface,
      size: Responsive.responsiveTextSize(
          context, mobile: 24, tablet: 26, web: 20),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _EnhancedCard(
          onTap: () => _navigateToRecipes(context),
          svgAsset: Assets.icons.icRecipe,
          title: 'Recipes',
          subtitle: 'Discover & manage your cooking recipes',
          colors: _CardColors.recipes(context),
        ),
        const SizedBox(height: _cardSpacing),
        _EnhancedCard(
          onTap: () => _navigateToIngredients(context),
          svgAsset: Assets.icons.icIngredient,
          title: 'Ingredients',
          subtitle: 'Track & organize your food ingredients',
          colors: _CardColors.ingredients(context),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    try {
      HapticFeedback.lightImpact();
      await Future.wait([
        controller.fetchRecipes(),
        controller.fetchIngredients(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void _navigateToRecipes(BuildContext context) async {
    HapticFeedback.selectionClick();

    if (!controller.isLoading.value) {
      controller.fetchRecipes();
    }

    await Get.to<void>(
          () => const ReceipesView(),
      transition: Transition.rightToLeftWithFade,
    );
  }

  void _navigateToIngredients(BuildContext context) async {
    HapticFeedback.selectionClick();

    if (!controller.isLoading.value) {
      controller.fetchIngredients();
    }

    await Get.to<void>(
          () => const IngredientsView(),
      transition: Transition.rightToLeftWithFade,
    );
  }

  void _navigateToStatistics() async {
    HapticFeedback.selectionClick();

    await Get.toNamed(AppRoutes.mealStatistics);
  }
}

class _EnhancedCard extends StatelessWidget {
  final VoidCallback onTap;
  final SvgGenImage svgAsset;
  final String title;
  final String subtitle;
  final _CardColors colors;

  const _EnhancedCard({
    required this.onTap,
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $subtitle',
      button: true,
      child: Container(
        height: MobileMeal._cardHeight,
        child: Material(
          borderRadius: BorderRadius.circular(MobileMeal._cardBorderRadius),
          elevation: 0,
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(MobileMeal._cardBorderRadius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    MobileMeal._cardBorderRadius),
                gradient: colors.gradient,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Builder(
                      builder: (context) => _buildDecorationCircles(context)),
                  _buildContent(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorationCircles(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.theme.colorScheme.surfaceContainerLowest
                  .withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -20,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.theme.colorScheme.surfaceContainerLowest
                  .withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          _buildIconContainer(context),
          const SizedBox(width: 20),
          _buildTextContent(context),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest.withValues(
            alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: svgAsset.svg(
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(
          context.theme.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText.semiBold(
            title,
            color: context.theme.colorScheme.onSurface,
            size: Responsive.responsiveTextSize(
                context, mobile: 24, tablet: 28, web: 22),
          ),
          const SizedBox(height: 8),
          AppText(
            subtitle,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.9),
            size: Responsive.responsiveTextSize(
                context, mobile: 16, tablet: 18, web: 14),
          ),
        ],
      ),
    );
  }
}

class _CardColors {
  final Color primary;
  final Color secondary;
  final Gradient gradient;

  const _CardColors({
    required this.primary,
    required this.secondary,
    required this.gradient,
  });

  /// Recipes card color set, uses primary/secondary theme colors.
  factory _CardColors.recipes(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary.withValues(alpha: 0.7);
    final secondary = theme.colorScheme.secondary.withValues(alpha: 0.6);
    return _CardColors(
      primary: primary,
      secondary: secondary,
      gradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Ingredients card color set, uses tertiary surface colors or similar.
  factory _CardColors.ingredients(BuildContext context) {
    final theme = Theme.of(context);
    // Fallbacks if theme extensions missing
    final primary = theme.colorScheme.tertiary.withValues(alpha: 0.7);
    final secondary = theme.colorScheme.tertiaryContainer.withValues(
        alpha: 0.8);
    return _CardColors(
      primary: primary,
      secondary: secondary,
      gradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
