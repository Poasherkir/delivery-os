import 'package:meta/meta.dart';

/// The driver's stored language preference.
///
/// A wrapper around one nullable string, which looks like ceremony until you
/// try to do without it. `users.locale` is nullable — null means "follow the
/// device" — so a bare `Future<String?>` would collapse two different answers
/// into the same value:
///
/// * there is no user row yet (bootstrap has not run)
/// * there is a user row, and the driver's preference is "follow the device"
///
/// The first means "ask again later"; the second is a real preference that must
/// be honoured, including by overwriting a stale explicit choice in the cache.
/// Reconciliation would silently do nothing in the second case if it could not
/// tell them apart.
@immutable
final class LocalePreference {
  const LocalePreference(this.tag);

  /// The language tag, or null for "follow the device".
  final String? tag;

  /// Whether the driver has expressed an explicit choice.
  bool get isExplicit => tag != null;

  @override
  bool operator ==(Object other) =>
      other is LocalePreference && other.tag == tag;

  @override
  int get hashCode => tag.hashCode;

  @override
  String toString() => 'LocalePreference(${tag ?? 'follow the device'})';
}

/// The driver's persisted settings, as everything outside `data/` sees them.
///
/// Exists so `core/` and `features/` can write a setting without importing
/// Drift. The layering rule is one-directional — `data/` implements what
/// `domain/` declares — and the language selector is the first thing in the app
/// that needs to write a row.
///
/// Deliberately narrow and no `User` type. The only setting the MVP reconciles
/// is the language; a richer interface would be inventing a shape for rows and
/// fields that do not exist yet, which is the failure mode CONTRIBUTING.md
/// names outright.
abstract interface class UserSettings {
  /// The stored preference, or null when no user row exists yet.
  ///
  /// Both nulls are real states rather than errors, and they are not the same
  /// state — see [LocalePreference].
  Future<LocalePreference?> localePreference();

  /// Persists the driver's language preference.
  ///
  /// Null means "follow the device", and is stored as null rather than as a
  /// resolved tag. Storing what the device happened to resolve to would turn a
  /// standing instruction into a fixed choice, and at V2 would hand a driver
  /// the old phone's language on a new phone configured differently.
  ///
  /// The tag is stored as given. Validating it against the shipped locales is
  /// the caller's job — the store's job is to not lose it, so a language this
  /// build has dropped still round-trips instead of being silently rewritten to
  /// something the driver never chose.
  Future<void> setLocale(String? locale);
}
