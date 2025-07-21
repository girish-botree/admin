# 🚀 Flutter Admin Network Service - Complete Guide

A comprehensive, production-ready network service built with Dio and Retrofit for Flutter applications. This guide will make you an expert in using and extending this network service.

## 📋 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Quick Start](#-quick-start)
3. [Configuration Setup](#️-configuration-setup)
4. [Basic API Usage](#-basic-api-usage)
5. [Advanced Features](#-advanced-features)
6. [Adding New APIs](#-adding-new-apis)
7. [Authentication & Security](#-authentication--security)
8. [Error Handling](#-error-handling)
9. [File Operations](#-file-operations)
10. [Testing & Debugging](#-testing--debugging)
11. [Performance Optimization](#⚡-performance-optimization)
12. [Production Deployment](#-production-deployment)
13. [Best Practices](#-best-practices)
14. [Troubleshooting](#-troubleshooting)

## 🏗️ Architecture Overview

The network service consists of 6 core components:

```
network_service/
├── api_constants.dart      # Configuration constants & error messages
├── app_url_config.dart     # Environment-based URL management
├── network_module.dart     # Dio configuration & interceptors
├── api_client.dart         # Retrofit API definitions
├── api_client.g.dart       # Auto-generated Retrofit code
└── dio_network_service.dart # High-level service methods
```

### Key Features

✅ **Type-safe API calls** with Retrofit  
✅ **Automatic error handling** with user-friendly messages  
✅ **Request/response logging** in debug mode  
✅ **Authentication management** with automatic token handling  
✅ **Retry logic** for failed requests  
✅ **File upload/download** support  
✅ **Environment-based configuration**  
✅ **Backward compatibility** with existing code  

## 🚀 Quick Start

### 1. Initialize the Network Service

In your `main.dart`:

```dart
import 'package:admin/network_service/dio_network_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize network service (required)
  NetworkService.initialize();
  
  runApp(MyApp());
}
```

### 2. Make Your First API Call

```dart
// Simple GET request
final users = await NetworkService.getData('users');

// POST request with data
final newUser = await NetworkService.postData(
  {'name': 'John', 'email': 'john@example.com'}, 
  'users'
);
```

## ⚙️ Configuration Setup

### Environment Configuration

#### 1. Configure Base URLs

Edit `app_url_config.dart`:

```dart
class AppUrl {
  // Environment-specific URLs
  static const String devBaseUrl = 'https://dev-api.yourcompany.com/api/v1/';
  static const String stagingBaseUrl = 'https://staging-api.yourcompany.com/api/v1/';
  static const String prodBaseUrl = 'https://api.yourcompany.com/api/v1/';

  // Dynamic URL selection based on environment
  static String getBaseUrl() {
    const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    
    switch (environment.toLowerCase()) {
      case 'prod':
      case 'production':
        return prodBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'dev':
      case 'development':
      default:
        return devBaseUrl;
    }
  }

  // API Endpoints
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String users = 'users';
  static const String profile = 'user/profile';
  // Add your endpoints here...
}
```

#### 2. Network Configuration

Adjust settings in `app_url_config.dart`:

```dart
class NetworkConfig {
  static const bool enableLogging = true; // Set false for production
  static const bool enableDebugMode = true; // Set false for production
  
  // Timeout configurations (in seconds)
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  
  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
}
```

#### 3. Environment Variables

Set environment variables for different builds:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Staging
flutter run --dart-define=ENVIRONMENT=staging

# Production
flutter run --dart-define=ENVIRONMENT=production
```

## 📡 Basic API Usage

### GET Requests

```dart
// Simple GET
final response = await NetworkService.getData('users');

// GET with query parameters
final response = await DioNetworkService.getData(
  'users',
  queryParameters: {
    'page': 1,
    'limit': 10,
    'search': 'john'
  },
);

// GET with authentication
final profile = await NetworkService.getData('profile', bearerToken: true);
```

### POST Requests

```dart
// JSON POST
final userData = {
  'name': 'John Doe',
  'email': 'john@example.com',
  'role': 'admin'
};
final response = await NetworkService.postData(userData, 'users');

// POST with authentication
final response = await NetworkService.postData(
  userData, 
  'users', 
  bearerToken: true
);

// POST with custom error handling
final response = await DioNetworkService.postData(
  userData,
  'users',
  showLoader: false,
  handleError: false, // Handle errors manually
);
```

### PUT Requests

```dart
// PUT with body
final updateData = {'name': 'Updated Name'};
final response = await NetworkService.putDataWithBody(updateData, 'users/123');

// PUT without body (for actions like activate/deactivate)
final response = await NetworkService.putDataWithOutBody('users/123/activate');
```

### DELETE Requests

```dart
// Simple DELETE
final response = await DioNetworkService.deleteData('users/123');

// DELETE with query parameters
final response = await DioNetworkService.deleteData(
  'users/123',
  queryParameters: {'reason': 'inactive'},
);
```

## 🔥 Advanced Features

### Custom Headers

```dart
// Using the API client directly for custom headers
final apiClient = ApiHelper.getApiClient();
final dio = NetworkModule.getDio();

// Add custom headers to a specific request
dio.options.headers.addAll({
  'X-Custom-Header': 'custom-value',
  'X-Request-ID': 'unique-request-id',
});

final response = await apiClient.get('custom-endpoint');
```

### Request/Response Interceptors

Modify `network_module.dart` to add custom interceptors:

```dart
// Add custom interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // Modify request before sending
    options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  },
  onResponse: (response, handler) {
    // Process response data
    print('Response received: ${response.statusCode}');
    handler.next(response);
  },
  onError: (error, handler) {
    // Custom error handling
    print('Request failed: ${error.message}');
    handler.next(error);
  },
));
```

### Caching Requests

```dart
// Add caching interceptor
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

final cacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  hitCacheOnErrorExcept: [401, 403],
  maxStale: const Duration(days: 7),
);

dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
```

## 🆕 Adding New APIs

### Step 1: Define API Endpoints

Add new endpoints to `app_url_config.dart`:

```dart
class AppUrl {
  // ... existing endpoints ...
  
  // New endpoints
  static const String products = 'products';
  static const String orders = 'orders';
  static const String analytics = 'analytics/dashboard';
  static const String uploadDocument = 'documents/upload';
}
```

### Step 2: Add Retrofit Methods

Edit `api_client.dart` to add new API methods:

```dart
@RestApi(baseUrl: '')
abstract class ApiClient {
  // ... existing methods ...

  /// Product Management
  @GET(AppUrl.products)
  Future<HttpResponse<dynamic>> getProducts(
    @Queries() Map<String, dynamic>? queryParameters,
  );

  @GET('${AppUrl.products}/{id}')
  Future<HttpResponse<dynamic>> getProductById(@Path('id') String productId);

  @POST(AppUrl.products)
  Future<HttpResponse<dynamic>> createProduct(@Body() Map<String, dynamic> body);

  @PUT('${AppUrl.products}/{id}')
  Future<HttpResponse<dynamic>> updateProduct(
    @Path('id') String productId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('${AppUrl.products}/{id}')
  Future<HttpResponse<dynamic>> deleteProduct(@Path('id') String productId);

  /// Order Management
  @GET(AppUrl.orders)
  Future<HttpResponse<dynamic>> getOrders(
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('limit') int? limit,
  );

  @POST(AppUrl.orders)
  Future<HttpResponse<dynamic>> createOrder(@Body() Map<String, dynamic> order);

  /// Analytics
  @GET(AppUrl.analytics)
  Future<HttpResponse<dynamic>> getDashboardAnalytics(
    @Query('from') String fromDate,
    @Query('to') String toDate,
  );

  /// File Upload with Progress
  @POST(AppUrl.uploadDocument)
  @MultiPart()
  Future<HttpResponse<dynamic>> uploadDocument(
    @Part() File file,
    @Part() String category,
    @Part() String? description,
  );
}
```

### Step 3: Generate Code

Run the build runner to generate the implementation:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Add High-Level Service Methods

Add convenience methods to `DioNetworkService` class:

```dart
class DioNetworkService {
  // ... existing methods ...

  /// Product Management Methods
  static Future<dynamic> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
      if (category != null) 'category': category,
    };
    
    return await getData('products', queryParameters: queryParams);
  }

  static Future<dynamic> createProduct(Map<String, dynamic> productData) async {
    return await postData(productData, 'products');
  }

  static Future<dynamic> updateProduct(String productId, Map<String, dynamic> productData) async {
    return await putDataWithBody(productData, 'products/$productId');
  }

  static Future<dynamic> deleteProduct(String productId) async {
    return await deleteData('products/$productId');
  }

  /// Order Management Methods
  static Future<dynamic> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    };
    
    return await getData('orders', queryParameters: queryParams);
  }

  static Future<dynamic> createOrder(Map<String, dynamic> orderData) async {
    return await postData(orderData, 'orders');
  }

  /// Analytics Methods
  static Future<dynamic> getDashboardAnalytics({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final queryParams = {
      'from': fromDate.toIso8601String(),
      'to': toDate.toIso8601String(),
    };
    
    return await getData('analytics/dashboard', queryParameters: queryParams);
  }
}
```

### Step 5: Usage Examples

```dart
// Use the new APIs
class ProductService {
  static Future<List<Product>> fetchProducts({String? search}) async {
    try {
      final response = await DioNetworkService.getProducts(
        page: 1,
        limit: 50,
        search: search,
      );
      
      return (response['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  static Future<bool> createProduct(Product product) async {
    try {
      final response = await DioNetworkService.createProduct(product.toJson());
      return response['success'] == true;
    } catch (e) {
      print('Error creating product: $e');
      return false;
    }
  }
}
```

## 🔐 Authentication & Security

### Refresh Token Implementation

The admin app now implements a robust refresh token system that automatically handles token expiration:

#### How It Works

1. **Token Types**:
   - **Access Token**: Short-lived (15 minutes), used for API requests
   - **Refresh Token**: Long-lived (7 days), used to get new access tokens

2. **Automatic Token Refresh**:
   - When an API request receives a 401 (Unauthorized) response
   - The system automatically attempts to refresh the access token
   - If successful, the original request is retried with the new token
   - If refresh fails, the admin is logged out

3. **Token Storage**:
   - Both tokens are securely stored using SharedPreferences
   - Access token stored in `AppConstants.bearerToken`
   - Refresh token stored in `AppConstants.refreshToken`

#### Backend API Compatibility

The implementation is compatible with your backend API:

```json
// Admin Login Response
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here",
  "expires": "2025-01-01T10:15:00Z",
  "refreshExpires": "2025-01-08T10:00:00Z"
}

// Refresh Token Request
POST /api/auth/refresh-token
{
  "refreshToken": "your-refresh-token-here"
}

// Refresh Token Response
{
  "token": "new-jwt-token",
  "refreshToken": "new-refresh-token",
  "expires": "2025-01-01T10:15:00Z",
  "refreshExpires": "2025-01-08T10:00:00Z"
}
```

### Token Management

#### Storing Tokens (Admin Login)

```dart
class AdminAuthService {
  static Future<bool> login(String email, String password) async {
    try {
      final response = await DioNetworkService.login(email, password);
      
      if (response != null && response['token'] != null) {
        // Store both access and refresh tokens automatically
        await DioNetworkService.storeAuthTokens(response);
        return true;
      }
      return false;
    } catch (e) {
      print('Admin login failed: $e');
      return false;
    }
  }
}
```

#### Manual Token Operations

```dart
// Get current tokens
final accessToken = await DioNetworkService.getToken();
final refreshToken = await DioNetworkService.getRefreshToken();

// Check authentication status
final isAuthenticated = await DioNetworkService.isAuthenticated();

// Manual token refresh (usually not needed - handled automatically)
final newTokens = await DioNetworkService.refreshAccessToken();
if (newTokens != null) {
  print('Admin tokens refreshed successfully');
}

// Logout (clears all tokens)
await DioNetworkService.clearToken();
```

#### Network Interceptor

The refresh token logic is implemented in the network interceptor:

```dart
// NetworkModule handles this automatically for admin app
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    final isRefreshRequest = error.requestOptions.path.contains('refresh-token');
    
    if (!isRefreshRequest) {
      final refreshResult = await _tryRefreshToken();
      
      if (refreshResult != null) {
        // Retry original request with new token
        final retryOptions = error.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer ${refreshResult['token']}';
        
        final retryResponse = await _dio!.fetch(retryOptions);
        handler.resolve(retryResponse);
        return;
      }
    }
    
    // Refresh failed - logout admin
    await _handleUnauthorizedError();
  }
  handler.next(error);
}
```

### Security Features

1. **Token Rotation**: Both access and refresh tokens are rotated on each refresh
2. **Automatic Cleanup**: Failed refresh attempts clear all tokens
3. **Loop Prevention**: Refresh requests don't trigger additional refresh attempts
4. **Secure Storage**: Tokens stored in platform-specific secure storage
5. **Admin-specific Logging**: Enhanced logging for administrative operations

### Admin-Specific Error Handling

The system handles admin scenarios gracefully:

- **Network Errors**: Admin tokens preserved until successful refresh or explicit logout
- **Invalid Refresh Token**: Automatic admin logout and redirect to login
- **Backend Errors**: Fallback to manual admin login if refresh consistently fails
- **Permission Errors**: Clear admin session if elevated permissions are revoked

### Usage Examples for Admin Operations

```dart
// Admin dashboard data fetch (automatic token handling)
final dashboardData = await DioNetworkService.getData('api/admin/dashboard');

// Admin user management (automatic token handling)  
final users = await DioNetworkService.getData('api/admin/users');

// Admin ingredient management (automatic token handling)
final ingredients = await DioNetworkService.getData('api/admin/ingredients');

// Admin meal plan management (automatic token handling)
final mealPlans = await DioNetworkService.getData('api/admin/mealplan');
```

### Testing Admin Token Refresh

```dart
// Test admin token refresh functionality
class AdminTokenTest {
  static Future<void> testTokenRefresh() async {
    // Admin login first
    final loginSuccess = await AdminAuthService.login('admin@example.com', 'AdminPass@123');
    assert(loginSuccess);
    
    // Verify admin tokens are stored
    final accessToken = await DioNetworkService.getToken();
    final refreshToken = await DioNetworkService.getRefreshToken();
    assert(accessToken != null);
    assert(refreshToken != null);
    
    // Make admin API calls (will automatically refresh if needed)
    try {
      final adminData = await DioNetworkService.getData('api/admin/dashboard');
      print('Admin API call successful: $adminData');
    } catch (e) {
      print('Admin API call failed: $e');
    }
    
    // Admin logout
    await DioNetworkService.clearToken();
    
    // Verify admin tokens are cleared
    final clearedAccess = await DioNetworkService.getToken();
    final clearedRefresh = await DioNetworkService.getRefreshToken();
    assert(clearedAccess == null);
    assert(clearedRefresh == null);
  }
}
```

## ⚠️ Error Handling

### Built-in Error Types

The service automatically handles these errors:

```dart
// Network errors
- No internet connection
- Request timeout
- SSL certificate errors

// HTTP errors
- 400 Bad Request
- 401 Unauthorized (auto-logout)
- 403 Forbidden
- 404 Not Found
- 429 Too Many Requests
- 500 Internal Server Error
```

### Custom Error Handling

```dart
// Disable automatic error handling
final response = await DioNetworkService.getData(
  'users',
  handleError: false, // Handle errors manually
);

// Custom error handling with try-catch
try {
  final response = await NetworkService.getData('users');
  // Handle success
} on DioException catch (dioError) {
  // Handle Dio-specific errors
  switch (dioError.type) {
    case DioExceptionType.connectionTimeout:
      showCustomError('Connection timeout');
      break;
    case DioExceptionType.badResponse:
      showCustomError('Server error: ${dioError.response?.statusCode}');
      break;
    default:
      showCustomError('Network error occurred');
  }
} catch (e) {
  // Handle other errors
  showCustomError('Unexpected error: $e');
}
```

### Global Error Handler

Create a global error handler:

```dart
class GlobalErrorHandler {
  static void handleError(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          // Handle unauthorized
          _redirectToLogin();
          break;
        case 403:
          // Handle forbidden
          _showNoPermissionDialog();
          break;
        case 500:
          // Handle server error
          _showServerErrorDialog();
          break;
        default:
          _showGenericError(error.message);
      }
    } else {
      _showGenericError(error.toString());
    }
  }
}
```

## 📁 File Operations

### File Upload

```dart
// Single file upload
final file = File('/path/to/document.pdf');
final response = await DioNetworkService.uploadFile(
  file,
  'documents/upload',
  fileName: 'important-document.pdf',
  additionalData: {
    'category': 'contracts',
    'description': 'Important business contract',
  },
);

// Multiple files upload
Future<void> uploadMultipleFiles(List<File> files) async {
  for (final file in files) {
    await DioNetworkService.uploadFile(file, 'documents/upload');
  }
}
```

### File Upload with Progress

```dart
Future<void> uploadWithProgress(File file) async {
  final dio = NetworkModule.getDio();
  
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });

  await dio.post(
    'documents/upload',
    data: formData,
    onSendProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(1);
      print('Upload progress: $progress%');
      // Update UI progress indicator
    },
  );
}
```

### File Download

```dart
Future<void> downloadFile(String url, String savePath) async {
  final dio = NetworkModule.getDio();
  
  await dio.download(
    url,
    savePath,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        final progress = (received / total * 100).toStringAsFixed(1);
        print('Download progress: $progress%');
      }
    },
  );
}
```

## 🧪 Testing & Debugging

### Enable Debug Logging

In `app_url_config.dart`:

```dart
class NetworkConfig {
  static const bool enableLogging = true; // Enable for debugging
  static const bool enableDebugMode = true;
}
```

### Unit Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:admin/network_service/dio_network_service.dart';

void main() {
  group('Network Service Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      NetworkService.initialize();
    });

    test('should fetch users successfully', () async {
      final response = await NetworkService.getData('users');
      expect(response, isNotNull);
    });

    test('should handle authentication', () async {
      final isAuth = await DioNetworkService.isAuthenticated();
      expect(isAuth, isA<bool>());
    });
  });
}
```

