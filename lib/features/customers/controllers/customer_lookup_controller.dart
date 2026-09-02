import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../app/di.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/value_objects/phone_e164.dart';

/// What typing a phone number has turned up so far.
///
/// A sealed type rather than a record of nullable fields, because the states
/// are genuinely exclusive and the UI has to render exactly one of them. A
/// `{customer?, parsed?, searching}` bag would permit combinations that cannot
/// happen and leave the screen deciding which to believe.
@immutable
sealed class CustomerLookup {
  const CustomerLookup();
}

/// Nothing typed yet, or too little to act on.
final class LookupIdle extends CustomerLookup {
  const LookupIdle();
}

/// A query is in flight. Rendered as nothing rather than a spinner — a
/// flickering indicator under a field being typed into is worse than silence.
final class LookupSearching extends CustomerLookup {
  const LookupSearching();
}

/// The number does not parse and will be kept verbatim.
///
/// Not an error state. Algeria closed its numbering plan in 2008 and older
/// landline formats are shorter than the nine digits `PhoneE164` expects, so
/// this is as likely to be our gap as the driver's typo.
final class LookupUnrecognized extends CustomerLookup {
  const LookupUnrecognized();
}

/// The number parses and belongs to nobody yet.
final class LookupNew extends CustomerLookup {
  const LookupNew(this.phone);

  final PhoneE164 phone;
}

/// The number already belongs to somebody.
///
/// The whole point of looking up as the driver types rather than at save: at
/// this moment the answer is "you already know this person, here they are",
/// which saves re-typing a name and address. Discovering it after the form is
/// filled in saves nothing.
final class LookupExisting extends CustomerLookup {
  const LookupExisting(this.customer);

  final Customer customer;
}

/// Looks a customer up by phone, as it is typed.
///
/// **Debounced.** The M1 gate is fifteen orders in under four minutes, so this
/// runs on the critical path of the fastest thing the app does. A query per
/// keystroke would put ten round trips behind one phone number for an answer
/// only the last one can give.
class CustomerLookupController extends Notifier<CustomerLookup> {
  Timer? _debounce;

  /// Guards against an earlier query landing after a later one. Without it, a
  /// slow lookup for `0550` could overwrite the result for `0550123456` and
  /// show the driver a customer they are not typing.
  int _generation = 0;

  static const Duration debounce = Duration(milliseconds: 250);

  @override
  CustomerLookup build() {
    ref.onDispose(() => _debounce?.cancel());
    return const LookupIdle();
  }

  /// Call on every keystroke.
  void onPhoneChanged(String raw) {
    _debounce?.cancel();
    final int generation = ++_generation;
    final String trimmed = raw.trim();

    if (trimmed.isEmpty) {
      state = const LookupIdle();
      return;
    }

    final PhoneE164? parsed = PhoneE164.tryParse(trimmed);
    if (parsed == null) {
      // Answered without a query and without waiting: parsing is local, and
      // there is nothing to look up.
      state = const LookupUnrecognized();
      return;
    }

    state = const LookupSearching();
    _debounce = Timer(debounce, () => _run(parsed, generation));
  }

  /// Resolves immediately, skipping the debounce. For a field that has just
  /// lost focus, where the driver has stopped typing by definition.
  Future<void> resolveNow(String raw) async {
    _debounce?.cancel();
    final PhoneE164? parsed = PhoneE164.tryParse(raw.trim());
    if (parsed == null) {
      state = raw.trim().isEmpty
          ? const LookupIdle()
          : const LookupUnrecognized();
      return;
    }
    await _run(parsed, ++_generation);
  }

  Future<void> _run(PhoneE164 phone, int generation) async {
    final CustomerRepository? repo = ref.read(customerRepositoryProvider);
    if (repo == null) {
      // No database. The form still works — it just cannot warn about a
      // duplicate, and the unique index remains the real guarantee.
      state = LookupNew(phone);
      return;
    }

    final Customer? found = await repo.findByPhone(phone);
    if (generation != _generation) {
      return;
    }
    state = found == null ? LookupNew(phone) : LookupExisting(found);
  }
}

final NotifierProvider<CustomerLookupController, CustomerLookup>
customerLookupProvider =
    NotifierProvider<CustomerLookupController, CustomerLookup>(
      CustomerLookupController.new,
    );
