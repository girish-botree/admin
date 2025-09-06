import 'dart:ui';
import 'package:admin/config/app_config.dart';
import 'package:admin/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'delivery_person_controller.dart';
import '../../../widgets/centered_dropdown.dart';
import 'delivery_person_model.dart';
import '../../meal/shared/widgets/common_widgets.dart';

class DeliveryPersonView extends GetView<DeliveryPersonController> {
  const DeliveryPersonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: AppText.semiBold(
          'Delivery Management',
          color: context.theme.colorScheme.onSurface,
          size: 20,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.theme.colorScheme.onSurface,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.fetchDeliveryAgents(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildDeliveryPersonsView(context),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _showAddPersonDialog(context),
      //   icon: const Icon(Icons.add),
      //   label: const Text('Add'),
      //   backgroundColor: context.theme.colorScheme.primary,
      //   foregroundColor: context.theme.colorScheme.onPrimary,
      // ),
    );
  }

  Widget _buildDeliveryPersonsView(BuildContext context) {
    return Column(
      children: [
        // Search Bar with modern design
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ModernSearchBar(
            controller: controller.searchController,
            hintText: 'Search delivery persons...',
            onChanged: (value) => controller.searchDeliveryPersons(value),
            onClear: () {
              controller.searchController.clear();
              controller.searchDeliveryPersons('');
            },
          ),
        ),

        // Delivery Persons List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Use delivery agents instead of delivery persons
            final itemsToShow = controller.isShowingAgents.value
                ? controller.filteredDeliveryAgents
                : controller.filteredDeliveryPersons;

            if (itemsToShow.isEmpty) {
              return _buildEmptyState(
                context,
                Icons.person_outline,
                'No delivery agents found',
                'Delivery agents will appear here when registered',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itemsToShow.length,
              itemBuilder: (context, index) {
                if (controller.isShowingAgents.value) {
                  final agent = controller.filteredDeliveryAgents[index];
                  return _buildExpandableAgentCard(context, agent, index);
                } else {
                  final person = controller.filteredDeliveryPersons[index];
                  return _buildExpandablePersonCard(context, person, index);
                }
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title,
      String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              icon,
              size: 48,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandablePersonCard(BuildContext context, DeliveryPerson person,
      int index) {
    return GetBuilder<DeliveryPersonController>(
      id: 'person_$index',
      builder: (controller) {
        final isExpanded = controller.expandedPersonCards.contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.togglePersonCardExpansion(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Always visible header
                    Row(
                      children: [
                        // Vehicle icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.theme.colorScheme.onSurface
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            _getVehicleIcon(person.vehicleType),
                            color: context.theme.colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Vehicle number (main identifier)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person.vehicleNumber,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${person.vehicleType} • ${person.firstName}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action menu
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: context.theme.colorScheme.onSurface,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditDialog(context, person);
                                break;
                              case 'delete':
                                controller.showDeleteConfirmation(person);
                                break;
                            }
                          },
                          itemBuilder: (context) =>
                          [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 20,
                                      color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Expand/Collapse icon
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.expand_more,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    // Expandable content
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildPersonExpandedContent(context, person),
                        ],
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
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

  Widget _buildExpandableAgentCard(BuildContext context, DeliveryAgent agent,
      int index) {
    return GetBuilder<DeliveryPersonController>(
      id: 'agent_$index',
      builder: (controller) {
        final isExpanded = controller.expandedAgentCards.contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: context.theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.toggleAgentCardExpansion(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Always visible header
                    Row(
                      children: [
                        // Vehicle icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.theme.colorScheme.onSurface
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            _getVehicleIcon(agent.vehicleType),
                            color: context.theme.colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Vehicle number and status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.vehicleNumber,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${agent.vehicleType} • ${agent
                                    .availabilityStatus}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action menu
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: context.theme.colorScheme.onSurface,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditAgentDialog(context, agent);
                                break;
                              case 'delete':
                                controller.showDeleteConfirmationForAgent(
                                    agent);
                                break;
                            }
                          },
                          itemBuilder: (context) =>
                          [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 20,
                                      color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Expand/Collapse icon
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.expand_more,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    // Expandable content
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildAgentExpandedContent(context, agent),
                        ],
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
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

  Widget _buildPersonExpandedContent(BuildContext context,
      DeliveryPerson person) {
    return Column(
      children: [
        // Profile section
        Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
              backgroundImage: person.profilePictureUrl != null
                  ? NetworkImage(person.profilePictureUrl!)
                  : null,
              child: person.profilePictureUrl == null
                  ? Text(
                person.firstName.isNotEmpty
                    ? person.firstName[0].toUpperCase()
                    : 'D',
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.fullName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.email,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contact & Personal Info
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                'Phone',
                person.phoneNumber,
                Icons.phone_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                'Age',
                '${person.age} years',
                Icons.cake_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Address
        _buildInfoTile(
          context,
          'Address',
          person.address,
          Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),

        // Additional details
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                'ID Number',
                person.identificationNumber,
                Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                'Emergency',
                person.emergencyContact,
                Icons.emergency_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgentExpandedContent(BuildContext context,
      DeliveryAgent agent) {
    return Column(
      children: [
        // Profile section
        Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
              backgroundImage: agent.profilePictureUrl != null
                  ? NetworkImage(agent.profilePictureUrl!)
                  : null,
              child: agent.profilePictureUrl == null
                  ? Text(
                agent.vehicleType.isNotEmpty
                    ? agent.vehicleType[0].toUpperCase()
                    : 'D',
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${agent.availabilityStatus}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contact & Capacity Info
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                'Phone',
                agent.phoneNumber,
                Icons.phone_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                'Capacity',
                '${agent.currentLoad}/${agent.maxCapacity}',
                Icons.inventory_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Address
        _buildInfoTile(
          context,
          'Address',
          agent.address,
          Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),

        // Additional details
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                'ID Number',
                agent.identificationNumber,
                Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                'Emergency',
                agent.emergencyContact,
                Icons.emergency_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Ratings and joined date
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                context,
                'Ratings',
                agent.ratings?.toStringAsFixed(1) ?? 'No rating',
                Icons.star_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                context,
                'Joined',
                '${agent.joinedOn.day}/${agent.joinedOn.month}/${agent.joinedOn
                    .year}',
                Icons.calendar_today,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: context.theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'bike':
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'car':
        return Icons.directions_car;
      case 'truck':
      case 'van':
        return Icons.local_shipping;
      case 'bicycle':
        return Icons.pedal_bike;
      default:
        return Icons.delivery_dining;
    }
  }

  void _showEditDialog(BuildContext context, DeliveryPerson person) {
    controller.loadDeliveryPersonForEdit(person);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      constraints: BoxConstraints(
        maxWidth: Responsive.isWeb(context) ? 600 : double.infinity,
        maxHeight: MediaQuery
            .of(context)
            .size
            .height * 0.9,
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Delivery Person',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit Form
                  _buildEditForm(context, person),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditAgentDialog(BuildContext context, DeliveryAgent agent) {
    controller.loadDeliveryAgentForEdit(agent);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      constraints: BoxConstraints(
        maxWidth: Responsive.isWeb(context) ? 600 : double.infinity,
        maxHeight: MediaQuery
            .of(context)
            .size
            .height * 0.9,
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Delivery Agent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit Form for Agent
                  _buildAgentEditForm(context, agent),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditForm(BuildContext context, DeliveryPerson person) {
    return Form(
      child: Column(
        children: [
          // Name Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.editFirstNameController,
                  decoration: _createInputDecoration(context, 'First Name'),
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.editLastNameController,
                  decoration: _createInputDecoration(context, 'Last Name'),
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Fields
          TextFormField(
            controller: controller.editEmailController,
            decoration: _createInputDecoration(context, 'Email'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: controller.editPhoneNumberController,
            decoration: _createInputDecoration(context, 'Phone Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: controller.editAddressController,
            decoration: _createInputDecoration(context, 'Address'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Identification Number
          TextFormField(
            controller: controller.editIdentificationNumberController,
            decoration: _createInputDecoration(
                context, 'Identification Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          // Vehicle Type Dropdown - Centered
          Obx(() => CenteredDropdown<String>(
            value: controller.editSelectedVehicleType.value.isEmpty 
                ? null 
                : controller.editSelectedVehicleType.value,
            items: _buildSimpleVehicleTypeItems(),
            onChanged: (String? newValue) {
              controller.editSelectedVehicleType.value = newValue ?? '';
            },
            labelText: 'Vehicle Type',
            hintText: 'Select vehicle type',
            enabled: true,
          )),
          const SizedBox(height: 16),

          // Vehicle Number
          TextFormField(
            controller: controller.editVehicleNumberController,
            decoration: _createInputDecoration(context, 'Vehicle Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),

          // Date of Birth Picker
          Obx(() =>
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.editSelectedDateOfBirth.value,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
                  );
                  if (picked != null) {
                    controller.editSelectedDateOfBirth.value = picked;
                  }
                },
                child: InputDecorator(
                  decoration: _createInputDecoration(context, 'Date of Birth'),
                  child: Text(
                    '${controller.editSelectedDateOfBirth.value
                        .day}/${controller.editSelectedDateOfBirth.value
                        .month}/${controller.editSelectedDateOfBirth.value
                        .year}',
                    style: TextStyle(
                        color: context.theme.colorScheme.onSurface),
                  ),
                ),
              )),
          const SizedBox(height: 16),

          // Emergency Contact
          TextFormField(
            controller: controller.editEmergencyContactController,
            decoration: _createInputDecoration(context, 'Emergency Contact'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Optional Fields
          TextFormField(
            controller: controller.editProfilePictureUrlController,
            decoration: _createInputDecoration(
                context, 'Profile Picture URL (Optional)'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: controller.editDocumentsUrlController,
            decoration: _createInputDecoration(
                context, 'Documents URL (Optional)'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearEditForm();
                    Get.back<void>();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() =>
                    ElevatedButton(
                      onPressed: controller.isUpdating.value
                          ? null
                          : () => controller.updateDeliveryPerson(person.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme.primary,
                        foregroundColor: context.theme.colorScheme.onPrimary,
                      ),
                      child: controller.isUpdating.value
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.theme.colorScheme.onPrimary,
                        ),
                      )
                          : const Text('Update'),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentEditForm(BuildContext context, DeliveryAgent agent) {
    return Form(
      child: Column(
        children: [
          // Agent Name
          TextFormField(
            controller: controller.editAgentNameController,
            decoration: _createInputDecoration(context, 'Agent Name'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: controller.editAgentPhoneController,
            decoration: _createInputDecoration(context, 'Phone Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Max Capacity
          TextFormField(
            controller: controller.editAgentMaxCapacityController,
            decoration: _createInputDecoration(context, 'Max Capacity'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Availability Status Dropdown
          Obx(() =>
              CenteredDropdown<String>(
                value: controller.editSelectedAvailabilityStatus.value,
                items: ['ACTIVE', 'INACTIVE', 'BUSY'].map((status) =>
                    DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                ).toList(),
                onChanged: (String? newValue) {
                  controller.editSelectedAvailabilityStatus.value =
                      newValue ?? 'ACTIVE';
                },
                labelText: 'Availability Status',
                hintText: 'Select status',
                enabled: true,
              )),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearAgentEditForm();
                    Get.back<void>();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() =>
                    ElevatedButton(
                      onPressed: controller.isUpdating.value
                          ? null
                          : () => controller.updateDeliveryAgent(agent.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme.primary,
                        foregroundColor: context.theme.colorScheme.onPrimary,
                      ),
                      child: controller.isUpdating.value
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.theme.colorScheme.onPrimary,
                        ),
                      )
                          : const Text('Update'),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _createInputDecoration(BuildContext context,
      String labelText) {
    final borderRadius = BorderRadius.circular(8);
    final onSurfaceColor = context.theme.colorScheme.onSurface;
    final borderSide = BorderSide(color: onSurfaceColor.withAlpha(30));

    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
          borderRadius: borderRadius, borderSide: borderSide),
      enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius, borderSide: borderSide),
      focusedBorder: OutlineInputBorder(borderRadius: borderRadius,
          borderSide: BorderSide(color: onSurfaceColor)),
      errorBorder: OutlineInputBorder(borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.red)),
      labelStyle: TextStyle(color: onSurfaceColor),
      fillColor: context.theme.colorScheme.surfaceContainerLowest,
      filled: true,
    );
  }

  List<DropdownMenuItem<String>> _buildSimpleVehicleTypeItems() {
    return (controller.vehicleTypes as List<String>).map<DropdownMenuItem<String>>((String vehicleType) {
      return DropdownMenuItem<String>(
        value: vehicleType,
        child: Text(vehicleType),
      );
    }).toList();
  }

  void _showAddPersonDialog(BuildContext context) {
    // TODO: Implement add delivery person dialog
    Get.snackbar(
      'Info',
      'Add delivery person functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );
  }
}