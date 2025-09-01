import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipeShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int Function(double) getCrossAxisCount;

  const RecipeShimmerGrid({
    super.key,
    this.itemCount = 12,
    required this.getCrossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = getCrossAxisCount(
                  constraints.crossAxisExtent);

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.0, // Square format
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return const ShimmerRecipeCard();
                  },
                  childCount: itemCount,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShimmerRecipeCard extends StatefulWidget {
  const ShimmerRecipeCard({super.key});

  @override
  ShimmerRecipeCardState createState() => ShimmerRecipeCardState();
}

class ShimmerRecipeCardState extends State<ShimmerRecipeCard>
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
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _buildShimmerContainer(
                      double.infinity, double.infinity, borderRadius: 18),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3)
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerContainer(120, 16, borderRadius: 8),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildShimmerContainer(60, 12, borderRadius: 6),
                          const SizedBox(width: 8),
                          _buildShimmerContainer(40, 12, borderRadius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: _buildShimmerContainer(24, 24, borderRadius: 12),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: _buildShimmerContainer(60, 20, borderRadius: 10),
              ),
            ],
          ),
        );
      },
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