import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers the SIL Open Font Licence for the bundled IBM Plex faces.
///
/// The OFL requires its text to accompany any redistribution of the fonts, and
/// shipping them inside the APK is a redistribution. This puts the licence in
/// the app's own licence page rather than only in the repository.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final String text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const <String>[
      'IBM Plex Sans',
      'IBM Plex Sans Arabic',
    ], text);
  });
}
