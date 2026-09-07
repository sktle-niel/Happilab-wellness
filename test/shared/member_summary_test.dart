import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/shared/domain/member_summary.dart';
import 'package:happilab/shared/utils/date_format.dart';

void main() {
  group('MemberSummary', () {
    test(
      'membershipSummary reads when they joined and what it added up to',
      () {
        final summary = MemberSummary(
          name: 'Ivy Santos',
          referralCode: 'FCV-IVY24',
          joinedOn: DateTime(2025, 3, 12),
          points: 1240,
          lifetimePoints: 4860,
          referredPeople: 8,
          referredBuyers: 5,
          unreadNotifications: 0,
        );

        expect(
          summary.membershipSummary,
          'Joined March 2025 · 4,860 pts earned',
        );
      },
    );
  });

  group('DateFormat', () {
    test('monthYear spells the month out, first to last', () {
      expect(DateFormat.monthYear(DateTime(2024, 1, 31)), 'January 2024');
      expect(DateFormat.monthYear(DateTime(2026, 12, 1)), 'December 2026');
    });

    test('time reads on a twelve-hour clock', () {
      expect(DateFormat.time(DateTime(2026, 9, 7, 15, 5)), '3:05 PM');
      expect(DateFormat.time(DateTime(2026, 9, 7, 0, 30)), '12:30 AM');
      expect(DateFormat.time(DateTime(2026, 9, 7, 12, 0)), '12:00 PM');
    });
  });
}
