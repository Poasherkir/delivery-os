import 'package:delivery_os/domain/state/order_status.dart';
import 'package:test/test.dart';

void main() {
  test('there are eight states, and settled is not one of them', () {
    // Settlement is a fact about the batch. An order that was both delivered
    // and inside a settled batch would lose its delivery outcome, and with it
    // the ability to reproduce the settlement computed from it.
    expect(OrderStatus.values, hasLength(8));
    expect(
      OrderStatus.values.map((OrderStatus s) => s.name),
      isNot(contains('settled')),
    );
    // One driver makes assignment meaningless; optimizing is a UI state.
    expect(
      OrderStatus.values.map((OrderStatus s) => s.name),
      isNot(anyOf(contains('assigned'), contains('optimizing'))),
    );
  });

  group('isTerminal', () {
    test('is exactly delivered, returned and cancelled', () {
      expect(
        OrderStatus.values.where((OrderStatus s) => s.isTerminal),
        <OrderStatus>[
          OrderStatus.delivered,
          OrderStatus.returnedToAgency,
          OrderStatus.cancelled,
        ],
      );
    });

    test('failed is not terminal', () {
      // It means "attempt failed, disposition pending". The driver resolves it
      // into rescheduled or returnedToAgency at end of day, and that choice is
      // financial: a rescheduled parcel is still in the driver's possession and
      // has earned nothing, a returned one triggers the retour fee.
      expect(OrderStatus.failed.isTerminal, isFalse);
    });

    test('rescheduled is not terminal either', () {
      // The parcel comes back in a future batch.
      expect(OrderStatus.rescheduled.isTerminal, isFalse);
    });
  });

  group('closesTheBatch', () {
    test('is the terminal three plus rescheduled', () {
      expect(
        OrderStatus.values.where((OrderStatus s) => s.closesTheBatch).toSet(),
        <OrderStatus>{
          OrderStatus.delivered,
          OrderStatus.returnedToAgency,
          OrderStatus.cancelled,
          OrderStatus.rescheduled,
        },
      );
    });

    test('the open states are exactly the other four', () {
      expect(
        OrderStatus.values.where((OrderStatus s) => s.isOpen).toSet(),
        <OrderStatus>{
          OrderStatus.pending,
          OrderStatus.onRoute,
          OrderStatus.arrived,
          OrderStatus.failed,
        },
      );
    });

    test('every status is open or closing, never both and never neither', () {
      // The settlement precondition depends on this being a partition: a batch
      // cannot settle while any order is open, so a status that fell through
      // would let a batch settle with unknown money in it.
      for (final OrderStatus status in OrderStatus.values) {
        expect(status.isOpen, !status.closesTheBatch, reason: status.name);
      }
    });

    test('terminal implies closing, but not the reverse', () {
      for (final OrderStatus status in OrderStatus.values) {
        if (status.isTerminal) {
          expect(status.closesTheBatch, isTrue, reason: status.name);
        }
      }
      expect(OrderStatus.rescheduled.closesTheBatch, isTrue);
      expect(OrderStatus.rescheduled.isTerminal, isFalse);
    });

    test('failed holds the batch open, which is why it must be resolved', () {
      expect(OrderStatus.failed.isOpen, isTrue);
      expect(OrderStatus.failed.closesTheBatch, isFalse);
    });
  });

  group('display tone', () {
    test('maps onto the four buckets, not eight colours', () {
      expect(
        <OrderStatus, OrderStatusTone>{
          for (final OrderStatus s in OrderStatus.values) s: s.tone,
        },
        <OrderStatus, OrderStatusTone>{
          OrderStatus.pending: OrderStatusTone.neutral,
          OrderStatus.rescheduled: OrderStatusTone.neutral,
          OrderStatus.onRoute: OrderStatusTone.inProgress,
          OrderStatus.arrived: OrderStatusTone.inProgress,
          OrderStatus.delivered: OrderStatusTone.success,
          OrderStatus.failed: OrderStatusTone.problem,
          OrderStatus.returnedToAgency: OrderStatusTone.problem,
          OrderStatus.cancelled: OrderStatusTone.problem,
        },
      );
    });

    test('a customer asking for another day is not a problem', () {
      // Deliberate: rescheduled is neutral, not problem. Colouring a
      // reschedule red tells the driver something untrue about their day.
      expect(OrderStatus.rescheduled.tone, OrderStatusTone.neutral);
      expect(OrderStatus.rescheduled.tone, isNot(OrderStatusTone.problem));
    });

    test('every bucket is used, and every status has one', () {
      expect(
        OrderStatus.values.map((OrderStatus s) => s.tone).toSet(),
        OrderStatusTone.values.toSet(),
      );
    });
  });
}
