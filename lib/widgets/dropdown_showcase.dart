import 'package:flutter/material.dart';
import 'searchable_dropdown.dart';
import 'multi_select_dropdown.dart';
import '../config/dropdown_data.dart';

class DropdownShowcase extends StatefulWidget {
  const DropdownShowcase({super.key});

  @override
  State<DropdownShowcase> createState() => _DropdownShowcaseState();
}

class _DropdownShowcaseState extends State<DropdownShowcase> {
  // Single select values
  dynamic selectedDietaryCategory;
  dynamic selectedBmiCategory;
  dynamic selectedMealCategory;
  dynamic selectedRecipeCategory;
  String? selectedVehicleType;

  // Multi-select values
  List<dynamic> selectedVitamins = [];
  List<dynamic> selectedMinerals = [];
  List<dynamic> selectedPriorities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beautiful Searchable Dropdowns'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .surface,
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildSectionHeader(
              'Single Select Dropdowns',
              'Choose one option from beautiful, searchable lists',
              Icons.arrow_drop_down_circle_outlined,
            ),
            const SizedBox(height: 24),

            // Single select examples
            _buildDropdownCard(
              'Dietary Categories',
              'Select your dietary preferences',
              TypedSearchableDropdown(
                dropdownType: DropdownType.dietaryCategories,
                value: selectedDietaryCategory,
                label: 'Dietary Category',
                hint: 'Select your dietary preference',
                onChanged: (value) =>
                    setState(() => selectedDietaryCategory = value),
              ),
            ),

            _buildDropdownCard(
              'BMI Categories',
              'Choose your BMI range',
              TypedSearchableDropdown(
                dropdownType: DropdownType.bmiCategories,
                value: selectedBmiCategory,
                label: 'BMI Category',
                hint: 'Select your BMI range',
                onChanged: (value) =>
                    setState(() => selectedBmiCategory = value),
              ),
            ),

            _buildDropdownCard(
              'Meal Categories',
              'Pick your meal type preference',
              TypedSearchableDropdown(
                dropdownType: DropdownType.mealCategories,
                value: selectedMealCategory,
                label: 'Meal Category',
                hint: 'Select meal type',
                onChanged: (value) =>
                    setState(() => selectedMealCategory = value),
              ),
            ),

            _buildDropdownCard(
              'Recipe Categories',
              'Choose the type of recipe',
              TypedSearchableDropdown(
                dropdownType: DropdownType.recipeCategories,
                value: selectedRecipeCategory,
                label: 'Recipe Category',
                hint: 'Select recipe type',
                onChanged: (value) =>
                    setState(() => selectedRecipeCategory = value),
              ),
            ),

            _buildDropdownCard(
              'Custom Vehicle Types',
              'Example of custom dropdown items',
              SearchableDropdown<String>(
                items: _getVehicleItems(),
                value: selectedVehicleType,
                label: 'Vehicle Type',
                hint: 'Select your vehicle',
                onChanged: (value) =>
                    setState(() => selectedVehicleType = value),
              ),
            ),

            const SizedBox(height: 40),

            // Multi-select header
            _buildSectionHeader(
              'Multi Select Dropdowns',
              'Choose multiple options with chips and search',
              Icons.checklist_rounded,
            ),
            const SizedBox(height: 24),

            // Multi-select examples
            _buildDropdownCard(
              'Vitamins Selection',
              'Select multiple vitamins for your health plan',
              TypedMultiSelectDropdown(
                dropdownType: DropdownType.vitamins,
                selectedValues: selectedVitamins,
                label: 'Vitamins',
                hint: 'Select vitamins',
                maxSelections: 5,
                onChanged: (values) =>
                    setState(() => selectedVitamins = values),
              ),
            ),

            _buildDropdownCard(
              'Minerals Selection',
              'Choose essential minerals',
              TypedMultiSelectDropdown(
                dropdownType: DropdownType.minerals,
                selectedValues: selectedMinerals,
                label: 'Minerals',
                hint: 'Select minerals',
                onChanged: (values) =>
                    setState(() => selectedMinerals = values),
              ),
            ),

            _buildDropdownCard(
              'Priority Levels',
              'Select multiple priority levels',
              TypedMultiSelectDropdown(
                dropdownType: DropdownType.priorityLevels,
                selectedValues: selectedPriorities,
                label: 'Priority Levels',
                hint: 'Select priorities',
                maxSelections: 3,
                onChanged: (values) =>
                    setState(() => selectedPriorities = values),
              ),
            ),

            const SizedBox(height: 40),

            // Features section
            _buildSectionHeader(
              'Key Features',
              'What makes these dropdowns special',
              Icons.star_rounded,
            ),
            const SizedBox(height: 16),

            _buildFeaturesList(),

            const SizedBox(height: 40),

            // Summary section
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownCard(String title, String description, Widget dropdown) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme
              .of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme
                .of(context)
                .shadowColor
                .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            dropdown,
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.search,
        'title': 'Real-time Search',
        'description': 'Instant filtering as you type with fuzzy matching',
      },
      {
        'icon': Icons.palette,
        'title': 'Beautiful Design',
        'description': 'Modern UI with smooth animations and Material Design 3',
      },
      {
        'icon': Icons.data_object,
        'title': 'Centralized Data',
        'description': 'All dropdown values managed in one place for easy updates',
      },
      {
        'icon': Icons.touch_app,
        'title': 'Great UX',
        'description': 'Haptic feedback, keyboard navigation, and accessibility support',
      },
      {
        'icon': Icons.checklist,
        'title': 'Multi-select',
        'description': 'Select multiple items with visual chips and selection limits',
      },
      {
        'icon': Icons.smartphone,
        'title': 'Responsive',
        'description': 'Works perfectly on all screen sizes and orientations',
      },
    ];

    return Column(
      children: features.map((feature) =>
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme
                    .of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['description'] as String,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
    );
  }

  Widget _buildSummaryCard() {
    final selectedCount = [
      selectedDietaryCategory,
      selectedBmiCategory,
      selectedMealCategory,
      selectedRecipeCategory,
      selectedVehicleType,
    ]
        .where((item) => item != null)
        .length;

    final multiSelectCount = selectedVitamins.length + selectedMinerals.length +
        selectedPriorities.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme
                .of(context)
                .colorScheme
                .primaryContainer,
            Theme
                .of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme
                .of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: Theme
                .of(context)
                .colorScheme
                .onPrimaryContainer,
          ),
          const SizedBox(height: 16),
          Text(
            'Selection Summary',
            style: Theme
                .of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme
                  .of(context)
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have selected $selectedCount single items and $multiSelectCount multi-select items',
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '🎉 Beautiful, functional, and user-friendly dropdowns! 🎉',
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<DropdownItem> _getVehicleItems() {
    return [
      DropdownItem(
        value: 'bicycle',
        label: 'Bicycle',
        description: 'Eco-friendly and healthy option',
        icon: '🚲',
      ),
      DropdownItem(
        value: 'motorcycle',
        label: 'Motorcycle',
        description: 'Fast and fuel-efficient',
        icon: '🏍️',
      ),
      DropdownItem(
        value: 'car',
        label: 'Car',
        description: 'Comfortable and versatile',
        icon: '🚗',
      ),
      DropdownItem(
        value: 'truck',
        label: 'Truck',
        description: 'Heavy-duty transportation',
        icon: '🚛',
      ),
      DropdownItem(
        value: 'van',
        label: 'Van',
        description: 'Spacious and practical',
        icon: '🚐',
      ),
    ];
  }
}