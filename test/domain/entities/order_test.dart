import 'package:delivery_os/domain/entities/order.dart';
import 'package:delivery_os/domain/repositories/order_repository.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:test/test.dart';

Order anOrder({
  String id = 'o1',
  String tracking = 'YAL-0001',
  OrderStatus status = OrderStatus.pending,
  int version = 1,
  String? customerId,
  Centimes cod = Centimes.zero,
}) => Order(
  id: id,
  batchId: 'b1',
  companyId: 'c1',
  trackingNumber: tracking,
  status: status,
  version: version,
  customerId: customerId,
  codAmount: cod,
);

void main() {
  group('identity is the id and the version together', () {
    test('the same row at the same version is the same order', () {
      expect(anOrder(), anOrder());
    });

    test('a different row is not', () {
      expect(anOrder(id: 'o1'), isNot(anOrder(id: 'o2')));
    });

    test('and the same row after a write is not', () {
      // A list holding a stale order must rebuild when the row moves under it.
      expect(anOrder(version: 1), isNot(anOrder(version: 2)));
    });

    test('an order is not equal to something else entirely', () {
      expect(anOrder(), isNot('o1'));
    });

    test('hashCode agrees with ==', () {
      expect(anOrder().hashCode, anOrder().hashCode);
      expect(anOrder(id: 'o1').hashCode, isNot(anOrder(id: 'o2').hashCode));
    });
  });

  group('needsCustomer', () {
    test('is true when nobody is attached yet', () {
      // A parcel can be entered before its person is. Enterable, not
      // deliverable — and the list has to be able to say which.
      expect(anOrder().needsCustomer, isTrue);
    });

    test('and false once somebody is', () {
      expect(anOrder(customerId: 'cust1').needsCustomer, isFalse);
    });
  });

  group('defaults', () {
    test('are a home delivery owing nothing', () {
      // Nothing is invented at construction. A stop-desk parcel and a
      // cash-on-delivery amount are both things the driver states.
      expect(anOrder().deliveryType, DeliveryType.home);
      expect(anOrder().codAmount, Centimes.zero);
      expect(anOrder().notes, isNull);
      expect(anOrder().addressId, isNull);
    });

    test('and money is centimes, not a double', () {
      // Invariant 1. 4500 DA is 450000 centimes by the definition of the unit.
      expect(anOrder(cod: Centimes.fromDinars(4500)).codAmount.value, 450000);
    });
  });

  group('toString', () {
    test('names the parcel and where it stands', () {
      final String rendered = anOrder(status: OrderStatus.delivered).toString();

      expect(rendered, contains('o1'));
      expect(rendered, contains('v1'));
      expect(rendered, contains('YAL-0001'));
      expect(rendered, contains('delivered'));
    });

    test('and does not carry the customer', () {
      // A tracking number identifies a package and is printed on the outside of
      // it. A customer id would say nothing here and is left out rather than
      // carried as noise into a log line.
      expect(
        anOrder(customerId: 'cust-secret').toString(),
        isNot(contains('cust-secret')),
      );
    });
  });

  test('DuplicateTrackingException names the order that already has it', () {
    final Order first = anOrder();

    expect(DuplicateTrackingException(first).existing, first);
    expect(DuplicateTrackingException(first).toString(), contains('o1'));
    expect(DuplicateTrackingException(first), isA<Exception>());
  });
}
