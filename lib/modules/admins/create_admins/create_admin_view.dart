import 'dart:ui';

import 'package:admin/config/app_config.dart';
import 'package:admin/modules/admins/create_admins/create_admin_controller.dart';
import 'package:admin/utils/responsive.dart';
import 'package:admin/widgets/searchable_dropdown.dart';
import 'package:admin/config/dropdown_data.dart';
import 'package:admin/widgets/custom_displays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CreateAdminView extends StatelessWidget {
  const CreateAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-show the registration bottom sheet when view is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminBottomSheets.showRegistrationBottomSheet(context, "admin");
    });

    // Use a scaffold with app bar as base UI
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Admin',
            style: TextStyle(color: context.theme.colorScheme.onSurface)),
        backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back, color: context.theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.3),
              context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.2),
              context.theme.colorScheme.surfaceContainerLowest.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: context.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Admin Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Use the form to register a new admin',
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminBottomSheets {
  /// Shows bottom sheet with admin registration options
  static void showAdminOptionsBottomSheet(BuildContext context) {
    Responsive.isPortrait(context);
    final screenWidth = Responsive.screenWidth(context);
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: Responsive.isWeb(context) ? screenWidth * 0.5 : screenWidth,
      ),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(Responsive.responsiveValue(
              context, 
              mobile: 16.0, 
              tablet: 24.0, 
              web: 32.0,
            )),
            color: context.theme.colorScheme.surfaceContainerLowest,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person_add, color: context.theme.colorScheme.onSurface),
                  title: Text('Register Users as Admin', style: TextStyle(color: context.theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    showRegistrationBottomSheet(context, "admin");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_shipping, color: context.theme.colorScheme.onSurface),
                  title: Text('Register Users as Delivery persons', style: TextStyle(color: context.theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    showRegistrationBottomSheet(context, "delivery persons");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Creates a consistent input decoration for form fields
  static InputDecoration _createInputDecoration(BuildContext context, String labelText) {
    final borderRadius = BorderRadius.circular(Responsive.responsiveValue(
      context, 
      mobile: 8.0, 
      tablet: 10.0, 
      web: 12.0,
    ));
    final onSurfaceColor = context.theme.colorScheme.onSurface;
    final borderSide = BorderSide(color: onSurfaceColor.withValues(alpha: 0.3));
    
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: borderRadius, borderSide: borderSide),
      enabledBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: borderSide),
      focusedBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide(color: onSurfaceColor)),
      errorBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: const BorderSide(color: Colors.red)),
      labelStyle: TextStyle(color: onSurfaceColor),
      fillColor: context.theme.colorScheme.surfaceContainerLowest,
      filled: true,
    );
  }

  /// Shows registration form in a bottom sheet
  static void showRegistrationBottomSheet(BuildContext context, String userType) {
    // Get or create controller instance for this bottom sheet
    final CreateAdminController controller = Get.put(
        CreateAdminController(), tag: userType);
    controller.clearForm();
    
    final screenHeight = Responsive.screenHeight(context);
    final screenWidth = Responsive.screenWidth(context);
    final isPortrait = Responsive.isPortrait(context);
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      constraints: BoxConstraints(
        maxWidth: Responsive.isWeb(context) ? screenWidth * 0.5 : screenWidth,
        maxHeight: screenHeight * 0.9,
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: Responsive.responsiveValue(
              context,
              mobile: isPortrait ? screenHeight * 0.7 : screenHeight * 0.9,
              tablet: isPortrait ? screenHeight * 0.6 : screenHeight * 0.8,
              web: screenHeight * 0.7,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.responsiveValue(
                context, 
                mobile: 16.0, 
                tablet: 24.0, 
                web: 32.0,
              ),
              vertical: Responsive.responsiveValue(
                context, 
                mobile: 16.0, 
                tablet: 20.0, 
                web: 24.0,
              ),
            ),
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Register $userType",
                      style: TextStyle(
                        fontSize: Responsive.responsiveValue(
                          context, 
                          mobile: 20.0, 
                          tablet: 24.0, 
                          web: 28.0,
                        ),
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.responsiveValue(
                      context, 
                      mobile: 16.0, 
                      tablet: 20.0, 
                      web: 24.0,
                    )),
                    TextFormField(
                      controller: controller.firstNameController,
                      decoration: _createInputDecoration(context, 'First Name'),
                      style: TextStyle(color: context.theme.colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        if (value.length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'First name should only contain letters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.responsiveValue(
                      context, 
                      mobile: 16.0, 
                      tablet: 20.0, 
                      web: 24.0,
                    )),
                    TextFormField(
                      controller: controller.lastNameController,
                      decoration: _createInputDecoration(context, 'Last Name'),
                      style: TextStyle(color: context.theme.colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        if (value.length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Last name should only contain letters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.responsiveValue(
                      context, 
                      mobile: 16.0, 
                      tablet: 20.0, 
                      web: 24.0,
                    )),
                    LayoutBuilder(builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 400;
                      
                      return isNarrow
                        ? Column(
                            children: [
                              TextFormField(
                                controller: controller.emailController,
                                decoration: _createInputDecoration(context, 'Email'),
                                style: TextStyle(color: context.theme.colorScheme.onSurface),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email address';
                                  }
                                  if (!GetUtils.isEmail(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  // Trigger validation state update for inline message
                                  controller.emailController.text = value;
                                },
                              ),

                              // Inline validation message for email
                              // Note: Email validation is handled in the form validator
                              // Real-time validation can be added later if needed
                              SizedBox(height: Responsive.responsiveValue(
                                context, 
                                mobile: 8.0, 
                                tablet: 12.0, 
                                web: 16.0,
                              )),
                              SizedBox(
                                width: double.infinity,
                                child: Obx(() => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: context.theme.colorScheme.onSurface,
                                    backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () => controller.sendOtp(controller.emailController.text, userType),
                                  child: const Text('Send OTP'),
                                )),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.emailController,
                                  decoration: _createInputDecoration(context, 'Email'),
                                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email address';
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    // Trigger validation state update for inline message
                                    controller.emailController.text = value;
                                  },
                                ),
                              ),

                              // Inline validation message for email
                              // Note: Email validation is handled in the form validator
                              // Real-time validation can be added later if needed
                              SizedBox(width: Responsive.responsiveValue(
                                context, 
                                mobile: 8.0, 
                                tablet: 12.0, 
                                web: 16.0,
                              )),
                              Obx(() => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: context.theme.colorScheme.onSurface,
                                  backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.responsiveValue(
                                      context, 
                                      mobile: 12.0, 
                                      tablet: 16.0, 
                                      web: 20.0,
                                    ),
                                    vertical: Responsive.responsiveValue(
                                      context, 
                                      mobile: 10.0, 
                                      tablet: 12.0, 
                                      web: 14.0,
                                    ),
                                  ),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.sendOtp(controller.emailController.text, userType),
                                child: const Text('Send OTP'),
                              )),
                            ],
                          );
                    }),
                    SizedBox(height: Responsive.responsiveValue(
                      context, 
                      mobile: 16.0, 
                      tablet: 20.0, 
                      web: 24.0,
                    )),
                    Obx(() => TextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      cursorColor: context.theme.colorScheme.onSurface,
                      cursorWidth: 2.0,
                      controller: controller.otpController,
                      decoration: _createInputDecoration(context, 'OTP'),
                      style: TextStyle(color: context.theme.colorScheme.onSurface),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'OTP should contain only digits';
                        }
                        return null;
                      },
                      enabled: controller.isOtpSent.value,
                    )),

                    // Inline message for OTP status
                    Obx(() {
                      if (controller.isOtpSent.value) {
                        return const InlineMessage(
                          message: 'OTP sent successfully! Check your email.',
                          type: MessageType.success,
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Verify OTP Button - only show when OTP is sent but not verified
                    Obx(() =>
                    controller.isOtpSent.value &&
                        !controller.isOtpVerified.value
                        ? Column(
                      children: [
                        SizedBox(height: Responsive.responsiveValue(
                          context,
                          mobile: 12.0,
                          tablet: 16.0,
                          web: 20.0,
                        )),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: context.theme.colorScheme
                                  .onSurface,
                              backgroundColor: context.theme.colorScheme
                                  .surfaceContainerLowest,
                              padding: EdgeInsets.symmetric(
                                vertical: Responsive.responsiveValue(
                                  context,
                                  mobile: 12.0,
                                  tablet: 16.0,
                                  web: 20.0,
                                ),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : () =>
                                controller.verifyOtpOnly(
                                    controller.otpController.text),
                            child: controller.isLoading.value
                                ? SizedBox(
                              height: 20,
                              width:
                              20,
                              child: CircularProgressIndicator(
                                color: context.theme.colorScheme.onSurface,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text('Verify OTP'),
                          ),
                        ),
                      ],
                    )
                        : const SizedBox.shrink()),

                    // Show OTP verified message
                    Obx(() {
                      if (controller.isOtpVerified.value) {
                        return Column(
                          children: [
                            SizedBox(height: Responsive.responsiveValue(
                              context,
                              mobile: 12.0,
                              tablet: 16.0,
                              web: 20.0,
                            )),
                            const InlineMessage(
                              message: 'OTP verified successfully! You can now complete registration.',
                              type: MessageType.success,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    SizedBox(height: Responsive.responsiveValue(
                      context, 
                      mobile: 16.0, 
                      tablet: 20.0, 
                      web: 24.0,
                    )),
                    TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: _createInputDecoration(context, 'Password'),
                      style: TextStyle(color: context.theme.colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]')
                            .hasMatch(value)) {
                          return 'Password must contain uppercase, lowercase, number and special character';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Trigger validation state update for inline messages
                        controller.passwordController.text = value;
                      },
                    ),

                    // Inline validation messages for password requirements
                    // Note: Password validation is handled in the form validator
                    // Real-time validation can be added later if needed
                    SizedBox(height: Responsive.responsiveValue(
                      context, 
                      mobile: 16.0, 
                      tablet: 20.0, 
                      web: 24.0,
                    )),

                    // Delivery person specific fields
                    if (userType == "delivery persons") ...[
                      TextFormField(
                        controller: controller.phoneNumberController,
                        decoration: _createInputDecoration(
                            context, 'Phone Number'),
                        style: TextStyle(color: context.theme.colorScheme
                            .onSurface),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(
                              value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                            return 'Please enter a valid phone number';
                          }
                          if (value
                              .replaceAll(RegExp(r'[\s\-\(\)\+]'), '')
                              .length < 10) {
                            return 'Phone number must be at least 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      TextFormField(
                        controller: controller.addressController,
                        decoration: _createInputDecoration(context, 'Address'),
                        style: TextStyle(color: context.theme.colorScheme
                            .onSurface),
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          if (value.length < 10) {
                            return 'Address must be at least 10 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9\s,.\-#/]+$').hasMatch(
                              value)) {
                            return 'Address contains invalid characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      TextFormField(
                        controller: controller.identificationNumberController,
                        decoration: _createInputDecoration(
                            context, 'Identification Number'),
                        style: TextStyle(color: context.theme.colorScheme
                            .onSurface),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter identification number';
                          }
                          if (value.length < 6) {
                            return 'Identification number must be at least 6 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                            return 'Identification number should only contain letters and numbers';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      // Vehicle Type Dropdown - Using new searchable dropdown
                      SearchableDropdown<String>(
                        items: _getVehicleTypeItems(),
                        value: controller.selectedVehicleType.value.isNotEmpty
                            ? controller.selectedVehicleType.value
                            : null,
                        label: 'Vehicle Type',
                        hint: 'Select vehicle type',
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedVehicleType.value = newValue;
                          }
                        },
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      TextFormField(
                        controller: controller.vehicleNumberController,
                        decoration: _createInputDecoration(
                            context, 'Vehicle Number'),
                        style: TextStyle(color: context.theme.colorScheme
                            .onSurface),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle number';
                          }
                          if (value.length < 4) {
                            return 'Vehicle number must be at least 4 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(value)) {
                            return 'Vehicle number contains invalid characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      // Date of Birth Picker
                      Obx(() =>
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: controller.selectedDateOfBirth
                                    .value,
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now().subtract(
                                    const Duration(days: 18 * 365)),
                              );
                              if (picked != null) {
                                controller.selectedDateOfBirth.value = picked;
                              }
                            },
                            child: InputDecorator(
                              decoration: _createInputDecoration(
                                  context, 'Date of Birth'),
                              child: Text(
                                '${controller.selectedDateOfBirth.value
                                    .day}/${controller.selectedDateOfBirth.value
                                    .month}/${controller.selectedDateOfBirth
                                    .value.year}',
                                style: TextStyle(
                                    color: context.theme.colorScheme.onSurface),
                              ),
                            ),
                          )),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      TextFormField(
                        controller: controller.emergencyContactController,
                        decoration: _createInputDecoration(
                            context, 'Emergency Contact'),
                        style: TextStyle(color: context.theme.colorScheme
                            .onSurface),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter emergency contact';
                          }
                          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(
                              value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                            return 'Please enter a valid emergency contact number';
                          }
                          if (value
                              .replaceAll(RegExp(r'[\s\-\(\)\+]'), '')
                              .length < 10) {
                            return 'Emergency contact must be at least 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),

                      // Profile Picture and Documents Section
                      Column(
                        children: [
                          // Profile Picture Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Picture (Optional)',
                                  style: TextStyle(
                                    color: context.theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Obx(() =>
                                    controller.selectedProfileImage.value !=
                                        null
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        controller.selectedProfileImage.value!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: context.theme.colorScheme
                                            .surfaceContainerLow,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: context.theme.colorScheme
                                            .onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: context.theme
                                            .colorScheme.onSurface,
                                        backgroundColor: context.theme
                                            .colorScheme.surfaceContainerLowest,
                                      ),
                                      onPressed: () =>
                                          controller.showImagePickerOptions(
                                            context,
                                            isProfilePicture: true,
                                          ),
                                      child: const Text('Select Image'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: Responsive.responsiveValue(
                            context,
                            mobile: 16.0,
                            tablet: 20.0,
                            web: 24.0,
                          )),

                          // Documents Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Documents (Optional)',
                                  style: TextStyle(
                                    color: context.theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Obx(() =>
                                    controller.selectedDocumentImage.value !=
                                        null
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        controller.selectedDocumentImage.value!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: context.theme.colorScheme
                                            .surfaceContainerLow,
                                      ),
                                      child: Icon(
                                        Icons.description,
                                        color: context.theme.colorScheme
                                            .onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: context.theme
                                            .colorScheme.onSurface,
                                        backgroundColor: context.theme
                                            .colorScheme.surfaceContainerLowest,
                                      ),
                                      onPressed: () =>
                                          controller.showImagePickerOptions(
                                            context,
                                            isProfilePicture: false,
                                          ),
                                      child: const Text('Select Document'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.responsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        web: 24.0,
                      )),
                    ],

                    Obx(() =>
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: context.theme.colorScheme
                                .onSurface,
                            backgroundColor: context.theme.colorScheme
                                .surfaceContainerLowest,
                            minimumSize: Size(
                                double.infinity, Responsive.responsiveValue(
                              context,
                              mobile: 48.0,
                              tablet: 56.0,
                              web: 64.0,
                            )),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.responsiveValue(
                                context,
                                mobile: 12.0,
                                tablet: 16.0,
                                web: 20.0,
                          ),
                        ),
                      ),
                      onPressed: controller.isLoading.value || !controller
                          .isOtpSent.value
                          ? null
                          : () => controller.verifyOtp(userType: userType),
                      child: controller.isLoading.value
                          ? SizedBox(
                          height: Responsive.responsiveValue(
                            context,
                            mobile: 24.0,
                            tablet: 28.0,
                            web: 32.0,
                          ),
                          width: Responsive.responsiveValue(
                            context,
                            mobile: 24.0,
                            tablet: 28.0,
                            web: 32.0,
                          ),
                          child: CircularProgressIndicator(
                              color: context.theme.colorScheme.onSurface)
                      )
                          : Text(
                        'Register',
                        style: TextStyle(fontSize: Responsive.responsiveValue(
                          context,
                          mobile: 16.0,
                          tablet: 18.0,
                          web: 20.0,
                        )),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to create vehicle type dropdown items
  static List<DropdownItem> _getVehicleTypeItems() {
    return [
      const DropdownItem(
        value: 'Bicycle',
        label: 'Bicycle',
        description: 'Eco-friendly short distance delivery',
        icon: '🚲',
      ),
      const DropdownItem(
        value: 'Motorcycle',
        label: 'Motorcycle',
        description: 'Fast urban delivery',
        icon: '🏍️',
      ),
      const DropdownItem(
        value: 'Car',
        label: 'Car',
        description: 'Comfortable delivery option',
        icon: '🚗',
      ),
      const DropdownItem(
        value: 'Van',
        label: 'Van',
        description: 'Large capacity delivery',
        icon: '🚐',
      ),
      const DropdownItem(
        value: 'Truck',
        label: 'Truck',
        description: 'Heavy duty delivery',
        icon: '🚛',
      ),
    ];
  }
}