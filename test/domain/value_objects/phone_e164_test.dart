import 'package:delivery_os/domain/value_objects/phone_e164.dart';
import 'package:test/test.dart';

/// The number every test normalizes to, spelled differently each time.
const String _canonical = '+213550123456';

// Bidi and invisible controls, written as escapes rather than as literal
// characters. They are invisible in an editor, so a literal is impossible to
// review and trivially mangled by a copy-paste.
/// A single character by codepoint.
///
/// Bidi and invisible controls are written as numbers, never as literals: a
/// literal is invisible in an editor, impossible to review in a diff, and
/// silently mangled by a copy-paste. This file stays plain ASCII.
String _u(int codePoint) => String.fromCharCode(codePoint);

final String lrm = _u(0x200E); // left-to-right mark
final String rlm = _u(0x200F); // right-to-left mark
final String alm = _u(0x061C); // Arabic letter mark
final String rle = _u(0x202B); // right-to-left embedding
final String lro = _u(0x202D); // left-to-right override
final String pdf = _u(0x202C); // pop directional formatting
final String lri = _u(0x2066); // left-to-right isolate
final String rli = _u(0x2067); // right-to-left isolate
final String pdi = _u(0x2069); // pop directional isolate
final String zwsp = _u(0x200B); // zero-width space
final String zwnj = _u(0x200C); // zero-width non-joiner
final String zwj = _u(0x200D); // zero-width joiner
final String bom = _u(0xFEFF); // byte order mark
final String nbsp = _u(0x00A0); // non-breaking space
final String nnbsp = _u(0x202F); // narrow non-breaking space
final String hyphen = _u(0x2010); // typographic hyphen
final String enDash = _u(0x2013);
final String minus = _u(0x2212); // minus sign, not the ASCII hyphen
final String alef = _u(0x0627); // an Arabic letter, which must be rejected

/// Rewrites ASCII digits into the Arabic-Indic block (U+0660..U+0669).
/// Built rather than typed, so the mapping is visible and cannot be mistyped.
String _arabicIndic(String source) => String.fromCharCodes(
  source.runes.map((int r) => r >= 0x30 && r <= 0x39 ? r - 0x30 + 0x0660 : r),
);

/// Rewrites ASCII digits into the Extended Arabic-Indic block
/// (U+06F0..U+06F9), which Persian and Urdu keyboard layouts emit.
String _extendedArabicIndic(String source) => String.fromCharCodes(
  source.runes.map((int r) => r >= 0x30 && r <= 0x39 ? r - 0x30 + 0x06F0 : r),
);

void _parsesTo(String raw, String expected) {
  final PhoneE164? parsed = PhoneE164.tryParse(raw);
  expect(parsed, isNotNull, reason: 'rejected: ${raw.runes.toList()}');
  expect(parsed!.e164, expected, reason: 'from: ${raw.runes.toList()}');
}

void _rejects(String raw) {
  expect(
    PhoneE164.tryParse(raw),
    isNull,
    reason: 'accepted: ${raw.runes.toList()}',
  );
}

