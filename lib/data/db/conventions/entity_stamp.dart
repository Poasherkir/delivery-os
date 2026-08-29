import 'package:meta/meta.dart';

import '../../../core/time/clock.dart';

/// The audit values a write to an owned mutable entity must carry.
///
/// Produced only by [EntityStamper]. A DAO assembling these by hand is the bug
/// this type exists to make visible.
@immutable
final class EntityStamp {
  const EntityStamp({
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.version,
  });

  /// Set once, at insert, and never touched again.
  final DateTime createdAt;

  final DateTime updatedAt;

  /// Null means live.
  final DateTime? deletedAt;

  final int version;

  bool get isDeleted => deletedAt != null;

  @override
  bool operator ==(Object other) =>
      other is EntityStamp &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.version == version;

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, deletedAt, version);

  @override
  String toString() =>
      'EntityStamp(v$version, updated $updatedAt'
      '${isDeleted ? ', deleted $deletedAt' : ''})';
}

/// The single sanctioned way to stamp a write to an owned mutable entity.
///
/// Invariant 3 says `version` increments on every write. Leaving that to each
/// DAO method to remember is the same failure mode the purity guard and the
/// raw-`Text` guard exist to prevent, and it is worse here because it is
/// silent: one forgotten bump is a row that syncs wrong at V2, with nothing
/// anywhere to notice.
///
/// So the increment is not a thing a DAO does. It is a thing this produces,
/// and a DAO that writes an owned entity without one is caught by the guard
/// that lands with the first real DAO.
///
/// Every timestamp comes from [Clock], never `DateTime.now()`, so a test can
/// fix the instant and get a stable row back.
final class EntityStamper {
  const EntityStamper(this._clock);

  final Clock _clock;

  /// The stamp for a new row. Version 1, created and updated at the same
  /// instant, not deleted.
  @useResult
  EntityStamp forInsert() {
    final DateTime now = _clock.nowUtc();
    return EntityStamp(
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      version: 1,
    );
  }

  /// The stamp for updating [current]. Bumps the version, moves `updated_at`,
  /// and leaves `created_at` and `deleted_at` alone.
  ///
  /// Updating a soft-deleted row keeps it deleted: undeleting is [forRestore],
  /// a different and deliberate act.
  @useResult
  EntityStamp forUpdate(EntityStamp current) => EntityStamp(
    createdAt: current.createdAt,
    updatedAt: _clock.nowUtc(),
    deletedAt: current.deletedAt,
    version: _next(current.version),
  );

  /// The stamp for a soft delete. A delete is a write, so it bumps the version
  /// like any other.
  ///
  /// Deleting an already-deleted row keeps the original `deleted_at`: the row
  /// died once, and moving the timestamp would falsify when.
  @useResult
  EntityStamp forSoftDelete(EntityStamp current) {
    final DateTime now = _clock.nowUtc();
    return EntityStamp(
      createdAt: current.createdAt,
      updatedAt: now,
      deletedAt: current.deletedAt ?? now,
      version: _next(current.version),
    );
  }

  /// The stamp for undeleting a row.
  @useResult
  EntityStamp forRestore(EntityStamp current) => EntityStamp(
    createdAt: current.createdAt,
    updatedAt: _clock.nowUtc(),
    deletedAt: null,
    version: _next(current.version),
  );

  /// The `created_at` for an append-only record, which has nothing else to
  /// stamp — no version to bump and no update that could ever happen.
  @useResult
  DateTime forAppendOnly() => _clock.nowUtc();

  static int _next(int version) {
    if (version < 1) {
      // Version 0 means the row was written by something that bypassed this
      // stamper, which is precisely what must not happen silently.
      throw ArgumentError.value(
        version,
        'version',
        'must be at least 1; a row below that was not stamped by EntityStamper',
      );
    }
    return version + 1;
  }
}
