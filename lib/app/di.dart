import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
