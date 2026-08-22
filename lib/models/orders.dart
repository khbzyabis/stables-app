import 'market.dart';

/// A step in an order's four-stage timeline, ending at "seller paid, once the
/// return window closes".
class OrderStep {
  const OrderStep({required this.title, required this.when, required this.done});
  final String title;
  final String when;
  final bool done;
}

/// A paid order (follows the seller it was placed with).
class Order {
  const Order({
    required this.ref,
    required this.seller,
    required this.total,
    required this.paidLabel,
    required this.steps,
    required this.lines,
  });
  final String ref;
  final String seller;
  final String total;
  final String paidLabel;
  final List<OrderStep> steps;
  final List<BasketLine> lines;
}

/// A returned provider quote — a range (not a figure), an expiry, and a note.
/// Accepting one books the slot and lapses the others.
class Quote {
  const Quote({
    required this.id,
    required this.name,
    required this.meta,
    required this.range,
    required this.expires,
    required this.note,
  });
  final String id;
  final String name;
  final String meta;
  final String range;
  final String expires;
  final String note;
}

/// A reason for raising a problem with an order — its placeholder text changes
/// per reason.
class ReturnReason {
  const ReturnReason(this.label, this.placeholder);
  final String label;
  final String placeholder;
}
