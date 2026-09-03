import 'package:delivery_os/domain/state/order_state_machine.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:test/test.dart';

/// Invariant 6, exercised exhaustively rather than sampled.
///
/// The machine is a pure function over eight states, so every pair can be
/// checked — 64 of them — and a rule that holds for all of them is a property
/// rather than an example. That is the whole reason this logic lives in
/// `domain/` instead of inside a DAO.
void main() {
  group('the machine covers every state', () {
    test('all eight, with none invented and none missing', () {
      // Fails closed when a state is added to the enum: a new status with no
      // entry would otherwise silently have no legal moves, and every attempt
      // to move it would throw at runtime rather than here.
      expect(
        OrderStateMachine.states.toSet(),
        OrderStatus.values.toSet(),
        reason:
            'a status exists that the machine does not know, or the machine '
            'knows one that does not exist',
      );
    });

    test('nextFrom is total', () {
      for (final OrderStatus s in OrderStatus.values) {
        expect(() => OrderStateMachine.nextFrom(s), returnsNormally);
      }
    });
  });

  group('terminal states are terminal', () {
    // The strongest property in the file. If any of these acquired an outgoing
    // edge, a delivered order could change after its batch was settled and the
    // settlement could no longer be reproduced from it.
    for (final OrderStatus terminal in OrderStatus.values.where(
      (OrderStatus s) => s.isTerminal,
    )) {
      test('${terminal.name} goes nowhere', () {
        expect(OrderStateMachine.nextFrom(terminal), isEmpty);

        for (final OrderStatus to in OrderStatus.values) {
          expect(
            OrderStateMachine.canTransition(terminal, to),
            isFalse,
            reason: '${terminal.name} → ${to.name} must be impossible',
          );
        }
      });
    }

    test('and there are exactly three of them', () {
      // Asserted by name, not by count alone: a count check passes if one
      // terminal state is swapped for another.
      expect(
        OrderStatus.values.where((OrderStatus s) => s.isTerminal).toSet(),
        <OrderStatus>{
          OrderStatus.delivered,
          OrderStatus.returnedToAgency,
          OrderStatus.cancelled,
        },
      );
    });
  });

  group('no state transitions to itself', () {
    // It looks harmless and is not. Every real transition writes a
    // delivery_attempts row or moves money, so a no-op reporting success would
    // let a double tap record a second attempt for one knock at one door.
    for (final OrderStatus s in OrderStatus.values) {
      test('${s.name} → ${s.name} is refused', () {
        expect(OrderStateMachine.canTransition(s, s), isFalse);
        expect(
          () => OrderStateMachine.transitionTo(s, s),
          throwsA(isA<IllegalOrderTransition>()),
        );
      });
    }
  });

  group('the happy path', () {
    test('pending to delivered, one step at a time', () {
      OrderStatus s = OrderStateMachine.initial;
      expect(s, OrderStatus.pending);

      s = OrderStateMachine.transitionTo(s, OrderStatus.onRoute);
      s = OrderStateMachine.transitionTo(s, OrderStatus.arrived);
      s = OrderStateMachine.transitionTo(s, OrderStatus.delivered);

      expect(s, OrderStatus.delivered);
      expect(s.isTerminal, isTrue);
    });

    test('a parcel cannot be delivered without arriving', () {
      // The shortcut somebody will eventually try, because it is one tap fewer.
      // Delivery writes money; arriving is what says the driver was at the door.
      expect(
        () => OrderStateMachine.transitionTo(
          OrderStatus.pending,
          OrderStatus.delivered,
        ),
        throwsA(isA<IllegalOrderTransition>()),
      );
      expect(
        () => OrderStateMachine.transitionTo(
          OrderStatus.onRoute,
          OrderStatus.delivered,
        ),
        throwsA(isA<IllegalOrderTransition>()),
      );
    });
  });

  group('failed is not terminal, and resolves three ways', () {
    test('re-attempt the same day', () {
      expect(
        OrderStateMachine.transitionTo(OrderStatus.failed, OrderStatus.onRoute),
        OrderStatus.onRoute,
      );
    });

    test('or resolve at end of day, either way', () {
      // The distinction is financial rather than cosmetic: a rescheduled parcel
      // is still in the driver's possession and has earned nothing, while a
      // returned one triggers the retour fee.
      expect(
        OrderStateMachine.canTransition(
          OrderStatus.failed,
          OrderStatus.rescheduled,
        ),
        isTrue,
      );
      expect(
        OrderStateMachine.canTransition(
          OrderStatus.failed,
          OrderStatus.returnedToAgency,
        ),
        isTrue,
      );
    });

    test('but never straight to delivered', () {
      // A failed attempt that becomes a delivery without a second attempt would
      // record money against a knock that did not happen.
      expect(
        OrderStateMachine.canTransition(
          OrderStatus.failed,
          OrderStatus.delivered,
        ),
        isFalse,
      );
    });

    test('and it does not close the batch', () {
      // The settlement precondition: `failed` means the disposition is unknown,
      // so the money is unknown, so the batch cannot be totalled.
      expect(OrderStatus.failed.closesTheBatch, isFalse);
      expect(OrderStatus.failed.isOpen, isTrue);
    });
  });

  group('rescheduled rejoins as pending', () {
    test('a new batch on a new day', () {
      expect(
        OrderStateMachine.transitionTo(
          OrderStatus.rescheduled,
          OrderStatus.pending,
        ),
        OrderStatus.pending,
      );
    });

    test('and it is the only way back into pending', () {
      // Other than creation. If anything else could reach `pending`, an order
      // could silently leave a route without a record of why.
      final Set<OrderStatus> sources = OrderStatus.values
          .where(
            (OrderStatus s) =>
                OrderStateMachine.canTransition(s, OrderStatus.pending),
          )
          .toSet();

      expect(sources, <OrderStatus>{OrderStatus.rescheduled});
    });

    test('it closes the batch without being terminal', () {
      // Today's numbers are complete even though the order is not.
      expect(OrderStatus.rescheduled.closesTheBatch, isTrue);
      expect(OrderStatus.rescheduled.isTerminal, isFalse);
    });
  });

  group('cancellation', () {
    test('is possible from every non-terminal state', () {
      // §6.4: by the merchant, at any time before delivered.
      for (final OrderStatus s in OrderStatus.values.where(
        (OrderStatus s) => !s.isTerminal,
      )) {
        expect(
          OrderStateMachine.canCancel(s),
          isTrue,
          reason: 'a merchant cannot cancel a ${s.name} order',
        );
      }
    });

    test('and from none of the terminal ones', () {
      for (final OrderStatus s in OrderStatus.values.where(
        (OrderStatus s) => s.isTerminal,
      )) {
        expect(OrderStateMachine.canCancel(s), isFalse);
      }
    });

    test('canCancel agrees with the transition table', () {
      // Two ways of asking one question. They are the same call underneath
      // precisely so they cannot drift.
      for (final OrderStatus s in OrderStatus.values) {
        expect(
          OrderStateMachine.canCancel(s),
          OrderStateMachine.canTransition(s, OrderStatus.cancelled),
        );
      }
    });
  });

  group('the failure message', () {
    test('names both ends and what was legal', () {
      // The useful question when this fires is never "what happened" but "what
      // did the caller think the order was".
      final Object error = () {
        try {
          OrderStateMachine.transitionTo(
            OrderStatus.delivered,
            OrderStatus.failed,
          );
        } on IllegalOrderTransition catch (e) {
          return e;
        }
        return 'no error';
      }();

      expect(error, isA<IllegalOrderTransition>());
      expect(error.toString(), contains('delivered'));
      expect(error.toString(), contains('failed'));
      expect(error.toString(), contains('Legal from delivered'));
    });
  });

  test('every legal move is reachable from the initial state', () {
    // Catches an orphan: a state written into the table that nothing can ever
    // arrive at would look correct in the map and be dead in the product.
    final Set<OrderStatus> reachable = <OrderStatus>{OrderStateMachine.initial};
    final List<OrderStatus> queue = <OrderStatus>[OrderStateMachine.initial];

    while (queue.isNotEmpty) {
      for (final OrderStatus next in OrderStateMachine.nextFrom(
        queue.removeLast(),
      )) {
        if (reachable.add(next)) {
          queue.add(next);
        }
      }
    }

    expect(
      reachable,
      OrderStatus.values.toSet(),
      reason:
          'these states cannot be reached from pending: '
          '${OrderStatus.values.toSet().difference(reachable)}',
    );
  });
}
