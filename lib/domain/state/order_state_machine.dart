import 'order_status.dart';

/// Raised when something tries to move an order somewhere it cannot go.
///
/// An `Error`, not an `Exception`: an illegal transition is a bug in the caller
/// rather than a condition to recover from. There is no sensible `catch` for
/// "this code tried to deliver a cancelled parcel".
///
/// The message names both ends and what was legal, because the useful question
/// when this fires is never "what happened" but "what did the caller think the
/// order was".
final class IllegalOrderTransition extends Error {
  IllegalOrderTransition({required this.from, required this.to});

  final OrderStatus from;
  final OrderStatus to;

  @override
  String toString() =>
      'IllegalOrderTransition: ${from.name} cannot become ${to.name}. '
      'Legal from ${from.name}: '
      '${OrderStateMachine.nextFrom(from).map((OrderStatus s) => s.name).join(', ')}';
}

/// Invariant 6: every order status change goes through here.
///
/// A pure function over §6.4's diagram, with no database and no clock, so the
/// rules can be exercised exhaustively rather than sampled through a DAO.
///
/// The reason this exists rather than a `status = x` assignment is offline
/// conflict resolution (§11). Two devices editing one order have to be
/// reconciled by replaying commands, and a replay is only tractable if the set
/// of legal moves is small, total, and written down once.
abstract final class OrderStateMachine {
  /// Where an order starts. In a batch, not yet on a route.
  static const OrderStatus initial = OrderStatus.pending;

  /// The legal moves, exactly as §6.4 draws them.
  ///
  /// Every state is a key, including the terminal ones — mapping them to an
  /// empty set rather than omitting them is what lets [nextFrom] be total and
  /// what makes `_allowed.length` a meaningful check.
  static const Map<OrderStatus, Set<OrderStatus>> _allowed =
      <OrderStatus, Set<OrderStatus>>{
        OrderStatus.pending: <OrderStatus>{
          OrderStatus.onRoute,
          OrderStatus.cancelled,
        },
        OrderStatus.onRoute: <OrderStatus>{
          OrderStatus.arrived,
          OrderStatus.cancelled,
        },
        OrderStatus.arrived: <OrderStatus>{
          OrderStatus.delivered,
          OrderStatus.failed,
          OrderStatus.cancelled,
        },
        // The only state with three dispositions, and the reason `failed` is
        // not terminal: re-attempt today, or resolve at end of day into a
        // rescheduled parcel still in the driver's possession or a returned one
        // that triggers the retour fee.
        OrderStatus.failed: <OrderStatus>{
          OrderStatus.onRoute,
          OrderStatus.rescheduled,
          OrderStatus.returnedToAgency,
          OrderStatus.cancelled,
        },
        // A new batch on a new day. The parcel re-enters as `pending`, which is
        // why `pending` is reachable from somewhere other than creation.
        OrderStatus.rescheduled: <OrderStatus>{
          OrderStatus.pending,
          OrderStatus.cancelled,
        },
        // Terminal. Present with empty sets so every state is accounted for.
        OrderStatus.delivered: <OrderStatus>{},
        OrderStatus.returnedToAgency: <OrderStatus>{},
        OrderStatus.cancelled: <OrderStatus>{},
      };

  /// Everywhere [from] can legally go. Empty for a terminal state.
  static Set<OrderStatus> nextFrom(OrderStatus from) =>
      _allowed[from] ?? const <OrderStatus>{};

  /// Whether the move is legal. Never throws.
  ///
  /// A status "changing" to itself is **not** legal. It looks harmless and is
  /// not: every real transition writes a `delivery_attempts` row or moves
  /// money, so a no-op that reports success would let a double tap record a
  /// second delivery attempt for one knock at one door.
  static bool canTransition(OrderStatus from, OrderStatus to) =>
      nextFrom(from).contains(to);

  /// The move, or [IllegalOrderTransition].
  ///
  /// Returns [to] rather than void so a caller cannot assign the status it
  /// hoped for instead of the one this sanctioned — the call site reads
  /// `status = OrderStateMachine.transitionTo(...)`, which is the shape the
  /// invariant wants.
  static OrderStatus transitionTo(OrderStatus from, OrderStatus to) {
    if (!canTransition(from, to)) {
      throw IllegalOrderTransition(from: from, to: to);
    }
    return to;
  }

  /// Whether a merchant can still cancel.
  ///
  /// §6.4: "cancelled by the merchant, at any time before delivered". Expressed
  /// as a question about the current state rather than duplicated as a rule,
  /// so it cannot disagree with [_allowed].
  static bool canCancel(OrderStatus from) =>
      canTransition(from, OrderStatus.cancelled);

  /// Every state the machine knows. Used by the exhaustiveness test.
  static Iterable<OrderStatus> get states => _allowed.keys;
}
