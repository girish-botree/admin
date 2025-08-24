import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IngredientShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int Function(double) getCrossAxisCount;

  const IngredientShimmerGrid({
    super.key,
    this.itemCount = 12,
    required this.getCrossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = getCrossAxisCount(constraints.maxWidth);

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0, // Square format
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return const ShimmerIngredientCard();
            },
          );
        },
      ),
    );
  }
}

class ShimmerIngredientCard extends StatefulWidget {
  const ShimmerIngredientCard({super.key});

  @override
  ShimmerIngredientCardState createState() => ShimmerIngredientCardState();
}

class ShimmerIngredientCardState extends State<ShimmerIngredientCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: context.theme.colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildShimmerContainer(100, 16, borderRadius: 8),
                    ),
                    const SizedBox(width: 8),
                    _buildShimmerContainer(24, 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 8),
                _buildShimmerContainer(120, 14, borderRadius: 6),
                const SizedBox(height: 6),
                Divider(height: 10,
                    color: context.theme.colorScheme.outline.withValues(
                        alpha: 0.3)),
                const SizedBox(height: 4),
                _buildShimmerNutrientChips(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerNutrientChips() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerChip()),
            const SizedBox(width: 4),
            Expanded(child: _buildShimmerChip()),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(child: _buildShimmerChip()),
            const SizedBox(width: 4),
            Expanded(child: _buildShimmerChip()),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primaryContainer.withValues(
            alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShimmerContainer(20, 8, borderRadius: 4),
          const SizedBox(height: 2),
          _buildShimmerContainer(30, 10, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height,
      {double borderRadius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnimation.value - 1, 0),
          end: Alignment(_shimmerAnimation.value, 0),
          colors: const [
            Color(0xFFEBEBF4),
            Color(0xFFF4F4F4),
            Color(0xFFEBEBF4),
          ],
          stops: const [0.1, 0.3, 0.4],
        ),
      ),
    );
  }
}