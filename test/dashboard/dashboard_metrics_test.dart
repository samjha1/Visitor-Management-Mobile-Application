import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/core/constants/app_constants.dart';
import 'package:visitor_management/core/utils/date_formatter.dart';
import 'package:visitor_management/models/visitor.dart';

void main() {
  group('Dashboard Metrics Calculation Tests', () {
    final referenceDate = DateTime(2026, 10, 27, 14, 30); // 2:30 PM local date

    test('isToday returns true only for matching local calendar date', () {
      final sameDayMorning = DateTime(2026, 10, 27, 8, 15);
      final sameDayNight = DateTime(2026, 10, 27, 23, 59);
      final yesterday = DateTime(2026, 10, 26, 23, 59);
      final tomorrow = DateTime(2026, 10, 28, 0, 1);

      expect(
        DateFormatter.isToday(sameDayMorning, customToday: referenceDate),
        isTrue,
      );
      expect(
        DateFormatter.isToday(sameDayNight, customToday: referenceDate),
        isTrue,
      );
      expect(
        DateFormatter.isToday(yesterday, customToday: referenceDate),
        isFalse,
      );
      expect(
        DateFormatter.isToday(tomorrow, customToday: referenceDate),
        isFalse,
      );
      expect(DateFormatter.isToday(null, customToday: referenceDate), isFalse);
    });

    test('Correctly computes metrics from simulated visitor collection', () {
      final visitors = [
        // Visitor 1: Created today, Registered
        Visitor(
          id: '1',
          name: 'V1',
          mobile: '1111111111',
          visitorType: 'Customer',
          project: 'Project A',
          purpose: 'Tour',
          status: AppConstants.statusRegistered,
          createdAt: DateTime(2026, 10, 27, 9, 0),
        ),
        // Visitor 2: Created today, Checked In
        Visitor(
          id: '2',
          name: 'V2',
          mobile: '2222222222',
          visitorType: 'Vendor',
          project: 'Project B',
          purpose: 'Delivery',
          status: AppConstants.statusCheckedIn,
          createdAt: DateTime(2026, 10, 27, 10, 0),
          checkInTime: DateTime(2026, 10, 27, 10, 15),
        ),
        // Visitor 3: Created today, Checked Out today
        Visitor(
          id: '3',
          name: 'V3',
          mobile: '3333333333',
          visitorType: 'Other',
          project: 'Project C',
          purpose: 'Inspection',
          status: AppConstants.statusCheckedOut,
          createdAt: DateTime(2026, 10, 27, 11, 0),
          checkInTime: DateTime(2026, 10, 27, 11, 5),
          checkOutTime: DateTime(2026, 10, 27, 12, 0),
        ),
        // Visitor 4: Created YESTERDAY, Checked In yesterday and STILL Checked In
        Visitor(
          id: '4',
          name: 'V4',
          mobile: '4444444444',
          visitorType: 'Vendor',
          project: 'Project A',
          purpose: 'Overnight work',
          status: AppConstants.statusCheckedIn,
          createdAt: DateTime(2026, 10, 26, 20, 0),
          checkInTime: DateTime(2026, 10, 26, 20, 30),
        ),
        // Visitor 5: Created YESTERDAY, Checked Out YESTERDAY
        Visitor(
          id: '5',
          name: 'V5',
          mobile: '5555555555',
          visitorType: 'Customer',
          project: 'Project B',
          purpose: 'Yesterday visit',
          status: AppConstants.statusCheckedOut,
          createdAt: DateTime(2026, 10, 26, 14, 0),
          checkInTime: DateTime(2026, 10, 26, 14, 10),
          checkOutTime: DateTime(2026, 10, 26, 16, 0),
        ),
      ];

      int totalToday = 0;
      int currentlyCheckedIn = 0;
      int checkedOutToday = 0;

      for (final v in visitors) {
        if (DateFormatter.isToday(v.createdAt, customToday: referenceDate)) {
          totalToday++;
        }
        if (v.status == AppConstants.statusCheckedIn) {
          currentlyCheckedIn++;
        }
        if (v.checkOutTime != null &&
            DateFormatter.isToday(v.checkOutTime, customToday: referenceDate)) {
          checkedOutToday++;
        }
      }

      // V1, V2, V3 created today = 3
      expect(totalToday, 3);

      // V2 and V4 currently checked in = 2
      expect(currentlyCheckedIn, 2);

      // Only V3 checked out today = 1 (V5 checked out yesterday)
      expect(checkedOutToday, 1);
    });
  });
}
