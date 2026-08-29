import 'package:drift/drift.dart';

import '../../../domain/value_objects/centimes.dart';
import '../../../domain/value_objects/geo_confidence.dart';
import '../../../domain/value_objects/phone_e164.dart';

/// Thrown when a stored value does not decode to anything this build knows.
///
/// Never a fallback. An unrecognised order status is corrupt data, and
/// defaulting it to `pending` would resurrect a delivered order and lose the
/// money attached to it. This app wrote every one of these rows itself, so an
/// unknown value means something is genuinely wrong and a loud failure is the
/// only honest response.
final class UnknownStoredValueError extends Error {
  UnknownStoredValueError({
    required this.type,
    required this.value,
    required this.known,
  });

  /// The Dart type the value failed to decode into.
  final String type;

  /// The value found in the database.
  final String value;

  /// What this build would have accepted.
  final List<String> known;

  @override
  String toString() =>
      'UnknownStoredValueError: "$value" is not a $type. '
      'This build knows: ${known.join(', ')}';
}

/// Stores a [DateTime] as milliseconds since the Unix epoch, UTC.
///
/// **Not `dateTime()`.** Drift's own `DateTime` column stores Unix *seconds*,
/// which is too coarse: `delivery_attempts` and `outbox` both need ordering
/// within a second, and a driver marking three parcels delivered in the same
/// lift would get an arbitrary order.
///
/// Milliseconds still collide, so the ordering convention everywhere is
/// `ORDER BY created_at, id`. UUIDv7 is time-sortable, so the id breaks the tie
/// deterministically rather than arbitrarily (see `ARCHITECTURE.md` §6.1).
///
/// A local `DateTime` is converted rather than rejected: the conversion is
/// exact, since a `DateTime` carries its own offset, so no information is lost
/// and no bug is hidden. What comes back out is always UTC.
final class UtcMillisecondsConverter extends TypeConverter<DateTime, int> {
  const UtcMillisecondsConverter();

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);
}

/// Stores [Centimes] as the raw integer it already is.
///
/// Invariant 1: money crosses the storage boundary as an `int` and nothing
/// else. The converter exists so a column cannot be read as a bare `int` and
/// quietly find its way into arithmetic that skips [Centimes].
final class CentimesConverter extends TypeConverter<Centimes, int> {
  const CentimesConverter();

  @override
  int toSql(Centimes value) => value.value;

  @override
  Centimes fromSql(int fromDb) => Centimes(fromDb);
}

/// Stores a [PhoneE164] as its canonical `+213XXXXXXXXX` form.
///
/// Reading re-parses, so a value that somehow reached the column without being
/// normalized fails here rather than silently becoming a second identity for a
/// customer who already exists.
final class PhoneE164Converter extends TypeConverter<PhoneE164, String> {
  const PhoneE164Converter();

  @override
  String toSql(PhoneE164 value) => value.e164;

  @override
  PhoneE164 fromSql(String fromDb) => PhoneE164.parse(fromDb);
}

/// Stores a [GeoConfidence] as its numeric tier.
///
/// The tier, not the name: `customer_addresses.geo_confidence` is documented in
/// the schema as `SMALLINT 0..4`, and the numbers are the contract.
final class GeoConfidenceConverter extends TypeConverter<GeoConfidence, int> {
  const GeoConfidenceConverter();

  @override
  int toSql(GeoConfidence value) => value.tier;

  @override
  GeoConfidence fromSql(int fromDb) => GeoConfidence.fromTier(fromDb);
}

/// Stores an enum as **TEXT**, by name.
///
/// Never as an ordinal. An ordinal makes reordering the enum silently reassign
/// every existing row — inserting a status in the middle of the list would
/// turn every `delivered` order into something else, with no error anywhere.
/// The name is stable under reordering and readable in a database browser when
/// something goes wrong at 7am.
///
/// Decoding an unrecognised name throws [UnknownStoredValueError] rather than
/// falling back to a default.
final class EnumTextConverter<T extends Enum> extends TypeConverter<T, String> {
  const EnumTextConverter(this.values, this.typeName);

  /// The enum's `values`, passed in because Dart cannot reach them from `T`.
  final List<T> values;

  /// Used only to make the failure message name the type.
  final String typeName;

  @override
  String toSql(T value) => value.name;

  @override
  T fromSql(String fromDb) {
    for (final T value in values) {
      if (value.name == fromDb) {
        return value;
      }
    }
    throw UnknownStoredValueError(
      type: typeName,
      value: fromDb,
      known: values.map((T value) => value.name).toList(),
    );
  }
}
