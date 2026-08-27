import 'package:delivery_os/core/theme/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_fonts.dart';

const String _latin = 'Bab Ezzouar — 3 400,00 DA';
const String _arabic = 'باب الزوار — ٣٤٠٠ دج';

void _expectDescending(Map<String, TextStyle> scale, String label) {
  final List<MapEntry<String, TextStyle>> steps = scale.entries.toList();
  for (int i = 1; i < steps.length; i++) {
    expect(
      steps[i].value.fontSize,
      lessThan(steps[i - 1].value.fontSize!),
      reason:
          '$label is not monotonic: ${steps[i].key} '
          '(${steps[i].value.fontSize}) >= ${steps[i - 1].key} '
          '(${steps[i - 1].value.fontSize})',
    );
  }
}

void main() {
  // Loaded here, not inside a test body: FontLoader awaits real file I/O,
  // which deadlocks inside the fake-async zone testWidgets runs in.
  setUpAll(loadAppFonts);

  group('scale', () {
    test('prose sizes decrease monotonically', () {
      _expectDescending(TypeTokens.prose, 'prose scale');
    });

    test('money sizes decrease monotonically', () {
      _expectDescending(TypeTokens.money, 'money scale');
    });
  });

  group('every style', () {
    TypeTokens.all.forEach((String name, TextStyle style) {
      test('$name is fully specified', () {
        expect(style.fontFamily, TypeTokens.family);
        expect(style.fontFamilyFallback, contains('IBMPlexSansArabic'));
        expect(style.fontSize, isNotNull);
        // An unset height hands the line box to the font, and the two faces
        // disagree about it. See font_metrics_test.dart.
        expect(style.height, isNotNull, reason: '$name has no explicit height');
        expect(style.fontWeight, isNotNull);
      });

      test('$name uses no font feature', () {
        // IBM Plex ships no `tnum`; its figures are already tabular. Requesting
        // the feature would imply a guarantee the font does not provide.
        expect(style.fontFeatures, anyOf(isNull, isEmpty));
      });

      test('$name respects the informational size floor', () {
        expect(
          style.fontSize,
          greaterThanOrEqualTo(TypeTokens.minInformationalSize),
          reason:
              '$name is ${style.fontSize}sp — nothing carrying information '
              'renders below ${TypeTokens.minInformationalSize}sp',
        );
      });

      test('$name is not a thin weight at a small size', () {
        if (style.fontSize! < TypeTokens.minSizeForRegularWeight) {
          expect(
            style.fontWeight!.value,
            greaterThanOrEqualTo(TypeTokens.medium.value),
            reason:
                '$name is ${style.fontSize}sp at ${style.fontWeight} — '
                'below ${TypeTokens.minSizeForRegularWeight}sp use medium '
                'or heavier',
          );
        }
      });
    });
  });

  test('the caption step sits at or above the caption floor', () {
    expect(
      TypeTokens.caption.fontSize,
      greaterThanOrEqualTo(TypeTokens.captionFloor),
    );
  });

  test('the caption step is the smallest step in the scale', () {
    final double smallest = TypeTokens.all.values
        .map((TextStyle s) => s.fontSize!)
        .reduce((double a, double b) => a < b ? a : b);
    expect(TypeTokens.caption.fontSize, smallest);
  });

  group('strut', () {
    test('strutFor mirrors the style and forces the line box', () {
      TypeTokens.all.forEach((String name, TextStyle style) {
        final StrutStyle strut = TypeTokens.strutFor(style);
        expect(strut.forceStrutHeight, isTrue, reason: name);
        expect(strut.fontSize, style.fontSize, reason: name);
        expect(strut.height, style.height, reason: name);
      });
    });

    test('AR and FR line boxes match for every token style', () {
      TypeTokens.all.forEach((String name, TextStyle style) {
        final StrutStyle strut = TypeTokens.strutFor(style);

        double measure(String text, TextDirection direction) => (TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: direction,
          strutStyle: strut,
        )..layout()).height;

        expect(
          measure(_arabic, TextDirection.rtl),
          closeTo(measure(_latin, TextDirection.ltr), 0.01),
          reason: '$name shifts height between AR and FR',
        );
      });
    });
  });
}
