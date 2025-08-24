import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IngredientCard extends StatelessWidget {
  final dynamic ingredient;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.green,
    ];
    final color = colors[ingredient['name']
        .toString()
        .length % colors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (ingredient['name']
          .toString()
          .length % 3) * 30),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: context.theme.colorScheme.shadow.withValues(
                        alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact header
                    Container(
                      height: 50, // Reduced height for square format
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.8),
                            color.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Simple background pattern
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Compact icon
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getIngredientIcon(
                                    ingredient['category'] as String?),
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Compact menu
                          Positioned(
                            right: 6,
                            top: 6,
                            child: IngredientPopupMenu(
                              ingredient: ingredient,
                              onEdit: onEdit,
                              onDelete: onDelete,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Compact content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Name - single line
                            Text(
                              (ingredient['name'] as String?) ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16, // Reduced font size
                                fontWeight: FontWeight.w700,
                                color: context.theme.colorScheme.onSurface,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4), // Reduced spacing

                            // Category badge - smaller
                            if ((ingredient['category'] as String?)
                                ?.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ingredient['category'] as String,
                                  style: TextStyle(
                                    fontSize: 7, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            // Compact nutrition - horizontal layout
                            CompactNutrientDisplay(
                                ingredient: ingredient, color: color),
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
      },
    );
  }

  IconData _getIngredientIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'vegetable':
      case 'vegetables':
        return Icons.local_florist_rounded;
      case 'fruit':
      case 'fruits':
        return Icons.apple_rounded;
      case 'meat':
      case 'protein':
        return Icons.set_meal_rounded;
      case 'dairy':
        return Icons.emoji_food_beverage_rounded;
      case 'grain':
      case 'grains':
        return Icons.grain_rounded;
      case 'spice':
      case 'spices':
        return Icons.scatter_plot_rounded;
      case 'oil':
      case 'oils':
        return Icons.opacity_rounded;
      case 'nut':
      case 'nuts':
        return Icons.circle_rounded;
      case 'seafood':
      case 'fish':
        return Icons.set_meal_outlined;
      default:
        return Icons.eco_rounded;
    }
  }
}

class IngredientPopupMenu extends StatelessWidget {
  final dynamic ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const IngredientPopupMenu({
    super.key,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert_rounded,
          size: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        color: context.theme.colorScheme.surface,
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
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('Edit', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete',
                    style: TextStyle(fontSize: 13, color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompactNutrientDisplay extends StatelessWidget {
  final dynamic ingredient;
  final Color color;

  const CompactNutrientDisplay({
    super.key,
    required this.ingredient,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6), // Reduced padding
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer.withValues(
            alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CompactNutrientItem(
            icon: Icons.local_fire_department_rounded,
            value: '${((ingredient['calories'] as num?) ?? 0).toInt()}',
            color: Colors.orange,
          ),
          CompactNutrientItem(
            icon: Icons.fitness_center_rounded,
            value: '${((ingredient['protein'] as num?) ?? 0).toInt()}g',
            color: Colors.red,
          ),
          CompactNutrientItem(
            icon: Icons.grain_rounded,
            value: '${((ingredient['carbohydrates'] as num?) ?? 0).toInt()}g',
            color: Colors.blue,
          ),
          CompactNutrientItem(
            icon: Icons.opacity_rounded,
            value: '${((ingredient['fat'] as num?) ?? 0).toInt()}g',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class CompactNutrientItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const CompactNutrientItem({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 9, // Reduced font size
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}