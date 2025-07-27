/// App URL Configuration
/// This class manages base URLs for different environments
class AppUrl {
  // Environment-based base URL configuration
  // You can set this via environment variables or build configurations
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL', 
    defaultValue: 'https://elithapi-606254752351.asia-south1.run.app/'
  );

  // Alternative URLs for different environments
  static const String devBaseUrl = 'https://elithapi-606254752351.asia-south1.run.app/';
  static const String stagingBaseUrl = 'https://elithapi-606254752351.asia-south1.run.app/';
  static const String prodBaseUrl = 'https://elithapi-606254752351.asia-south1.run.app/';

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
  static const String login = 'api/Auth/login'; //live
  static const String logout = 'api/Auth/logout';
  static const String refreshToken = 'api/Auth/refresh';
  static const String profile = 'api/Auth/profile';
  static const String authenticate = 'api/Auth/authenticate';
  static const String sendOtp = 'api/Auth/send-otp';
  static const String registerAdmin = 'api/Auth/register-admin';
  static const String registerDeliveryPerson = 'api/Auth/register-delivery-agent';

  // Recipe endpoints
  static const String recipes = 'api/Admin/recipes';

  // Ingredient endpoints
  static const String ingredients = 'api/Admin/ingredients';
  static const String ingredient = 'api/Admin/ingredient';

  // Add more endpoints as needed
  static const String users = 'api/users';
  static const String uploads = 'api/uploads';
  static const String downloads = 'api/downloads';

  // File upload endpoints
  static const String uploadImage = 'api/upload/image';
  static const String uploadFile = 'api/upload/file';

  // Configuration endpoints
  static const String appConfig = 'api/config/app';
  static const String appVersion = 'api/config/version';
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

