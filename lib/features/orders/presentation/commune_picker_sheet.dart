import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/repositories/geography_repository.dart';
import '../../../shared/widgets/app_text.dart';

/// Picks a commune by typing.
///
/// A sheet rather than a screen: the driver is mid-parcel and comes straight
/// back. Search rather than a wilaya-then-commune drill-down, because there are
/// over fifteen hundred communes and the driver is reading one name off a
/// label — they know the name, not which of fifty-eight wilayas it sits in.
///
/// Matches either name, so a French label on a parcel and an Arabic spelling
/// find the same commune. Both names are shown for the same reason: whichever
/// one the driver is reading, the other confirms it.
class CommunePickerSheet extends ConsumerStatefulWidget {
  const CommunePickerSheet({super.key});

  /// Opens the sheet and returns the chosen commune, or null.
  static Future<Commune?> show(BuildContext context) =>
      showModalBottomSheet<Commune>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) => const CommunePickerSheet(),
      );

  @override
  ConsumerState<CommunePickerSheet> createState() => _CommunePickerSheetState();
}

class _CommunePickerSheetState extends ConsumerState<CommunePickerSheet> {
  final TextEditingController _query = TextEditingController();

  Timer? _debounce;

  /// Guards against an earlier search landing after a later one, the same way
  /// the phone lookup does. Without it a slow query for `bab` could overwrite
  /// the results for `bab ezz`.
  int _generation = 0;

  List<Commune> _results = const <Commune>[];
  bool _searched = false;

  static const Duration _debounceDelay = Duration(milliseconds: 200);

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final int generation = ++_generation;
    final String trimmed = value.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _results = const <Commune>[];
        _searched = false;
      });
      return;
    }

    _debounce = Timer(_debounceDelay, () => _run(trimmed, generation));
  }

  Future<void> _run(String query, int generation) async {
    final GeographyRepository? geo = ref.read(geographyRepositoryProvider);
    final List<Commune> found =
        await geo?.searchCommunes(query) ?? const <Commune>[];

    if (!mounted || generation != _generation) {
      return;
    }
    setState(() {
      _results = found;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    // Which name to show is decided here, from the active locale, because this
    // is the only place that knows it. `Commune` deliberately carries both.
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(SpaceTokens.space16),
            child: TextField(
              key: const Key('communePicker.query'),
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                labelText: l10n.orderCommuneSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Flexible(
            child: _searched && _results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(SpaceTokens.space24),
                    child: AppText(
                      l10n.orderCommuneNoResults,
                      AppTextStyle.body,
                      key: const Key('communePicker.empty'),
                      color: context.colors.textSecondary,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Commune commune = _results[index];
                      return ListTile(
                        key: Key('communePicker.row.${commune.id}'),
                        minTileHeight: 56,
                        title: AppText(
                          arabic ? commune.nameAr : commune.nameFr,
                          AppTextStyle.body,
                        ),
                        subtitle: AppText(
                          arabic ? commune.nameFr : commune.nameAr,
                          AppTextStyle.caption,
                          color: context.colors.textSecondary,
                        ),
                        onTap: () => Navigator.of(context).pop(commune),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
