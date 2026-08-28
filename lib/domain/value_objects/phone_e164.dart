/// A normalized Algerian telephone number.
///
/// Stored and compared as E.164: `+213` followed by nine national digits.
/// This is the customer identity key — `UNIQUE (owner_id, phone_e164)` in the
/// schema — so normalization has to be **total and deterministic**. Two
/// spellings of the same number must produce the same value or duplicate
/// detection quietly stops working and the learned-pin geocoder starts
/// splitting one household across several records.
///
/// Only Algerian numbers parse. A foreign number is a rejection, not a
/// pass-through: the MVP has no use for one, and accepting it would put an
/// unnormalizable string into the identity column.
///
/// **Input is assumed hostile,** because at M1 it arrives pasted out of
/// WhatsApp. Two classes of character are handled that a French-configured
/// test device would never produce:
///
/// * **Arabic-Indic digits.** `٠٥٥٠١٢٣٤٥٦` is what an Arabic keyboard emits,
///   and this is an Arabic-first app. Both the Arabic-Indic block
///   (U+0660–U+0669) and the Extended Arabic-Indic block used by Persian
///   layouts (U+06F0–U+06F9) fold to ASCII before parsing.
/// * **Bidi and invisible controls.** Text copied out of an RTL context
///   carries LRM/RLM marks, embeddings, isolates, zero-width characters and
///   BOMs. The whole Unicode format class is stripped, not the handful that
///   happened to come up in testing.
///
/// Anything else that is not a digit, a leading `+`, or a recognised separator
/// is a rejection. Discarding unknown characters would silently accept
/// `05a50123456`.
final class PhoneE164 implements Comparable<PhoneE164> {
  const PhoneE164._(this.e164, this.nationalNumber);

  /// Parses [raw], throwing [FormatException] if it is not an Algerian number.
  ///
  /// The exception deliberately does **not** quote the input. Phone numbers are
  /// the most sensitive data in this system (§13) and exception messages reach
  /// crash reports.
  factory PhoneE164.parse(String raw) {
    final PhoneE164? parsed = tryParse(raw);
    if (parsed == null) {
      throw const FormatException(
        'not a valid Algerian phone number: expected 9 national digits '
        'beginning 2-4 (landline) or 5-7 (mobile), optionally prefixed with '
        '0, 213, 00213 or +213',
      );
    }
    return parsed;
  }

  /// Parses [raw], returning null rather than throwing.
  static PhoneE164? tryParse(String raw) {
    final (String digits, bool hadPlus)? scanned = _scan(raw);
    if (scanned == null) {
      return null;
    }

    final String? national = _nationalNumber(scanned.$1, scanned.$2);
    if (national == null || !_hasKnownPrefix(national)) {
      return null;
    }

    return PhoneE164._('+$countryCode$national', national);
  }

  static const String countryCode = '213';

  /// Significant digits after the country code, for both mobiles and
  /// landlines.
  ///
  /// **Verify this against real numbers before M1 hardens ingestion.** Algeria
  /// closed its numbering plan in 2008 and older landline formats were shorter;
  /// if a real manifest turns up an 8-digit landline, this constant and the
  /// prefix table are what change.
  static const int nationalLength = 9;

  /// Leading digit of a mobile number.
  static const Set<int> mobilePrefixes = <int>{5, 6, 7};

  /// Leading digit of a landline number.
  static const Set<int> landlinePrefixes = <int>{2, 3, 4};

  /// Canonical form: `+213XXXXXXXXX`. This is what goes in the database.
  final String e164;

  /// The nine national digits, without country code or trunk zero.
  final String nationalNumber;

  bool get isMobile => mobilePrefixes.contains(_leadingDigit);

  bool get isLandline => landlinePrefixes.contains(_leadingDigit);

  int get _leadingDigit => nationalNumber.codeUnitAt(0) - 0x30;

  @override
  int compareTo(PhoneE164 other) => e164.compareTo(other.e164);

  @override
  bool operator ==(Object other) => other is PhoneE164 && other.e164 == e164;

  @override
  int get hashCode => e164.hashCode;

  /// Masked. The full number is available on [e164]; this is what ends up in
  /// logs and crash payloads, where a customer's number has no business being.
  @override
  String toString() =>
      'PhoneE164(+$countryCode…${nationalNumber.substring(nationalLength - 3)})';

  // --- scanning -------------------------------------------------------------

  /// Reduces [raw] to its digits, reporting whether it opened with `+`.
  ///
  /// Returns null if any character is neither a digit, a leading `+`, nor an
  /// ignorable separator or control.
  static (String, bool)? _scan(String raw) {
    final StringBuffer digits = StringBuffer();
    bool hadPlus = false;
    bool seenSignificant = false;

    for (final int rune in raw.runes) {
      final int? digit = _digitValue(rune);
      if (digit != null) {
        digits.write(digit);
        seenSignificant = true;
        continue;
      }

      if (rune == _plus) {
        // Only ever leading, and only once. "+213+550..." is not a typo worth
        // guessing at.
        if (seenSignificant) {
          return null;
        }
        hadPlus = true;
        seenSignificant = true;
        continue;
      }

      if (_isIgnorable(rune)) {
        continue;
      }

      return null;
    }

    return (digits.toString(), hadPlus);
  }

