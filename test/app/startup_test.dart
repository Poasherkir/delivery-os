import 'dart:io';

import 'package:delivery_os/app/di.dart';
import 'package:delivery_os/app/startup.dart';
import 'package:delivery_os/core/device/device_id_store.dart';
import 'package:delivery_os/core/l10n/app_locales.dart';
import 'package:delivery_os/core/l10n/locale_controller.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:delivery_os/data/db/encryption/database_key.dart';
import 'package:delivery_os/domain/repositories/user_settings.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late FixedClock clock;

  /// A container wired exactly as the app is, except that the database opens
  /// in memory instead of through `path_provider` and the keystore.
  ///
  /// [file] lets a test reuse one database across two containers, which is what
  /// a restart looks like. It has to be a file rather than a shared in-memory
  /// executor: disposing a container closes the database it opened, so the two
  /// runs must share storage rather than a connection — which is exactly what
  /// a real restart does.
  Future<ProviderContainer> container({
    Map<String, Object> stored = const <String, Object>{},
    File? file,
    Future<QueryExecutor> Function()? opener,
  }) async {
    SharedPreferences.setMockInitialValues(stored);
    prefs = await SharedPreferences.getInstance();
    clock = FixedClock(DateTime.utc(2026, 8, 31, 6, 15));

    // `Override` is not exported by Riverpod 3; the list type is inferred.
    final ProviderContainer c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock),
        databaseAccessProvider.overrideWithValue(
          DatabaseAccess(
            open:
                opener ??
                () async => file == null
                    ? NativeDatabase.memory()
                    : NativeDatabase(file),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('a successful startup', () {
    test('opens the database and seeds exactly one user', () async {
      final ProviderContainer c = await container();

      final StartupResult r = await c.read(startupProvider.future);

      expect(
        (await r.database
                .customSelect('SELECT count(*) c FROM users')
                .getSingle())
            .read<int>('c'),
        1,
      );
      expect(r.user.id, hasLength(36));
    });

    test('seeds no preference and no name', () async {
      // First launch has neither. Recording the resolved device locale here
      // would sync a choice the driver never made.
      final ProviderContainer c = await container();

      final StartupResult r = await c.read(startupProvider.future);

      expect(r.user.locale, isNull);
      expect(r.user.displayName, isNull);
    });

    test('obtains a device id and persists it', () async {
      final ProviderContainer c = await container();

      final StartupResult r = await c.read(startupProvider.future);

      expect(r.deviceId, hasLength(36));
      expect(prefs.getString(DeviceIdStore.storageKey), r.deviceId);
    });

    test('is idempotent across a restart', () async {
      // Same file, same preferences, fresh container — which is what a cold
      // start after a force-stop actually is.
      final File file = _tempDb();
      final ProviderContainer first = await container(file: file);
      final StartupResult a = await first.read(startupProvider.future);
      final String deviceId = prefs.getString(DeviceIdStore.storageKey)!;
      first.dispose();

      final ProviderContainer second = await container(
        stored: <String, Object>{DeviceIdStore.storageKey: deviceId},
        file: file,
      );
      final StartupResult b = await second.read(startupProvider.future);

      expect(b.user.id, a.user.id, reason: 'the owner id must be stable');
      expect(b.deviceId, a.deviceId, reason: 'the device id must be stable');
    });
  });

  group('the after-write verification hook', () {
    // On device this asserts the file is really encrypted — the one part of
    // encryption the host tests cannot reach, since they use a fake key store.
    // What is testable here is that it runs, and that it runs late enough to
    // have something to look at.

    test('runs only once the file exists and has been written', () async {
      // The ordering is the whole point, and this asserts it the same way the
      // device hook does: by looking at the file. Drift opens lazily, so a
      // check called before the first write would inspect a file that does not
      // exist yet and pass — a guard that guards nothing.
      final Directory dir = Directory.systemTemp.createTempSync('verify_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final File file = File('${dir.path}/app.db');

      bool? existedAtVerify;
      int sizeAtVerify = 0;

      final StartupResult r = await runStartup(
        openExecutor: () async => NativeDatabase(file),
        deviceIds: DeviceIdStore(
          await _prefs(),
          UuidV7Generator(clock: FixedClock.epoch()),
        ),
        clock: FixedClock.epoch(),
        uuid: UuidV7Generator(clock: FixedClock.epoch()),
        verifyAfterWrite: () async {
          existedAtVerify = file.existsSync();
          sizeAtVerify = existedAtVerify! ? file.lengthSync() : 0;
        },
      );
      addTearDown(r.database.close);

      expect(existedAtVerify, isTrue, reason: 'the hook ran before the open');
      expect(sizeAtVerify, greaterThan(0));
    });

    test('a failing verification fails startup', () async {
      await expectLater(
        runStartup(
          openExecutor: () async => NativeDatabase.memory(),
          deviceIds: DeviceIdStore(
            await _prefs(),
            UuidV7Generator(clock: FixedClock.epoch()),
          ),
          clock: FixedClock.epoch(),
          uuid: UuidV7Generator(clock: FixedClock.epoch()),
          verifyAfterWrite: () async =>
              throw StateError('plaintext header on disk'),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('the settings store', () {
    test('is null before startup resolves', () async {
      // The state the failure screen runs in, and the state the first frame
      // runs in. Reading it must not throw and must not block.
      final ProviderContainer c = await container();

      expect(c.read(userSettingsProvider), isNull);
    });

    test('becomes non-null once startup succeeds, with no override', () async {
      final ProviderContainer c = await container();

      await c.read(startupProvider.future);

      expect(c.read(userSettingsProvider), isA<UserSettings>());
    });

    test('is stamped with this run\'s device id', () async {
      // What ties a queued outbox row to the installation that made it.
      final ProviderContainer c = await container();
      final StartupResult r = await c.read(startupProvider.future);

      await c.read(userSettingsProvider)!.setLocale('fr');

      final QueryRow row = await r.database
          .customSelect('SELECT device_id FROM outbox')
          .getSingle();
      expect(row.read<String>('device_id'), r.deviceId);
    });
  });

  group('a failed startup', () {
    Future<QueryExecutor> refuse() =>
        Future<QueryExecutor>.error(DatabaseKeyMissingError());

    test('surfaces the error rather than hanging', () async {
      final ProviderContainer c = await container(opener: refuse);

      await expectLater(
        c.read(startupProvider.future),
        throwsA(isA<DatabaseKeyMissingError>()),
      );
    });

    test('leaves the settings store null', () async {
      // The contract the whole failure path depends on: a language change made
      // on the failure screen still reaches preferences, because there is no
      // database to write first.
      final ProviderContainer c = await container(opener: refuse);
      await c
          .read(startupProvider.future)
          .then<void>(
            (_) => fail('expected a failure'),
            onError: (Object _) {},
          );

      expect(c.read(userSettingsProvider), isNull);
    });

    test('a language change still works with no database', () async {
      final ProviderContainer c = await container(opener: refuse);
      await c
          .read(startupProvider.future)
          .then<void>(
            (_) => fail('expected a failure'),
            onError: (Object _) {},
          );

      await c.read(localeControllerProvider.notifier).select(AppLocales.french);

      expect(prefs.getString(LocaleController.storageKey), 'fr');
      expect(c.read(localeControllerProvider), AppLocales.french);
    });
  });

  group('locale reconciliation', () {
    test('runs after startup and takes the database value', () async {
      // The cache says Arabic; the database is the source of truth and says
      // French. After reconciliation the UI and the cache both say French.
      final File file = _tempDb();
      final ProviderContainer seed = await container(file: file);
      await seed.read(startupProvider.future);
      await seed.read(userSettingsProvider)!.setLocale('fr');
      seed.dispose();

      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'ar'},
        file: file,
      );
      expect(c.read(localeControllerProvider), AppLocales.arabic);

      await c.read(localeReconciliationProvider.future);

      expect(c.read(localeControllerProvider), AppLocales.french);
      expect(prefs.getString(LocaleController.storageKey), 'fr');
    });

    test('leaves a fresh install following the device', () async {
      // Startup seeds a null preference, so there is nothing to impose and the
      // driver keeps whatever their handset is set to.
      final ProviderContainer c = await container();

      await c.read(localeReconciliationProvider.future);

      expect(c.read(localeControllerProvider), isNull);
      expect(prefs.getString(LocaleController.storageKey), isNull);
    });

    test('never resolves when startup fails', () async {
      // Correct: there is no source of truth to reconcile against, and the
      // cached locale is the only thing keeping the failure screen readable.
      final ProviderContainer c = await container(
        stored: <String, Object>{LocaleController.storageKey: 'fr'},
        opener: refuseOpener,
      );

      await expectLater(
        c.read(localeReconciliationProvider.future),
        throwsA(isA<DatabaseKeyMissingError>()),
      );

      expect(c.read(localeControllerProvider), AppLocales.french);
    });
  });

  test('the uuid generator is a single instance per scope', () async {
    // Two instances would each restart the within-millisecond counter and
    // could mint ids that sort equal under a fixed clock.
    final ProviderContainer c = await container();

    expect(identical(c.read(uuidProvider), c.read(uuidProvider)), isTrue);
  });
}

/// A database file in a temp directory, removed when the test finishes.
File _tempDb() {
  final Directory dir = Directory.systemTemp.createTempSync('startup_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return File('${dir.path}/app.db');
}

Future<QueryExecutor> refuseOpener() =>
    Future<QueryExecutor>.error(DatabaseKeyMissingError());

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SharedPreferences.getInstance();
}
