import 'package:admin/config/app_config.dart';
import 'package:admin/modules/meal/ingredients/ingredients_view.dart';
import 'package:admin/modules/meal/meal_controller.dart';
import 'package:admin/modules/meal/receipe/receipes_view.dart';

class MealView extends StatelessWidget {
  const MealView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: AppText.bold(
            'Meal Management', 
            color: context.theme.colorScheme.onSurface, 
            size: 22,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          // leading: IconButton(
          //   onPressed: () {
          //     Get.back();
          //   },
          //   icon: Icon(
          //     Icons.arrow_back_ios,
          //     color: context.theme.colorScheme.onSurface,
          //   ),
          // ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Check if we're in landscape mode or on a larger screen
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isTabletOrLarger = constraints.maxWidth > 600;
            
            // For landscape or tablet, use a Row layout
            if (isLandscape || isTabletOrLarger) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: AppText('Manage your meals and recipes', 
                      color: context.theme.colorScheme.onSurface,
                      size: isTabletOrLarger ? 26 : 22,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRecipeCard(context, isTabletOrLarger),
                        ),
                        Expanded(
                          child: _buildIngredientCard(context, isTabletOrLarger),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } 
            // For portrait on smaller screens, use a Column layout
            else {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: AppText('Manage your meals and recipes', 
                      color: context.theme.colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    flex: 1, 
                    child: _buildRecipeCard(context, isTabletOrLarger),
                  ),
                  Expanded(
                    flex: 1, 
                    child: _buildIngredientCard(context, isTabletOrLarger),
                  ),
                ],
              );
            }
          },
        )
      ),
    );
  }
  
  // Helper method to build the recipe card
  Widget _buildRecipeCard(BuildContext context, bool isTabletOrLarger) {
    return InkWell(
      onTap: () {
        final controller = Get.put(MealController());
        if (!controller.isLoading.value) {
          controller.fetchRecipes(); // Refresh recipes before navigating
        }
        Get.to(()=>ReceipesView(),transition: Transition.rightToLeftWithFade);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blue.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, color: context.theme.colorScheme.primary, size: isTabletOrLarger ? 64 : 48),
                  const SizedBox(height: 12),
                  AppText('Recipes', color: context.theme.colorScheme.primary, size: isTabletOrLarger ? 28 : 24),
                  const SizedBox(height: 8),
                  AppText('Manage your cooking recipes', color: context.theme.colorScheme.onSurface, size: isTabletOrLarger ? 16 : 14),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
  
  // Helper method to build the ingredient card
  Widget _buildIngredientCard(BuildContext context, bool isTabletOrLarger) {
    return GestureDetector(
      onTap: () {
        final controller = Get.put(MealController());
        if (!controller.isLoading.value) {
          controller.fetchIngredients(); // Refresh ingredients before navigating
        }
        Get.to(()=>IngredientsView(),transition: Transition.rightToLeftWithFade);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.green.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket, color: context.theme.colorScheme.primary, size: isTabletOrLarger ? 64 : 48),
                  const SizedBox(height: 12),
                  AppText('Ingredients', color: context.theme.colorScheme.primary, size: isTabletOrLarger ? 28 : 24),
                  const SizedBox(height: 8),
                  AppText('Manage your food ingredients', color: context.theme.colorScheme.onSurface, size: isTabletOrLarger ? 16 : 14),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}