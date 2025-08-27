import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../meal_controller.dart';

class RecipeCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.theme.colorScheme.onSurface.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
                color: context.theme.colorScheme.onSurface.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: _buildPlaceholderImage(context, recipe),
                ),
                // Gradient overlay for better text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Popup menu top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: RecipePopupMenu(
                    recipe: recipe,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ),
                // Dietary badge top left
                Positioned(
                  top: 8,
                  left: 8,
                  child: DietaryBadge(recipe: recipe),
                ),
                // Card content at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Recipe name with proper overflow handling
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            recipe['name']?.toString() ?? 'Unnamed Recipe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Info chips with better spacing and overflow handling
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              if (recipe['cuisine']
                                  ?.toString()
                                  .isNotEmpty == true) ...[
                                RecipeInfoChip(
                                  icon: Icons.public_rounded,
                                  label: recipe['cuisine']?.toString() ?? '',
                                  backgroundColor: context.theme.colorScheme
                                      .onSurface
                                      .withOpacity(0.16),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (recipe['servings'] != null)
                                RecipeInfoChip(
                                  icon: Icons.people_alt_rounded,
                                  label: '${recipe['servings']
                                      .toString()} servings',
                                  backgroundColor: context.theme.colorScheme
                                      .onSurface
                                      .withOpacity(0.14),
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
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, dynamic recipe) {
    final color = Colors.primaries[recipe['name']
        .toString()
        .length % Colors.primaries.length];
    final imageUrl = recipe['imageUrl']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's base64 data
      if (imageUrl.startsWith('data:image/') || _isBase64String(imageUrl)) {
        try {
          // Handle data URL format (data:image/jpeg;base64,...)
          String base64String = imageUrl;
          if (imageUrl.startsWith('data:image/')) {
            base64String = imageUrl.split(',')[1];
          }

          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackImage(context, color);
            },
          );
        } catch (e) {
          return _buildFallbackImage(context, color);
        }
      } else {
        // Handle regular network URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage(context, color);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: color.withValues(alpha: 0.7),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      }
    } else {
      return _buildFallbackImage(context, color);
    }
  }

  Widget _buildFallbackImage(BuildContext context, Color color) {
    return Container(
      color: color.withValues(alpha: 0.7),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  // Helper method to check if a string is base64
  bool _isBase64String(String str) {
    try {
      // Remove any whitespace and check if it's valid base64
      final cleanStr = str.replaceAll(RegExp(r'\s+'), '');
      // Base64 strings should be divisible by 4 in length (with padding)
      if (cleanStr.length % 4 != 0) return false;

      // Try to decode - if it fails, it's not valid base64
      base64Decode(cleanStr);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class RecipePopupMenu extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecipePopupMenu({
    super.key,
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.onSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.surfaceContainerLowest.withOpacity(
              0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.onSurface.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_vert_rounded,
          color: context.theme.colorScheme.surfaceContainerLowest,
          size: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 12,
        color: context.theme.colorScheme.surfaceContainerLowest,
        constraints: const BoxConstraints(
          minWidth: 180,
          maxWidth: 220,
        ),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
              break;
            case 'delete':
              onDelete();
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      Icons.edit_rounded, size: 16,
                      color: context.theme.colorScheme.onSurface),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Recipe',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      Icons.delete_rounded, size: 16,
                      color: context.theme.colorScheme.onSurface),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      'Delete Recipe',
                      style: TextStyle(
                          color: context.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500
                      )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DietaryBadge extends StatelessWidget {
  final dynamic recipe;

  const DietaryBadge({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final dietaryCategory = recipe['dietaryCategory'] as int?;
    if (dietaryCategory == null || dietaryCategory == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 80), // Prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.onSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.surfaceContainerLowest.withOpacity(
              0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.onSurface.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _getDietaryLabel(dietaryCategory),
        style: TextStyle(
          color: context.theme.colorScheme.surfaceContainerLowest,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getDietaryLabel(int category) {
    switch (category) {
      case 0:
        return 'Vegan';
      case 1:
        return 'Vegetarian';
      case 2:
        return 'Eggitarian';
      case 3:
        return 'Non-Veg';
      case 4:
        return 'Other';
      default:
        return 'Regular';
    }
  }
}

class RecipeInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;

  const RecipeInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120), // Prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}