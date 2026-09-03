import '../value_objects/phone_e164.dart';

/// Handing a customer's number to whatever app can act on it.
///
/// An interface because `domain/` imports nothing from Flutter or a plugin
/// (invariant 4), and a screen test must be able to assert *that* a call was
/// launched without an Android intent existing to launch it.
///
/// **Nothing here places a call or sends a message.** [dial] opens the phone
/// app with the number filled in, where the driver presses the button; [whatsApp]
/// opens a chat. That distinction is why neither needs a permission, and it is
/// deliberate rather than a limitation — an app that could dial on its own is
/// an app that can dial by accident.
abstract interface class CustomerContact {
  /// Opens the dialer with [phone] filled in. The driver presses call.
  ///
  /// Returns false when nothing on the device can handle it, which the caller
  /// has to render rather than swallow: a button that silently does nothing is
  /// worse than one that says it cannot.
  Future<bool> dial(PhoneE164 phone);

  /// Opens a WhatsApp chat with [phone].
  ///
  /// Only meaningful for a mobile number — `PhoneE164.isMobile` is how a caller
  /// decides whether to offer it at all. Asked for a landline this will simply
  /// fail, which is the honest outcome but a worse one than not offering it.
  Future<bool> whatsApp(PhoneE164 phone);
}
