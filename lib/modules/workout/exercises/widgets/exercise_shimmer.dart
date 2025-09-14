import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../meal/shared/widgets/common_widgets.dart';

class ExerciseShimmerGrid extends StatelessWidget {
  const ExerciseShimmerGrid({
    super.key,
    required this.getCrossAxisCount,
  });

  final int Function(double) getCrossAxisCount;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      getCrossAxisCount: getCrossAxisCount,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(12, (index) => const ExerciseShimmerCard()),
    );
  }
}

class ExerciseShimmerCard extends StatelessWidget {
  const ExerciseShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainer,
        highlightColor: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and menu
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Exercise image placeholder
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),

              // Exercise details shimmer - limit to just one row to save space
              _buildShimmerDetailRow(),
              const SizedBox(height: 8),

              // Shorter container for description
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerDetailRow() {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}