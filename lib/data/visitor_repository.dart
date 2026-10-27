import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/visitor.dart';
import 'visitor_api_service.dart';

/// Repository that handles visitor domain operations, validates transitions,
/// and delegates to the REST API service.
class VisitorRepository {
  final VisitorApiService _apiService;

  VisitorRepository({VisitorApiService? apiService})
      : _apiService = apiService ?? VisitorApiService();

  /// Retrieve all visitors from the API.
  Future<List<Visitor>> getAllVisitors() async {
    final rawList = await _apiService.fetchVisitors();
    return rawList.map((map) => Visitor.fromJson(map)).toList();
  }

  /// Retrieve a single visitor by server-assigned ID.
  Future<Visitor> getVisitorById(String id) async {
    if (id.trim().isEmpty) {
      throw const InvalidQrCodeException('Visitor ID cannot be empty.');
    }
    final raw = await _apiService.fetchVisitorById(id.trim());
    return Visitor.fromJson(raw);
  }

  /// Register a new visitor through the API.
  /// Server returns the confirmed visitor with the generated ID.
  Future<Visitor> registerVisitor({
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
  }) async {
    final newVisitor = Visitor(
      id: '',
      name: name.trim(),
      mobile: mobile.trim(),
      email: (email != null && email.trim().isNotEmpty) ? email.trim() : null,
      visitorType: visitorType,
      project: project,
      purpose: purpose.trim(),
      status: AppConstants.statusRegistered,
      createdAt: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
    );

    final payload = newVisitor.toCreatePayload();
    final responseMap = await _apiService.createVisitor(payload);
    return Visitor.fromJson(responseMap);
  }

  /// Update an existing visitor's profile details.
  /// Preserves status and timestamps as mandated by the specification.
  Future<Visitor> updateVisitorProfile({
    required String id,
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
    required Visitor originalVisitor,
  }) async {
    final updated = originalVisitor.copyWith(
      name: name.trim(),
      mobile: mobile.trim(),
      email: (email != null && email.trim().isNotEmpty) ? email.trim() : null,
      visitorType: visitorType,
      project: project,
      purpose: purpose.trim(),
    );

    final payload = updated.toJson();
    final responseMap = await _apiService.updateVisitor(id, payload);
    return Visitor.fromJson(responseMap);
  }

  /// Check-in state transition: Registered -> Checked In
  /// Enforces state machine rules and records check_in_time.
  Future<Visitor> checkIn(Visitor visitor) async {
    if (!visitor.canCheckIn) {
      if (visitor.isCheckedIn) {
        throw const InvalidTransitionException(
          'Visitor is already Checked In and cannot check in again.',
        );
      } else if (visitor.isCheckedOut) {
        throw const InvalidTransitionException(
          'Visitor has already Checked Out. Cannot check in a completed visit.',
        );
      }
      throw InvalidTransitionException(
        'Invalid status transition from "${visitor.status}" to "${AppConstants.statusCheckedIn}".',
      );
    }

    final now = DateTime.now();
    final updated = visitor.copyWith(
      status: AppConstants.statusCheckedIn,
      checkInTime: now,
    );

    final payload = updated.toJson();
    final responseMap = await _apiService.updateVisitor(visitor.id, payload);
    return Visitor.fromJson(responseMap);
  }

  /// Check-out state transition: Checked In -> Checked Out
  /// Enforces state machine rules and records check_out_time.
  Future<Visitor> checkOut(Visitor visitor) async {
    if (!visitor.canCheckOut) {
      if (visitor.isRegistered) {
        throw const InvalidTransitionException(
          'Visitor has not checked in yet and cannot be checked out.',
        );
      } else if (visitor.isCheckedOut) {
        throw const InvalidTransitionException(
          'Visitor has already Checked Out and visit is complete.',
        );
      }
      throw InvalidTransitionException(
        'Invalid status transition from "${visitor.status}" to "${AppConstants.statusCheckedOut}".',
      );
    }

    final now = DateTime.now();
    final updated = visitor.copyWith(
      status: AppConstants.statusCheckedOut,
      checkOutTime: now,
    );

    final payload = updated.toJson();
    final responseMap = await _apiService.updateVisitor(visitor.id, payload);
    return Visitor.fromJson(responseMap);
  }

  /// Delete a visitor record by ID.
  Future<void> deleteVisitor(String id) async {
    if (id.trim().isEmpty) {
      throw const ServerException('Cannot delete visitor without an ID.');
    }
    await _apiService.deleteVisitor(id.trim());
  }
}
