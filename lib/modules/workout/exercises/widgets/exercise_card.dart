import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExerciseImageCard extends StatelessWidget {
  const ExerciseImageCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  final dynamic exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Full-size image background
            Positioned.fill(
              child: _buildExerciseImage(theme),
            ),
            // Gradient overlay
            Positioned.fill(
              child: _buildGradientOverlay(),
            ),
            // Exercise name on top of the gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildExerciseName(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImage(ThemeData theme) {
    final imageUrl = exercise['imageUrl'] as String?;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(theme),
      );
    }

    return _buildPlaceholder(theme);
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 0.6, 0.7, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildExerciseName(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Text(
        (exercise['name'] as String?) ?? 'Unknown Exercise',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black38,
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 40,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final dynamic exercise;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and menu
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (exercise['name'] as String?) ?? 'Unknown Exercise',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildMenuButton(context),
                ],
              ),
              const SizedBox(height: 12),

              // Exercise image or placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildExerciseImage(),
                ),
              ),
              const SizedBox(height: 12),

              // Exercise details
              _buildDetailRow(
                icon: Icons.fitness_center_rounded,
                label: 'Muscle Group',
                value: (exercise['muscleGroup'] as String?) ?? 'Unknown',
                theme: theme,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.sports_gymnastics_rounded,
                label: 'Equipment',
                value: (exercise['equipment'] as String?) ?? 'Unknown',
                theme: theme,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.signal_cellular_alt,
                label: 'Difficulty',
                value: _getDifficultyText(exercise['difficulty']),
                theme: theme,
                valueColor: _getDifficultyColor(exercise['difficulty'], theme),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                (exercise['description'] as String?) ??
                    'No description available',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseImage() {
    final imageUrl = exercise['imageUrl'] as String?;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ??
                  theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 16,
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      color: context.theme.colorScheme.surface,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) =>
      [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  size: 14,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(dynamic difficulty) {
    final level = (difficulty as num?)?.toInt() ?? 1;
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Moderate';
      case 4:
        return 'Hard';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  Color _getDifficultyColor(dynamic difficulty, ThemeData theme) {
    final level = (difficulty as num?)?.toInt() ?? 1;
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }
}