  /// Extracts the nine national digits from a scanned digit string.
  static String? _nationalNumber(String digits, bool hadPlus) {
    if (hadPlus) {
      // An explicit country code that is not Algeria's is a foreign number.
      if (!digits.startsWith(countryCode)) {
        return null;
      }
      return _afterCountryCode(digits.substring(countryCode.length));
    }

    if (digits.startsWith('00$countryCode')) {
      return _afterCountryCode(digits.substring(2 + countryCode.length));
    }

    // `0213…` is rejected while `+213 (0)…` is accepted, and the two rules are
    // not in tension — the difference is whether an international marker is
    // present.
    //
    // With a leading `+` or `00`, everything after the country code is by
    // definition a national number, so a leading zero there can only be a
    // redundant trunk zero: see [_afterCountryCode].
    //
    // With neither marker, `0213…` has two readings — a trunk zero followed by
    // an area code beginning 213, or a mangled `00213` — and nothing in the
    // string distinguishes them. Guessing wrong writes a wrong identity key,
    // so neither reading is chosen.
    if (digits.startsWith('0$countryCode')) {
      return null;
    }

    if (digits.startsWith(countryCode) &&
        digits.length == countryCode.length + nationalLength) {
      return digits.substring(countryCode.length);
    }

    // Trunk zero: the form a driver types.
    if (digits.startsWith('0') && digits.length == 1 + nationalLength) {
      return digits.substring(1);
    }

    // Bare national number, for a driver who omits the trunk zero.
    return _exactly(digits);
  }

  /// Interprets the digits following an explicit country code.
  ///
  /// Accepts a redundant trunk zero — the `+213 (0) 550 123 456` form found on
  /// business cards and websites. Deterministic rather than a guess: no
  /// Algerian national number begins with `0`, so ten digits beginning with
  /// one can only be a trunk zero.
  ///
  /// Only reachable behind `+` or `00`. Without an international marker the
  /// same shape is ambiguous, which is why bare `0213…` is rejected.
  static String? _afterCountryCode(String rest) {
    if (rest.length == 1 + nationalLength && rest.startsWith('0')) {
      return rest.substring(1);
    }
    return _exactly(rest);
  }

  static String? _exactly(String digits) =>
      digits.length == nationalLength ? digits : null;

  static bool _hasKnownPrefix(String national) {
    final int leading = national.codeUnitAt(0) - 0x30;
    return mobilePrefixes.contains(leading) ||
        landlinePrefixes.contains(leading);
  }

  static const int _plus = 0x2B;

  /// ASCII, Arabic-Indic and Extended Arabic-Indic digits all fold to a value.
  static int? _digitValue(int rune) {
    if (rune >= 0x0030 && rune <= 0x0039) {
      return rune - 0x0030;
    }
    if (rune >= 0x0660 && rune <= 0x0669) {
      return rune - 0x0660;
    }
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      return rune - 0x06F0;
    }
    return null;
  }

  /// Characters that carry no information in a phone number: separators people
  /// type, every Unicode whitespace character, and the entire format class —
  /// bidi marks, embeddings, isolates, zero-width joiners and BOMs.
  ///
  /// Ranges rather than an enumeration of the ones that happened to come up:
  /// pasted RTL text carries whichever of these the source application used.
  static const List<(int, int)> _ignorable = <(int, int)>[
    // Separators typed by hand.
    (0x0028, 0x0029), // ( )
    (0x002D, 0x002F), // - . /
    (0x2010, 0x2015), // hyphens and dashes
    (0x2212, 0x2212), // minus sign
    // Unicode White_Space.
    (0x0009, 0x000D),
    (0x0020, 0x0020),
    (0x0085, 0x0085),
    (0x00A0, 0x00A0), // NBSP
    (0x1680, 0x1680),
    (0x2000, 0x200A),
    (0x2028, 0x2029),
    (0x202F, 0x202F), // narrow NBSP
    (0x205F, 0x205F),
    (0x3000, 0x3000),
    // Unicode format class (Cf).
    (0x00AD, 0x00AD), // soft hyphen
    (0x0600, 0x0605), // Arabic number signs
    (0x061C, 0x061C), // Arabic letter mark
    (0x06DD, 0x06DD),
    (0x070F, 0x070F),
    (0x08E2, 0x08E2),
    (0x180E, 0x180E),
    (0x200B, 0x200F), // ZWSP, ZWNJ, ZWJ, LRM, RLM
    (0x202A, 0x202E), // LRE, RLE, PDF, LRO, RLO
    (0x2060, 0x2064),
    (0x2066, 0x206F), // LRI, RLI, FSI, PDI and deprecated formatting
    (0xFEFF, 0xFEFF), // BOM / zero-width no-break space
    (0xFFF9, 0xFFFB),
  ];

  static bool _isIgnorable(int rune) {
    for (final (int start, int end) in _ignorable) {
      if (rune >= start && rune <= end) {
        return true;
      }
    }
    return false;
  }
}
