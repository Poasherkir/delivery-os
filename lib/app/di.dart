import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/device/device_id_store.dart';
import '../core/time/clock.dart';
import '../core/utils/uuid_v7.dart';
import '../data/db/daos/user_settings_dao.dart';
import '../data/db/database_location.dart';
import '../data/db/encryption/database_key.dart';
import '../data/db/encryption/encrypted_database.dart';
import '../data/db/encryption/secure_key_store.dart';
import '../domain/repositories/user_settings.dart';
import 'startup.dart';

/// Root providers: the ones overridden at bootstrap because their value is not
/// constructible from inside the graph.
///
/// Overridden in `main()` with an instance loaded before the first frame, so
/// the app never renders once in the wrong language and then swaps.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw StateError(
        'sharedPreferencesProvider must be overridden in ProviderScope',
      ),
    );

/// The app's only source of "now". Overridden with a [FixedClock] in tests.
final Provider<Clock> clockProvider = Provider<Clock>(
  (Ref ref) => const SystemClock(),
);

/// One generator for the process, so its within-millisecond counter is
/// actually monotonic. A second instance would restart the counter and could
/// mint two ids that sort equal.
final Provider<UuidV7Generator> uuidProvider = Provider<UuidV7Generator>(
  (Ref ref) => UuidV7Generator(clock: ref.watch(clockProvider)),
);

/// How the database gets opened.
///
/// A provider rather than a direct call because this is the one step that
/// reaches for `path_provider` and the platform keystore, neither of which
/// runs on the test host. Overriding this is how a test drives the real
/// startup sequence against an in-memory database.
final Provider<Future<QueryExecutor> Function()> databaseOpenerProvider =
    Provider<Future<QueryExecutor> Function()>((Ref ref) => _openOnDevice);

Future<QueryExecutor> _openOnDevice() async => openEncryptedDatabase(
  file: await defaultDatabaseFile(),
  keys: DatabaseKeyProvider(const SecureKeyStore()),
);

/// The startup sequence: device id, encrypted database, seeded user.
///
/// **Resolves after the first frame.** A `FutureProvider` runs when it is first
/// watched and yields `AsyncLoading` until it completes, so the widget tree
/// exists before the open is attempted. That is deliberate and load-bearing —
/// see [runStartup].
///
/// Closes the database when the scope is disposed. Nothing else owns it.
final FutureProvider<StartupResult> startupProvider =
    FutureProvider<StartupResult>((Ref ref) async {
      final StartupResult result = await runStartup(
        openExecutor: ref.watch(databaseOpenerProvider),
        deviceIds: DeviceIdStore(
          ref.watch(sharedPreferencesProvider),
          ref.watch(uuidProvider),
        ),
        clock: ref.watch(clockProvider),
        uuid: ref.watch(uuidProvider),
      );

      ref.onDispose(result.database.close);
      return result;
    });

/// The database-backed settings store — **null until the database is open**.
///
/// Null rather than a throwing default, unlike [sharedPreferencesProvider], and
/// the difference is deliberate. Preferences is loaded before the first frame,
/// so a missing override there is a wiring bug and should fail loudly. The
/// database is not: it opens asynchronously, after the UI already exists, and
/// it can fail permanently. Null is a state this app genuinely runs in, not an
/// error — it is what the "your data cannot be decrypted" path looks like from
/// here, and a language change made in that state still has to reach
/// preferences.
///
/// Derived from [startupProvider] rather than overridden at runtime, so it
/// becomes non-null on its own the moment startup succeeds.
final Provider<UserSettings?> userSettingsProvider = Provider<UserSettings?>((
  Ref ref,
) {
  final StartupResult? started = ref.watch(startupProvider).value;
  if (started == null) {
    return null;
  }

  return UserSettingsDao(
    database: started.database,
    clock: ref.watch(clockProvider),
    uuid: ref.watch(uuidProvider),
    deviceId: started.deviceId,
  );
});
