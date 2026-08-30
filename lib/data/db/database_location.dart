import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Where the encrypted database lives on the device.
///
/// **Application-private internal storage, never external.** External storage
/// is world-readable on older Android and survives an uninstall; this file is a
/// list of Algerian households, their addresses, and when they receive valuable
/// cash-on-delivery parcels (§13). Encryption is the real protection, but
/// putting the file somewhere other apps can enumerate is a second mistake with
/// no upside.
///
/// Kept in its own file because `path_provider` is a platform plugin and cannot
/// run on the test host. Everything that decides *whether* to open, and with
/// what key, lives in `encryption/` and is testable — this only answers where.
Future<File> defaultDatabaseFile() async {
  final Directory documents = await getApplicationDocumentsDirectory();
  return File('${documents.path}/delivery_os.db');
}
