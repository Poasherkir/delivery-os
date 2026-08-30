import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:delivery_os/domain/value_objects/customer_risk_flag.dart';
import 'package:delivery_os/domain/value_objects/delivery_attempt_outcome.dart';
import 'package:delivery_os/domain/value_objects/delivery_type.dart';
import 'package:delivery_os/domain/value_objects/payment_method.dart';
import 'package:test/test.dart';

void main() {
  group('DeliveryAttemptOutcome', () {
    test('has the six values, collapsed from eight', () {
      // `absent` overlapped `noAnswer` and `rescheduled` overlapped
      // `postponed`. Provisional: additions come from observed field failures.
      expect(DeliveryAttemptOutcome.values.map((e) => e.name), <String>[
        'delivered',
        'noAnswer',
        'refused',
        'wrongAddress',
        'postponed',
        'cancelled',
      ]);
    });

    test('only delivered is a success', () {
      for (final DeliveryAttemptOutcome outcome
          in DeliveryAttemptOutcome.values) {
        expect(
          outcome.isSuccess,
          outcome == DeliveryAttemptOutcome.delivered,
          reason: outcome.name,
        );
      }
    });

    test('is a different axis from OrderStatus', () {
      // An attempt records what happened at the door; the status records where
      // the parcel now stands. One refused attempt does not by itself decide
      // whether the order ends up rescheduled or returned — the driver decides
      // that at end of day, and the money depends on which.
      expect(
        DeliveryAttemptOutcome.values.map((e) => e.name),
        isNot(contains('returnedToAgency')),
      );
      expect(
        DeliveryAttemptOutcome.values.map((e) => e.name),
        isNot(contains('rescheduled')),
      );
    });
  });

  group('CustomerRiskFlag', () {
    test('defaults to none and escalates in order', () {
      expect(CustomerRiskFlag.values, <CustomerRiskFlag>[
        CustomerRiskFlag.none,
        CustomerRiskFlag.watch,
        CustomerRiskFlag.problem,
      ]);
      expect(CustomerRiskFlag.none.needsAttention, isFalse);
      expect(CustomerRiskFlag.watch.needsAttention, isTrue);
      expect(CustomerRiskFlag.problem.needsAttention, isTrue);
    });
  });

  group('DeliveryType', () {
    test('only home delivery is routable', () {
      // Roughly half of Algerian COD volume is stop-desk. Routing one would
      // make the driver's route wrong on day one.
      expect(DeliveryType.home.isRoutable, isTrue);
      expect(DeliveryType.stopdesk.isRoutable, isFalse);
    });
  });

  group('BatchStatus', () {
    test('only a settled batch is closed to writes', () {
      expect(BatchStatus.open.isEditable, isTrue);
      expect(BatchStatus.closed.isEditable, isTrue);
      // Invariant 7: corrections become settlement_adjustments, never edits.
      expect(BatchStatus.settled.isEditable, isFalse);
    });
  });

  group('PaymentMethod', () {
    test('only cash moves the cash-on-hand figure', () {
      // A card payment counting toward cash on hand would make the number a
      // driver checks against the agency's figure a lie.
      for (final PaymentMethod method in PaymentMethod.values) {
        expect(
          method.isCash,
          method == PaymentMethod.cash,
          reason: method.name,
        );
      }
    });
  });

  test('no two enums share a value name that could be confused', () {
    // `cancelled` appears in both OrderStatus and DeliveryAttemptOutcome and
    // means different things — which is exactly why they are separate types
    // rather than one shared enum.
    expect(
      DeliveryAttemptOutcome.values.map((e) => e.name),
      contains('cancelled'),
    );
  });
}