### Mock Testing

```dart
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('API Tests with Mocks', () {
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
    });

    test('should return user data', () async {
      // Arrange
      final expectedResponse = {'users': [{'id': 1, 'name': 'John'}]};
      when(mockDio.get('/users')).thenAnswer(
        (_) async => Response(
          data: expectedResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users'),
        ),
      );

      // Act & Assert
      final response = await mockDio.get('/users');
      expect(response.data, equals(expectedResponse));
    });
  });
}
```

### Integration Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Network Integration Tests', () {
    testWidgets('should perform complete login flow', (tester) async {
      // Initialize app
      await tester.pumpWidget(MyApp());
      
      // Perform login
      final response = await DioNetworkService.login('test@example.com', 'password');
      
      // Verify response
      expect(response['success'], isTrue);
      expect(await DioNetworkService.isAuthenticated(), isTrue);
    });
  });
}
```

## ⚡ Performance Optimization

### Connection Pooling

```dart
// Configure connection pool in network_module.dart
dio.options.connectTimeout = Duration(milliseconds: 5000);
dio.options.receiveTimeout = Duration(milliseconds: 3000);

// Add connection pooling
final connectionPool = ConnectionPoolHttp(
  maxConnections: 20,
  maxConnectionsPerHost: 5,
);
```

### Request Batching

```dart
class BatchRequestService {
  static Future<List<dynamic>> batchRequests(List<String> endpoints) async {
    final futures = endpoints.map((endpoint) => 
      NetworkService.getData(endpoint)
    ).toList();
    
    return await Future.wait(futures);
  }
}
```

### Response Caching

```dart
// Implement simple memory cache
class ApiCache {
  static final Map<String, CacheEntry> _cache = {};
  
