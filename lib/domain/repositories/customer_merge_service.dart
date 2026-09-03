import '../entities/customer.dart';

/// Merges [loser] into [survivor], as `features/` sees it.
///
/// A separate interface from [CustomerRepository] deliberately. Two records
/// for one human happens for ordinary reasons — a number entered before
/// normalization improved, the same person arriving through two companies —
/// and merge is the real answer to it. `CustomerRepository` explains why it
/// offers no `restore`: the partial unique index makes restoring into a
/// collision have no good answer, and this is the operation that actually
/// solves the problem restore would only have papered over.
///
/// **What moves and what does not.** Every live order and address on
/// [loser] moves onto [survivor]. Nothing else does — not notes, not the
/// risk flag, not the display name. Those are the survivor's own facts and
/// merge does not invent a policy for combining them that nobody asked for;
/// the driver picked which record survives, and it survives as itself.
///
/// **The pins are the part that must not be lost.** Where [loser] and
/// [survivor] both hold an address at the same door — same wilaya, same
/// commune, same detail — only the higher-confidence one survives, and any
/// order that pointed at the one retired is repointed to the one kept.
/// Silently keeping the lower-confidence pin, or silently duplicating the
/// door as two rows, would each waste real evidence: a confidence-4 pin is a
/// GPS fix confirmed at an actual delivery, and invariant 9 says a pin is
/// never silently downgraded. A tie keeps the survivor's own row, since nothing
/// distinguishes them and the survivor's is already where its orders point.
abstract interface class CustomerMergeService {
  /// Merges [loser] into [survivor]. [loser] ends up soft-deleted.
  ///
  /// Throws [ArgumentError] if the two ids are the same — a screen that lets
  /// a driver pick two records to merge must never let them pick one record
  /// twice, so reaching this is a bug in the caller, not a state to render.
  ///
  /// Throws [StateError] if either id does not currently name a live
  /// customer. A row that vanished between the driver choosing it and the
  /// merge running is a state the screen has to handle, not one to absorb
  /// silently here.
  Future<Customer> merge({required String survivorId, required String loserId});
}
