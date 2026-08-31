import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../core/utils/uuid_v7.dart';
import 'app_database.dart';
import 'queries/current_user.dart';

/// Brings a freshly opened database up to the state the app assumes.
///
/// Runs on every launch, not only the first: "has this already been done" is a
/// question the database can answer, and a flag in preferences saying it has
/// would be one more thing that can disagree with reality.
final class AppBootstrap {
  const AppBootstrap(this._db, this._clock, this._uuid);

  final AppDatabase _db;
  final Clock _clock;
  final UuidV7Generator _uuid;

  /// Seeds the single `users` row if it is not already there, and returns it.
  ///
  /// **Idempotent.** Running it twice yields one user with a stable id — which
  /// matters more than it looks, because that id becomes the `owner_id` on
  /// every other row in the database. A second user row would silently
  /// partition the driver's own data against itself.
  ///
  /// **Writes no outbox row, and that is not an oversight.** Invariant 5 covers
  /// *mutations* — things the driver did, which a server will one day need to
  /// be told about. Seeding is not one: it is this device reaching the state
  /// every device starts in. At V2 sign-in the server adopts this row's UUID
  /// rather than issuing a new one, so there is nothing to send and a queued
  /// `user.create` would be a command the server must learn to ignore. The M0
  /// gate's invariant-5 audit should read this paragraph and move on.
  ///
  /// **Both fields default to null, and that is the correct first-launch
  /// state** rather than a gap waiting to be filled.
  ///
  /// [locale] null means "follow the device". Seeding the *resolved* device tag
  /// instead would look harmless and would be the bug the nullable column
  /// exists to prevent: it records a preference the driver never expressed, so
  /// a driver who has never touched the language setting would sync `ar` to a
  /// second phone configured in French and be given Arabic there. The device
  /// locale still decides what renders — it just is not a preference.
  ///
  /// [displayName] null means the driver has not told us their name. `data/` is
  /// the wrong layer to invent user-facing text: invariant 10 forbids hardcoded
  /// strings, and a placeholder minted here would not re-localize when the
  /// driver switches language. A localized stand-in belongs in presentation.
  Future<User> ensureUser({String? locale, String? displayName}) {
    return _db.transaction(() async {
      final User? existing = await selectCurrentUser(_db);
      if (existing != null) {
        return existing;
      }

      final DateTime now = _clock.nowUtc();
      return _db
          .into(_db.users)
          .insertReturning(
            UsersCompanion.insert(
              id: _uuid.next(),
              displayName: Value(displayName),
              locale: Value(locale),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }
}
