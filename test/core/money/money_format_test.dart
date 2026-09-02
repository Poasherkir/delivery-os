import 'package:delivery_os/core/money/money_format.dart';
import 'package:delivery_os/domain/value_objects/centimes.dart';
import 'package:test/test.dart';

/// The non-breaking space, built from its codepoint here too so the expected
/// values in this file are readable in a diff.
final String _nbsp = String.fromCharCode(0x00A0);

void main() {
  group('the shape of an amount', () {
    // Every expected value below is derived by hand from the definition —
    // centimes divided by 100, grouped in threes from the right, two decimals
    // always — rather than from running the implementation.

    test('a whole number of dinars still shows two decimals', () {
      // 45500 dinars = 4_550_000 centimes. Money that sometimes shows decimals
      // and sometimes does not is money a driver reads twice.
      expect(MoneyFormat.amount(const Centimes(4550000)), '45${_nbsp}500,00');
    });

    test('centimes are not rounded away', () {
      // 3400,27 DA = 340027 centimes.
      expect(MoneyFormat.amount(const Centimes(340027)), '3${_nbsp}400,27');
    });

    test('a leading zero on the fraction survives', () {
      // 7 centimes is 0,07 — not 0,7, which is a hundredfold error in the
      // direction that would be paid out.
      expect(MoneyFormat.amount(const Centimes(7)), '0,07');
    });

    test('zero is zero', () {
      expect(MoneyFormat.amount(Centimes.zero), '0,00');
    });

    test('groups appear only above a thousand', () {
      // 999,99 DA = 99999 centimes.
      expect(MoneyFormat.amount(const Centimes(99999)), '999,99');
      // 1000,00 DA = 100000 centimes.
      expect(MoneyFormat.amount(const Centimes(100000)), '1${_nbsp}000,00');
    });

    test('every group is three digits, including the millions', () {
      // 1 234 567,89 DA = 123456789 centimes.
      expect(
        MoneyFormat.amount(const Centimes(123456789)),
        '1${_nbsp}234${_nbsp}567,89',
      );
    });

    test('a negative amount keeps the sign outside the grouping', () {
      // The retour case: a driver can owe the company. -45 500,00.
      expect(MoneyFormat.amount(const Centimes(-4550000)), '-45${_nbsp}500,00');
    });

    test('the most negative value formats rather than throwing', () {
      // Centimes.abs() throws here, correctly — there is no positive
      // counterpart in 64 bits. A formatter's job is to render whatever it is
      // handed, so it must not inherit that.
      expect(
        () => MoneyFormat.amount(Centimes(-9223372036854775807 - 1)),
        returnsNormally,
      );
    });
  });

  group('the symbols are pinned, not inherited', () {
    // The reason this file exists. A driver reads a total here and compares it
    // against the company's paper bordereau, which does not change language. If
    // the Arabic build rendered ٤٥٬٥٠٠ against a bordereau saying 45 500, he
    // would be converting scripts in his head while reconciling cash.

    test('digits are Western, never Arabic-Indic', () {
      final String rendered = MoneyFormat.amount(const Centimes(123456789));

      for (final String easternDigit in <String>[
        '٠',
        '١',
        '٢',
        '٣',
        '٤',
        '٥',
        '٦',
        '٧',
        '٨',
        '٩',
      ]) {
        expect(
          rendered,
          isNot(contains(easternDigit)),
          reason: 'Eastern Arabic-Indic digits reached a money string',
        );
      }
      // Built from codepoints rather than written as a character class
      // containing a pasted non-breaking space — which is what this file did
      // first, in the test that pins a codepoint-built separator.
      const Set<int> allowed = <int>{
        0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, // 0-9
        0x2C, // comma
        0x2D, // minus
        0xA0, // non-breaking space
      };
      expect(
        rendered.codeUnits.every(allowed.contains),
        isTrue,
        reason: 'a character outside the pinned set reached a money string',
      );
    });

    test('the group separator is a non-breaking space', () {
      // Non-breaking so an amount never wraps across a line: `45 500` split
      // over two lines is a number a tired driver can misread as two.
      // Asserted by codepoint, not against another constructed string: two
      // identical constructions comparing equal proves nothing about which
      // character it is.
      expect(MoneyFormat.groupSeparator, hasLength(1));
      expect(MoneyFormat.groupSeparator.codeUnitAt(0), 0xA0);
      expect(
        MoneyFormat.amount(const Centimes(100000)),
        isNot(contains(' ')),
        reason: 'an ordinary space would let the amount wrap',
      );
    });

    test('the decimal separator is a comma', () {
      expect(MoneyFormat.decimalSeparator, ',');
      expect(MoneyFormat.amount(const Centimes(100)), '1,00');
    });

    test('nothing in the output depends on an ambient locale', () {
      // There is no locale parameter and no locale lookup, which is the
      // structural version of this guarantee: the same call cannot produce two
      // answers. This asserts the observable half.
      final String once = MoneyFormat.amount(const Centimes(4550027));
      final String twice = MoneyFormat.amount(const Centimes(4550027));

      expect(once, twice);
      expect(once, '45${_nbsp}500,27');
    });
  });

  group('the currency abbreviation', () {
    test('is whatever the caller passes, in either script', () {
      // The one part that may localize, because DA and دج are read as the same
      // word and neither is a number.
      expect(
        MoneyFormat.withCurrency(const Centimes(4550000), 'DA'),
        '45${_nbsp}500,00${_nbsp}DA',
      );
      const String dinarAr = 'دج';
      expect(
        MoneyFormat.withCurrency(const Centimes(4550000), dinarAr),
        '45${_nbsp}500,00$_nbsp$dinarAr',
      );
    });

    test('is joined by a non-breaking space too', () {
      // The unit must not wrap away from its number.
      expect(
        MoneyFormat.withCurrency(Centimes.zero, 'DA'),
        isNot(contains(' ')),
      );
    });
  });
}
