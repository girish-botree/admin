import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:admin/network_service/dio_network_service.dart';
import 'package:admin/network_service/api_constants.dart';
import 'package:admin/network_service/app_url_config.dart';

void main() {
  group('Network Service Tests', () {
    setUpAll(() async {
      // Initialize bindings for SharedPreferences
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Mock SharedPreferences
      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return <String, Object>{}; // Return an empty map
          case 'setBool':
          case 'setDouble':
          case 'setInt':
          case 'setString':
          case 'setStringList':
            return true; // Return success
          case 'remove':
            return true; // Return success
          case 'clear':
            return true; // Return success
          default:
            return null;
        }
      });
      
      // Initialize the network service
      NetworkService.initialize();
    });

    group('Configuration Tests', () {
      test('should have correct API constants', () {
        expect(apiVersion, equals('/v1'));
        expect(connectTimeout, equals(30000));
        expect(receiveTimeout, equals(30000));
        expect(sendTimeout, equals(30000));
      });

      test('should have correct status codes', () {
        expect(statusCodeOk, equals(200));
        expect(statusCodeUnauthorized, equals(401));
        expect(statusCodeInternalServerError, equals(500));
      });

      test('should have correct error messages', () {
        expect(errorNoInternet, isNotEmpty);
        expect(errorTimeout, isNotEmpty);
        expect(errorUnauthorized, isNotEmpty);
      });
    });

    group('URL Configuration Tests', () {
      test('should have base URL configuration', () {
        final baseUrl = AppUrl.getBaseUrl();
        expect(baseUrl, isNotEmpty);
        expect(baseUrl, contains('http'));
      });

      test('should have API endpoints defined', () {
        expect(AppUrl.login, isNotEmpty);
        // expect(AppUrl.logout, isNotEmpty);
        // expect(AppUrl.profile, isNotEmpty);
        // expect(AppUrl.authenticate, isNotEmpty);
      });
    });

    group('Network Configuration Tests', () {
      test('should have correct network configuration', () {
        expect(NetworkConfig.enableLogging, isA<bool>());
        expect(NetworkConfig.enableDebugMode, isA<bool>());
        expect(NetworkConfig.connectTimeoutSeconds, greaterThan(0));
        expect(NetworkConfig.maxRetries, greaterThan(0));
      });
    });

    group('Authentication Tests', () {
      test('should handle authentication status correctly', () async {
        final isAuthenticated = await DioNetworkService.isAuthenticated();
        expect(isAuthenticated, isA<bool>());
      });

      test('should handle token operations', () async {
        const testToken = 'test-token-123';
        
        // Store token
        await DioNetworkService.storeToken(testToken);
        
        // Retrieve token
        final retrievedToken = await DioNetworkService.getToken();
        expect(retrievedToken, equals(testToken));
        
        // Clear token
        await DioNetworkService.clearToken();
        
        // Verify token is cleared
        final clearedToken = await DioNetworkService.getToken();
        expect(clearedToken, isNull);
      });
    });

    group('Backward Compatibility Tests', () {
      test('should maintain backward compatibility methods', () {
        // Test that old methods exist
        expect(NetworkService.showLoader, isA<Function>());
        expect(NetworkService.dismissLoader, isA<Function>());
        expect(NetworkService.headersWithToken, isA<Function>());
        expect(NetworkService.headersWithoutToken, isA<Function>());
      });

      test('should generate correct headers', () {
        const testToken = 'test-token';
        
        final headersWithToken = NetworkService.headersWithToken(testToken);
        expect(headersWithToken['Authorization'], equals('Bearer $testToken'));
        expect(headersWithToken['Content-type'], equals('application/json'));
        expect(headersWithToken['Accept'], equals('application/json'));
        
        final headersWithoutToken = NetworkService.headersWithoutToken(null);
        expect(headersWithoutToken['Content-type'], equals('application/json'));
        expect(headersWithoutToken['Accept'], equals('application/json'));
        expect(headersWithoutToken.containsKey('Authorization'), isFalse);
      });
    });

    group('Error Handling Tests', () {
      test('should have proper error message constants', () {
        expect(errorNoInternet, equals('No internet connection available'));
        expect(errorTimeout, equals('Request timeout. Please try again'));
        expect(errorServerError, equals('Internal server error occurred'));
        expect(errorUnauthorized, equals('Unauthorized access. Please login again'));
      });
    });
  });
}

// Mock tests for network requests (these would need actual API endpoints to test)
void main_integration_tests() {
  group('Integration Tests', () {
    // Note: These tests require actual API endpoints to work
    // They are provided as examples of how to test the network service
    
    test('should make GET request successfully', () async {
      // This would need a real API endpoint
      // final response = await NetworkService.getData('test-endpoint');
      // expect(response, isNotNull);
    });

    test('should make POST request successfully', () async {
      // This would need a real API endpoint
      // final data = {'test': 'data'};
      // final response = await NetworkService.postData(data, 'test-endpoint');
      // expect(response, isNotNull);
    });

    test('should handle authentication flow', () async {
      // This would need real authentication endpoints
      // final response = await DioNetworkService.login('testuser', 'testpass');
      // expect(response['success'], isTrue);
    });
  });
} 