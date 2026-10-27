import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/core/constants/app_constants.dart';
import 'package:visitor_management/models/visitor.dart';
import 'package:visitor_management/shared/widgets/visitor_card.dart';

void main() {
  group('VisitorCard Widget Tests', () {
    final testVisitor = Visitor(
      id: 'vis_101',
      name: 'Michael Scott',
      mobile: '9876543210',
      email: 'michael@dunder.com',
      visitorType: AppConstants.visitorTypeCustomer,
      project: AppConstants.projectB,
      purpose: 'Meeting with manager',
      status: AppConstants.statusRegistered,
      createdAt: DateTime.now(),
    );

    testWidgets('Renders visitor details on card', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisitorCard(
              visitor: testVisitor,
              onTap: () => tapped = true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify name, mobile, project, visitor type, status
      expect(find.text('Michael Scott'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text(AppConstants.projectB), findsOneWidget);
      expect(find.text(AppConstants.visitorTypeCustomer), findsOneWidget);
      expect(find.text(AppConstants.statusRegistered), findsOneWidget);

      // Verify tap callback
      await tester.tap(find.byType(VisitorCard));
      expect(tapped, isTrue);
    });
  });
}
