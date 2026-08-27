import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled IBM Plex faces into the test font collection.
///
/// `flutter_test` renders everything in Ahem by default, so any test that makes
/// a claim about real metrics — digit widths, line heights, Arabic shaping —
/// must call this first or it is measuring a placeholder.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final String family in <String>['IBMPlexSans', 'IBMPlexSansArabic']) {
    final FontLoader loader = FontLoader(family);
    for (final String weight in <String>['Regular', 'Medium', 'SemiBold']) {
      final File file = File('assets/fonts/$family-$weight.ttf');
      loader.addFont(
        file.readAsBytes().then(
          (Uint8List bytes) => ByteData.view(bytes.buffer),
        ),
      );
    }
    await loader.load();
  }
}
