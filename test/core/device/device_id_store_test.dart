import 'package:delivery_os/core/device/device_id_store.dart';
import 'package:delivery_os/core/time/clock.dart';
import 'package:delivery_os/core/utils/uuid_v7.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([Map<String, Object> stored = const {}]) {
  SharedPreferences.setMockInitialValues(stored);
  return SharedPreferences.getInstance();
}

DeviceIdStore _store(SharedPreferences prefs) =>
    DeviceIdStore(prefs, UuidV7Generator(clock: FixedClock.epoch()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates and persists an id when there is none', () async {
    final SharedPreferences prefs = await _prefs();

    final String id = await _store(prefs).obtain();

    expect(id, hasLength(36));
    expect(prefs.getString(DeviceIdStore.storageKey), id);
  });

  test('the id is stable across calls', () async {
    // The property the outbox depends on. A device id that changed per call
    // would make every queued row look like it came from a different device.
    final SharedPreferences prefs = await _prefs();
    final DeviceIdStore store = _store(prefs);

    final String first = await store.obtain();

    expect(await store.obtain(), first);
    expect(await store.obtain(), first);
  });

  test('and across instances, which is what a restart looks like', () async {
    final SharedPreferences prefs = await _prefs();

    final String first = await _store(prefs).obtain();

    expect(await _store(prefs).obtain(), first);
  });

  test('an existing id is returned untouched', () async {
    final SharedPreferences prefs = await _prefs(<String, Object>{
      DeviceIdStore.storageKey: 'previously-stored-id',
    });

    expect(await _store(prefs).obtain(), 'previously-stored-id');
  });

  test('a missing id is regenerated, not an error', () async {
    // Deliberately the opposite of DatabaseKeyProvider.obtain, which throws
    // rather than mint a key. Losing the database key makes a database
    // permanently unreadable; losing the device id costs sync attribution
    // granularity and nothing else. Applying the never-regenerate rule here by
    // analogy would turn a harmless reset into a hard startup failure.
    final SharedPreferences prefs = await _prefs();

    await expectLater(_store(prefs).obtain(), completes);
  });

  test('an empty stored value counts as missing', () async {
    // A partially written preferences store is a real state. Left alone, an
    // empty string would fail the outbox column's `min: 1` at insert time —
    // far from here, and much harder to read.
    final SharedPreferences prefs = await _prefs(<String, Object>{
      DeviceIdStore.storageKey: '',
    });

    final String id = await _store(prefs).obtain();

    expect(id, isNotEmpty);
    expect(id, hasLength(36));
    expect(prefs.getString(DeviceIdStore.storageKey), id);
  });

  test('two installations do not share an id', () async {
    final Set<String> ids = <String>{};
    for (int i = 0; i < 20; i++) {
      ids.add(await _store(await _prefs()).obtain());
    }

    expect(ids, hasLength(20));
  });

  test('the storage key is stable', () {
    // Changing this string orphans every existing installation's id, silently:
    // the app would mint a new one and nothing would look broken.
    expect(DeviceIdStore.storageKey, 'device.id');
  });
}
