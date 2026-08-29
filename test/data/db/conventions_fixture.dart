import 'package:delivery_os/data/db/conventions/audit_columns.dart';
import 'package:delivery_os/data/db/conventions/converters.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:delivery_os/domain/value_objects/geo_confidence.dart';
import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:drift/drift.dart';

part 'conventions_fixture.g.dart';

/// Stands in for a real status enum. Deliberately not one of the app's own:
/// this fixture verifies the *conventions*, and coupling it to `OrderStatus`
/// would make a schema change look like a conventions failure.
enum FixtureStatus { pending, delivered, returnedToAgency }

/// An owned mutable entity, per invariant 3's first category.
class OwnedThings extends Table with UuidPrimaryKey, OwnedMutableColumns {
  TextColumn get name => text()();

  IntColumn get amount => integer().map(const CentimesConverter())();

  TextColumn get phone => text().map(const PhoneE164Converter()).nullable()();

  IntColumn get confidence => integer().map(const GeoConfidenceConverter())();

  TextColumn get status => text().map(
    const EnumTextConverter<FixtureStatus>(
      FixtureStatus.values,
      'FixtureStatus',
    ),
  )();
}

/// An append-only record, per invariant 3's second category.
class AppendOnlyThings extends Table with UuidPrimaryKey, AppendOnlyColumns {
  TextColumn get note => text()();
}

/// A route-stop-shaped table, the first deliberate exception.
class StopThings extends Table with UuidPrimaryKey, RouteStopColumns {
  IntColumn get sequence => integer()();
}

/// A users-shaped table, the second.
class UserThings extends Table with UuidPrimaryKey, UserColumns {
  TextColumn get displayName => text()();
}

@DriftDatabase(
  tables: <Type>[OwnedThings, AppendOnlyThings, StopThings, UserThings],
)
class ConventionsFixtureDb extends _$ConventionsFixtureDb {
  ConventionsFixtureDb(super.executor);

  @override
  int get schemaVersion => 1;
}
