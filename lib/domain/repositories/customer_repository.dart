import '../entities/customer.dart';
import '../value_objects/customer_risk_flag.dart';
import '../value_objects/phone_e164.dart';

/// Raised when a number already belongs to a live customer.
///
/// A named failure rather than a bare exception, because the entry flow has to
/// tell them apart: this one has a good answer for the driver — "you already
/// have this customer" — and any other write failure does not.
final class DuplicatePhoneException implements Exception {
  const DuplicatePhoneException(this.existing);

  /// The customer already holding the number, so the UI can offer to open it
  /// rather than making the driver search again.
  final Customer existing;

  @override
  String toString() => 'DuplicatePhoneException(${existing.id})';
}

/// Reading and writing customers, as `features/` sees it.
///
/// Note what is absent. There is no `restore`: a soft-deleted customer stays
/// deleted, because restoring into a collision with the partial unique index
/// has no good answer, and the operation would exist only because it was
/// invented. The product need is merge, and it is [CustomerMergeService] — a
/// separate interface, because it is a separate decision with its own rules
/// about orders and learned pins rather than one more method bolted on here.
abstract interface class CustomerRepository {
  /// Every live customer, oldest first.
  Future<List<Customer>> all();

  /// Free-text search over name and number.
  ///
  /// An empty or whitespace query returns everything, so a search field that
  /// has been cleared behaves like no search rather than like no results.
  Future<List<Customer>> search(String query);

  /// The customer holding this number, or null.
  ///
  /// The identity lookup the entry flow runs before anything else.
  Future<Customer?> findByPhone(PhoneE164 phone);

  /// Customers whose number never parsed and still needs a human.
  Future<List<Customer>> needingPhoneReview();

  /// Creates a customer from a number that parsed.
  ///
  /// Throws [DuplicatePhoneException] when the number is already taken by a
  /// live customer, carrying that customer so the caller can offer it.
  Future<Customer> create({
    required PhoneE164 phone,
    required String displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag riskFlag,
  });

  /// Creates a customer from a number that did not parse.
  ///
  /// Separate from [create] on purpose: absorbing a parse failure silently
  /// would hide a typo, so keeping an unparseable number is a decision the
  /// caller makes explicitly.
  Future<Customer> createUnparsed({
    required String rawPhone,
    required String displayName,
    String? notes,
  });

  /// Edits a customer. Only the named fields move.
  Future<Customer> edit({
    required Customer current,
    String? displayName,
    PhoneE164? phoneAlt,
    String? notes,
    CustomerRiskFlag? riskFlag,
  });

  /// Replaces an unparsed number with one that parses.
  Future<Customer> resolvePhone({
    required Customer current,
    required PhoneE164 phone,
  });

  /// Soft-deletes a customer. Orders pointing at them still read.
  Future<void> softDelete(Customer current);
}
