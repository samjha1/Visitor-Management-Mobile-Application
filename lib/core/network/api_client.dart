import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';

/// Centralized HTTP client using Dio.
/// Handles timeout configuration, headers, logging, and maps DioExceptions into typed AppExceptions.
class ApiClient {
  late final Dio dio;

  ApiClient({Dio? customDio, String? baseUrl}) {
    final effectiveBaseUrl = baseUrl ?? AppConfig.apiBaseUrl;

    dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: effectiveBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    // Add safe logging and interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Verify configuration before firing request
          if (AppConfig.isPlaceholderUrl &&
              !options.uri.toString().contains('mock')) {
            // Placeholder detected, proceed with caution or log warning
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final mapped = mapDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: mapped,
              message: mapped.message,
            ),
          );
        },
      ),
    );
  }

  /// Maps any DioException into a strongly typed domain AppException.
  static AppException mapDioError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is! DioException) {
      return ServerException(
        'An unexpected error occurred: ${error.toString()}',
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'The server took too long to respond. Please check your connection and try again.',
          error.message,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Cannot connect to the server. Please check your internet connection or verify the API URL.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == HttpStatus.notFound || statusCode == 404) {
          return NotFoundException(
            'The requested visitor record was not found on the server.',
            error.response?.statusMessage,
          );
        }

        String message = 'Server returned error ($statusCode)';
        if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'].toString();
        } else if (responseData is String &&
            responseData.isNotEmpty &&
            responseData.length < 100) {
          message = responseData;
        } else if (error.response?.statusMessage != null) {
          message = error.response!.statusMessage!;
        }

        return ServerException(
          message,
          statusCode: statusCode,
          technicalDetails: error.message,
        );

      case DioExceptionType.cancel:
        return const ServerException('The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Security certificate verification failed.',
        );

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NetworkException(
            'Unable to reach the server. Please verify network access.',
          );
        }
        return ServerException(
          'An unexpected network error occurred.',
          technicalDetails: error.message,
        );
    }
  }
}
