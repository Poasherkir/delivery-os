import 'package:delivery_os/domain/entities/order_summary.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:test/test.dart';

OrderSummary aSummary({
  String id = 'o1',
  String? customerName,
  String? communeFr,
  String? communeAr,
  String? detail,
}) => OrderSummary(
  id: id,
  trackingNumber: 'YAL-0001',
  status: OrderStatus.pending,
  deliveryType: DeliveryType.home,
  codAmount: Centimes.zero,
  companyName: 'Yalidine',
  serviceDate: '2026-09-03',
  customerName: customerName,
  communeNameFr: communeFr,
  communeNameAr: communeAr,
  addressDetail: detail,
);

void main() {
  group('identity is the id alone', () {
    // A read model, not an owned entity: there is no version to compare, and
    // the row is re-fetched on every list refresh rather than held across one.
    test('the same id is the same summary', () {
      expect(aSummary(id: 'o1'), aSummary(id: 'o1', customerName: 'Amine'));
    });

    test('a different id is not', () {
      expect(aSummary(id: 'o1'), isNot(aSummary(id: 'o2')));
    });

    test('hashCode agrees with ==', () {
      expect(aSummary(id: 'o1').hashCode, aSummary(id: 'o1').hashCode);
    });
  });

  group('needsCustomer', () {
    test('is true when nobody is attached', () {
      expect(aSummary().needsCustomer, isTrue);
    });

    test('and false once somebody is', () {
      expect(aSummary(customerName: 'Amine').needsCustomer, isFalse);
    });
  });

  group('needsAddress', () {
    test('is true with no commune', () {
      expect(aSummary().needsAddress, isTrue);
    });

    test('and false once one is attached', () {
      expect(
        aSummary(
          communeFr: 'Bab Ezzouar',
          communeAr: 'باب الزوار',
        ).needsAddress,
        isFalse,
      );
    });
  });

  group('commune', () {
    test(
      'picks French or Arabic by the caller\'s choice, not a locale it reads',
      () {
        // domain/ cannot see a BuildContext. The caller states which language it
        // wants, rather than this type inferring one.
        final OrderSummary s = aSummary(
          communeFr: 'Bab Ezzouar',
          communeAr: 'باب الزوار',
        );

        expect(s.commune(arabic: false), 'Bab Ezzouar');
        expect(s.commune(arabic: true), 'باب الزوار');
      },
    );

    test('is null in either language when there is no address', () {
      expect(aSummary().commune(arabic: false), isNull);
      expect(aSummary().commune(arabic: true), isNull);
    });
  });

  group('toString', () {
    test('names the parcel and the day', () {
      final String rendered = aSummary(id: 'o1').toString();

      expect(rendered, contains('o1'));
      expect(rendered, contains('YAL-0001'));
      expect(rendered, contains('2026-09-03'));
      expect(rendered, contains('pending'));
    });

    test('and carries neither the customer nor the address', () {
      // Together a name, a commune and a street are a household. None of the
      // three belongs in a string that can reach a log line.
      final String rendered = aSummary(
        customerName: 'Amine Bensalem',
        communeFr: 'Bab Ezzouar',
        communeAr: 'باب الزوار',
        detail: 'Bt 12, 3e étage',
      ).toString();

      expect(rendered, isNot(contains('Amine')));
      expect(rendered, isNot(contains('Bab Ezzouar')));
      expect(rendered, isNot(contains('باب الزوار')));
      expect(rendered, isNot(contains('Bt 12')));
    });
  });
}
