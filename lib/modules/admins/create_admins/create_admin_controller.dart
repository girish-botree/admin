import 'package:admin/config/app_config.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/routes/app_routes.dart';
import 'package:admin/widgets/custom_displays.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class CreateAdminController extends GetxController {
  
  // Error messages
  final otpErrorMessage = ''.obs;
  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();

  // Delivery person specific controllers
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final identificationNumberController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final profilePictureUrlController = TextEditingController();
  final documentsUrlController = TextEditingController();

  // Image handling
  final selectedProfileImage = Rx<File?>(null);
  final selectedDocumentImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Observables for delivery person
  final selectedVehicleType = 'Car'.obs;
  final selectedDateOfBirth = DateTime
      .now()
      .subtract(Duration(days: 18 * 365))
      .obs;

  // Vehicle type options
  final vehicleTypes = ['Car', 'Motorcycle', 'Bicycle', 'Van', 'Truck'].obs;

  // Form keys
  final formKey = GlobalKey<FormState>();
  
  // Loading states
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final isOtpLoading = false.obs;


  // Show image picker options
  void showImagePickerOptions(BuildContext context,
      {required bool isProfilePicture}) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: context.theme.colorScheme.onSurface),
                title: Text('Camera', style: TextStyle(
                    color: context.theme.colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(
                      ImageSource.camera, isProfilePicture: isProfilePicture);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library,
                    color: context.theme.colorScheme.onSurface),
                title: Text('Gallery', style: TextStyle(
                    color: context.theme.colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(
                      ImageSource.gallery, isProfilePicture: isProfilePicture);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source,
      {required bool isProfilePicture}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Compress image to GZIP format
        String compressedImageData = await _compressImageToGzip(imageFile);

        if (isProfilePicture) {
          selectedProfileImage.value = imageFile;
          profilePictureUrlController.text = compressedImageData;
        } else {
          selectedDocumentImage.value = imageFile;
          documentsUrlController.text = compressedImageData;
        }

        CustomDisplays.showSnackBar(
            message: 'Image selected and compressed successfully');
      }
    } catch (e) {
      CustomDisplays.showSnackBar(message: 'Error picking image: $e');
    }
  }

  // Compress image to GZIP format
  Future<String> _compressImageToGzip(File imageFile) async {
    try {
      // Read image bytes
      List<int> imageBytes = await imageFile.readAsBytes();

      // Compress using GZIP with dart:io
      List<int> gzipBytes = gzip.encode(imageBytes);

      // Convert to base64 string for transmission
      String base64Gzip = base64Encode(gzipBytes);

      return base64Gzip;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Send OTP to the provided email
  Future<void> sendOtp(String email, String userType) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      CustomDisplays.showSnackBar(message: 'Please enter a valid email address');
      return;
    }
    
    isLoading.value = true;
    try {
      final response = await DioNetworkService.sendOtp(email, showLoader: false);
      
      // Handle the enhanced response structure
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      final responseData = response['httpResponse']?['data'] ?? response['data'];
      final message = responseData?['message'] ?? response['message'];
      
      if (httpStatus == 200 && (message == 'OTP sent successfully' || message != null)) {
        isOtpSent.value = true;
        CustomDisplays.showSnackBar(message: 'OTP sent successfully to your email');
      } else {
        CustomDisplays.showSnackBar(message: message?.toString() ?? 'Failed to send OTP. Please try again.');
      }
    } on DioException catch (dioError) {
      // DioException sending OTP

      String errorMessage = 'Failed to send OTP. Please try again.';

      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        final responseData = dioError.response!.data;

        // Status Code and Response Data logging removed

        if (statusCode == 400) {
          if (responseData is String &&
              responseData.toLowerCase().contains('email already exists')) {
            errorMessage =
            'This email is already registered. Please use a different email or try logging in instead.';
          } else if (responseData is Map && responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          }
        } else if (statusCode == 429) {
          errorMessage =
          'Too many requests. Please wait a moment and try again.';
        } else if (statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        }
      } else {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      CustomDisplays.showSnackBar(message: errorMessage);
    } catch (e) {
      // Error sending OTP
      CustomDisplays.showSnackBar(
          message: 'An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear form fields
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    otpController.clear();
    passwordController.clear();
    phoneNumberController.clear();
    addressController.clear();
    identificationNumberController.clear();
    vehicleNumberController.clear();
    emergencyContactController.clear();
    profilePictureUrlController.clear();
    documentsUrlController.clear();
    selectedProfileImage.value = null;
    selectedDocumentImage.value = null;
    isOtpSent.value = false;
  }
  
  // Clear OTP error message
  void clearOtpError() {
    otpErrorMessage.value = '';
  }
  
  // Verify OTP and complete registration
  Future<void> verifyOtp({String userType = "admin"}) async {
    if (otpController.text.isEmpty) {
      otpErrorMessage.value = 'Please enter OTP';
      return;
    }
    
    if (otpController.text.length != 6) {
      otpErrorMessage.value = 'OTP must be 6 digits';
      return;
    }

    clearOtpError();
    isOtpLoading.value = true;

    try {
      // Call appropriate register API based on user type
      final response = userType == "delivery persons" 
        ? await DioNetworkService.registerDeliveryPerson(
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            emailController.text.trim(),
            otpController.text.trim(),
            passwordController.text,
        phoneNumberController.text.trim(),
        addressController.text.trim(),
        identificationNumberController.text.trim(),
        selectedVehicleType.value,
        vehicleNumberController.text.trim(),
        selectedDateOfBirth.value,
        emergencyContactController.text.trim(),
        profilePictureUrl: profilePictureUrlController.text
            .trim()
            .isEmpty
            ? null
            : profilePictureUrlController.text.trim(),
        documentsUrl: documentsUrlController.text
            .trim()
            .isEmpty
            ? null
            : documentsUrlController.text.trim(),
          )
        : await DioNetworkService.registerAdmin(
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            emailController.text.trim(),
            otpController.text.trim(),
            passwordController.text,
          );

      // Handle the enhanced response structure
      final httpStatus = response['httpResponse']?['status'] ?? 0;
      final responseData = response['httpResponse']?['data'] ?? response;
      
      // Check if registration was successful
      // For admin registration: look for token
      // For delivery person registration: look for success flag and message
      bool isSuccess = false;
      String successMessage = '';

      if (userType == "delivery persons") {
        // Delivery person registration success check
        isSuccess = (httpStatus == 200 || httpStatus == 201) &&
            (responseData?['success'] == true ||
                responseData?['message'] == "Delivery agent created");
        successMessage =
        'Delivery person registered successfully! Welcome to the team.';
      } else {
        // Admin registration success check
        final token = responseData?['token'] ?? response['token'];
        isSuccess = (httpStatus == 200 || httpStatus == 201) && token != null;
        successMessage =
        'Admin registration completed successfully! Welcome to the dashboard.';

        if (isSuccess) {
          // Store the authentication tokens for admin
          await DioNetworkService.storeAuthTokens(
              responseData as Map<String, dynamic>);
        }
      }

      if (isSuccess) {
        // Close the bottom sheet first
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
        }

        // Small delay to ensure bottom sheet closes properly
        await Future<void>.delayed(Duration(milliseconds: 300));

        // Navigate to home page
        Get.offAllNamed<void>(AppRoutes.home);
        
        // Show success message
        Get.snackbar(
          'Success',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else {
        // Response received but no token - treat as error
        otpErrorMessage.value =
            responseData?['message'] as String? ??
                'Registration failed. Invalid response from server.';
      }
    } on DioException catch (dioError) {
      // Handle specific HTTP errors
      String errorMsg = 'Registration failed. Please try again.';
      
      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        final responseData = dioError.response!.data as Map<String, dynamic>?;
        
        switch (statusCode) {
          case 400:
            errorMsg = responseData?['message'] as String? ??
                'Invalid OTP or registration data.';
            break;
          case 401:
            errorMsg = 'Invalid or expired OTP. Please request a new one.';
            break;
          case 409:
            errorMsg = 'Email already registered. Please use a different email.';
            break;
          case 429:
            errorMsg = 'Too many attempts. Please try again later.';
            break;
          case 500:
            errorMsg = 'Server error. Please try again later.';
            break;
          default:
            errorMsg = responseData?['message'] as String? ??
                'Registration failed. Please try again.';
        }
      } else {
        // Network error
        errorMsg = 'Network error. Please check your internet connection.';
      }
      
      otpErrorMessage.value = errorMsg;
    } catch (error) {
      otpErrorMessage.value = 'An unexpected error occurred. Please try again.';
    } finally {
      isOtpLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    identificationNumberController.dispose();
    vehicleNumberController.dispose();
    emergencyContactController.dispose();
    profilePictureUrlController.dispose();
    documentsUrlController.dispose();
    super.onClose();
  }
}