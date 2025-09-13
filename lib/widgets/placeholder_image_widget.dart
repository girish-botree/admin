import 'package:flutter/material.dart';

class PlaceholderImageWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final IconData? icon;
  final String? text;
  final BoxFit fit;

  const PlaceholderImageWidget({
    super.key,
    this.width,
    this.height,
    this.gradientColors,
    this.icon,
    this.text,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColors = gradientColors ?? [
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
    ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: defaultColors,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7),
              ),
              const SizedBox(height: 8),
            ],
            if (text != null)
              Text(
                text!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}