  static Future<dynamic> getCachedResponse(String key) async {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data;
    }
    return null;
  }
  
  static void cacheResponse(String key, dynamic data, Duration ttl) {
    _cache[key] = CacheEntry(data, DateTime.now().add(ttl));
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;
  
  CacheEntry(this.data, this.expiry);
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

## 🚀 Production Deployment

### Production Configuration

1. **Disable Debug Logging**:
```dart
class NetworkConfig {
  static const bool enableLogging = false; // IMPORTANT: Disable in production
  static const bool enableDebugMode = false;
}
```

2. **Set Production URLs**:
```dart
class AppUrl {
  static const String prodBaseUrl = 'https://api.yourcompany.com/api/v1/';
}
```

3. **Environment Variables**:
```bash
flutter build apk --dart-define=ENVIRONMENT=production
flutter build ios --dart-define=ENVIRONMENT=production
```

### Security Checklist

- [ ] Disable debug logging
- [ ] Use HTTPS URLs only
- [ ] Implement certificate pinning
- [ ] Enable request/response encryption if needed
- [ ] Remove any hardcoded credentials
- [ ] Implement proper token refresh
- [ ] Add request rate limiting
- [ ] Set up error monitoring

### Certificate Pinning

```dart
// Add to network_module.dart
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

dio.interceptors.add(CertificatePinningInterceptor(
  allowedSHAFingerprints: ['YOUR_CERTIFICATE_FINGERPRINT']
));
```

### Error Monitoring

```dart
// Integrate with crash reporting service
import 'package:sentry_flutter/sentry_flutter.dart';

void reportError(dynamic error, StackTrace stackTrace) {
  Sentry.captureException(error, stackTrace: stackTrace);
}
```

## 💡 Best Practices

### 1. API Response Models

Create model classes for type safety:

```dart
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// Usage
final response = await NetworkService.getData('users');
final users = (response['data'] as List)
    .map((json) => User.fromJson(json))
    .toList();
```

### 2. Service Layer Pattern

```dart
class UserService {
  static Future<List<User>> getUsers({int page = 1}) async {
    final response = await DioNetworkService.getData(
      'users',
      queryParameters: {'page': page},
    );
    
    return (response['data'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  static Future<User?> getUserById(String id) async {
    try {
      final response = await DioNetworkService.getData('users/$id');
      return User.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
}
```

### 3. Repository Pattern

```dart
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User?> getUserById(String id);
  Future<bool> createUser(User user);
}

class ApiUserRepository implements UserRepository {
  @override
  Future<List<User>> getUsers() async {
    return await UserService.getUsers();
  }

  @override
  Future<User?> getUserById(String id) async {
    return await UserService.getUserById(id);
  }

  @override
  Future<bool> createUser(User user) async {
    try {
      await DioNetworkService.postData(user.toJson(), 'users');
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### 4. Error Handling Strategy

```dart
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;
  Result.error(this.error) : data = null, isSuccess = false;
}

