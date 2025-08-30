import 'package:flutter/material.dart';

import '../../../config/app_text.dart';


class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String semanticLabel;
  final String? trend;
  final double? trendPercentage;
  final Color? color;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.semanticLabel,
    this.trend,
    this.trendPercentage,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                if (trendPercentage != null)
                  _buildTrendIndicator(),
              ],
            ),

            const SizedBox(height: 20),

            AppText.bold(
              value,
              size: 36,
              color: const Color(0xFF111827),
              height: 1.0,
            ),

            const SizedBox(height: 6),

            AppText.medium(
              title,
              size: 14,
              color: const Color(0xFF6B7280),
              height: 1.2,
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final bool isPositive = trendPercentage! > 0;
    final Color trendColor = isPositive ? const Color(0xFF10B981) : const Color(
        0xFFEF4444);
    final IconData trendIcon = isPositive ? Icons.trending_up_rounded : Icons
        .trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 14,
            color: trendColor,
          ),
          const SizedBox(width: 4),
          AppText(
            '${trendPercentage!.abs().toStringAsFixed(1)}%',
            size: 12,
            color: trendColor,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}