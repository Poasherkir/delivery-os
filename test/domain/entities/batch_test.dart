import 'package:delivery_os/domain/entities/batch.dart';
import 'package:delivery_os/domain/repositories/batch_repository.dart';
import 'package:delivery_os/domain/value_objects/batch_status.dart';
import 'package:test/test.dart';

Batch aBatch({
  String id = 'b1',
  String company = 'c1',
  String date = '2026-09-03',
  BatchStatus status = BatchStatus.open,
  int version = 1,
}) => Batch(
  id: id,
  companyId: company,
  serviceDate: date,
  status: status,
  version: version,
);

void main() {
  group('identity is the id and the version together', () {
    test('the same row at the same version is the same batch', () {
      expect(aBatch(), aBatch());
    });

    test('a different row is not', () {
      expect(aBatch(id: 'b1'), isNot(aBatch(id: 'b2')));
    });

    test('and the same row after a write is not', () {
      expect(aBatch(version: 1), isNot(aBatch(version: 2)));
    });

    test('a batch is not equal to something else entirely', () {
      expect(aBatch(), isNot('b1'));
    });

    test('hashCode agrees with ==', () {
      expect(aBatch().hashCode, aBatch().hashCode);
      expect(aBatch(id: 'b1').hashCode, isNot(aBatch(id: 'b2').hashCode));
    });
  });

  group('isOpen', () {
    test('is true only for open', () {
      // Derived from status rather than stored beside it, so the two cannot
      // disagree. Every status is named here so a new one has to be decided
      // rather than inherited.
      expect(aBatch(status: BatchStatus.open).isOpen, isTrue);
      expect(aBatch(status: BatchStatus.closed).isOpen, isFalse);
      expect(aBatch(status: BatchStatus.settled).isOpen, isFalse);
    });

    test('and the check covers every status there is', () {
      // The check above is a list, and a list goes stale. This fails the day a
      // fourth status is added without a decision about what it means here.
      expect(BatchStatus.values, <BatchStatus>[
        BatchStatus.open,
        BatchStatus.closed,
        BatchStatus.settled,
      ]);
    });
  });

  test('toString names the row, the day and the state', () {
    final String rendered = aBatch(status: BatchStatus.settled).toString();

    expect(rendered, contains('b1'));
    expect(rendered, contains('v1'));
    expect(rendered, contains('2026-09-03'));
    expect(rendered, contains('settled'));
  });

  group('BatchNotOpenException', () {
    test('says which batch and what state it is in', () {
      // This reaches a log line, and the whole reason it exists is that
      // something wrote a state M1 cannot produce. A message that did not name
      // the row would leave nothing to look at.
      const BatchNotOpenException e = BatchNotOpenException(
        batchId: 'b1',
        status: BatchStatus.settled,
        isDeleted: false,
      );

      expect(e.toString(), contains('b1'));
      expect(e.toString(), contains('settled'));
      expect(e.toString(), isNot(contains('deleted')));
    });

    test('and says so when the batch was deleted', () {
      const BatchNotOpenException e = BatchNotOpenException(
        batchId: 'b2',
        status: BatchStatus.open,
        isDeleted: true,
      );

      expect(e.toString(), contains('b2'));
      expect(e.toString(), contains('deleted'));
    });

    test('it is an Exception, not an Error', () {
      // Callers catch this one. An Error would say the program is broken; this
      // says the data is, and the entry flow has something to show for it.
      expect(
        const BatchNotOpenException(
          batchId: 'b1',
          status: BatchStatus.closed,
          isDeleted: false,
        ),
        isA<Exception>(),
      );
    });
  });
}
