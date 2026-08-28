import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/theme/tokens/tokens.dart';

// AppText is unusable without AppTextStyle, so callers get both from one
// import rather than having to know which token file the enum lives in.
export '../../core/theme/tokens/type_tokens.dart' show AppTextStyle;

/// The only sanctioned way to render text in this app.
///
/// Two things it guarantees that a bare [Text] does not:
///
/// 1. **The strut.** IBM Plex Sans and IBM Plex Sans Arabic disagree on
///    vertical metrics, so an Arabic line box comes out ~2px taller than its
///    French counterpart and the layout shifts on locale switch.
///    `TextStyle.height` alone does not fix it; a forced strut does. Every
///    [AppTextStyle] carries its own, and this widget always applies it.
/// 2. **The scale.** Taking an [AppTextStyle] rather than a [TextStyle] means
///    a call site cannot invent a size, so the type scale stays a scale.
///
/// A guard test fails the build on any raw `Text(` under `lib/features/` or
/// `lib/shared/`, because neither guarantee survives ten weeks of discipline
/// across forty screens.
class AppText extends StatelessWidget {
  const AppText(
    this.data,
    this.appStyle, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
  });

  final String data;

  /// The scale step. Not a [TextStyle] — see the class doc.
  final AppTextStyle appStyle;

  /// Defaults to the theme's primary text colour.
  ///
  /// Pass a semantic token (`context.colors.statusSuccessFg`,
  /// `context.colors.moneyEarningFg`), never a literal.
  final Color? color;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// Overrides what a screen reader announces. Needed where the visible string
  /// is abbreviated — "1 250,00 DA" reads badly without it.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ColorTokens tokens = context.colors;

    // Arabic may need a size bump the Latin scale does not; the multiplier is
    // 1.0 until measured on a device. Applied to the strut as well, so the
    // line box grows with the glyphs instead of clipping them.
    final double scale = TypeTokens.scriptMultiplierFor(
      Localizations.maybeLocaleOf(context),
    );
    final TextStyle style = scale == 1
        ? appStyle.style
        : appStyle.style.copyWith(fontSize: appStyle.style.fontSize! * scale);
    final StrutStyle strut = scale == 1
        ? appStyle.strut
        : TypeTokens.strutFor(style);

    // The one place a raw Text is allowed. See the guard test.
    return Text(
      data,
      style: style.copyWith(color: color ?? tokens.textPrimary),
      strutStyle: strut,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );
  }
}
