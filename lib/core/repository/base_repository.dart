import 'package:get/get.dart';
import '../../network_service/api_helper.dart';

/// Base Repository Pattern
/// Provides common CRUD operations and error handling
abstract class BaseRepository<T> {
  final String endpoint;
  
  BaseRepository(this.endpoint);

  /// Generic GET request with error handling
  Future<List<T>> getAll({
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
  }) async {
    try {
      final response = await ApiHelper.callApi(
        () => _makeGetRequest(queryParameters),
        showLoadingIndicator: showLoading,
      );

      if (response?.response.statusCode == 200) {
        final responseData = response?.data;
        if (responseData is Map<String, dynamic> && responseData['data'] is List) {
          final dataList = responseData['data'] as List;
          return dataList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      _handleError('Failed to fetch $endpoint', e);
      return [];
    }
  }

  /// Generic GET by ID request
  Future<T?> getById(String id, {bool showLoading = true}) async {
    try {
      final response = await ApiHelper.callApi(
        () => _makeGetByIdRequest(id),
        showLoadingIndicator: showLoading,
      );

      if (response?.response.statusCode == 200) {
        final responseData = response?.data;
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          return fromJson(responseData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      _handleError('Failed to fetch $endpoint/$id', e);
      return null;
    }
  }

  /// Generic POST request
  Future<bool> create(Map<String, dynamic> data, {bool showLoading = true}) async {
    try {
      final response = await ApiHelper.callApi(
        () => _makeCreateRequest(data),
        showLoadingIndicator: showLoading,
      );

      return response?.response.statusCode == 200 || response?.response.statusCode == 201;
    } catch (e) {
      _handleError('Failed to create $endpoint', e);
      return false;
    }
  }

  /// Generic PUT request
  Future<bool> update(String id, Map<String, dynamic> data, {bool showLoading = true}) async {
    try {
      final response = await ApiHelper.callApi(
        () => _makeUpdateRequest(id, data),
        showLoadingIndicator: showLoading,
      );

      return response?.response.statusCode == 200;
    } catch (e) {
      _handleError('Failed to update $endpoint/$id', e);
      return false;
    }
  }

  /// Generic DELETE request
  Future<bool> delete(String id, {bool showLoading = true}) async {
    try {
      final response = await ApiHelper.callApi(
        () => _makeDeleteRequest(id),
        showLoadingIndicator: showLoading,
      );

      return response?.response.statusCode == 200;
    } catch (e) {
      _handleError('Failed to delete $endpoint/$id', e);
      return false;
    }
  }

  /// Abstract methods for specific API calls
  /// These should be implemented by concrete repositories
  Future<dynamic> _makeGetRequest(Map<String, dynamic>? queryParameters);
  Future<dynamic> _makeGetByIdRequest(String id);
  Future<dynamic> _makeCreateRequest(Map<String, dynamic> data);
  Future<dynamic> _makeUpdateRequest(String id, Map<String, dynamic> data);
  Future<dynamic> _makeDeleteRequest(String id);

  /// Convert JSON to model
  T fromJson(Map<String, dynamic> json);

  /// Convert model to JSON
  Map<String, dynamic> toJson(T model);

  /// Handle errors consistently
  void _handleError(String message, dynamic error) {
    
    // TODO: Implement proper error logging and user notification
  }
}
