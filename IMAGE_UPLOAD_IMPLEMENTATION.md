# Image Upload Implementation Guide

This document explains how the image upload system has been implemented in the Flutter admin app, following the requirement to upload images first and then use the returned `fileUrl` in subsequent API calls.

## Overview

The image upload system follows this process:
1. Upload the image first using the FileUpload API
2. Take the `fileUrl` from the response
3. Use that `fileUrl` in the next API (Create Recipe, Update Profile, Create Workout, etc.)

## Components

### 1. File Upload Service (`lib/services/file_upload_service.dart`)

The main service that handles file uploads with progress tracking and error handling.

**Key Features:**
- Progress tracking with UI feedback
- Error handling with user-friendly messages
- Support for different file types (RecipeImage, ProfilePicture, WorkoutImage, etc.)
- Image picker integration
- File size validation (max 10MB)

**Usage Example:**
```dart
final result = await FileUploadService().uploadFile(
  file: File('path/to/image.jpg'),
  fileType: 'RecipeImage',
  description: 'Recipe image for chicken bowl',
  showProgressDialog: true,
);

if (result.isSuccess) {
  final imageUrl = result.fileUrl;
  // Use imageUrl in your recipe creation API
}
```

### 2. Image Upload Widget (`lib/widgets/image_upload_widget.dart`)

A reusable Material Design widget for image uploads.

**Key Features:**
- Material Design interface
- Progress indicators
- Error handling
- Image preview
- Remove functionality
- Compact version for smaller spaces

**Usage Example:**
```dart
ImageUploadWidget(
  fileType: 'RecipeImage',
  description: 'Recipe image',
  currentImageUrl: existingImageUrl,
  onImageUploaded: (String imageUrl) {
    // Handle uploaded image URL
    setState(() {
      uploadedImageUrl = imageUrl;
    });
  },
  onError: (String error) {
    // Handle upload error
    Get.snackbar('Upload Error', error);
  },
  label: 'Recipe Image',
  hintText: 'Upload a photo of your recipe (JPG, PNG up to 10MB)',
  height: 200,
)
```

### 3. API Client Integration (`lib/network_service/api_client.dart`)

The API client has been updated to include the file upload endpoint.

**New Endpoint:**
```dart
@POST(AppUrl.fileUpload)
@MultiPart()
Future<HttpResponse<dynamic>> uploadFile(
  @Part() File file,
  @Part() String fileType,
  @Part() String? description,
);
```

## File Types

The system supports different file types for different use cases:

- `RecipeImage` - For recipe images
- `ProfilePicture` - For user profile pictures
- `WorkoutImage` - For workout images
- `ExerciseImage` - For exercise images
- `DriverImage` - For delivery driver images
- `IngredientImage` - For ingredient images

## Integration Examples

### 1. Recipe Creation/Editing

The recipe dialogs have been updated to use the image upload widget:

```dart
// In recipe dialog
ImageUploadWidget(
  fileType: 'RecipeImage',
  description: 'Recipe image for ${recipeName}',
  currentImageUrl: uploadedImageUrl,
  onImageUploaded: (String imageUrl) {
    setState(() {
      uploadedImageUrl = imageUrl.isNotEmpty ? imageUrl : null;
    });
  },
  onError: (String error) {
    Get.snackbar('Upload Error', error);
  },
  label: 'Recipe Image',
  hintText: 'Upload a photo of your recipe (JPG, PNG up to 10MB)',
  height: 200,
)

// When creating/updating recipe
if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty) {
  data['imageUrl'] = uploadedImageUrl;
}
```

### 2. Exercise Creation/Editing

The exercise dialogs have been updated similarly:

```dart
// In exercise dialog
ImageUploadWidget(
  fileType: 'ExerciseImage',
  description: 'Exercise image for ${exerciseName}',
  currentImageUrl: uploadedImageUrl,
  onImageUploaded: onImageUploaded,
  onError: (String error) {
    Get.snackbar('Upload Error', error);
  },
  label: 'Exercise Image',
  hintText: 'Upload a photo of the exercise (JPG, PNG up to 10MB)',
  height: 200,
)

// In exercise controller
Map<String, dynamic> createExerciseData({String? uploadedImageUrl}) {
  return {
    'name': nameController.text.trim(),
    'description': descriptionController.text.trim(),
    'muscleGroup': muscleGroupController.text.trim(),
    'equipment': equipmentController.text.trim(),
    'difficulty': int.tryParse(difficultyController.text) ?? 1,
    'instructionData': instructionData,
    'imageUrl': uploadedImageUrl ?? imageUrlController.text.trim(),
    'videoUrl': videoUrlController.text.trim(),
  };
}
```

### 3. Profile Management

The profile widget has been updated to include image upload functionality:

```dart
// In profile dialog
ImageUploadWidget(
  fileType: 'ProfilePicture',
  description: 'Profile picture for ${userEmail}',
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
)
```

## API Flow

### Step 1: Upload Image

```http
POST /api/FileUpload/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: [binary file]
fileType: "RecipeImage"
description: "Recipe image"
```

**Response:**
```json
{
  "success": true,
  "message": "File uploaded successfully",
  "data": {
    "fileUrl": "https://elith-api-files.s3.ap-south-1.amazonaws.com/recipe-images/chicken_bowl.jpg"
  }
}
```

### Step 2: Use fileUrl in Recipe API

```http
POST /api/admin/recipes
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Chicken and Rice Bowl",
  "description": "Healthy bowl with grilled chicken breast and brown rice",
  "servings": 2,
  "imageUrl": "https://elith-api-files.s3.ap-south-1.amazonaws.com/recipe-images/chicken_bowl.jpg",
  "dietaryCategory": "NON_VEGETARIAN",
  "cuisine": "American"
}
```

## Error Handling

The system provides comprehensive error handling:

- **Network errors**: Connection timeout, no internet
- **File errors**: File too large, unsupported format
- **Server errors**: HTTP status codes with user-friendly messages
- **Validation errors**: File size limits, format restrictions

## Progress Tracking

The upload process shows progress indicators:

- **Progress dialog**: Shows during upload with cancel option
- **Loading states**: Visual feedback in the upload widget
- **Success/Error messages**: Toast notifications for user feedback

## Best Practices

1. **Always upload first**: Never send raw image files directly to other APIs
2. **Use appropriate file types**: Choose the correct fileType for your use case
3. **Handle errors gracefully**: Show user-friendly error messages
4. **Validate file size**: Check file size before upload (max 10MB)
5. **Provide feedback**: Show progress and success/error states
6. **Clean up**: Remove temporary files after successful upload

## Testing

To test the implementation:

1. **Recipe Creation**: Create a new recipe with an image
2. **Recipe Editing**: Edit an existing recipe and change the image
3. **Exercise Creation**: Create a new exercise with an image
4. **Exercise Editing**: Edit an existing exercise and change the image
5. **Profile Management**: Update profile picture
6. **Error Scenarios**: Test with large files, network errors, etc.

## Future Enhancements

Potential improvements for the image upload system:

1. **Image compression**: Automatic image compression before upload
2. **Multiple file uploads**: Support for uploading multiple images at once
3. **Image editing**: Basic image editing capabilities (crop, rotate, etc.)
4. **Cloud storage integration**: Direct integration with cloud storage providers
5. **Image optimization**: Automatic image optimization for different screen sizes
6. **Batch uploads**: Support for batch uploading multiple files

## Conclusion

The image upload system has been successfully implemented following the specified requirements. It provides a robust, user-friendly interface for uploading images with proper error handling, progress tracking, and Material Design integration. The system is modular and reusable, making it easy to integrate into different parts of the application.
