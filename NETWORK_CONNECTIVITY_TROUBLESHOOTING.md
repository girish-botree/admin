# Network Connectivity Troubleshooting Guide

## Overview
This guide helps you troubleshoot network connectivity issues in the Flutter Admin app. The app now includes comprehensive network monitoring and error handling.

## Common Issues and Solutions

### 1. "No Network" Error Despite Being Connected

**Symptoms:**
- App shows "No Internet Connection" message
- API calls fail with network errors
- You have internet access in other apps

**Possible Causes:**
- DNS resolution issues
- Firewall blocking the app
- Network configuration problems
- App permissions

**Solutions:**

#### A. Check App Permissions
```bash
# For Android, ensure these permissions are in AndroidManifest.xml:
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### B. Test Network Connectivity
Use the Network Test Widget in the app:
1. Navigate to the Network Test screen
2. Run the "Quick Connection Test"
3. If it fails, try the "Detailed Stability Test"

#### C. Check DNS Settings
The app uses multiple DNS servers for reliability:
- Google DNS (8.8.8.8)
- Cloudflare DNS (1.1.1.1)
- OpenDNS (208.67.222.222)

#### D. Restart Network Services
```bash
# On your device:
1. Turn off WiFi
2. Turn off Mobile Data
3. Wait 10 seconds
4. Turn on WiFi/Mobile Data
5. Restart the app
```

### 2. Intermittent Connection Issues

**Symptoms:**
- Connection works sometimes but fails randomly
- Timeout errors
- Inconsistent API responses

**Solutions:**

#### A. Increase Timeout Values
The app uses configurable timeouts:
- Connection timeout: 30 seconds
- Receive timeout: 30 seconds
- Send timeout: 30 seconds

#### B. Enable Retry Logic
The app automatically retries failed requests for:
- Network timeouts
- 5xx server errors
- Connection errors

#### C. Check Network Stability
Use the "Detailed Stability Test" to check if your network is stable.

### 3. API Server Connection Issues

**Symptoms:**
- Network is working but API calls fail
- Specific endpoints not responding
- Server errors

**Solutions:**

#### A. Check API Base URL
Verify the API base URL in `lib/network_service/app_url_config.dart`:
```dart
static String getBaseUrl() {
  // Ensure this points to your correct API server
  return 'https://your-api-server.com';
}
```

#### B. Test API Endpoints
Use tools like Postman or curl to test API endpoints directly:
```bash
curl -X GET https://your-api-server.com/api/health
```

#### C. Check Server Status
- Verify the API server is running
- Check server logs for errors
- Ensure CORS is properly configured for web builds

### 4. Web-Specific Issues

**Symptoms:**
- App works on mobile but not on web
- CORS errors in browser console
- Network requests blocked

**Solutions:**

#### A. CORS Configuration
Ensure your API server allows requests from your web domain:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

#### B. Browser Network Settings
- Disable browser extensions that might block requests
- Check browser's network tab for failed requests
- Clear browser cache and cookies

### 5. Mobile-Specific Issues

**Symptoms:**
- App works on web but not on mobile
- Network requests timeout on mobile
- App crashes on network errors

**Solutions:**

#### A. Check Mobile Permissions
Ensure the app has internet permissions:
```xml
<!-- Android -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- iOS -->
<!-- Add to Info.plist if needed -->
```

#### B. Test on Different Networks
- Try WiFi vs Mobile Data
- Test on different WiFi networks
- Check if corporate networks block the app

#### C. Check Device Settings
- Ensure airplane mode is off
- Check if data saver is enabled
- Verify VPN settings

## Debugging Tools

### 1. Network Test Widget
The app includes a built-in network test widget:
```dart
// Navigate to NetworkTestWidget to test connectivity
```

### 2. Debug Logs
Enable debug logging to see network requests:
```dart
// Check console logs for network-related messages
// Look for "Network connection restored" or "Network connection lost"
```

### 3. Error Handling
Use proper error handling for network operations:
```dart
// Show loading indicators during network operations
// Handle errors with user-friendly messages
// Provide retry mechanisms where appropriate
```

## Best Practices

### 1. Handle Network Errors in API Calls
```dart
try {
  final response = await apiCall();
} catch (e) {
  // Handle network errors gracefully
  if (e.toString().contains('network') || e.toString().contains('connection')) {
    // Show network-specific error
  } else {
    // Show general error
  }
}
```

### 2. Handle Network Errors Gracefully
```dart
// Use try-catch blocks to handle network errors
try {
  // Your network operations
} catch (e) {
  // Show appropriate error message
}
```

### 3. Handle Network Errors Gracefully
```dart
try {
  final response = await apiCall();
} catch (e) {
  if (e.toString().contains('network')) {
    // Show network-specific error
  } else {
    // Show general error
  }
}
```

## Configuration

### Network Timeouts
Adjust timeouts in `lib/network_service/network_module.dart`:
```dart
connectTimeout: Duration(milliseconds: 30000), // 30 seconds
receiveTimeout: Duration(milliseconds: 30000), // 30 seconds
sendTimeout: Duration(milliseconds: 30000),    // 30 seconds
```

### Retry Configuration
Configure retry logic in `lib/network_service/network_module.dart`:
```dart
static const int maxRetries = 3;
static const int retryDelaySeconds = 2;
```

## Testing Network Connectivity

### Manual Testing
1. Test API calls with different network conditions
2. Check error handling and user feedback
3. Verify retry mechanisms work properly
4. Test on different devices and networks

### Error Handling
The app includes robust error handling that:
- Catches network-related errors
- Shows user-friendly error messages
- Provides retry options where appropriate
- Handles different types of network failures

## Support

If you continue to experience network issues:

1. **Review debug logs** for specific error messages
2. **Test on different devices/networks** to isolate the issue
3. **Verify API server status** and configuration
4. **Check app permissions** and device settings
5. **Test with different network conditions** (WiFi, mobile data, etc.)

## Recent Improvements

The app has been updated with:
- ✅ Robust error handling for network operations
- ✅ User-friendly error messages
- ✅ Retry logic for failed requests
- ✅ Comprehensive debugging tools
- ✅ Graceful handling of network failures

These improvements should resolve most network connectivity issues and provide better user experience when network problems occur.
