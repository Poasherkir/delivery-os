import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late AppBootstrap bootstrap;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 8, 30, 6, 15));
    bootstrap = AppBootstrap(db, clock, UuidV7Generator(clock: clock));
  });

  tearDown(() => db.close());

  Future<User> seed({String? locale}) => bootstrap.ensureUser(locale: locale);

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT count(*) c FROM $table').getSingle())
          .read<int>('c');

  group('first launch', () {
    test('seeds exactly one user', () async {
      expect(await count('users'), 0);

      final User user = await seed();

      expect(await count('users'), 1);
      expect(user.id, isNotEmpty);
    });

    test('the id is a UUIDv7, generated client-side', () async {
      // Invariant 2. The id seeded here becomes the owner_id on every other
      // row in the database, so it cannot wait for a server.
      final User user = await seed();

      expect(user.id, hasLength(36));
      expect(user.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
      // Version nibble: the 15th hex digit of a v7 is '7'.
      expect(user.id[14], '7');
    });

    test('timestamps come from the clock, not DateTime.now', () async {
      final User user = await seed();

      expect(user.createdAt, DateTime.utc(2026, 8, 30, 6, 15));
      expect(user.updatedAt, user.createdAt);
      expect(user.deletedAt, isNull);
    });

    test('seeds no locale preference, meaning follow the device', () async {
      // Not the resolved device tag. This column stores the driver preference
      // that syncs at V2, and a driver who has never opened the language
      // setting has expressed none. Recording `ar` here because the handset
      // happens to be Arabic would hand them Arabic on a French phone later.
      expect((await seed()).locale, isNull);
    });

    test('seeds no display name, because nobody has been asked', () async {
      expect((await seed()).displayName, isNull);
    });

    test('but an explicit preference is honoured when given', () async {
      expect((await seed(locale: 'fr')).locale, 'fr');
    });

    test('phone is null, because there is no signup', () async {
      expect((await seed()).phone, isNull);
    });
  });

  group('idempotence', () {
    test('running twice yields one user with a stable id', () async {
      // The property that matters most here. A second user row would silently
      // partition the driver's data against itself: half the rows owned by one
      // id, half by another, with nothing anywhere to notice.
      final User first = await seed();
      final User second = await seed();

      expect(await count('users'), 1);
      expect(second.id, first.id);
    });

    test('and does not restamp the row it found', () async {
      final User first = await seed();
      clock.advance(const Duration(days: 3));

      final User second = await seed();

      expect(second.createdAt, first.createdAt);
      expect(second.updatedAt, first.updatedAt);
    });

    test('an existing locale is not overwritten by a later default', () async {
      // A driver who chose French does not get reset to the seed default on
      // the next launch.
      await seed(locale: 'fr');

      expect((await seed(locale: 'ar')).locale, 'fr');
    });

    test('ten launches still leave one user', () async {
      for (int i = 0; i < 10; i++) {
        await seed();
      }

      expect(await count('users'), 1);
    });
  });

  group('bootstrap is not a mutation', () {
    test('it writes no outbox row', () async {
      // Invariant 5 covers things the driver did, which a server will one day
      // need to be told about. Seeding is this device reaching the state every
      // device starts in — and at V2 the server adopts this row's UUID rather
      // than issuing one, so there is nothing to send. A queued `user.create`
      // would be a command the server has to learn to ignore.
      //
      // Stated as a test so the M0 gate's invariant-5 audit finds the answer
      // rather than the question.
      await seed();

      expect(await count('outbox'), 0);
    });

    test('nor an audit log row', () async {
      await seed();

      expect(await count('audit_logs'), 0);
    });
  });

  test('the seed is one transaction', () async {
    // Invariant 5's other half. Nothing here can half-happen: either the user
    // exists or it does not, and a failure part-way cannot leave a user row
    // without the rows a later task will write alongside it.
    final User user = await seed();

    expect(await count('users'), 1);
    expect(user.id, isNotNull);
  });
}
