import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class MealPlanLoading extends StatelessWidget {
  const MealPlanLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar skeleton
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const MealPlanCardSkeleton(),
          ),
          const SizedBox(height: 24),
          // Date title skeleton
          const MealPlanCardSkeleton(),
          const SizedBox(height: 16),
          // Meal sections skeletons
          const MealSectionSkeleton(),
          const MealSectionSkeleton(),
          const MealSectionSkeleton(),
        ],
      ),
    );
  }
}

class MealSectionSkeleton extends StatelessWidget {
  const MealSectionSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MealPlanCardSkeleton(),
              const SizedBox(width: 8),
              Expanded(child: const MealPlanCardSkeleton()),
            ],
          ),
          const SizedBox(height: 12),
          const MealPlanCardSkeleton(),
          const MealPlanCardSkeleton(),
        ],
      ),
    );
  }
}

class MealPlanCardSkeleton extends StatefulWidget {
  const MealPlanCardSkeleton({Key? key}) : super(key: key);

  @override
  State<MealPlanCardSkeleton> createState() => _MealPlanCardSkeletonState();
}

class _MealPlanCardSkeletonState extends State<MealPlanCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 16,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColor.shimmerBase.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}