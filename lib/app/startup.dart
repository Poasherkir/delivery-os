import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../core/device/device_id_store.dart';
import '../core/time/clock.dart';
import '../core/utils/uuid_v7.dart';
import '../data/db/app_database.dart';
import '../data/db/bootstrap.dart';

/// What a successful startup produced.
///
/// Holds the open database rather than handing it to a global, so the thing
/// that opened it is also the thing responsible for closing it.
@immutable
final class StartupResult {
  const StartupResult({
    required this.database,
    required this.deviceId,
    required this.user,
  });

  final AppDatabase database;

  /// This installation's id, stamped onto every outbox row (§11.5).
  final String deviceId;

  /// The single driver row, seeded on first launch.
  final User user;
}

/// Opens the database and brings it to the state the app assumes.
///
/// **This runs after the first frame, never before it, and that ordering is
/// load-bearing.** The database open is an async keystore round trip that can
/// fail permanently — a wiped key, a corrupted file — and when it does the
/// driver has to be told so in a language they read. If the app awaited this
/// before `runApp`, there would be no widget tree to render that message into
/// and no locale loaded to render it in: the failure would be a blank screen or
/// a crash, on the one path where communicating clearly matters most.
///
/// That is also the entire reason the shared-preferences locale cache exists.
/// A refactor that "simplifies" startup by opening the database before
/// `runApp` does not just reorder two lines — it silently removes the ability
/// to show the failure screen at all, and makes the cache look redundant on
/// the way past.
///
/// Takes [openExecutor] as a function rather than a database, because opening
/// is the part that reaches for `path_provider` and the platform keystore.
/// Injecting it keeps every decision this function makes testable on the host.
Future<StartupResult> runStartup({
  required Future<QueryExecutor> Function() openExecutor,
  required DeviceIdStore deviceIds,
  required Clock clock,
  required UuidV7Generator uuid,
}) async {
  // First, and deliberately not inside the database transaction. The device id
  // lives in preferences precisely so it survives a database that will not
  // open, and obtaining it here means the failure screen has one even when
  // nothing else worked.
  final String deviceId = await deviceIds.obtain();

  final AppDatabase database = AppDatabase(await openExecutor());

  // Both null: first launch has no name and no language preference. Seeding
  // the resolved device locale here would record a choice the driver never
  // made — see `AppBootstrap.ensureUser`.
  final User user = await AppBootstrap(database, clock, uuid).ensureUser();

  return StartupResult(database: database, deviceId: deviceId, user: user);
}
