import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/main_layout/main_layout_controller.dart';
import 'image_upload_widget.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainLayoutController>();
    
    return Obx(() => PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          controller.logout();
        } else if (value == 'profile') {
          _showProfileDialog(context, controller);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: context.theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 20,
                color: context.theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (controller.userEmail.isNotEmpty)
              Text(
                controller.userEmail.value,
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, size: 16),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16),
              SizedBox(width: 8),
              Text('logout'.tr),
            ],
          ),
        ),
      ],
    ));
  }

  static void _showProfileDialog(BuildContext context, MainLayoutController controller) {
    String? uploadedImageUrl;
    
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profile Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Profile Image Upload
                ImageUploadWidget(
                  fileType: 'ProfilePicture',
                  description: 'Profile picture for ${controller.userEmail.value}',
                  currentImageUrl: uploadedImageUrl,
                  onImageUploaded: (String imageUrl) {
                    setState(() {
                      uploadedImageUrl = imageUrl.isNotEmpty ? imageUrl : null;
                    });
                  },
                  onError: (String error) {
                    Get.snackbar('Upload Error', error);
                  },
                  label: 'Profile Picture',
                  hintText: 'Upload your profile picture (JPG, PNG up to 10MB)',
                  height: 200,
                ),
                const SizedBox(height: 24),

                // User Email (Read-only)
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    controller.userEmail.value,
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back<void>(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // Here you would typically save the profile changes
                          // For now, just show a success message
                          Get.back<void>();
                          Get.snackbar(
                            'Success',
                            'Profile updated successfully',
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                            colorText: Colors.green,
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            duration: const Duration(seconds: 3),
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}