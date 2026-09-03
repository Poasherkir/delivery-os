import 'package:url_launcher/url_launcher.dart';

import '../../domain/repositories/customer_contact.dart';
import '../../domain/value_objects/phone_e164.dart';

/// [CustomerContact] through Android intents.
///
/// The only place in the app that knows `url_launcher` exists. It is not a
/// network client and does not become one: both methods hand a URI to the
/// system and return, and nothing here reads a response.
final class UrlLauncherCustomerContact implements CustomerContact {
  const UrlLauncherCustomerContact();

  @override
  Future<bool> dial(PhoneE164 phone) =>
      // `tel:` and not `callto:`, and DIAL rather than CALL: this fills the
      // dialer in and stops. The driver presses the button, which is why no
      // permission is involved.
      _open(Uri(scheme: 'tel', path: phone.e164));

  @override
  Future<bool> whatsApp(PhoneE164 phone) {
    // wa.me wants E.164 with no `+` and no separators. Built from the
    // canonical form rather than reassembled from parts, so there is one
    // definition of this customer's number and this is a view of it.
    final String digits = phone.e164.startsWith('+')
        ? phone.e164.substring(1)
        : phone.e164;

    return _open(Uri.https('wa.me', '/$digits'));
  }

  /// Returns false rather than throwing when nothing can handle the URI.
  ///
  /// A phone with no WhatsApp installed is an ordinary state, not an error —
  /// the caller renders it. `canLaunchUrl` needs the matching `<intent>` in
  /// the manifest's `<queries>` on Android 11+, or it answers no for
  /// everything.
  Future<bool> _open(Uri uri) async {
    if (!await canLaunchUrl(uri)) {
      return false;
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
