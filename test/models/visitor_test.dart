import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/core/constants/app_constants.dart';
import 'package:visitor_management/models/visitor.dart';

void main() {
  group('Visitor Model Tests', () {
    test('Correctly deserializes from valid snake_case JSON', () {
      final json = {
        'id': '101',
        'name': 'Alice Smith',
        'mobile': '9876543210',
        'email': 'alice@example.com',
        'visitor_type': 'Customer',
        'project': 'Project A',
        'purpose': 'Site inspection',
        'status': 'Registered',
        'created_at': '2026-10-27T10:00:00.000Z',
        'check_in_time': null,
        'check_out_time': null,
      };

      final visitor = Visitor.fromJson(json);

      expect(visitor.id, '101');
      expect(visitor.name, 'Alice Smith');
      expect(visitor.mobile, '9876543210');
      expect(visitor.email, 'alice@example.com');
      expect(visitor.visitorType, 'Customer');
      expect(visitor.project, 'Project A');
      expect(visitor.purpose, 'Site inspection');
      expect(visitor.status, AppConstants.statusRegistered);
      expect(visitor.isRegistered, isTrue);
      expect(visitor.canCheckIn, isTrue);
      expect(visitor.canCheckOut, isFalse);
      expect(visitor.isCompleted, isFalse);
      expect(visitor.checkInTime, isNull);
      expect(visitor.checkOutTime, isNull);
    });

    test('Correctly handles integer IDs from server and converts to String', () {
      final json = {
        'id': 42,
        'name': 'Bob Bobson',
        'mobile': '0123456789',
        'visitor_type': 'Vendor',
        'project': 'Project B',
        'purpose': 'Delivery',
        'status': 'Registered',
      };

      final visitor = Visitor.fromJson(json);
      expect(visitor.id, '42');
      expect(visitor.mobile, '0123456789');
    });

    test('Correctly handles null email and empty email fields', () {
      final jsonWithNull = {
        'id': '1',
        'name': 'No Email',
        'mobile': '9999999999',
        'email': null,
        'visitor_type': 'Other',
        'project': 'Project C',
        'purpose': 'Inquiry',
        'status': 'Registered',
      };
      final v1 = Visitor.fromJson(jsonWithNull);
      expect(v1.email, isNull);

      final jsonWithBlank = {
        'id': '2',
        'name': 'Blank Email',
        'mobile': '8888888888',
        'email': '   ',
        'visitor_type': 'Other',
        'project': 'Project C',
        'purpose': 'Inquiry',
        'status': 'Registered',
      };
      final v2 = Visitor.fromJson(jsonWithBlank);
      expect(v2.email, isNull);
    });

    test('Correctly parses and preserves ISO 8601 timestamps', () {
      final json = {
        'id': '5',
        'name': 'Charlie',
        'mobile': '1112223334',
        'visitor_type': 'Vendor',
        'project': 'Project A',
        'purpose': 'Maintenance',
        'status': 'Checked In',
        'created_at': '2026-10-27T08:00:00.000Z',
        'check_in_time': '2026-10-27T08:30:00.000Z',
        'check_out_time': null,
      };

      final visitor = Visitor.fromJson(json);
      expect(visitor.isCheckedIn, isTrue);
      expect(visitor.canCheckIn, isFalse);
      expect(visitor.canCheckOut, isTrue);
      expect(visitor.checkInTime, isNotNull);
      expect(visitor.checkInTime!.toUtc().hour, 8);
      expect(visitor.checkInTime!.toUtc().minute, 30);
    });

    test('Serializes to JSON with snake_case keys and ISO strings', () {
      final now = DateTime.parse('2026-10-27T10:00:00.000Z');
      final visitor = Visitor(
        id: '12',
        name: 'David',
        mobile: '9876543210',
        email: 'david@example.com',
        visitorType: 'Customer',
        project: 'Project B',
        purpose: 'Site Visit',
        status: AppConstants.statusCheckedOut,
        createdAt: now,
        checkInTime: now.add(const Duration(minutes: 30)),
        checkOutTime: now.add(const Duration(hours: 2)),
      );

      final map = visitor.toJson();
      expect(map['id'], '12');
      expect(map['visitor_type'], 'Customer');
      expect(map['created_at'], '2026-10-27T10:00:00.000Z');
      expect(map['check_in_time'], '2026-10-27T10:30:00.000Z');
      expect(map['check_out_time'], '2026-10-27T12:00:00.000Z');
      expect(visitor.isCompleted, isTrue);
      expect(visitor.canCheckIn, isFalse);
      expect(visitor.canCheckOut, isFalse);
    });

    test('toCreatePayload omits ID so server generates it', () {
      final visitor = Visitor(
        id: 'temporary-client-id',
        name: 'Eve',
        mobile: '1234567890',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Meeting',
        status: AppConstants.statusRegistered,
        createdAt: DateTime.now(),
      );

      final payload = visitor.toCreatePayload();
      expect(payload.containsKey('id'), isFalse);
      expect(payload['status'], AppConstants.statusRegistered);
      expect(payload['check_in_time'], isNull);
      expect(payload['check_out_time'], isNull);
    });
  });
}
