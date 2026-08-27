import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Semantic colour tokens for one theme.
///
/// Two instances exist, [light] and [dark]. Every role is a required
/// constructor argument, so a colour cannot be defined for one theme and
/// forgotten in the other — the compiler enforces the parity rather than a
/// reviewer noticing.
///
/// The palette is neutral-heavy with a single accent, and the accent is
/// reserved for the primary action. Status, money and action never share a hue.
/// Contrast ratios are asserted in `test/core/theme/color_tokens_test.dart`
/// against measured values; nothing here was judged by eye.
///
/// **Colour is never the only signal.** Every status also carries an icon and a
/// label. The four status hues survive a deuteranopia/protanopia/tritanopia
/// simulation as foregrounds, but their pale backgrounds do not reliably, and
/// sunlight narrows the margin further.
@immutable
class ColorTokens {
  const ColorTokens({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textInverse,
    required this.accent,
    required this.accentPressed,
    required this.accentSubtle,
    required this.onAccent,
    required this.focus,
    required this.statusNeutralFg,
    required this.statusNeutralBg,
    required this.statusProgressFg,
    required this.statusProgressBg,
    required this.statusSuccessFg,
    required this.statusSuccessBg,
    required this.statusProblemFg,
    required this.statusProblemBg,
    required this.moneyEarningFg,
    required this.moneyEarningBg,
    required this.moneyOwedFg,
    required this.moneyOwedBg,
    required this.scrim,
  });

  /// Page background. Slightly off-surface so bordered cards read as cards.
  final Color canvas;

  /// Card, row and sheet background.
  final Color surface;

  /// Modals and bottom sheets sitting above [surface].
  final Color surfaceRaised;

  /// Inset areas — meta blocks, disabled fields.
  final Color surfaceSunken;

  /// Default 1px rule. Decorative; it is not required to be perceivable alone.
  final Color border;

  /// Emphasised divider and input outline. Meets 3:1 against [surface].
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  /// Text on top of [accent].
  final Color textInverse;

  /// The one accent. Primary action only — never a status, never decoration.
  final Color accent;
  final Color accentPressed;

  /// Tinted accent background for selected rows and subtle emphasis.
  final Color accentSubtle;
  final Color onAccent;
  final Color focus;

  /// Status bucket: `pending`.
  final Color statusNeutralFg;
  final Color statusNeutralBg;

  /// Status bucket: `on_route`, `arrived`.
  final Color statusProgressFg;
  final Color statusProgressBg;

  /// Status bucket: `delivered`.
  final Color statusSuccessFg;
  final Color statusSuccessBg;

  /// Status bucket: `failed`, `rescheduled`, `returned_to_agency`,
  /// `cancelled_by_merchant`.
  final Color statusProblemFg;
  final Color statusProblemBg;

  /// Money the driver keeps.
  final Color moneyEarningFg;
  final Color moneyEarningBg;

  /// Money held on the company's behalf. Custodial, not an error — this must
  /// never be the problem red. A driver holding 400 000 DA is not in a failure
  /// state.
  final Color moneyOwedFg;
  final Color moneyOwedBg;

  /// Behind modals.
  final Color scrim;

  /// Every token by name. Used by the token gallery and by the contrast tests
  /// so a newly added colour cannot escape verification.
  Map<String, Color> get all => <String, Color>{
    'canvas': canvas,
    'surface': surface,
    'surfaceRaised': surfaceRaised,
    'surfaceSunken': surfaceSunken,
    'border': border,
    'borderStrong': borderStrong,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'textDisabled': textDisabled,
    'textInverse': textInverse,
    'accent': accent,
    'accentPressed': accentPressed,
    'accentSubtle': accentSubtle,
    'onAccent': onAccent,
    'focus': focus,
    'statusNeutralFg': statusNeutralFg,
    'statusNeutralBg': statusNeutralBg,
    'statusProgressFg': statusProgressFg,
    'statusProgressBg': statusProgressBg,
    'statusSuccessFg': statusSuccessFg,
    'statusSuccessBg': statusSuccessBg,
    'statusProblemFg': statusProblemFg,
    'statusProblemBg': statusProblemBg,
    'moneyEarningFg': moneyEarningFg,
    'moneyEarningBg': moneyEarningBg,
    'moneyOwedFg': moneyOwedFg,
    'moneyOwedBg': moneyOwedBg,
    'scrim': scrim,
  };

  static const ColorTokens light = ColorTokens(
    canvas: Color(0xFFEEF1F5),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE4E8EE),
    border: Color(0xFFD3D9E0),
    borderStrong: Color(0xFF808A97),
    textPrimary: Color(0xFF14181D),
    textSecondary: Color(0xFF545C68),
    textDisabled: Color(0xFF8A94A0),
    textInverse: Color(0xFFFFFFFF),
    accent: Color(0xFF1350C4),
    accentPressed: Color(0xFF0E3E99),
    accentSubtle: Color(0xFFE4ECFB),
    onAccent: Color(0xFFFFFFFF),
    focus: Color(0xFF1350C4),
    statusNeutralFg: Color(0xFF545C68),
    statusNeutralBg: Color(0xFFE4E8EE),
    statusProgressFg: Color(0xFF7A4A00),
    statusProgressBg: Color(0xFFFBEED4),
    statusSuccessFg: Color(0xFF0F6034),
    statusSuccessBg: Color(0xFFDFF1E6),
    statusProblemFg: Color(0xFFA81F16),
    statusProblemBg: Color(0xFFFBE4E2),
    moneyEarningFg: Color(0xFF06605C),
    moneyEarningBg: Color(0xFFDBF0EE),
    moneyOwedFg: Color(0xFF6B3A86),
    moneyOwedBg: Color(0xFFF0E5F5),
    scrim: Color(0x8014181D),
  );

  static const ColorTokens dark = ColorTokens(
    canvas: Color(0xFF0D1014),
    surface: Color(0xFF171C22),
    surfaceRaised: Color(0xFF1F252D),
    surfaceSunken: Color(0xFF10141A),
    border: Color(0xFF2C343E),
    borderStrong: Color(0xFF6C7683),
    textPrimary: Color(0xFFF2F5F8),
    textSecondary: Color(0xFFA9B3C0),
    textDisabled: Color(0xFF6C7683),
    textInverse: Color(0xFF0A1220),
    accent: Color(0xFF6FA3FF),
    accentPressed: Color(0xFFA0C4FF),
    accentSubtle: Color(0xFF16233A),
    onAccent: Color(0xFF0A1220),
    focus: Color(0xFF6FA3FF),
    statusNeutralFg: Color(0xFFA9B3C0),
    statusNeutralBg: Color(0xFF232A33),
    statusProgressFg: Color(0xFFF0B849),
    statusProgressBg: Color(0xFF33280F),
    statusSuccessFg: Color(0xFF5FD08A),
    statusSuccessBg: Color(0xFF102B1C),
    statusProblemFg: Color(0xFFFF8A80),
    statusProblemBg: Color(0xFF35191A),
    moneyEarningFg: Color(0xFF4FD1C5),
    moneyEarningBg: Color(0xFF0E2B2A),
    moneyOwedFg: Color(0xFFC79BE0),
    moneyOwedBg: Color(0xFF271A31),
    scrim: Color(0xB3000000),
  );
}
