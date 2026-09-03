import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart' as db;
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/batch_dao.dart';
import 'package:delivery_os/data/db/daos/company_dao.dart';
import 'package:delivery_os/data/repositories/drift_batch_repository.dart';
import 'package:delivery_os/domain/entities/batch.dart';
import 'package:delivery_os/domain/repositories/batch_repository.dart';
import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late db.AppDatabase database;
  late FixedClock clock;
  late BatchRepository repo;
  late String companyId;

  /// Opens a fresh database with the clock fixed at [instant].
  ///
  /// A parameter rather than a constant because the service date is derived
  /// from the clock, so the only way to test the derivation is to move it.
  Future<void> openAt(DateTime instant) async {
    database = db.AppDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(instant);
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final db.User user = await AppBootstrap(database, clock, uuid).ensureUser();

    companyId = (await CompanyDao(
      database: database,
      clock: clock,
      uuid: uuid,
      deviceId: 'device-under-test',
    ).create(ownerId: user.id, name: 'Yalidine')).id;

    repo = DriftBatchRepository(
      dao: BatchDao(
        database: database,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      clock: clock,
      ownerId: user.id,
    );
  }

  // 07:00 UTC is 08:00 in Algiers: an ordinary morning, well past the 04:00
  // cutoff, so the service day is that same calendar day.
  setUp(() => openAt(DateTime.utc(2026, 9, 3, 7)));

  tearDown(() => database.close());

  test('the day defaults to the current service day', () async {
    final Batch b = await repo.ensureOpenBatch(companyId: companyId);

    expect(b.serviceDate, '2026-09-03');
    expect(b.status, BatchStatus.open);
    expect(b.companyId, companyId);
  });

  test('and after midnight it is still the day that has just ended', () async {
    // 23:30 UTC is 00:30 in Algiers on the 4th. The driver settling up is
    // closing the 3rd, and their last delivery must not open a new batch.
    await database.close();
    await openAt(DateTime.utc(2026, 9, 3, 23, 30));

    expect(
      (await repo.ensureOpenBatch(companyId: companyId)).serviceDate,
      '2026-09-03',
    );
  });

  test('the date is a default, not a constraint', () async {
    // A driver entering tomorrow's orders tonight is a real case. Nothing on
    // the entry path names a date; a batch screen in M2 will.
    final Batch today = await repo.ensureOpenBatch(companyId: companyId);
    final Batch tomorrow = await repo.ensureOpenBatch(
      companyId: companyId,
      serviceDate: '2026-09-04',
    );

    expect(tomorrow.serviceDate, '2026-09-04');
    expect(tomorrow.id, isNot(today.id));
  });

  test('calling it twice in a day returns the same batch', () async {
    final Batch first = await repo.ensureOpenBatch(companyId: companyId);
    clock.advance(const Duration(hours: 5));

    expect((await repo.ensureOpenBatch(companyId: companyId)).id, first.id);
  });

  test('and midnight does not split a working day in two', () async {
    // The case the whole cutoff exists for, seen from the repository. The first
    // call is 08:00 local on the 3rd; 17h10m later is 01:10 local on the 4th,
    // which is before the cutoff and therefore still the 3rd's work. Both
    // deliveries file under one batch.
    final Batch morning = await repo.ensureOpenBatch(companyId: companyId);
    clock.advance(const Duration(hours: 17, minutes: 10));

    final Batch afterMidnight = await repo.ensureOpenBatch(
      companyId: companyId,
    );

    expect(afterMidnight.id, morning.id);
    expect(afterMidnight.serviceDate, '2026-09-03');
  });

  test(
    'a batch that cannot take orders surfaces as a domain failure',
    () async {
      // The exception is declared in `domain/` so `features/` can catch it
      // without importing `data/`.
      final Batch b = await repo.ensureOpenBatch(companyId: companyId);
      await database.customStatement(
        'UPDATE batches SET status = ? WHERE id = ?',
        <Object?>['settled', b.id],
      );

      await expectLater(
        repo.ensureOpenBatch(companyId: companyId),
        throwsA(isA<BatchNotOpenException>()),
      );
    },
  );
}
