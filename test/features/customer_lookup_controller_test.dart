import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/domain/entities/customer.dart';
import 'package:delivery_os/domain/repositories/customer_repository.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:delivery_os/features/customers/controllers/customer_lookup_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts lookups and can be made slow, which is what the debounce and the
/// stale-result guard need to be observable at all.
final class _CountingRepo implements CustomerRepository {
  _CountingRepo([this._rows = const <Customer>[]]);

  final List<Customer> _rows;
  int lookups = 0;

  /// Applied to the next lookup only, so one query can be made to land after
  /// a later one.
  Duration? nextDelay;

  @override
  Future<Customer?> findByPhone(PhoneE164 phone) async {
    lookups++;
    final Duration? delay = nextDelay;
    nextDelay = null;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    return _rows.where((Customer c) => c.phone == phone).firstOrNull;
  }

  @override
  Future<List<Customer>> all() async => _rows;
  @override
  Future<List<Customer>> search(String q) async => _rows;
  @override
  Future<List<Customer>> needingPhoneReview() async => const <Customer>[];
  @override
  Future<Customer> create({
    required PhoneE164 phone,
    required String displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag riskFlag = CustomerRiskFlag.none,
  }) => throw UnimplementedError();
  @override
  Future<Customer> createUnparsed({
    required String rawPhone,
    required String displayName,
    String? notes,
  }) => throw UnimplementedError();
  @override
  Future<Customer> edit({
    required Customer current,
    String? displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag? riskFlag,
  }) => throw UnimplementedError();
  @override
  Future<Customer> resolvePhone({
    required Customer current,
    required PhoneE164 phone,
  }) => throw UnimplementedError();
  @override
  Future<void> softDelete(Customer current) => throw UnimplementedError();
}

Customer _amine({int orders = 12}) => Customer(
  id: 'amine',
  displayName: 'Amine Bensalem',
  version: 1,
  phone: PhoneE164.parse('0550123456'),
  totalOrders: orders,
);

void main() {
  ProviderContainer containerWith(_CountingRepo repo) {
    final ProviderContainer c = ProviderContainer(
      overrides: [customerRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  CustomerLookupController notifierOf(ProviderContainer c) =>
      c.read(customerLookupProvider.notifier);

  group('answers that need no query', () {
    test('an empty field is idle', () async {
      final ProviderContainer c = containerWith(_CountingRepo());

      notifierOf(c).onPhoneChanged('   ');

      expect(c.read(customerLookupProvider), isA<LookupIdle>());
    });

    test('an unparseable number is answered without waiting', () async {
      // Parsing is local. Making the driver wait 250ms to be told we could not
      // read the number would be latency bought for nothing.
      final _CountingRepo repo = _CountingRepo();
      final ProviderContainer c = containerWith(repo);

      notifierOf(c).onPhoneChanged('021 44');

      expect(c.read(customerLookupProvider), isA<LookupUnrecognized>());
      expect(repo.lookups, 0);
    });
  });

  group('the debounce', () {
    test('a burst of keystrokes runs one query, not ten', () async {
      // The M1 gate is fifteen orders in under four minutes, so this sits on
      // the critical path of the fastest thing the app does.
      final _CountingRepo repo = _CountingRepo();
      final ProviderContainer c = containerWith(repo);

      for (final String partial in <String>[
        '0',
        '05',
        '055',
        '0550',
        '05501',
        '055012',
        '0550123',
        '05501234',
        '055012345',
        '0550123456',
      ]) {
        notifierOf(c).onPhoneChanged(partial);
      }

      expect(repo.lookups, 0, reason: 'a query ran before the debounce fired');

      await Future<void>.delayed(
        CustomerLookupController.debounce + const Duration(milliseconds: 80),
      );

      expect(repo.lookups, 1);
    });

    test('shows searching while the query is pending', () async {
      final ProviderContainer c = containerWith(_CountingRepo());

      notifierOf(c).onPhoneChanged('0550123456');

      expect(c.read(customerLookupProvider), isA<LookupSearching>());
    });

    test('resolveNow skips the wait', () async {
      // For a field that has lost focus: the driver has stopped typing by
      // definition, so there is nothing left to debounce.
      final _CountingRepo repo = _CountingRepo();
      final ProviderContainer c = containerWith(repo);

      await notifierOf(c).resolveNow('0550123456');

      expect(repo.lookups, 1);
      expect(c.read(customerLookupProvider), isA<LookupNew>());
    });
  });

  group('the result', () {
    test('a free number is new', () async {
      final ProviderContainer c = containerWith(_CountingRepo());

      await notifierOf(c).resolveNow('0660999888');

      final CustomerLookup state = c.read(customerLookupProvider);
      expect(state, isA<LookupNew>());
      expect((state as LookupNew).phone.e164, '+213660999888');
    });

    test('a taken number carries the customer and their order count', () async {
      // The count is what lets a driver tell two Amines apart faster than a
      // name can.
      final ProviderContainer c = containerWith(
        _CountingRepo(<Customer>[_amine(orders: 12)]),
      );

      await notifierOf(c).resolveNow('0550123456');

      final CustomerLookup state = c.read(customerLookupProvider);
      expect(state, isA<LookupExisting>());
      expect((state as LookupExisting).customer.totalOrders, 12);
    });

    test('every spelling of the number finds the same customer', () async {
      for (final String spelling in <String>[
        '0550123456',
        '+213550123456',
        '00213550123456',
        '0550 12 34 56',
      ]) {
        final ProviderContainer c = containerWith(
          _CountingRepo(<Customer>[_amine()]),
        );

        await notifierOf(c).resolveNow(spelling);

        expect(
          c.read(customerLookupProvider),
          isA<LookupExisting>(),
          reason: '"$spelling" did not find the existing customer',
        );
      }
    });
  });

  test('a slow earlier query cannot overwrite a later one', () async {
    // Without the generation guard, a lookup for a half-typed number landing
    // late would show the driver a customer they are not typing — and the
    // field would look authoritative while being wrong.
    final _CountingRepo repo = _CountingRepo(<Customer>[_amine()]);
    final ProviderContainer c = containerWith(repo);

    repo.nextDelay = const Duration(milliseconds: 200);
    final Future<void> slow = notifierOf(c).resolveNow('0550123456');

    // A second, faster lookup for a different number resolves first.
    await notifierOf(c).resolveNow('0660999888');
    expect(c.read(customerLookupProvider), isA<LookupNew>());

    await slow;

    expect(
      c.read(customerLookupProvider),
      isA<LookupNew>(),
      reason: 'the stale result overwrote the current one',
    );
  });

  test('with no database the form still works', () async {
    // The lookup cannot warn about a duplicate, and the unique index remains
    // the real guarantee. Refusing to answer would block the entry flow over a
    // convenience.
    final ProviderContainer c = ProviderContainer(
      overrides: [customerRepositoryProvider.overrideWithValue(null)],
    );
    addTearDown(c.dispose);

    await c.read(customerLookupProvider.notifier).resolveNow('0550123456');

    expect(c.read(customerLookupProvider), isA<LookupNew>());
  });
}
