import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';

/// Low-level HTTP API Service communicating with the REST API provider.
class VisitorApiService {
  final Dio _dio;

  VisitorApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// GET /visitors
  /// Fetches all visitors from the REST API.
  Future<List<Map<String, dynamic>>> fetchVisitors() async {
    try {
      final response = await _dio.get(AppConstants.visitorsEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } else {
        throw const ParseException(
          'Unexpected response format: Expected a list of visitors.',
        );
      }
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException('Failed to parse visitors list: ${e.toString()}');
    }
  }

  /// GET /visitors/{id}
  /// Fetches a single visitor by their server-assigned ID.
  Future<Map<String, dynamic>> fetchVisitorById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.visitorsEndpoint}/$id');

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw const ParseException(
          'Unexpected response format: Expected a visitor object.',
        );
      }
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException('Failed to parse visitor data: ${e.toString()}');
    }
  }

  /// POST /visitors
  /// Registers a new visitor. Server assigns and returns the unique ID.
  Future<Map<String, dynamic>> createVisitor(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        AppConstants.visitorsEndpoint,
        data: payload,
      );

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw const ParseException(
          'Unexpected response format upon visitor creation.',
        );
      }
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException('Failed to create visitor: ${e.toString()}');
    }
  }

  /// PUT /visitors/{id}
  /// Updates an existing visitor's fields, status, or timestamps.
  Future<Map<String, dynamic>> updateVisitor(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      // MockAPI supports both PUT and PATCH
      final response = await _dio.put(
        '${AppConstants.visitorsEndpoint}/$id',
        data: payload,
      );

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw const ParseException(
          'Unexpected response format upon visitor update.',
        );
      }
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException('Failed to update visitor: ${e.toString()}');
    }
  }

  /// DELETE /visitors/{id}
  /// Deletes a visitor record by ID.
  Future<void> deleteVisitor(String id) async {
    try {
      await _dio.delete('${AppConstants.visitorsEndpoint}/$id');
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to delete visitor: ${e.toString()}');
    }
  }
}
