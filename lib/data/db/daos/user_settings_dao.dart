import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../domain/repositories/user_settings.dart';
import '../../../domain/value_objects/ledger_enums.dart';
import '../app_database.dart';
import '../queries/current_user.dart';

/// [UserSettings] against the local database.
///
/// The first thing in the app to write an outbox row, so it is also the first
/// worked example of invariant 5: the entity write and the queue row go in one
/// transaction, and the queue is never sent.
final class UserSettingsDao implements UserSettings {
  /// Routed through a private positional constructor so the fields can stay
  /// private while the call site stays named — Dart forbids a named parameter
  /// called `_clock`, which an initializing formal would require. Same shape
  /// as [UuidV7Generator], for the same reason.
  factory UserSettingsDao({
    required AppDatabase database,
    required Clock clock,
    required UuidV7Generator uuid,
    required String deviceId,
  }) => UserSettingsDao._(database, clock, uuid, deviceId);

  const UserSettingsDao._(this._db, this._clock, this._uuid, this._deviceId);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;
  final String _deviceId;

  @override
  Future<String?> locale() async => (await selectCurrentUser(_db))?.locale;

  @override
  Future<void> setLocale(String locale) {
    return _db.transaction(() async {
      final User? user = await selectCurrentUser(_db);
      if (user == null) {
        // Reachable only if something calls this before bootstrap. Failing is
        // right: silently seeding a user here would mint an `owner_id` outside
        // the one place allowed to, and the caller would never know.
        throw StateError(
          'no user row: AppBootstrap.ensureUser must run before a setting '
          'can be written',
        );
      }

      final DateTime now = _clock.nowUtc();

      await (_db.update(_db.users)
            ..where(($UsersTable u) => u.id.equals(user.id)))
          .write(UsersCompanion(locale: Value(locale), updatedAt: Value(now)));

      // Invariant 5. Nothing sends this, and it is written anyway.
      //
      // A command, not a state diff (§11.2) — `{locale: fr}` is what the
      // driver asked for, and it replays correctly whatever else changed in
      // the meantime. `operation` is `update` because that is what happened to
      // the row; the payload is what makes it replayable.
      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              id: _uuid.next(),
              entityType: 'user',
              entityId: user.id,
              operation: OutboxOperation.update,
              payload: jsonEncode(<String, String>{'locale': locale}),
              deviceId: _deviceId,
              createdAt: now,
            ),
          );
    });
  }
}
