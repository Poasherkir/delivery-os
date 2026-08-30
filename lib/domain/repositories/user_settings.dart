/// The driver's persisted settings, as everything outside `data/` sees them.
///
/// Exists so `core/` and `features/` can write a setting without importing
/// Drift. The layering rule is one-directional — `data/` implements what
/// `domain/` declares — and the language selector is the first thing in the app
/// that needs to write a row.
///
/// Deliberately two methods and no `User` type. The only setting the MVP
/// reconciles is the language; a richer interface would be inventing a shape
/// for rows and fields that do not exist yet, which is the failure mode
/// CLAUDE.md names outright.
abstract interface class UserSettings {
  /// The stored language tag, or null when no user row exists yet.
  ///
  /// Null is a real state, not an error: it is what a launch sees between the
  /// database opening and bootstrap seeding the row.
  Future<String?> locale();

  /// Persists [locale] as the driver's language.
  ///
  /// The tag is stored as given. Validating it against the shipped locales is
  /// the caller's job — the store's job is to not lose it, so that a language
  /// this build has dropped still round-trips instead of being silently
  /// rewritten to something the driver never chose.
  Future<void> setLocale(String locale);
}
