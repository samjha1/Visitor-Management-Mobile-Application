import '../core/constants/app_constants.dart';

/// Typed domain model representing a registered visitor.
class Visitor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  /// Status checks
  bool get isRegistered => status == AppConstants.statusRegistered;
  bool get isCheckedIn => status == AppConstants.statusCheckedIn;
  bool get isCheckedOut => status == AppConstants.statusCheckedOut;

  /// Business transition validation rules
  bool get canCheckIn => isRegistered;
  bool get canCheckOut => isCheckedIn;
  bool get isCompleted => isCheckedOut;

  /// Deserialization with comprehensive safety and key fallback handling
  factory Visitor.fromJson(Map<String, dynamic> json) {
    // ID handling: server may return String or int, or MockAPI / MongoDB style id/_id
    final rawId = json['id'] ?? json['_id'] ?? '';
    final id = rawId.toString();

    final name = (json['name'] ?? '').toString();
    final mobile = (json['mobile'] ?? '').toString();

    // Email is nullable
    final rawEmail = json['email']?.toString();
    final email = (rawEmail != null && rawEmail.trim().isNotEmpty) ? rawEmail.trim() : null;

    final visitorType = (json['visitor_type'] ?? json['visitorType'] ?? AppConstants.visitorTypeCustomer).toString();
    final project = (json['project'] ?? AppConstants.projectA).toString();
    final purpose = (json['purpose'] ?? '').toString();
    final status = (json['status'] ?? AppConstants.statusRegistered).toString();

    // Timestamps parsing
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawCreatedAt != null) {
      final parsed = DateTime.tryParse(rawCreatedAt.toString());
      if (parsed != null) createdAt = parsed;
    }

    final rawCheckIn = json['check_in_time'] ?? json['checkInTime'];
    DateTime? checkInTime;
    if (rawCheckIn != null && rawCheckIn.toString().trim().isNotEmpty) {
      checkInTime = DateTime.tryParse(rawCheckIn.toString());
    }

    final rawCheckOut = json['check_out_time'] ?? json['checkOutTime'];
    DateTime? checkOutTime;
    if (rawCheckOut != null && rawCheckOut.toString().trim().isNotEmpty) {
      checkOutTime = DateTime.tryParse(rawCheckOut.toString());
    }

    return Visitor(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      visitorType: visitorType,
      project: project,
      purpose: purpose,
      status: status,
      createdAt: createdAt,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
  }

  /// Full JSON serialization including ID and snake_case API keys
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'mobile': mobile,
      if (email != null) 'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (checkInTime != null) 'check_in_time': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'check_out_time': checkOutTime!.toIso8601String(),
    };
  }

  /// Payload for POST /visitors (omits ID to ensure server generates it)
  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'mobile': mobile,
      if (email != null && email!.isNotEmpty) 'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': AppConstants.statusRegistered,
      'created_at': createdAt.toIso8601String(),
      'check_in_time': null,
      'check_out_time': null,
    };
  }

  /// Immutability copyWith helper
  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    DateTime? createdAt,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Visitor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mobile == other.mobile &&
          email == other.email &&
          visitorType == other.visitorType &&
          project == other.project &&
          purpose == other.purpose &&
          status == other.status &&
          createdAt == other.createdAt &&
          checkInTime == other.checkInTime &&
          checkOutTime == other.checkOutTime;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      mobile.hashCode ^
      email.hashCode ^
      visitorType.hashCode ^
      project.hashCode ^
      purpose.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      checkInTime.hashCode ^
      checkOutTime.hashCode;
}
