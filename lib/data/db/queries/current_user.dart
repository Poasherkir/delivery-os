import 'package:drift/drift.dart';

import '../app_database.dart';

/// The single `users` row, or null before bootstrap has seeded it.
///
/// One definition, imported by everything that needs the driver, because the
/// ordering below is a correctness rule rather than a formality and a second
/// copy of it would eventually lose the `orderBy`.
///
/// §6.1's `ORDER BY created_at, id` earns its keep precisely here. The app
/// assumes exactly one user; if a bug ever produces two, an unordered `LIMIT 1`
/// returns whichever row SQLite reaches first, so the app would flip between
/// two `owner_id` values across launches and partition the driver's data
/// against itself intermittently. Ordering makes it consistently pick the
/// oldest — the damage becomes visible and bounded instead of random.
Future<User?> selectCurrentUser(AppDatabase db) {
  return (db.select(db.users)
        ..orderBy(<OrderClauseGenerator<$UsersTable>>[
          ($UsersTable u) => OrderingTerm(expression: u.createdAt),
          ($UsersTable u) => OrderingTerm(expression: u.id),
        ])
        ..limit(1))
      .getSingleOrNull();
}
