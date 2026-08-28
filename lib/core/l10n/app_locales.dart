import 'dart:ui' show Locale;

/// The locales this app ships, and how one is chosen.
///
/// Resolution is a pure function so it can be tested without a widget tree,
/// and so the rule lives in one readable place rather than being an emergent
/// property of Flutter's default matching.
abstract final class AppLocales {
  static const Locale arabic = Locale('ar');
  static const Locale french = Locale('fr');

  /// Order matters: this is also the order offered in the language selector.
  static const List<Locale> supported = <Locale>[arabic, french];

  /// Where an unsupported device language lands. Arabic, not French — most
  /// drivers read Arabic first, and a colonial-era default would be a poor
  /// first impression.
  static const Locale fallback = arabic;

  /// Picks a locale.
  ///
  /// * an explicit [override] the driver chose, if it is supported
  /// * otherwise the first [deviceLocales] entry whose language is supported,
  ///   so a device set to `ar-DZ` or `fr-FR` is honoured
  /// * otherwise [fallback]
  ///
  /// Only the language subtag is compared. `ar-DZ`, `ar-MA` and bare `ar` all
  /// resolve to the same bundle; this app does not ship regional variants.
  static Locale resolve(Iterable<Locale>? deviceLocales, {Locale? override}) {
    if (override != null) {
      final Locale? chosen = _match(override);
      if (chosen != null) {
        return chosen;
      }
    }

    for (final Locale candidate in deviceLocales ?? const <Locale>[]) {
      final Locale? matched = _match(candidate);
      if (matched != null) {
        return matched;
      }
    }

    return fallback;
  }

  /// Whether [locale] renders in a right-to-left script.
  static bool isRtl(Locale locale) =>
      locale.languageCode == arabic.languageCode;

  /// Whether a bare language subtag is one this app ships.
  ///
  /// Guards the empty string explicitly: `Locale('')` throws, and this is
  /// called with whatever is sitting in shared preferences, which a corrupted
  /// or partially-written store can leave blank. Crashing at startup over a
  /// stored preference is not an acceptable failure mode.
  static bool isSupported(String languageCode) =>
      languageCode.isNotEmpty && _match(Locale(languageCode)) != null;

  static Locale? _match(Locale locale) {
    for (final Locale candidate in supported) {
      if (candidate.languageCode == locale.languageCode) {
        return candidate;
      }
    }
    return null;
  }
}
