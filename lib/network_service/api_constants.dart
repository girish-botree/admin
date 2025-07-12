// API version configuration
const String apiVersion = '/v1';

// Authentication configuration keys
const String keyNoNeedAuthToken = 'noNeedAuthToken';
const Map<String, bool> extraNoNeedAuthToken = {keyNoNeedAuthToken: true};

// Request encryption configuration keys
const String keyNeedToEncryptRequest = 'needToEncryptRequest';
const Map<String, bool> extraNoNeedToEncryptRequest = {keyNeedToEncryptRequest: false};

// Response decryption configuration keys
const String keyNeedToDecryptResponse = 'needToDecryptResponse';
const Map<String, bool> extraNoNeedToDecryptResponse = {keyNeedToDecryptResponse: false};

// Request/Response timeout configuration
const int connectTimeout = 30000; // 30 seconds
const int receiveTimeout = 30000; // 30 seconds
const int sendTimeout = 30000; // 30 seconds

// Content type constants
const String contentTypeJson = 'application/json; charset=utf-8';
const String contentTypeFormData = 'multipart/form-data';
const String contentTypeText = 'text/plain; charset=utf-8';

// HTTP status codes
const int statusCodeOk = 200;
const int statusCodeCreated = 201;
const int statusCodeAccepted = 202;
const int statusCodeBadRequest = 400;
const int statusCodeUnauthorized = 401;
const int statusCodeForbidden = 403;
const int statusCodeNotFound = 404;
const int statusCodeMethodNotAllowed = 405;
const int statusCodeRequestTimeout = 408;
const int statusCodeConflict = 409;
const int statusCodeUnprocessableEntity = 422;
const int statusCodeTooManyRequests = 429;
const int statusCodeInternalServerError = 500;
const int statusCodeBadGateway = 502;
const int statusCodeServiceUnavailable = 503;
const int statusCodeGatewayTimeout = 504;

// Error messages
const String errorNoInternet = 'No internet connection available';
const String errorTimeout = 'Request timeout. Please try again';
const String errorServerError = 'Internal server error occurred';
const String errorUnknown = 'An unexpected error occurred';
const String errorBadRequest = 'Bad request. Please check your input';
const String errorUnauthorized = 'Unauthorized access. Please login again';
const String errorForbidden = 'Access forbidden';
const String errorNotFound = 'Resource not found';
const String errorTooManyRequests = 'Too many requests. Please try again later'; 