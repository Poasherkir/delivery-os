import 'package:delivery_os/core/time/service_day.dart';
import 'package:test/test.dart';

/// Every expected value is worked out by hand from the definition — add one
/// hour for Algeria, then take the previous day if the local hour is under
/// four — rather than from running the implementation.
void main() {
  group('an ordinary working day', () {
    test('morning is its own date', () {
      // 06:00 UTC is 07:00 in Algiers, well past the cutoff.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 3, 6)), '2026-09-03');
    });

    test('and so is late evening', () {
      // 22:00 UTC is 23:00 local, still the same day.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 3, 22)), '2026-09-03');
    });
  });

  group('the after-midnight case this exists for', () {
    test('a delivery at 00:30 local closes the previous day', () {
      // 23:30 UTC on the 3rd is 00:30 local on the 4th. The driver is settling
      // up the 3rd, not opening the 4th.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 3, 23, 30)), '2026-09-03');
    });

    test('and so does 03:59 local', () {
      // 02:59 UTC is 03:59 local — one minute before the cutoff.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 4, 2, 59)), '2026-09-03');
    });

    test('but 04:00 local starts the new one', () {
      // 03:00 UTC is 04:00 local, exactly the cutoff. The boundary is
      // inclusive at the start of the new day.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 4, 3)), '2026-09-04');
    });
  });

  group('the offset is applied, not ignored', () {
    test('an instant that crosses midnight only in local time', () {
      // 23:10 UTC is still the 3rd in UTC but 00:10 on the 4th locally. A
      // naive implementation that truncated the UTC timestamp would return
      // 2026-09-03 here for the wrong reason — it happens to be right, so the
      // next case is the one that separates them.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 3, 23, 10)), '2026-09-03');
    });

    test('and one where ignoring the offset gives a different answer', () {
      // 03:30 UTC on the 4th is 04:30 local, past the cutoff, so the 4th.
      // Ignoring the offset would read 03:30 as before the cutoff and return
      // the 3rd. This is the case that fails if utcOffset is dropped.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 4, 3, 30)), '2026-09-04');
    });

    test('a local time is converted, not assumed to be UTC already', () {
      // Same instant expressed two ways must give one answer.
      final DateTime asUtc = DateTime.utc(2026, 9, 4, 3, 30);
      expect(ServiceDay.from(asUtc), ServiceDay.from(asUtc.toLocal()));
    });
  });

  group('month and year boundaries', () {
    test('crossing into a new month', () {
      // 23:30 UTC on 30 September is 00:30 local on 1 October, so the work
      // belongs to September.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 30, 23, 30)), '2026-09-30');
    });

    test('crossing into a new year', () {
      expect(ServiceDay.from(DateTime.utc(2026, 12, 31, 23, 30)), '2026-12-31');
    });

    test('a leap day is a day like any other', () {
      // 2028 is a leap year; 29 February exists.
      expect(ServiceDay.from(DateTime.utc(2028, 2, 29, 12)), '2028-02-29');
      // And 00:30 local on 1 March closes 29 February.
      expect(ServiceDay.from(DateTime.utc(2028, 2, 29, 23, 30)), '2028-02-29');
    });
  });

  group('the format sorts correctly as text', () {
    test('single digits are zero-padded', () {
      // A TEXT column sorts lexicographically, so `2026-9-3` would sort after
      // `2026-10-01` and every date range query would be quietly wrong.
      expect(ServiceDay.format(DateTime.utc(2026, 9, 3)), '2026-09-03');
      expect(ServiceDay.format(DateTime.utc(2026, 10, 1)), '2026-10-01');
    });

    test('and lexicographic order matches chronological order', () {
      final List<String> dates = <String>[
        ServiceDay.format(DateTime.utc(2026, 10, 1)),
        ServiceDay.format(DateTime.utc(2026, 9, 3)),
        ServiceDay.format(DateTime.utc(2027, 1, 2)),
        ServiceDay.format(DateTime.utc(2026, 9, 30)),
      ];

      expect(List<String>.of(dates)..sort(), <String>[
        '2026-09-03',
        '2026-09-30',
        '2026-10-01',
        '2027-01-02',
      ]);
    });

    test('the string is exactly ten characters', () {
      // `service_date` is TEXT(10). A value of another length would be
      // rejected at insert, far from here.
      expect(ServiceDay.from(DateTime.utc(2026, 9, 3, 6)), hasLength(10));
      expect(ServiceDay.format(DateTime.utc(999, 1, 1)), hasLength(10));
    });
  });

  group('the constants are pinned', () {
    test('the cutoff is 04:00', () {
      // Provisional, and the point of it being one constant is that moving it
      // is one line. This asserts the current answer so a change is deliberate
      // rather than incidental.
      expect(ServiceDay.cutoffHour, 4);
    });

    test('the offset is UTC+1 with no daylight saving', () {
      // Hard-coded rather than read from the device: a phone whose timezone is
      // wrong would otherwise file a day's work under the wrong date, and the
      // settlement built from it would be short by a day with nothing to
      // notice.
      expect(ServiceDay.utcOffset, const Duration(hours: 1));
    });

    test('and every hour of the day lands on one of two dates', () {
      // A sweep rather than samples: whatever the constants are, the function
      // must be total and must never produce a third date.
      final Set<String> dates = <String>{
        for (int hour = 0; hour < 24; hour++)
          ServiceDay.from(DateTime.utc(2026, 9, 3, hour)),
      };

      expect(dates, <String>{'2026-09-02', '2026-09-03'});
    });
  });
}
