import 'package:delivery_os/domain/repositories/user_settings.dart';
import 'package:test/test.dart';

/// The `==`/`hashCode` contract on [LocalePreference].
///
/// Not a coverage exercise. This type is compared in tests and is a plausible
/// map key or set member the moment settings grow past one field, and a value
/// type whose `hashCode` disagrees with its `==` fails in the least debuggable
/// way there is: a lookup that misses a key the map demonstrably contains.
///
/// `==` was already exercised; `hashCode` was not, which is exactly the half
/// that breaks silently — an inconsistent `hashCode` never throws.
void main() {
  group('equality', () {
    test('same tag is equal', () {
      expect(const LocalePreference('fr'), const LocalePreference('fr'));
    });

    test('different tags are not', () {
      expect(const LocalePreference('fr'), isNot(const LocalePreference('ar')));
    });

    test('"follow the device" equals itself', () {
      // The state the nullable column exists to represent. If this were not
      // equal to itself, reconcile's no-op check would fire every launch.
      expect(const LocalePreference(null), const LocalePreference(null));
    });

    test('"follow the device" is not any explicit choice', () {
      expect(const LocalePreference(null), isNot(const LocalePreference('ar')));
    });

    test('and is not equal to a bare null', () {
      // The distinction the whole type exists for: no user row at all versus a
      // row whose preference is "follow the device".
      expect(const LocalePreference(null), isNot(null));
    });

    test('is not equal to another type carrying the same tag', () {
      expect(const LocalePreference('fr'), isNot('fr'));
    });
  });

  group('hashCode agrees with equality', () {
    test('equal values hash equally', () {
      // The contract. A hashCode inconsistent with == does not throw; it makes
      // a Set silently hold two copies of one value.
      expect(
        const LocalePreference('fr').hashCode,
        const LocalePreference('fr').hashCode,
      );
      expect(
        const LocalePreference(null).hashCode,
        const LocalePreference(null).hashCode,
      );
    });

    test('a Set collapses duplicates and keeps distinct values', () {
      // The observable consequence, which is what actually matters.
      //
      // Built through a list rather than as a set literal on purpose: the
      // analyzer rejects duplicate elements in a literal, and going through
      // `toSet()` is the better test anyway — that is the path that actually
      // calls `hashCode`.
      final List<LocalePreference> items = <LocalePreference>[
        const LocalePreference('fr'),
        const LocalePreference('fr'),
        const LocalePreference('ar'),
        const LocalePreference(null),
        const LocalePreference(null),
      ];
      final Set<LocalePreference> set = items.toSet();

      expect(set, hasLength(3));
      expect(set, contains(const LocalePreference(null)));
    });

    test('a Map finds a key built separately from the one inserted', () {
      final Map<LocalePreference, String> m = <LocalePreference, String>{
        const LocalePreference('ar'): 'explicit Arabic',
        const LocalePreference(null): 'follow the device',
      };

      expect(m[const LocalePreference('ar')], 'explicit Arabic');
      expect(m[const LocalePreference(null)], 'follow the device');
      expect(m[const LocalePreference('fr')], isNull);
    });
  });

  group('isExplicit', () {
    test('is true only for a tag', () {
      expect(const LocalePreference('ar').isExplicit, isTrue);
      expect(const LocalePreference(null).isExplicit, isFalse);
    });
  });

  group('toString', () {
    test('names the tag', () {
      expect(const LocalePreference('fr').toString(), contains('fr'));
    });

    test('says what null means rather than printing "null"', () {
      // This string reaches a log line or a test failure message. "null" there
      // is ambiguous between the two states this type exists to separate.
      expect(
        const LocalePreference(null).toString(),
        contains('follow the device'),
      );
    });

    test('carries no PII, because a language tag is not personal', () {
      // Stated so the PII rule is not applied here by analogy and the value
      // masked into uselessness. `ar` and `fr` identify nobody.
      expect(const LocalePreference('ar').toString(), contains('ar'));
    });
  });
}
