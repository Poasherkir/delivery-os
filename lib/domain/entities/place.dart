import 'package:meta/meta.dart';

/// A wilaya, as `features/` sees it.
///
/// Carries both names because which one to show is the *caller's* decision,
/// made from the active locale — a picker cannot be handed a pre-resolved
/// string without also being handed the locale that resolved it, and then two
/// places decide the same thing.
@immutable
final class Wilaya {
  const Wilaya({
    required this.code,
    required this.nameFr,
    required this.nameAr,
    this.isRetired = false,
  });

  final int code;
  final String nameFr;
  final String nameAr;

  /// True when the bundled dataset no longer lists this wilaya.
  ///
  /// Retired rows stay resolvable so an address recorded before an
  /// administrative reform still renders its province name. They are kept out
  /// of pickers — offering a driver a wilaya that no longer exists would
  /// produce addresses nobody can deliver to.
  final bool isRetired;

  @override
  bool operator ==(Object other) => other is Wilaya && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Wilaya($code, $nameFr)';
}

/// A commune, and the wilaya it belongs to.
@immutable
final class Commune {
  const Commune({
    required this.id,
    required this.wilayaCode,
    required this.nameFr,
    required this.nameAr,
    this.isRetired = false,
  });

  final int id;
  final int wilayaCode;
  final String nameFr;
  final String nameAr;

  /// See [Wilaya.isRetired]. Communes are where this matters most: the eleven
  /// wilayas created in November 2025 were carved out of existing ones, so a
  /// commune's *parent* can change without the commune itself moving.
  final bool isRetired;

  @override
  bool operator ==(Object other) => other is Commune && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Commune($id, $nameFr)';
}
