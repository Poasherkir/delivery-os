import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../app/di.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/batch.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/address_repository.dart';
import '../../../domain/repositories/batch_repository.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/value_objects/centimes.dart';
import '../../../domain/value_objects/delivery_type.dart';
import '../../../domain/value_objects/phone_e164.dart';

/// What the driver has filled in, before any of it is written.
///
/// A plain value rather than a pile of arguments, so the save path can be
/// exercised without building a screen — which is the only way the ordering
/// below gets tested at all.
@immutable
final class OrderDraft {
  const OrderDraft({
    required this.companyId,
    required this.trackingNumber,
    this.phone = '',
    this.customerName = '',
    this.wilayaCode,
    this.communeId,
    this.addressDetail,
    this.codAmount = Centimes.zero,
    this.deliveryType = DeliveryType.home,
    this.notes,
  });

  final String companyId;
  final String trackingNumber;

  /// Raw, as typed. Parsed here rather than by the field, because a number that
  /// will not parse is kept verbatim rather than refused.
  final String phone;

  final String customerName;
  final int? wilayaCode;
  final int? communeId;
  final String? addressDetail;
  final Centimes codAmount;
  final DeliveryType deliveryType;
  final String? notes;

  bool get hasPhone => phone.trim().isNotEmpty;

  bool get hasCommune => wilayaCode != null && communeId != null;
}

/// The outcome of trying to save. Exclusive by construction.
@immutable
sealed class OrderEntryResult {
  const OrderEntryResult();
}

final class OrderEntrySaved extends OrderEntryResult {
  const OrderEntrySaved(this.order);

  final Order order;
}

/// The company already has an order with this tracking number.
///
/// Not an error. Scanning the same parcel twice is the ordinary way this
/// happens, and the answer is to show the driver the parcel they already
/// entered.
final class OrderEntryDuplicate extends OrderEntryResult {
  const OrderEntryDuplicate(this.existing);

  final Order existing;
}

/// The database is not open. The form cannot save and says so rather than
/// appearing to.
final class OrderEntryUnavailable extends OrderEntryResult {
  const OrderEntryUnavailable();
}

/// Writes one parcel into today's work.
///
/// Four entities can be touched by one save — a batch, a customer, an address
/// and the order — and **the order in which they are attempted is the design**:
///
/// 1. The duplicate check runs *first*, before anything is written. Scanning a
///    parcel twice is ordinary, and creating a customer for an order that is
///    then refused would leave a record of somebody nobody asked for.
/// 2. The batch is found or opened. `orders.batch_id` is NOT NULL, so nothing
///    else can happen without it.
/// 3. The customer is resolved before being created. A number that already
///    belongs to somebody reuses them, which is the whole point of looking up
///    while the driver types.
/// 4. The address is reused before being created, so a repeat customer at the
///    same door does not accumulate a row per parcel.
///
/// Each write is atomic on its own and queues its own outbox row. They are not
/// wrapped in a single transaction, and that is a deliberate limit rather than
/// an oversight: a customer created without their order is a reusable record,
/// not corruption, and the duplicate check above removes the case that would
/// otherwise cause it.
class OrderEntryController {
  const OrderEntryController(this._ref);

  final Ref _ref;

  Future<OrderEntryResult> submit(OrderDraft draft) async {
    final OrderRepository? orders = _ref.read(orderRepositoryProvider);
    final BatchRepository? batches = _ref.read(batchRepositoryProvider);
    if (orders == null || batches == null) {
      return const OrderEntryUnavailable();
    }

    final String tracking = draft.trackingNumber.trim();

    // First, before anything is written. See the class doc.
    final Order? clash = await orders.findByTracking(
      companyId: draft.companyId,
      trackingNumber: tracking,
    );
    if (clash != null) {
      return OrderEntryDuplicate(clash);
    }

    final Batch batch = await batches.ensureOpenBatch(
      companyId: draft.companyId,
    );

    final Customer? customer = await _resolveCustomer(draft);
    final Address? address = customer == null
        ? null
        : await _resolveAddress(draft, customer);

    return OrderEntrySaved(
      await orders.create(
        batchId: batch.id,
        companyId: draft.companyId,
        trackingNumber: tracking,
        customerId: customer?.id,
        addressId: address?.id,
        codAmount: draft.codAmount,
        deliveryType: draft.deliveryType,
        notes: draft.notes,
      ),
    );
  }

  /// The customer this parcel is for, creating one only if the number is new.
  ///
  /// Returns null when no number was typed. An order with no customer is
  /// enterable and not yet deliverable, which is a real state — a manifest can
  /// name a parcel before it names a person — and refusing to save would stop
  /// a driver standing in an agency at 07:00.
  Future<Customer?> _resolveCustomer(OrderDraft draft) async {
    final CustomerRepository? customers = _ref.read(customerRepositoryProvider);
    if (customers == null || !draft.hasPhone) {
      return null;
    }

    final String raw = draft.phone.trim();
    final PhoneE164? parsed = PhoneE164.tryParse(raw);

    if (parsed != null) {
      final Customer? existing = await customers.findByPhone(parsed);
      if (existing != null) {
        return existing;
      }
      return customers.create(phone: parsed, displayName: _name(draft, raw));
    }

    // The number did not parse. Kept verbatim rather than refused: Algeria
    // closed its numbering plan in 2008 and older landline formats are shorter
    // than the nine digits `PhoneE164` expects, so this is as likely to be our
    // gap as the driver's typo. The customer is flagged for correction later.
    return customers.createUnparsed(
      rawPhone: raw,
      displayName: _name(draft, raw),
    );
  }

  /// A name is required on a customer, and the driver may not have typed one.
  ///
  /// Falls back to the number they did type. Not a localized placeholder and
  /// not an invented name: the number is a true fact about this customer, it is
  /// what the driver will recognise them by, and it is what they would have to
  /// search for anyway.
  String _name(OrderDraft draft, String rawPhone) {
    final String typed = draft.customerName.trim();
    return typed.isEmpty ? rawPhone : typed;
  }

  /// The address for this parcel, reusing one before adding another.
  ///
  /// Three cases, in order. No commune typed and the customer already has an
  /// address: use the primary, which is the payoff for having looked them up.
  /// A commune typed that matches an address they already have: use that one,
  /// so a repeat customer at the same door does not collect a row per parcel.
  /// Otherwise add one.
  Future<Address?> _resolveAddress(OrderDraft draft, Customer customer) async {
    final AddressRepository? addresses = _ref.read(addressRepositoryProvider);
    if (addresses == null) {
      return null;
    }

    final List<Address> existing = await addresses.forCustomer(customer.id);

    if (!draft.hasCommune) {
      // Primary first, so `firstOrNull` is the primary when there is one.
      return existing.firstOrNull;
    }

    final String? detail = _blankToNull(draft.addressDetail);
    final Address? same = existing
        .where(
          (Address a) => a.communeId == draft.communeId && a.detail == detail,
        )
        .firstOrNull;
    if (same != null) {
      return same;
    }

    return addresses.create(
      customerId: customer.id,
      wilayaCode: draft.wilayaCode!,
      communeId: draft.communeId!,
      detail: detail,
    );
  }

  static String? _blankToNull(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

final Provider<OrderEntryController> orderEntryControllerProvider =
    Provider<OrderEntryController>(OrderEntryController.new);