void main() {
  group('the spellings a driver produces', () {
    test('trunk zero', () => _parsesTo('0550123456', _canonical));
    test('plus and country code', () => _parsesTo('+213550123456', _canonical));
    test('international prefix', () {
      _parsesTo('00213550123456', _canonical);
    });
    test('country code alone', () => _parsesTo('213550123456', _canonical));
    test('bare national number, trunk zero omitted', () {
      _parsesTo('550123456', _canonical);
    });

    test('a redundant trunk zero behind an international marker', () {
      // The "+213 (0) 550 123 456" form on business cards and websites.
      // Deterministic to strip: no Algerian national number begins with 0.
      _parsesTo('+213 (0) 550 123 456', _canonical);
      _parsesTo('+2130550123456', _canonical);
      _parsesTo('00213 (0) 550 123 456', _canonical);
      _parsesTo('002130550123456', _canonical);
    });

    test('but not without one — bare 213 stays strict', () {
      // No `+` and no `00`, so nothing marks this as an international form and
      // the extra tolerance is not licensed. Keeping this branch tight also
      // keeps a 13-digit tracking number from parsing as a phone.
      _rejects('2130550123456');
    });
  });

  group('separators are noise', () {
    test('spaces, in every grouping a person might use', () {
      _parsesTo('0550 12 34 56', _canonical);
      _parsesTo('05 50 12 34 56', _canonical);
      _parsesTo('+213 550 123 456', _canonical);
      _parsesTo('  0550123456  ', _canonical);
    });

    test('dashes, dots, slashes and brackets', () {
      _parsesTo('0550-12-34-56', _canonical);
      _parsesTo('0550.12.34.56', _canonical);
      _parsesTo('0550/12/34/56', _canonical);
      _parsesTo('(0550) 12 34 56', _canonical);
    });

    test('typographic dashes, which is what a paste produces', () {
      // U+2010 hyphen, U+2013 en dash, U+2212 minus — none of them the ASCII
      // hyphen a keyboard emits.
      _parsesTo('0550${hyphen}12${enDash}34${minus}56', _canonical);
    });

    test('non-breaking and narrow spaces', () {
      _parsesTo('0550${nbsp}12${nbsp}34${nbsp}56', _canonical);
      _parsesTo('0550${nnbsp}12${nnbsp}34${nnbsp}56', _canonical);
    });
  });

  group('Arabic-Indic digits', () {
    // An Arabic keyboard emits these, and this is an Arabic-first app. Nothing
    // on a French-configured device would produce one, which is exactly why it
    // needs a test rather than a manual check.
    test('Arabic-Indic block U+0660..U+0669', () {
      _parsesTo(_arabicIndic('0550123456'), _canonical);
    });

    test('Extended Arabic-Indic block U+06F0..U+06F9', () {
      _parsesTo(_extendedArabicIndic('0550123456'), _canonical);
    });

    test('the country code in Arabic-Indic too', () {
      _parsesTo(_arabicIndic('+213 550 123 456'), _canonical);
      _parsesTo(_arabicIndic('00213550123456'), _canonical);
    });

    test('mixed with ASCII, which a partial paste produces', () {
      _parsesTo(
        '0${_arabicIndic('55')}${_extendedArabicIndic('0')}123456',
        _canonical,
      );
    });

    test('every digit maps to the right value, not just the length', () {
      // 0123456789 in each block, so a transposed table would fail rather than
      // producing a number of the correct length.
      _parsesTo(_arabicIndic('0512345678'), '+213512345678');
      _parsesTo(_extendedArabicIndic('0698765432'), '+213698765432');
    });
  });

  group('bidi and invisible controls', () {
    // WhatsApp in an RTL context wraps numbers in these, and which ones depends
    // on the sending application — hence stripping the class rather than a list
    // of the ones that came up here.
    test('directional marks', () {
      _parsesTo('${lrm}0550123456$rlm', _canonical);
      _parsesTo('$alm 0550123456', _canonical);
    });

    test('embeddings and overrides', () {
      _parsesTo('$rle 0550123456 $pdf', _canonical);
      _parsesTo('$lro 0550123456 $pdf', _canonical);
    });

    test('isolates', () {
      _parsesTo('$lri 0550123456 $pdi', _canonical);
      _parsesTo('$rli${_arabicIndic('0550123456')}$pdi', _canonical);
    });

    test('zero-width characters and the BOM', () {
      _parsesTo('0550${zwsp}123${zwnj}4${zwj}56', _canonical);
      _parsesTo('$bom-0550123456', _canonical);
    });

    test('a number wrapped the way a real paste arrives', () {
      _parsesTo('$rli$rlm 0550${nbsp}12 34 56 $lrm$pdi', _canonical);
    });
  });

  group('prefix rules', () {
    test('mobile prefixes 5, 6 and 7 parse', () {
      for (final String prefix in <String>['5', '6', '7']) {
        final PhoneE164 phone = PhoneE164.parse('0${prefix}50123456');
        expect(phone.isMobile, isTrue, reason: prefix);
        expect(phone.isLandline, isFalse, reason: prefix);
      }
    });

    test('landline prefixes 2, 3 and 4 parse', () {
      for (final String prefix in <String>['2', '3', '4']) {
        final PhoneE164 phone = PhoneE164.parse('0${prefix}50123456');
        expect(phone.isLandline, isTrue, reason: prefix);
        expect(phone.isMobile, isFalse, reason: prefix);
      }
    });

    test('0, 1, 8 and 9 are not assignable leading digits', () {
      for (final String prefix in <String>['0', '1', '8', '9']) {
        _rejects('0${prefix}50123456');
      }
    });
  });

  group('rejections', () {
    test('0213 is ambiguous and is never guessed at', () {
      // A trunk zero followed by the country code, or a landline whose national
      // number begins 213. Guessing wrong writes a wrong identity key, so
      // neither reading is chosen.
      _rejects('0213456789');
      _rejects('0213550123456');
      _rejects('0 213 55 01 23 456');
    });

    test('foreign numbers', () {
      _rejects('+33612345678'); // France
      _rejects('+212612345678'); // Morocco, one digit from Algeria
      _rejects('+216550123456'); // Tunisia
      _rejects('+15550123456');
    });

    test('wrong length', () {
      _rejects('055012345'); // one short
      _rejects('05501234567'); // one long
      _rejects('+21355012345');
      _rejects('+2135501234567');
      _rejects('');
      _rejects('0');
    });

    test('letters, rather than being silently discarded', () {
      // The reason unknown characters reject instead of being skipped: a
      // stripping normalizer turns 05a50123456 into a valid number.
      _rejects('05a50123456');
      _rejects('0550123456x');
      _rejects('tel:0550123456');
      _rejects('${_arabicIndic('0550123456')}$alef');
    });

    test('a plus that is not leading', () {
      _rejects('0550+123456');
      _rejects('+213+550123456');
      _rejects('213+550123456');
    });

    test('separators alone', () {
      _rejects('----');
      _rejects('$lrm$rlm');
      _rejects('+');
      _rejects('  ');
    });
  });

  group('identity', () {
    test('every spelling of one number is one value', () {
      // The property the customer table depends on: UNIQUE(owner_id,
      // phone_e164) only detects duplicates if these all collapse to one.
      final Set<PhoneE164> distinct = <PhoneE164>{};
      for (final String spelling in <String>[
        '0550123456',
        '0550 12 34 56',
        '+213550123456',
        '+213 550 123 456',
        '00213550123456',
        '213550123456',
        '550123456',
        '0550-12-34-56',
        '$rli$rlm 0550${nbsp}12 34 56 $pdi',
        _arabicIndic('0550123456'),
        _extendedArabicIndic('0550123456'),
      ]) {
        distinct.add(PhoneE164.parse(spelling));
      }

      expect(distinct, hasLength(1));
      expect(distinct.single.e164, _canonical);
    });

    test('different numbers stay different', () {
      expect(
        PhoneE164.parse('0550123456'),
        isNot(PhoneE164.parse('0550123457')),
      );
    });

    test('hashes agree with equality', () {
      expect(
        PhoneE164.parse('0550123456').hashCode,
        PhoneE164.parse('+213 550 123 456').hashCode,
      );
    });

    test('sorts by canonical form', () {
      final List<PhoneE164> phones = <PhoneE164>[
        PhoneE164.parse('0770123456'),
        PhoneE164.parse('0550123456'),
        PhoneE164.parse('0660123456'),
      ]..sort();

      expect(phones.map((PhoneE164 p) => p.e164), <String>[
        '+213550123456',
        '+213660123456',
        '+213770123456',
      ]);
    });

    test('is never equal to its own string', () {
      expect(PhoneE164.parse('0550123456'), isNot(_canonical));
    });
  });

  group('accessors', () {
    test('exposes the national number without country code or trunk zero', () {
      expect(PhoneE164.parse('0550123456').nationalNumber, '550123456');
      expect(
        PhoneE164.parse('0550123456').nationalNumber,
        hasLength(PhoneE164.nationalLength),
      );
    });

    test('parse throws where tryParse returns null', () {
      expect(() => PhoneE164.parse('+33612345678'), throwsFormatException);
      expect(() => PhoneE164.parse('05a50123456'), throwsFormatException);
    });

    test('the exception never quotes the number', () {
      // Phone numbers are the most sensitive data in this system (§13) and
      // exception messages reach crash reports.
      try {
        PhoneE164.parse('0550123456789');
        fail('expected a FormatException');
      } on FormatException catch (e) {
        expect(e.toString(), isNot(contains('0550123456789')));
      }
    });

    test('toString is masked, for the same reason', () {
      final String rendered = PhoneE164.parse('0550123456').toString();

      expect(rendered, isNot(contains('550123456')));
      expect(rendered, contains('456')); // enough to tell two apart in a log
      expect(rendered, contains('213'));
    });
  });
}
