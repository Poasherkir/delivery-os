import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/repositories/user_settings.dart';

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
/// Overridden once the database is open and bootstrap has seeded the user row.
final Provider<UserSettings?> userSettingsProvider = Provider<UserSettings?>(
  (Ref ref) => null,
);
