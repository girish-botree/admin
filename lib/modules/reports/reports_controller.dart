import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:retrofit/retrofit.dart';
import '../../network_service/api_client.dart';
import '../../network_service/dio_network_service.dart';
import '../../widgets/custom_displays.dart';

class ReportSummary {
  final int totalDeliveries;
  final int delivered;
  final int pending;
  final int customizedMeals;
  final String deliveryDate;
  final String mealPeriod;

  ReportSummary({
    required this.totalDeliveries,
    required this.delivered,
    required this.pending,
    required this.customizedMeals,
    required this.deliveryDate,
    required this.mealPeriod,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalDeliveries: json['totalDeliveries'] != null
          ? json['totalDeliveries'] as int
          : 0,
      delivered: json['delivered'] != null ? json['delivered'] as int : 0,
      pending: json['pending'] != null ? json['pending'] as int : 0,
      customizedMeals: json['customizedMeals'] != null
          ? json['customizedMeals'] as int
          : 0,
      deliveryDate: json['deliveryDate'] != null
          ? json['deliveryDate'].toString()
          : '',
      mealPeriod: json['mealPeriod'] != null
          ? json['mealPeriod'].toString()
          : '',
    );
  }
}

class DeliveryDetail {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String deliveryAddress;
  final String city;
  final String state;
  final String postalCode;
  final String landmark;
  final String deliveryInstructions;
  final String subscriptionId;
  final String subscriptionPlanName;
  final String subscriptionPlanType;
  final String mealPlanId;
  final String mealDate;
  final String mealPeriod;
  final String originalCategory;
  final String currentCategory;
  final bool isCustomized;
  final String customizationReason;
  final String recipeId;
  final String recipeName;
  final String recipeDescription;
  final String recipeCuisine;
  final int recipeServings;
  final double recipeCalories;
  final double recipeProtein;
  final double recipeCarbohydrates;
  final double recipeFat;
  final String recipeImageUrl;
  final bool isDelivered;
  final String? deliveredAt;
  final String deliveredBy;

  DeliveryDetail({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.deliveryAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.landmark,
    required this.deliveryInstructions,
    required this.subscriptionId,
    required this.subscriptionPlanName,
    required this.subscriptionPlanType,
    required this.mealPlanId,
    required this.mealDate,
    required this.mealPeriod,
    required this.originalCategory,
    required this.currentCategory,
    required this.isCustomized,
    required this.customizationReason,
    required this.recipeId,
    required this.recipeName,
    required this.recipeDescription,
    required this.recipeCuisine,
    required this.recipeServings,
    required this.recipeCalories,
    required this.recipeProtein,
    required this.recipeCarbohydrates,
    required this.recipeFat,
    required this.recipeImageUrl,
    required this.isDelivered,
    this.deliveredAt,
    required this.deliveredBy,
  });

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryDetail(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Unknown',
      userEmail: json['userEmail']?.toString() ?? '',
      userPhone: json['userPhone']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      deliveryInstructions: json['deliveryInstructions']?.toString() ?? '',
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      subscriptionPlanName: json['subscriptionPlanName']?.toString() ??
          'Unknown',
      subscriptionPlanType: json['subscriptionPlanType']?.toString() ?? '',
      mealPlanId: json['mealPlanId']?.toString() ?? '',
      mealDate: json['mealDate']?.toString() ?? '',
      mealPeriod: json['mealPeriod']?.toString() ?? '',
      originalCategory: json['originalCategory']?.toString() ?? '',
      currentCategory: json['currentCategory']?.toString() ?? '',
      isCustomized: json['isCustomized'] == true,
      customizationReason: json['customizationReason']?.toString() ?? '',
      recipeId: json['recipeId']?.toString() ?? '',
      recipeName: json['recipeName']?.toString() ?? 'Unknown Recipe',
      recipeDescription: json['recipeDescription']?.toString() ?? '',
      recipeCuisine: json['recipeCuisine']?.toString() ?? '',
      recipeServings: int.tryParse(json['recipeServings']?.toString() ?? '1') ??
          1,
      recipeCalories: double.tryParse(
          json['recipeCalories']?.toString() ?? '0') ?? 0.0,
      recipeProtein: double.tryParse(
          json['recipeProtein']?.toString() ?? '0') ?? 0.0,
      recipeCarbohydrates: double.tryParse(
          json['recipeCarbohydrates']?.toString() ?? '0') ?? 0.0,
      recipeFat: double.tryParse(json['recipeFat']?.toString() ?? '0') ?? 0.0,
      recipeImageUrl: json['recipeImageUrl']?.toString() ?? '',
      isDelivered: json['isDelivered'] == true,
      deliveredAt: json['deliveredAt']?.toString(),
      deliveredBy: json['deliveredBy']?.toString() ?? '',
    );
  }

  String get status => isDelivered ? 'Delivered' : 'Pending';

  String get address => '$deliveryAddress, $city, $state $postalCode';

  String get phone => userPhone;

  String get notes => deliveryInstructions;

  String get customerName => userName;

  String get subscriptionName => subscriptionPlanName;

  String get mealPlanName => currentCategory;
}

class ExcelReportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? message;

  ExcelReportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.message,
  });
}

class ReportsController extends GetxController {
  final RxBool isLoadingDates = false.obs;
  final RxBool isLoadingReportData = false.obs;
  final RxBool isGeneratingExcel = false.obs;

  final RxList<String> availableDates = <String>[].obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxInt selectedMealPeriod = 0.obs; // Default to Breakfast

  final RxMap<String, dynamic> reportData = <String, dynamic>{}.obs;

  final RxBool isGridView = false.obs; // Added for grid/list view toggle

  // Property to store the path of the last downloaded Excel file
  final RxString lastDownloadedFilePath = ''.obs;

  // Date range filtering
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxBool isDateRangeActive = false.obs;
  final RxBool isRefreshing = false.obs;

  // Computed properties
  ReportSummary get reportSummary {
    if (reportData.isEmpty || reportData['summary'] == null) {
      return ReportSummary(
        totalDeliveries: 0,
        delivered: 0,
        pending: 0,
        customizedMeals: 0,
        deliveryDate: '',
        mealPeriod: '',
      );
    }
    return ReportSummary.fromJson(
        reportData['summary'] as Map<String, dynamic>);
  }

  List<DeliveryDetail> get deliveries {
    if (reportData.isEmpty || reportData['data'] == null) {
      return [];
    }
    return (reportData['data'] as List<dynamic>)
        .map((item) => DeliveryDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAvailableDates();
  }

  Future<void> fetchAvailableDates() async {
    isLoadingDates.value = true;
    try {
      final response = await DioNetworkService.getDeliveryReportAvailableDates(
          showLoader: false);

      if (response != null) {
        if (response is Map<String, dynamic> &&
            response['success'] == true &&
            response['data'] != null) {
          final List<dynamic> dates = response['data'] as List<dynamic>;
          availableDates.value = dates.map((date) => date.toString()).toList();
        } else if (response is List<dynamic>) {
          // Handle case where API directly returns a list of dates
          availableDates.value =
              response.map((date) => date.toString()).toList();
        } else {
          // If API doesn't return valid data, provide fallback dates for testing
          _provideFallbackDates();
        }
      } else {
        // Fallback to test dates if API call fails
        _provideFallbackDates();

        Get.snackbar(
          'Notice',
          'Could not fetch available dates from server. Using sample dates.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.tertiaryContainer,
          colorText: Get.theme.colorScheme.onTertiaryContainer,
          duration: const Duration(seconds: 3),
        );
      }

      // Set default selected date if we have dates
      if (availableDates.isNotEmpty) {
        selectedDate.value = DateTime.parse(availableDates.first);
      }

      // Set default date range with last 7 days if we have dates
      if (availableDates.isNotEmpty) {
        final latestDate = availableDates
            .map((dateStr) => DateTime.parse(dateStr))
            .reduce((a, b) => a.isAfter(b) ? a : b);

        endDate.value = latestDate;
        startDate.value = latestDate.subtract(const Duration(days: 7));
      }
    } catch (e) {
      // Fallback to test dates if API call fails
      _provideFallbackDates();

      Get.snackbar(
        'Notice',
        'Using sample delivery dates for demonstration.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.tertiaryContainer,
        colorText: Get.theme.colorScheme.onTertiaryContainer,
      );
    } finally {
      isLoadingDates.value = false;
    }
  }

  void _provideFallbackDates() {
    // Provide 7 days starting from today for testing
    final now = DateTime.now();
    final dates = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return DateFormat('yyyy-MM-dd').format(date);
    });
    availableDates.value = dates;
  }

  Future<String> getAuthToken() async {
    // In a real app, this would retrieve the token from secure storage
    // For this example, we'll return a placeholder
    return 'your_auth_token_here';
  }

  Future<void> loadReportData() async {
    if (selectedDate.value == null) return;

    isLoadingReportData.value = true;
    reportData.clear();

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(
          selectedDate.value!);

      final requestBody = {
        "deliveryDate": formattedDate,
        "mealPeriod": selectedMealPeriod.value,
      };

      debugPrint('Fetching report data with request: $requestBody');

      final response = await DioNetworkService.getDeliveryReportData(
        formattedDate,
        selectedMealPeriod.value,
        showLoader: false,
      );

      if (response != null) {
        if (response is Map<String, dynamic> &&
            response['success'] == true &&
            response['data'] != null) {
          final Map<String, dynamic> reportDataMap = response['data'] as Map<
              String,
              dynamic>;
          reportData.value = reportDataMap;
          debugPrint('Report data loaded successfully with ${deliveries
              .length} deliveries');
        } else {
          final message = response is Map<String, dynamic> &&
              response['message'] != null
              ? response['message'].toString()
              : 'Please try again.';

          Get.snackbar(
            'Error',
            'Failed to load report data. $message',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load report data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      debugPrint('Error loading report data: $e');
      Get.snackbar(
        'Error',
        'An error occurred while loading report data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingReportData.value = false;
    }
  }

  Future<ExcelReportResult?> generateExcelReport() async {
    if (selectedDate.value == null) return null;

    isGeneratingExcel.value = true;

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(
          selectedDate.value!);
      final mealPeriods = ['Breakfast', 'Lunch', 'Dinner'];
      final periodName = mealPeriods[selectedMealPeriod.value];
      final fileName = "DeliveryReport_${formattedDate}_$periodName.xlsx";

      await Future.delayed(const Duration(seconds: 2));

      try {
        final response = await DioNetworkService.generateDeliveryReportExcel(
          formattedDate,
          selectedMealPeriod.value,
          showLoader: false,
        );

        if (response != null &&
            response is Map<String, dynamic> &&
            response['fileUrl'] != null) {
          final filePath = response['fileUrl'].toString();
          return ExcelReportResult(
            success: true,
            filePath: filePath,
            fileName: fileName
          );
        }
      } catch (apiError) {
        debugPrint('API error: $apiError - using demo mode instead');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(
          'This is a placeholder Excel file for demonstration purposes.');

      Get.snackbar(
        'Demo Mode',
        'A placeholder Excel file has been created at $filePath',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surfaceVariant,
        colorText: Get.theme.colorScheme.onSurfaceVariant,
        duration: const Duration(seconds: 3),
      );

      return ExcelReportResult(
          success: true,
          filePath: filePath,
          fileName: fileName
      );
    } catch (e) {
      final errorMessage = 'An error occurred while generating Excel report: ${e
          .toString()}';
      _showDownloadError(errorMessage);
      return ExcelReportResult(success: false, message: errorMessage);
    } finally {
      isGeneratingExcel.value = false;
    }
  }

  Future<ExcelReportResult?> generateDateRangeExcelReport() async {
    if (startDate.value == null || endDate.value == null) return null;

    isGeneratingExcel.value = true;

    try {
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(
          startDate.value!);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate.value!);
      final mealPeriods = ['Breakfast', 'Lunch', 'Dinner'];
      final periodName = mealPeriods[selectedMealPeriod.value];
      final fileName = "DeliveryReport_${formattedStartDate}_to_${formattedEndDate}_$periodName.xlsx";

      await Future.delayed(const Duration(seconds: 2));

      try {
        final requestBody = {
          "startDate": formattedStartDate,
          "endDate": formattedEndDate,
          "mealPeriod": selectedMealPeriod.value
        };

        final response = await DioNetworkService
            .generateDeliveryReportExcelRange(
          formattedStartDate,
          formattedEndDate,
          selectedMealPeriod.value,
          showLoader: false,
        );

        if (response != null &&
            response is Map<String, dynamic> &&
            response['fileUrl'] != null) {
          final filePath = response['fileUrl'].toString();
          return ExcelReportResult(
              success: true,
              filePath: filePath,
              fileName: fileName
          );
        }
      } catch (apiError) {
        debugPrint('API error: $apiError - using demo mode instead');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(
          'This is a placeholder Excel file for date range report demonstration purposes.');

      Get.snackbar(
        'Demo Mode',
        'A placeholder Excel file has been created for date range report at $filePath',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surfaceVariant,
        colorText: Get.theme.colorScheme.onSurfaceVariant,
        duration: const Duration(seconds: 3),
      );

      return ExcelReportResult(
          success: true,
          filePath: filePath,
          fileName: fileName
      );
    } catch (e) {
      final errorMessage = 'An error occurred while generating date range Excel report: ${e
          .toString()}';
      _showDownloadError(errorMessage);
      return ExcelReportResult(success: false, message: errorMessage);
    } finally {
      isGeneratingExcel.value = false;
    }
  }

  Future<void> loadDateRangeReportData() async {
    if (startDate.value == null || endDate.value == null) return;

    isLoadingReportData.value = true;
    reportData.clear();

    try {
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(
          startDate.value!);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate.value!);

      final requestBody = {
        "startDate": formattedStartDate,
        "endDate": formattedEndDate,
        "mealPeriod": selectedMealPeriod.value
      };

      debugPrint('Fetching date range report data with request: $requestBody');

      final response = await DioNetworkService.getDeliveryReportDateRangeData(
        formattedStartDate,
        formattedEndDate,
        selectedMealPeriod.value,
        showLoader: false,
      );

      if (response != null) {
        if (response is Map<String, dynamic> &&
            response['success'] == true &&
            response['data'] != null) {
          final Map<String, dynamic> reportDataMap = response['data'] as Map<
              String,
              dynamic>;
          reportData.value = reportDataMap;
          debugPrint(
              'Date range report data loaded successfully with ${deliveries
                  .length} deliveries');
        } else {
          final message = response is Map<String, dynamic> &&
              response['message'] != null
              ? response['message'].toString()
              : 'Please try again.';

          Get.snackbar(
            'Error',
            'Failed to load date range report data. $message',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load date range report data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      debugPrint('Error loading date range report data: $e');
      Get.snackbar(
        'Error',
        'An error occurred while loading date range report data: ${e
            .toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingReportData.value = false;
    }
  }

  void toggleDateRangeMode() {
    isDateRangeActive.value = !isDateRangeActive.value;
    if (isDateRangeActive.value) {
      // Switch to date range mode - load data if start and end dates are set
      if (startDate.value != null && endDate.value != null) {
        loadDateRangeReportData();
      }
    } else {
      // Switch back to single date mode - load data if date is selected
      if (selectedDate.value != null) {
        loadReportData();
      }
    }
  }

  Future<void> refreshReportData() async {
    isRefreshing.value = true;
    try {
      if (isDateRangeActive.value) {
        await loadDateRangeReportData();
      } else {
        await loadReportData();
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  void openExcelFile(String filePath) async {
    try {
      CustomDisplays.showToast(
        message: 'Opening Excel file...',
        type: MessageType.info,
      );

      // Handle demo paths that start with /downloads/
      if (filePath.startsWith('/downloads/')) {
        Get.snackbar(
          'Demo Mode',
          'In a real app, this would open the Excel file "${filePath
              .split('/')
              .last}"',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.surfaceVariant,
          colorText: Get.theme.colorScheme.onSurfaceVariant,
          duration: const Duration(seconds: 4),
          borderRadius: 8,
          mainButton: TextButton.icon(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            label: const Text('OK', style: TextStyle(color: Colors.blue)),
            onPressed: () => Get.back(),
          ),
        );
        return;
      }

      // Handle web URLs (http/https)
      if (filePath.startsWith('http')) {
        final Uri uri = Uri.parse(filePath);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $uri');
        }
      }
      // Handle local file paths
      else {
        final file = File(filePath);
        if (await file.exists()) {
          // Use Share.shareXFiles which handles the FileProvider details internally
          final xFile = XFile(filePath);
          await Share.shareXFiles(
            [xFile],
            subject: 'Delivery Report',
            text: 'Please find attached delivery report',
          );
        } else {
          throw Exception('File does not exist at path: $filePath');
        }
      }

      CustomDisplays.showToast(
        message: 'Excel file opened successfully',
        type: MessageType.success,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error opening Excel file: $e');
      CustomDisplays.showToast(
        message: 'Failed to open Excel file: ${e.toString()}',
        type: MessageType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _showDownloadError(String message) {
    CustomDisplays.showToast(
      message: message,
      type: MessageType.error,
      duration: const Duration(seconds: 4),
    );
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }
}