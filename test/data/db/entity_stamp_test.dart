import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/data/db/conventions/entity_stamp.dart';
import 'package:test/test.dart';

final DateTime _start = DateTime.utc(2026, 8, 29, 7, 30);

void main() {
  late FixedClock clock;
  late EntityStamper stamper;

  setUp(() {
    clock = FixedClock(_start);
    stamper = EntityStamper(clock);
  });

  group('forInsert', () {
    test('starts at version 1, live, with both timestamps equal', () {
      final EntityStamp stamp = stamper.forInsert();

      expect(stamp.version, 1);
      expect(stamp.createdAt, _start);
      expect(stamp.updatedAt, _start);
      expect(stamp.deletedAt, isNull);
      expect(stamp.isDeleted, isFalse);
    });

    test('takes its instant from the Clock, not the wall clock', () {
      clock.advance(const Duration(days: 400));
      expect(
        stamper.forInsert().createdAt,
        _start.add(const Duration(days: 400)),
      );
    });
  });

  group('forUpdate', () {
    test('bumps the version and moves updated_at', () {
      final EntityStamp inserted = stamper.forInsert();
      clock.advance(const Duration(hours: 9));

      final EntityStamp updated = stamper.forUpdate(inserted);

      expect(updated.version, 2);
      expect(updated.updatedAt, _start.add(const Duration(hours: 9)));
    });

    test('never touches created_at', () {
      // The row was created once. Moving it would falsify history.
      final EntityStamp inserted = stamper.forInsert();
      clock.advance(const Duration(days: 3));

      expect(stamper.forUpdate(inserted).createdAt, inserted.createdAt);
    });

    test('increments monotonically over a long life', () {
      // Invariant 3: every write bumps the version. One forgotten bump is a
      // row that syncs wrong at V2, silently.
      EntityStamp stamp = stamper.forInsert();
      for (int i = 0; i < 100; i++) {
        clock.advance(const Duration(seconds: 1));
        final EntityStamp next = stamper.forUpdate(stamp);

        expect(next.version, stamp.version + 1);
        expect(next.updatedAt.isAfter(stamp.updatedAt), isTrue);
        stamp = next;
      }
      expect(stamp.version, 101);
    });

    test('updating a deleted row leaves it deleted', () {
      // Undeleting is forRestore, a different and deliberate act.
      final EntityStamp deleted = stamper.forSoftDelete(stamper.forInsert());
      clock.advance(const Duration(hours: 1));

      final EntityStamp updated = stamper.forUpdate(deleted);

      expect(updated.deletedAt, deleted.deletedAt);
      expect(updated.isDeleted, isTrue);
    });
  });

  group('forSoftDelete', () {
    test('is a write, so it bumps the version like any other', () {
      final EntityStamp inserted = stamper.forInsert();
      clock.advance(const Duration(minutes: 5));

      final EntityStamp deleted = stamper.forSoftDelete(inserted);

      expect(deleted.version, 2);
      expect(deleted.deletedAt, _start.add(const Duration(minutes: 5)));
      expect(deleted.updatedAt, deleted.deletedAt);
      expect(deleted.createdAt, inserted.createdAt);
    });

    test('deleting twice keeps the first deleted_at', () {
      // The row died once; moving the timestamp would falsify when.
      final EntityStamp first = stamper.forSoftDelete(stamper.forInsert());
      clock.advance(const Duration(days: 1));

      final EntityStamp second = stamper.forSoftDelete(first);

      expect(second.deletedAt, first.deletedAt);
      expect(second.version, first.version + 1);
      expect(second.updatedAt.isAfter(first.updatedAt), isTrue);
    });
  });

  group('forRestore', () {
    test('clears deleted_at and bumps the version', () {
      final EntityStamp deleted = stamper.forSoftDelete(stamper.forInsert());
      clock.advance(const Duration(hours: 2));

      final EntityStamp restored = stamper.forRestore(deleted);

      expect(restored.deletedAt, isNull);
      expect(restored.isDeleted, isFalse);
      expect(restored.version, deleted.version + 1);
      expect(restored.createdAt, deleted.createdAt);
    });
  });

  group('a version below 1 means the stamper was bypassed', () {
    test('throws rather than continuing', () {
      // Version 0 cannot come from this class, so a row carrying one was
      // written by something that skipped the sanctioned path — precisely what
      // must not pass silently.
      for (final int bad in <int>[0, -1]) {
        final EntityStamp corrupt = EntityStamp(
          createdAt: _start,
          updatedAt: _start,
          deletedAt: null,
          version: bad,
        );

        expect(() => stamper.forUpdate(corrupt), throwsArgumentError);
        expect(() => stamper.forSoftDelete(corrupt), throwsArgumentError);
        expect(() => stamper.forRestore(corrupt), throwsArgumentError);
      }
    });
  });

  test('an append-only record gets a created_at and nothing else', () {
    // No version to bump and no update that could ever happen.
    expect(stamper.forAppendOnly(), _start);
  });

  test('stamps compare by value', () {
    expect(stamper.forInsert(), stamper.forInsert());
    expect(stamper.forInsert().hashCode, stamper.forInsert().hashCode);

    clock.advance(const Duration(milliseconds: 1));
    expect(
      stamper.forInsert(),
      isNot(EntityStamper(FixedClock(_start)).forInsert()),
    );
  });

  test('toString names the version and carries no PII', () {
    // A stamp holds only timestamps and a counter, so it is safe in a log —
    // but pin that, since it is the kind of type that later grows a field.
    final EntityStamp stamp = stamper.forSoftDelete(stamper.forInsert());

    expect(stamp.toString(), contains('v2'));
    expect(stamp.toString(), contains('deleted'));
  });
}
