import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_fonts.dart';

const String _latin = 'Livraison Bab Ezzouar';
const String _arabic = 'توصيل باب الزوار';

const List<FontWeight> _weights = <FontWeight>[
  FontWeight.w400,
  FontWeight.w500,
  FontWeight.w600,
];

TextPainter _paint(
  String text,
  TextStyle style, {
  TextDirection direction = TextDirection.ltr,
  StrutStyle? strut,
}) => TextPainter(
  text: TextSpan(text: text, style: style),
  textDirection: direction,
  strutStyle: strut,
)..layout();

TextStyle _style({
  required double size,
  double? height,
  FontWeight weight = FontWeight.w400,
}) => TextStyle(
  fontFamily: 'IBMPlexSans',
  fontFamilyFallback: const <String>['IBMPlexSansArabic'],
  fontSize: size,
  height: height,
  fontWeight: weight,
);

void main() {
  setUpAll(loadAppFonts);

  group('digits are tabular by construction', () {
    // IBM Plex ships no `tnum` feature, so FontFeature.tabularFigures() would
    // be a no-op. It does not need one: every digit is 600/1000 em in every
    // face. This guards that — swap in a font with proportional figures and
    // money columns go ragged, which is precisely what must not happen.
    test('every digit has the same advance width, in every weight', () {
      for (final FontWeight weight in _weights) {
        final TextStyle style = _style(size: 16, weight: weight);
        final double reference = _paint('0000000000', style).width;

        for (int digit = 1; digit <= 9; digit++) {
          final String run = '$digit' * 10;
          expect(
            _paint(run, style).width,
            closeTo(reference, 0.01),
            reason: 'digit $digit is not the same width as 0 at $weight',
          );
        }
      }
    });

    test('a money column stays aligned across differing amounts', () {
      final TextStyle style = _style(size: 16, weight: FontWeight.w500);
      final List<String> amounts = <String>['1 234,00', '9 876,50', '0 000,00'];
      final Set<String> widths = amounts
          .map((String a) => _paint(a, style).width.toStringAsFixed(2))
          .toSet();

      expect(
        widths,
        hasLength(1),
        reason: 'equal-length amounts must occupy identical width',
      );
    });
  });

  group('Arabic and Latin line boxes', () {
    // The two faces disagree on vertical metrics: hhea ascent/descent is
    // 1025/-275 for Latin and 1085/-415 for Arabic, and typoLineGap is 300 vs
    // 500. Left to the font, an Arabic line is taller than its French
    // counterpart and the layout shifts on locale switch.
    test('differ when height is left to the font — the reason for the fix', () {
      final TextStyle unset = _style(size: 14);

      final double latin = _paint(_latin, unset).height;
      final double arabic = _paint(
        _arabic,
        unset,
        direction: TextDirection.rtl,
      ).height;

      expect(
        arabic,
        greaterThan(latin),
        reason:
            'if these ever match, the explicit-height rule can be revisited',
      );
    });

    test('height alone is NOT enough — Arabic stays ~2px taller', () {
      // Measured, not assumed: at 12/14/16/20/28sp the Arabic line box comes
      // out 2px taller than the Latin one even with height: 1.45 set. This is
      // why the tokens pair every style with a forced strut.
      for (final double size in <double>[12, 14, 16, 20, 28]) {
        final TextStyle style = _style(size: size, height: 1.45);

        expect(
          _paint(_arabic, style, direction: TextDirection.rtl).height,
          greaterThan(_paint(_latin, style).height),
          reason: 'if this ever passes, the forced strut can be revisited',
        );
      }
    });

    test('match exactly once a forced strut is applied', () {
      for (final double size in <double>[12, 13, 14, 16, 17, 20, 24, 28, 32]) {
        final TextStyle style = _style(size: size, height: 1.45);
        final StrutStyle strut = StrutStyle(
          fontFamily: 'IBMPlexSans',
          fontFamilyFallback: const <String>['IBMPlexSansArabic'],
          fontSize: size,
          height: 1.45,
          forceStrutHeight: true,
        );

        expect(
          _paint(
            _arabic,
            style,
            direction: TextDirection.rtl,
            strut: strut,
          ).height,
          closeTo(_paint(_latin, style, strut: strut).height, 0.01),
          reason: 'AR and FR line boxes diverge at ${size}sp',
        );
      }
    });
  });

  test('Arabic resolves to a real face rather than blank or tofu', () {
    final TextStyle style = _style(size: 14, height: 1.45);
    final TextPainter painter = _paint(
      _arabic,
      style,
      direction: TextDirection.rtl,
    );

    expect(painter.width, greaterThan(0));
    expect(painter.didExceedMaxLines, isFalse);
    // Shaped Arabic is narrower than the sum of its isolated glyphs, so a
    // per-character measurement that matches the run would mean no shaping.
    final double isolated = _arabic
        .split('')
        .map((String c) => _paint(c, style).width)
        .fold(0.0, (double a, double b) => a + b);
    expect(
      painter.width,
      lessThan(isolated),
      reason: 'Arabic is not being shaped — letters are rendering unjoined',
    );
  });
}
