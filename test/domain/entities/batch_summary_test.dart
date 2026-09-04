import 'package:delivery_os/domain/entities/batch_summary.dart';
import 'package:delivery_os/domain/state/order_status.dart';
import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:test/test.dart';

BatchSummary aSummary({
  String id = 'b1',
  BatchStatus status = BatchStatus.open,
  int version = 1,
  int total = 0,
  int open = 0,
  Centimes expected = Centimes.zero,
}) => BatchSummary(
  id: id,
  companyName: 'Yalidine',
  serviceDate: '2026-09-03',
  status: status,
  version: version,
  totalOrders: total,
  openOrders: open,
  expectedCollection: expected,
);

void main() {
  group('canClose', () {
    test('an open batch with nothing unresolved can close', () {
      expect(aSummary(total: 5).canClose, isTrue);
    });

    test('but not while a parcel is still unresolved', () {
      expect(aSummary(total: 5, open: 1).canClose, isFalse);
    });

    test('and a closed batch cannot close again', () {
      expect(aSummary(status: BatchStatus.closed).canClose, isFalse);
    });

    test('nor a settled one', () {
      expect(aSummary(status: BatchStatus.settled).canClose, isFalse);
    });

    test('and it is decided for every status there is', () {
      // Only `open` may close. Walked rather than listed, so a fourth batch
      // status added without a decision fails here.
      for (final BatchStatus status in BatchStatus.values) {
        expect(
          aSummary(status: status).canClose,
          status == BatchStatus.open,
          reason: '${status.name} was judged wrongly',
        );
      }
    });

    test('and it agrees with the rule the DAO enforces', () {
      // The screen must not offer a button that fails. `BatchDao.close`
      // refuses unless the batch is open and no order satisfies
      // `OrderStatus.isOpen`; this getter is the screen's copy of that, and a
      // copy that disagreed would be worse than no copy at all.
      final int openStatuses = OrderStatus.values
          .where((OrderStatus s) => s.isOpen)
          .length;
      expect(
        openStatuses,
        greaterThan(0),
        reason: 'no status holds a batch open, so this test proves nothing',
      );

      // One unresolved parcel is exactly what the DAO counts and refuses on.
      expect(aSummary(total: 1, open: 1).canClose, isFalse);
      expect(aSummary(total: 1).canClose, isTrue);
    });
  });

  group('resolvedOrders', () {
    test('is what is left after the unresolved', () {
      expect(aSummary(total: 15, open: 3).resolvedOrders, 12);
    });

    test('and an empty batch has nothing either way', () {
      expect(aSummary().resolvedOrders, 0);
      expect(aSummary().canClose, isTrue);
    });
  });

  group('identity is the id and the version together', () {
    test('the same row at the same version is the same summary', () {
      expect(aSummary(), aSummary());
    });

    test('and the same batch after a close is not', () {
      // Closing bumps the version, and a list holding the old summary must
      // rebuild rather than keep offering a close that would now fail.
      expect(
        aSummary(version: 1),
        isNot(aSummary(version: 2, status: BatchStatus.closed)),
      );
    });

    test('a different batch is not', () {
      expect(aSummary(id: 'b1'), isNot(aSummary(id: 'b2')));
    });

    test('a summary is not equal to something else entirely', () {
      expect(aSummary(), isNot('b1'));
    });

    test('hashCode agrees with ==', () {
      expect(aSummary().hashCode, aSummary().hashCode);
      expect(aSummary(id: 'b1').hashCode, isNot(aSummary(id: 'b2').hashCode));
    });
  });

  group('the money', () {
    test('is centimes, and named expected rather than collected', () {
      // 7000 DA is 700000 centimes. This is what the manifest says is owed at
      // the doors, not what came back — that is M3's to compute, and the two
      // must not be confused at a glance.
      expect(
        aSummary(expected: Centimes.fromDinars(7000)).expectedCollection,
        const Centimes(700000),
      );
    });
  });

  test('toString names the day and the progress, not the money', () {
    final String rendered = aSummary(
      total: 15,
      open: 3,
      expected: Centimes.fromDinars(7000),
    ).toString();

    expect(rendered, contains('b1'));
    expect(rendered, contains('2026-09-03'));
    expect(rendered, contains('12/15'));
    expect(rendered, contains('open'));
    expect(
      rendered,
      isNot(contains('700000')),
      reason: 'a day\'s takings do not belong in a log line',
    );
  });
}
