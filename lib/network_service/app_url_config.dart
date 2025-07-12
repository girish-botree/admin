/// App URL Configuration
/// This class manages base URLs for different environments
class AppUrl {
  // Environment-based base URL configuration
  // You can set this via environment variables or build configurations
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL', 
    defaultValue: 'https://your-api-domain.com/api/'
  );

  // Alternative URLs for different environments
  static const String devBaseUrl = 'https://dev-api.your-domain.com/api/';
  static const String stagingBaseUrl = 'https://staging-api.your-domain.com/api/';
  static const String prodBaseUrl = 'https://api.your-domain.com/api/';

  // Get base URL based on environment
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

  // API endpoints
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';
  static const String profile = 'user/profile';
  static const String authenticate = 'auth/authenticate';
  
  // Add more endpoints as needed
  static const String users = 'users';
  static const String uploads = 'uploads';
  static const String downloads = 'downloads';
  
  // File upload endpoints
  static const String uploadImage = 'upload/image';
  static const String uploadFile = 'upload/file';
  
  // Configuration endpoints
  static const String appConfig = 'config/app';
  static const String appVersion = 'config/version';
}

/// Network Configuration
class NetworkConfig {
  static const bool enableLogging = true;
  static const bool enableEncryption = false; // Set to true if you need encryption
  static const bool enableDebugMode = true; // Should be false in production
  
  // Timeout configurations
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  
  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
}

