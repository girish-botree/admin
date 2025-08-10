import 'dart:ui';
import 'package:admin/config/app_config.dart';
import 'package:admin/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'delivery_person_controller.dart';
import 'delivery_person_model.dart';

class DeliveryPersonView extends GetView<DeliveryPersonController> {
  const DeliveryPersonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: AppBar(
        title: AppText.semiBold(
          'Delivery Persons',
          color: context.theme.colorScheme.onSurface,
          size: 24,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(context),
            SizedBox(height: 16),

            // Delivery Persons List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.filteredDeliveryPersons.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildDeliveryPersonsList(context);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.fetchDeliveryPersons(),
        icon: Icon(Icons.refresh),
        label: Text('Refresh'),
        backgroundColor: context.theme.colorScheme.primary,
        foregroundColor: context.theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        labelText: 'Search delivery persons...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary,
          ),
        ),
      ),
      onChanged: controller.searchDeliveryPersons,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: context.theme.colorScheme.outline,
          ),
          SizedBox(height: 16),
          Text(
            'No delivery persons found',
            style: TextStyle(
              fontSize: 18,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Delivery persons will appear here when registered',
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPersonsList(BuildContext context) {
    return ListView.separated(
      itemCount: controller.filteredDeliveryPersons.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final person = controller.filteredDeliveryPersons[index];
        return _buildDeliveryPersonCard(context, person);
      },
    );
  }

  Widget _buildDeliveryPersonCard(BuildContext context, DeliveryPerson person) {
    return Card(
      color: context.theme.colorScheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Profile Picture or Initial
                CircleAvatar(
                  radius: 24,
                  backgroundColor: context.theme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  backgroundImage: person.profilePictureUrl != null
                      ? NetworkImage(person.profilePictureUrl!)
                      : null,
                  child: person.profilePictureUrl == null
                      ? Text(
                    person.firstName.isNotEmpty
                        ? person.firstName[0].toUpperCase()
                        : 'D',
                    style: TextStyle(
                      color: context.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 12),

                // Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        person.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: context.theme.colorScheme.outline,
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            // Details Grid
            _buildDetailsGrid(context, person),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, DeliveryPerson person) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailItem(
                context, 'Phone', person.phoneNumber, Icons.phone)),
            SizedBox(width: 16),
            Expanded(child: _buildDetailItem(
                context, 'Age', '${person.age} years', Icons.calendar_today)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDetailItem(context, 'Vehicle',
                '${person.vehicleType} - ${person.vehicleNumber}',
                Icons.directions_car)),
            SizedBox(width: 16),
            Expanded(child: _buildDetailItem(
                context, 'ID Number', person.identificationNumber,
                Icons.badge)),
          ],
        ),
        SizedBox(height: 12),
        _buildDetailItem(context, 'Address', person.address, Icons.location_on),
        SizedBox(height: 12),
        _buildDetailItem(context, 'Emergency Contact', person.emergencyContact,
            Icons.emergency),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value,
      IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
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
                color: context.theme.colorScheme.outline,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
            padding: EdgeInsets.all(20),
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
                  SizedBox(height: 20),

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
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.editLastNameController,
                  decoration: _createInputDecoration(context, 'Last Name'),
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Contact Fields
          TextFormField(
            controller: controller.editEmailController,
            decoration: _createInputDecoration(context, 'Email'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: controller.editPhoneNumberController,
            decoration: _createInputDecoration(context, 'Phone Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),

          // Address
          TextFormField(
            controller: controller.editAddressController,
            decoration: _createInputDecoration(context, 'Address'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            maxLines: 2,
          ),
          SizedBox(height: 16),

          // Identification Number
          TextFormField(
            controller: controller.editIdentificationNumberController,
            decoration: _createInputDecoration(
                context, 'Identification Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          SizedBox(height: 16),

          // Vehicle Type Dropdown
          Obx(() =>
              DropdownButtonFormField<String>(
                value: controller.editSelectedVehicleType.value,
                decoration: _createInputDecoration(context, 'Vehicle Type'),
                style: TextStyle(color: context.theme.colorScheme.onSurface),
                dropdownColor: context.theme.colorScheme.surfaceContainerLowest,
                items: controller.vehicleTypes.map((String vehicleType) {
                  return DropdownMenuItem<String>(
                    value: vehicleType,
                    child: Text(vehicleType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.editSelectedVehicleType.value = newValue;
                  }
                },
              )),
          SizedBox(height: 16),

          // Vehicle Number
          TextFormField(
            controller: controller.editVehicleNumberController,
            decoration: _createInputDecoration(context, 'Vehicle Number'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          SizedBox(height: 16),

          // Date of Birth Picker
          Obx(() =>
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.editSelectedDateOfBirth.value,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().subtract(Duration(days: 18 * 365)),
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
          SizedBox(height: 16),

          // Emergency Contact
          TextFormField(
            controller: controller.editEmergencyContactController,
            decoration: _createInputDecoration(context, 'Emergency Contact'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),

          // Optional Fields
          TextFormField(
            controller: controller.editProfilePictureUrlController,
            decoration: _createInputDecoration(
                context, 'Profile Picture URL (Optional)'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: controller.editDocumentsUrlController,
            decoration: _createInputDecoration(
                context, 'Documents URL (Optional)'),
            style: TextStyle(color: context.theme.colorScheme.onSurface),
          ),
          SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearEditForm();
                    Get.back<void>();
                  },
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 16),
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
                          : Text('Update'),
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
    final borderSide = BorderSide(color: onSurfaceColor.withValues(alpha: 0.3));

    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
          borderRadius: borderRadius, borderSide: borderSide),
      enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius, borderSide: borderSide),
      focusedBorder: OutlineInputBorder(borderRadius: borderRadius,
          borderSide: BorderSide(color: onSurfaceColor)),
      errorBorder: OutlineInputBorder(borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red)),
      labelStyle: TextStyle(color: onSurfaceColor),
      fillColor: context.theme.colorScheme.surfaceContainerLowest,
      filled: true,
    );
  }
}