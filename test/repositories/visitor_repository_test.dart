import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:visitor_management/core/constants/app_constants.dart';
import 'package:visitor_management/core/errors/app_exception.dart';
import 'package:visitor_management/data/visitor_api_service.dart';
import 'package:visitor_management/data/visitor_repository.dart';
import 'package:visitor_management/models/visitor.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late VisitorApiService apiService;
  late VisitorRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://test.mockapi.io/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    apiService = VisitorApiService(dio: dio);
    repository = VisitorRepository(apiService: apiService);
  });

  group('VisitorRepository Transition Validation Tests', () {
    final registeredVisitor = Visitor(
      id: '1',
      name: 'John Registered',
      mobile: '9876543210',
      visitorType: 'Customer',
      project: 'Project A',
      purpose: 'Meeting',
      status: AppConstants.statusRegistered,
      createdAt: DateTime.now(),
    );

    final checkedInVisitor = Visitor(
      id: '2',
      name: 'Jane CheckedIn',
      mobile: '9876543211',
      visitorType: 'Vendor',
      project: 'Project B',
      purpose: 'Delivery',
      status: AppConstants.statusCheckedIn,
      createdAt: DateTime.now(),
      checkInTime: DateTime.now(),
    );

    final checkedOutVisitor = Visitor(
      id: '3',
      name: 'Bob CheckedOut',
      mobile: '9876543212',
      visitorType: 'Other',
      project: 'Project C',
      purpose: 'Audit',
      status: AppConstants.statusCheckedOut,
      createdAt: DateTime.now(),
      checkInTime: DateTime.now(),
      checkOutTime: DateTime.now(),
    );

    test('Registered visitor CAN check in', () async {
      dioAdapter.onPut(
        '/visitors/1',
        (server) => server.reply(200, {
          'id': '1',
          'name': 'John Registered',
          'mobile': '9876543210',
          'visitor_type': 'Customer',
          'project': 'Project A',
          'purpose': 'Meeting',
          'status': 'Checked In',
          'created_at': DateTime.now().toIso8601String(),
          'check_in_time': DateTime.now().toIso8601String(),
        }),
        data: Matchers.any,
      );

      final result = await repository.checkIn(registeredVisitor);
      expect(result.status, AppConstants.statusCheckedIn);
      expect(result.checkInTime, isNotNull);
    });

    test(
      'Registered visitor CANNOT check out (throws InvalidTransitionException)',
      () async {
        expect(
          () => repository.checkOut(registeredVisitor),
          throwsA(isA<InvalidTransitionException>()),
        );
      },
    );

    test('Checked In visitor CAN check out', () async {
      dioAdapter.onPut(
        '/visitors/2',
        (server) => server.reply(200, {
          'id': '2',
          'name': 'Jane CheckedIn',
          'mobile': '9876543211',
          'visitor_type': 'Vendor',
          'project': 'Project B',
          'purpose': 'Delivery',
          'status': 'Checked Out',
          'created_at': DateTime.now().toIso8601String(),
          'check_in_time': DateTime.now().toIso8601String(),
          'check_out_time': DateTime.now().toIso8601String(),
        }),
        data: Matchers.any,
      );

      final result = await repository.checkOut(checkedInVisitor);
      expect(result.status, AppConstants.statusCheckedOut);
      expect(result.checkOutTime, isNotNull);
    });

    test(
      'Checked In visitor CANNOT check in again (duplicate check-in rejected)',
      () async {
        expect(
          () => repository.checkIn(checkedInVisitor),
          throwsA(isA<InvalidTransitionException>()),
        );
      },
    );

    test('Checked Out visitor CANNOT check in or check out again', () async {
      expect(
        () => repository.checkIn(checkedOutVisitor),
        throwsA(isA<InvalidTransitionException>()),
      );
      expect(
        () => repository.checkOut(checkedOutVisitor),
        throwsA(isA<InvalidTransitionException>()),
      );
    });
  });

  group('VisitorRepository HTTP Error Handling Tests', () {
    test('Handles 404 Not Found by throwing NotFoundException', () async {
      dioAdapter.onGet(
        '/visitors/999',
        (server) => server.reply(404, {'message': 'Not found'}),
      );

      expect(
        () => repository.getVisitorById('999'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Handles 500 Server Error by throwing ServerException', () async {
      dioAdapter.onGet(
        '/visitors',
        (server) => server.reply(500, {'message': 'Internal Server Error'}),
      );

      expect(
        () => repository.getAllVisitors(),
        throwsA(isA<ServerException>()),
      );
    });

    test('Uses server-returned ID upon successful registration', () async {
      dioAdapter.onPost(
        '/visitors',
        (server) => server.reply(201, {
          'id': 'srv_789456',
          'name': 'Server Generated ID Visitor',
          'mobile': '9988776655',
          'visitor_type': 'Customer',
          'project': 'Project A',
          'purpose': 'VIP Tour',
          'status': 'Registered',
          'created_at': DateTime.now().toIso8601String(),
        }),
        data: Matchers.any,
      );

      final created = await repository.registerVisitor(
        name: 'Server Generated ID Visitor',
        mobile: '9988776655',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'VIP Tour',
      );

      expect(created.id, 'srv_789456');
    });
  });
}
