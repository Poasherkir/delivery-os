import 'dart:convert';

import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/user_settings_dao.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late AppBootstrap bootstrap;
  late UserSettingsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 8, 30, 6, 15));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    bootstrap = AppBootstrap(db, clock, uuid);
    dao = UserSettingsDao(
      database: db,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    );
  });

  tearDown(() => db.close());

  Future<User> seed() =>
      bootstrap.ensureUser(locale: 'ar', displayName: 'Malik');

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();

  group('reading', () {
    test('is null before bootstrap has run', () async {
      // A real state, not an error: it is what a launch sees between the
      // database opening and the user row being seeded.
      expect(await dao.locale(), isNull);
    });

    test('returns the seeded locale', () async {
      await seed();

      expect(await dao.locale(), 'ar');
    });
  });

  group('writing', () {
    test('updates the user row', () async {
      await seed();

      await dao.setLocale('fr');

      expect(await dao.locale(), 'fr');
    });

    test('moves updated_at and leaves created_at alone', () async {
      final User before = await seed();
      clock.advance(const Duration(hours: 2));

      await dao.setLocale('fr');

      final User after = await db.select(db.users).getSingle();
      expect(after.createdAt, before.createdAt);
      expect(after.updatedAt, DateTime.utc(2026, 8, 30, 8, 15));
    });

    test('does not create a second user', () async {
      final User user = await seed();

      await dao.setLocale('fr');

      expect(await db.select(db.users).get(), hasLength(1));
      expect((await db.select(db.users).getSingle()).id, user.id);
    });
  });

  group('the outbox row', () {
    test('one write, one row', () async {
      // Invariant 5. Unlike bootstrap, this *is* a mutation — the driver chose
      // something, and a server will one day need to be told.
      await seed();

      await dao.setLocale('fr');

      expect(await outbox(), hasLength(1));
    });

    test('carries a replayable command, not a state diff', () async {
      // §11.2. `{locale: fr}` is what the driver asked for and replays
      // correctly whatever else changed in the meantime.
      await seed();

      await dao.setLocale('fr');

      final OutboxData row = (await outbox()).single;
      expect(jsonDecode(row.payload), <String, Object?>{'locale': 'fr'});
    });

    test('points at the user it changed', () async {
      final User user = await seed();

      await dao.setLocale('fr');

      final OutboxData row = (await outbox()).single;
      expect(row.entityType, 'user');
      expect(row.entityId, user.id);
    });

    test('is stamped with this device', () async {
      // What lets V2 tell two devices of the same driver apart, which is the
      // case the idempotency key has to survive.
      await seed();

      await dao.setLocale('fr');

      expect((await outbox()).single.deviceId, 'device-under-test');
    });

    test('starts unsent, with no attempts and no error', () async {
      // Nothing sends this queue in the MVP. It is written anyway.
      await seed();

      await dao.setLocale('fr');

      final OutboxData row = (await outbox()).single;
      expect(row.syncedAt, isNull);
      expect(row.attempts, 0);
      expect(row.lastError, isNull);
    });

    test('shares the entity write timestamp', () async {
      await seed();
      clock.advance(const Duration(minutes: 30));

      await dao.setLocale('fr');

      final OutboxData row = (await outbox()).single;
      final User user = await db.select(db.users).getSingle();
      expect(row.createdAt, user.updatedAt);
    });

    test('three changes queue three rows, in order', () async {
      await seed();

      for (final String tag in <String>['fr', 'ar', 'fr']) {
        clock.advance(const Duration(seconds: 1));
        await dao.setLocale(tag);
      }

      final List<OutboxData> rows = await outbox();
      expect(rows, hasLength(3));
      // Ids are UUIDv7, so lexicographic order is chronological order.
      final List<String> ids = rows.map((OutboxData r) => r.id).toList();
      expect(ids, List<String>.of(ids)..sort());
    });
  });

  group('writing before bootstrap', () {
    test('throws rather than seeding a user of its own', () async {
      // Silently seeding here would mint an owner_id outside the one place
      // allowed to, and the caller would never know it happened.
      await expectLater(dao.setLocale('fr'), throwsA(isA<StateError>()));
    });

    test('and the transaction leaves nothing behind', () async {
      // The half that matters. A thrown write that still queued an outbox row
      // would leave a command referring to a user that does not exist.
      await dao
          .setLocale('fr')
          .then<void>(
            (_) => fail('expected a StateError'),
            onError: (Object _) {},
          );

      expect(await db.select(db.users).get(), isEmpty);
      expect(await outbox(), isEmpty);
    });
  });
}
