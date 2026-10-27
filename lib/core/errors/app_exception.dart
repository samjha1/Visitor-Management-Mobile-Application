/// Base class for all domain and infrastructure errors in the application.
abstract class AppException implements Exception {
  final String message;
  final String? technicalDetails;
  final int? statusCode;

  const AppException(
    this.message, {
    this.technicalDetails,
    this.statusCode,
  });

  @override
  String toString() => message;
}

/// Network connectivity issues (e.g. no internet, socket exception).
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No network connectivity. Please check your internet connection.',
    String? details,
  ]) : super(technicalDetails: details);
}

/// Timeout when attempting to connect to or read from the server.
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The server took too long to respond. Please try again.',
    String? details,
  ]) : super(technicalDetails: details);
}

/// Server returned an HTTP error code (4xx, 5xx).
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.technicalDetails,
  });
}

/// Resource was not found (404).
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested visitor record was not found.',
    String? details,
  ]) : super(statusCode: 404, technicalDetails: details);
}

/// Malformed or unparseable JSON response.
class ParseException extends AppException {
  const ParseException([
    super.message = 'Failed to process data from the server. Unexpected response format.',
    String? details,
  ]) : super(technicalDetails: details);
}

/// Invalid state transition for Check-In or Check-Out.
class InvalidTransitionException extends AppException {
  const InvalidTransitionException(super.message);
}

/// Invalid QR code payload (e.g. empty, malformed, not a valid visitor ID).
class InvalidQrCodeException extends AppException {
  const InvalidQrCodeException([
    super.message = 'The scanned QR code is invalid or does not contain a valid visitor ID.',
  ]);
}

/// Camera permission denied or restricted.
class CameraPermissionException extends AppException {
  const CameraPermissionException([
    super.message = 'Camera permission is required to scan QR codes. Please enable camera access in app settings.',
  ]);
}

/// Configuration error (e.g. invalid or placeholder base URL).
class ConfigurationException extends AppException {
  const ConfigurationException([
    super.message = 'API base URL is not configured or is invalid. Please check your .env configuration.',
  ]);
}

/// Duplicate action prevented (e.g. double submission).
class DuplicateActionException extends AppException {
  const DuplicateActionException([
    super.message = 'An operation is already in progress. Please wait.',
  ]);
}
