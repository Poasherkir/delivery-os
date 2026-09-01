import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/app_database.dart';
import 'package:delivery_os/data/db/bootstrap.dart';
import 'package:delivery_os/data/db/daos/customer_dao.dart';
import 'package:delivery_os/data/repositories/drift_customer_repository.dart';
import 'package:delivery_os/domain/entities/customer.dart' as domain;
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late CustomerRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    clock = FixedClock(DateTime.utc(2026, 9, 1, 7));
    final UuidV7Generator uuid = UuidV7Generator(clock: clock);
    final User user = await AppBootstrap(db, clock, uuid).ensureUser();
    repo = DriftCustomerRepository(
      dao: CustomerDao(
        database: db,
        clock: clock,
        uuid: uuid,
        deviceId: 'device-under-test',
      ),
      ownerId: user.id,
    );
  });

  tearDown(() => db.close());

  Future<domain.Customer> create({
    String phone = '0550123456',
    String name = 'Amine',
  }) => repo.create(phone: PhoneE164.parse(phone), displayName: name);

  group('the domain type', () {
    test('carries a parsed number, or a raw one, never both', () async {
      final domain.Customer parsed = await create();
      expect(parsed.phone?.e164, '+213550123456');
      expect(parsed.phoneRaw, isNull);
      expect(parsed.needsPhoneReview, isFalse);

      final domain.Customer unparsed = await repo.createUnparsed(
        rawPhone: '021 44 55 66',
        displayName: 'Landline',
      );
      expect(unparsed.phone, isNull);
      expect(unparsed.phoneRaw, '021 44 55 66');
      expect(unparsed.needsPhoneReview, isTrue);
    });

    test('masks the number in toString, parsed or not', () async {
      // This reaches log lines and crash payloads, and an unparsed number is
      // the same human as a parsed one.
      final domain.Customer c = await create();

      expect(c.toString(), isNot(contains('550123456')));
    });
  });

  group('a duplicate number', () {
    test('names the customer that already holds it', () async {
      // A bare constraint violation would make the UI search for the existing
      // customer again just to say anything useful.
      final domain.Customer first = await create(name: 'Amine');

      await expectLater(
        create(name: 'Someone else'),
        throwsA(
          isA<DuplicatePhoneException>().having(
            (DuplicatePhoneException e) => e.existing.id,
            'existing',
            first.id,
          ),
        ),
      );
    });

    test('and a soft-deleted one does not count', () async {
      final domain.Customer first = await create();
      await repo.softDelete(first);

      await expectLater(create(name: 'Again'), completes);
    });

    test('correcting a number onto a taken one fails the same way', () async {
      final domain.Customer taken = await create(phone: '0550123456');
      final domain.Customer pending = await repo.createUnparsed(
        rawPhone: '021 44 55 66',
        displayName: 'Landline',
      );

      await expectLater(
        repo.resolvePhone(
          current: pending,
          phone: PhoneE164.parse('0550123456'),
        ),
        throwsA(
          isA<DuplicatePhoneException>().having(
            (DuplicatePhoneException e) => e.existing.id,
            'existing',
            taken.id,
          ),
        ),
      );
    });

    test('but correcting to the number you already have is fine', () async {
      // The self-collision. Resolving a customer onto their own number must
      // not be refused by a check aimed at somebody else's.
      final domain.Customer c = await create();
      final domain.Customer same = await repo.resolvePhone(
        current: c,
        phone: PhoneE164.parse('0550123456'),
      );

      expect(same.id, c.id);
    });
  });

  group('search', () {
    setUp(() async {
      await repo.create(
        phone: PhoneE164.parse('0550111111'),
        displayName: 'Amine Bensalem',
      );
      await repo.create(
        phone: PhoneE164.parse('0550222222'),
        displayName: 'Karim Haddad',
      );
      await repo.createUnparsed(
        rawPhone: '021 44 55 66',
        displayName: 'Atelier Centre',
      );
    });

    test('matches a name, case-insensitively', () async {
      expect(
        (await repo.search('amine')).map((domain.Customer c) => c.displayName),
        <String>['Amine Bensalem'],
      );
    });

    test('matches part of a number', () async {
      expect(
        (await repo.search('222222')).map((domain.Customer c) => c.displayName),
        <String>['Karim Haddad'],
      );
    });

    test('matches an unparsed number too', () async {
      // The customer most likely to be searched for by typing digits off the
      // parcel is precisely the one whose number never parsed.
      expect(
        (await repo.search('44 55')).map((domain.Customer c) => c.displayName),
        <String>['Atelier Centre'],
      );
    });

    test('an empty query is not a search that found nothing', () async {
      expect(await repo.search(''), hasLength(3));
      expect(await repo.search('   '), hasLength(3));
    });

    test('and a soft-deleted customer never matches', () async {
      final domain.Customer c = (await repo.search('amine')).single;
      await repo.softDelete(c);

      expect(await repo.search('amine'), isEmpty);
    });
  });

  group('editing', () {
    test('re-reads the row rather than trusting a stale version', () async {
      // A domain object that has sat in a form for two minutes carries the
      // version it was loaded with. Stamping an edit from that would overwrite
      // whatever moved in between without noticing.
      final domain.Customer loaded = await create();

      // Something else edits it while the form is open.
      await repo.edit(current: loaded, notes: 'changed elsewhere');

      final domain.Customer edited = await repo.edit(
        current: loaded,
        riskFlag: CustomerRiskFlag.watch,
      );

      expect(edited.version, 3, reason: 'the second edit reused version 1');
      expect(
        edited.notes,
        'changed elsewhere',
        reason: 'the other edit was lost',
      );
    });

    test(
      'editing a deleted customer fails rather than resurrecting it',
      () async {
        final domain.Customer c = await create();
        await repo.softDelete(c);
        await db.customStatement('DELETE FROM customers');

        await expectLater(
          repo.edit(current: c, notes: 'x'),
          throwsA(isA<StateError>()),
        );
      },
    );
  });

  test('needing review lists only the unparsed', () async {
    await create();
    await repo.createUnparsed(rawPhone: '021 44 55 66', displayName: 'Shop');

    final List<domain.Customer> pending = await repo.needingPhoneReview();

    expect(pending, hasLength(1));
    expect(pending.single.displayName, 'Shop');
  });
}
