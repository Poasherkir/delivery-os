import '../../domain/value_objects/centimes.dart';

/// Renders money for the driver.
///
/// **Identical in every locale, and that is a product decision rather than a
/// typographic one.** A driver reads a settlement total on this screen and
/// compares it against the company's paper bordereau. The paper does not change
/// language. If the Arabic build rendered `٤٥٬٥٠٠٫٠٠` and the bordereau said
/// `45 500,00`, he would have to convert scripts in his head while reconciling
/// cash — at the exact moment the app exists to make that easy.
///
/// So nothing here is inherited. Not the digits, not the grouping separator,
/// not the decimal separator, not from `MaterialLocalizations` and not from the
/// ambient locale. Every symbol is a constant in this file, and the tests pin
/// each one in both locales.
///
/// The one part that may localize is the currency abbreviation, because `DA`
/// and `دج` are read as the same word and neither is a number. It is passed in
/// rather than decided here.
abstract final class MoneyFormat {
  /// Western digits, always.
  ///
  /// Correct for Algeria — the Maghreb uses `0-9` while the Gulf uses
  /// `٠-٩` — and pinned rather than inherited, because it was previously
  /// correct only because `MaterialLocalizations` for `ar` happened to agree.
  /// A framework default that happens to match us is not a decision, and it can
  /// change silently.
  static const String digits = '0123456789';

  /// A non-breaking space, built from its codepoint rather than pasted: it is
  /// invisible in an editor and unreviewable in a diff.
  ///
  /// Non-breaking so an amount never wraps across a line. `45 500` split over
  /// two lines is a number a tired driver can misread as two.
  static final String groupSeparator = String.fromCharCode(0x00A0);

  /// Comma, as the bordereau uses.
  static const String decimalSeparator = ',';

  /// Groups of three, from the right.
  static const int groupSize = 3;

  /// Formats [amount] as a plain number, with no currency.
  ///
  /// Always two decimals: money that sometimes shows them and sometimes does
  /// not is money a driver has to read twice to be sure what it says.
  static String amount(Centimes amount) {
    final int value = amount.value;
    final bool negative = value < 0;

    // Split before formatting so the sign is never caught up in grouping, and
    // so a negative amount groups the same way a positive one does.
    //
    // `abs()` on the integer rather than on Centimes: the most negative 64-bit
    // value has no positive counterpart, and Centimes.abs would throw. That is
    // correct for money arithmetic and wrong for a formatter, whose job is to
    // render whatever it is handed.
    final BigInt magnitude = BigInt.from(value).abs();
    final BigInt perDinar = BigInt.from(Centimes.centimesPerDinar);

    final String dinars = _group((magnitude ~/ perDinar).toString());
    final String fraction = (magnitude % perDinar).toString().padLeft(2, '0');

    return '${negative ? '-' : ''}$dinars$decimalSeparator$fraction';
  }

  /// Formats [amount] with a currency abbreviation after it.
  ///
  /// [currency] is supplied by the caller from the l10n bundle, because `DA`
  /// and `دج` are the same word in two scripts. The separator before it is the
  /// same non-breaking space, so the unit never wraps away from its number.
  static String withCurrency(Centimes value, String currency) =>
      '${amount(value)}$groupSeparator$currency';

  static String _group(String digits) {
    if (digits.length <= groupSize) {
      return digits;
    }

    final StringBuffer out = StringBuffer();
    final int lead = digits.length % groupSize;

    if (lead > 0) {
      out.write(digits.substring(0, lead));
    }
    for (int i = lead; i < digits.length; i += groupSize) {
      if (out.isNotEmpty) {
        out.write(groupSeparator);
      }
      out.write(digits.substring(i, i + groupSize));
    }
    return out.toString();
  }
}
