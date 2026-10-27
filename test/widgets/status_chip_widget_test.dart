import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/core/constants/app_constants.dart';
import 'package:visitor_management/shared/widgets/status_chip.dart';

void main() {
  group('StatusChip Widget Tests', () {
    testWidgets('Renders Registered status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: AppConstants.statusRegistered),
          ),
        ),
      );

      expect(find.text(AppConstants.statusRegistered), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    testWidgets('Renders Checked In status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: AppConstants.statusCheckedIn),
          ),
        ),
      );

      expect(find.text(AppConstants.statusCheckedIn), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('Renders Checked Out status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: AppConstants.statusCheckedOut),
          ),
        ),
      );

      expect(find.text(AppConstants.statusCheckedOut), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });
  });
}
