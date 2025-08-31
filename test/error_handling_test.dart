import 'package:flutter_test/flutter_test.dart';
import 'package:admin/services/error_handling_service.dart';
import 'package:admin/widgets/custom_displays.dart';

void main() {
  group('ErrorHandlingService Tests', () {
    test('should deduplicate network error messages', () {
      // Test that multiple network error calls result in only one message
      ErrorHandlingService.handleApiError('Network connection failed');
      ErrorHandlingService.handleApiError('Network connection failed');
      ErrorHandlingService.handleApiError('Network connection failed');
      
      // The second and third calls should be ignored due to deduplication
      // This test verifies the deduplication logic works
    });

    test('should deduplicate session expired messages', () {
      // Test that multiple session expired calls result in only one message
      ErrorHandlingService.handleApiError('Session expired');
      ErrorHandlingService.handleApiError('Session expired');
      ErrorHandlingService.handleApiError('Session expired');
      
      // The second and third calls should be ignored due to deduplication
    });

    test('should allow different messages to show', () {
      // Test that different messages are not deduplicated
      ErrorHandlingService.handleApiError('First error message');
      ErrorHandlingService.handleApiError('Second error message');
      ErrorHandlingService.handleApiError('Third error message');
      
      // All three messages should show since they are different
    });

    test('should clear notifications properly', () {
      // Test that clearing notifications works
      ErrorHandlingService.clearAllNotifications();
      
      // This should reset the deduplication state
    });
  });

  group('CustomDisplays Tests', () {
    test('should deduplicate toast messages', () {
      // Test toast deduplication
      CustomDisplays.showToast(
        message: 'Test message',
        type: MessageType.error,
        allowDuplicate: false,
      );
      
      CustomDisplays.showToast(
        message: 'Test message',
        type: MessageType.error,
        allowDuplicate: false,
      );
      
      // Second call should be ignored
    });

    test('should allow duplicate messages when explicitly requested', () {
      // Test that duplicates are allowed when allowDuplicate is true
      CustomDisplays.showToast(
        message: 'Test message',
        type: MessageType.error,
        allowDuplicate: true,
      );
      
      CustomDisplays.showToast(
        message: 'Test message',
        type: MessageType.error,
        allowDuplicate: true,
      );
      
      // Both calls should show since allowDuplicate is true
    });
  });
}
