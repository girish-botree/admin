import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/responsive.dart';
import '../meal_controller.dart';
import '../ingredients/ingredients_view.dart';
import '../receipe/receipes_view.dart';
import 'meal_statistics_widget.dart';

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
      title: AppText.semiBold(
        'Meal Management',
        color: context.theme.colorScheme.onSurface,
        size: Responsive.responsiveTextSize(
            context, mobile: 22, tablet: 24, web: 20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() =>
              IconButton(
                onPressed: controller.isLoading.value ? null : _handleRefresh,
                icon: controller.isLoading.value
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.theme.colorScheme.primary,
                    ),
                  ),
                )
                    : Icon(
                  Icons.refresh_rounded,
                  color: context.theme.colorScheme.primary,
                ),
            tooltip: 'Refresh',
          )),
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
            _buildStatisticsSection(context),
            const SizedBox(height: _cardSpacing),
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
          colors: _CardColors.recipes,
        ),
        const SizedBox(height: _cardSpacing),
        _EnhancedCard(
          onTap: () => _navigateToIngredients(context),
          svgAsset: Assets.icons.icIngredient,
          title: 'Ingredients',
          subtitle: 'Track & organize your food ingredients',
          colors: _CardColors.ingredients,
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(_containerBorderRadius),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsHeader(context),
          const SizedBox(height: 16),
          const MealStatisticsWidget(),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.analytics_rounded,
            color: context.theme.colorScheme.primary,
            size: Responsive.responsiveValue(
                context, mobile: 24.0, tablet: 26.0, web: 20.0),
          ),
        ),
        const SizedBox(width: 12),
        AppText.semiBold(
          'Statistics',
          color: context.theme.colorScheme.onSurface,
          size: Responsive.responsiveTextSize(
              context, mobile: 22, tablet: 24, web: 18),
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
                    color: colors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _buildDecorationCircles(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorationCircles() {
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
              color: Colors.white.withOpacity(0.1),
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
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          _buildIconContainer(),
          const SizedBox(width: 20),
          _buildTextContent(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: svgAsset.svg(
        width: 32,
        height: 32,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            return AppText.semiBold(
              title,
              color: Colors.white,
              size: Responsive.responsiveTextSize(
                  context, mobile: 24, tablet: 28, web: 22),
            );
          }),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            return AppText(
              subtitle,
              color: Colors.white.withOpacity(0.9),
              size: Responsive.responsiveTextSize(
                  context, mobile: 16, tablet: 18, web: 14),
            );
          }),
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

  static const recipes = _CardColors(
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF8B5CF6),
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const ingredients = _CardColors(
    primary: Color(0xFF10B981),
    secondary: Color(0xFF059669),
    gradient: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
