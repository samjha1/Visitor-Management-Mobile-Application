import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/app.dart';

void main() {
  testWidgets('App launches and renders bottom navigation items', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VisitorManagementApp(),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify Bottom Navigation items
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Visitors'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
  });
}