class UserService {
  static Future<Result<List<User>>> getUsers() async {
    try {
      final response = await NetworkService.getData('users');
      final users = (response['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
      return Result.success(users);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
```

### 5. Loading States

```dart
class ApiState<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  ApiState({this.data, this.isLoading = false, this.error});

  ApiState<T> loading() => ApiState(isLoading: true);
  ApiState<T> success(T data) => ApiState(data: data);
  ApiState<T> failure(String error) => ApiState(error: error);
}
```

## 🔧 Troubleshooting

### Common Issues & Solutions

#### 1. Build Errors

**Problem**: Generated files missing or outdated
```bash
# Solution
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 2. Network Errors

**Problem**: Connection timeout or no internet
```dart
// Check network connectivity
import 'package:internet_connection_checker/internet_connection_checker.dart';

final hasInternet = await InternetConnectionChecker().hasConnection;
if (!hasInternet) {
  // Handle offline state
  showOfflineMessage();
}
```

#### 3. Authentication Issues

**Problem**: Token not being sent or expired
```dart
// Debug token issues
final token = await DioNetworkService.getToken();
print('Current token: $token');

if (token == null) {
  // User needs to login
  redirectToLogin();
}
```

#### 4. API Response Issues

**Problem**: Unexpected response format
```dart
// Add response validation
final response = await NetworkService.getData('users');
if (response is Map<String, dynamic> && response.containsKey('data')) {
  // Valid response
  processData(response['data']);
} else {
  // Invalid response format
  throw Exception('Invalid API response format');
}
```

### Debug Commands

```bash
# Analyze code issues
flutter analyze

# Run tests
flutter test

# Check network connectivity
adb shell settings put global http_proxy <proxy_host>:<proxy_port>

# Generate API client
flutter packages pub run build_runner build

# Clean build cache
flutter clean && flutter pub get
```

### Logging Network Requests

```dart
// Add detailed logging
class NetworkLogger {
  static void logRequest(RequestOptions options) {
    print('🚀 REQUEST: ${options.method} ${options.path}');
    print('📝 Headers: ${options.headers}');
    print('📦 Data: ${options.data}');
  }

  static void logResponse(Response response) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    print('📄 Data: ${response.data}');
  }

  static void logError(DioException error) {
    print('❌ ERROR: ${error.message}');
    print('📍 Path: ${error.requestOptions.path}');
    print('📊 Status: ${error.response?.statusCode}');
  }
}
```

## 📚 Additional Resources

### Useful Packages

```yaml
dependencies:
  # Core networking
  dio: ^5.8.0+1
  retrofit: ^4.2.0
  
  # Logging
  talker_dio_logger: ^4.4.1
  pretty_dio_logger: ^1.4.0
  
  # Caching
  dio_cache_interceptor: ^3.4.2
  
  # Security
  dio_certificate_pinning: ^6.0.0
  
  # Connectivity
  internet_connection_checker: ^3.0.1
  
  # Testing
  mockito: ^5.4.2
  dio_test: ^0.2.0
```

### Documentation Links

- [Dio Documentation](https://pub.dev/packages/dio)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Flutter Network Documentation](https://flutter.dev/docs/cookbook/networking)

---

## 🎯 Quick Reference

### Essential Commands
```bash
# Initialize project
flutter packages pub run build_runner build

# Clean and rebuild
flutter clean && flutter pub get

# Run with environment
flutter run --dart-define=ENVIRONMENT=dev

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Key Classes
- `NetworkService` - Main service interface (backward compatible)
- `DioNetworkService` - Advanced Dio-based service
- `ApiClient` - Retrofit API definitions
- `NetworkModule` - Dio configuration
- `ApiHelper` - Utility functions

Now you're ready to become an expert with this network service! 🚀

---

*Happy coding! 💻* 