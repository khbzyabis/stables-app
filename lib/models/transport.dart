import 'market.dart' show ItemFact;

export 'market.dart' show ItemFact;

/// Why a journey is happening — the note under the request changes with it.
class TransportReason {
  const TransportReason(this.label, this.note);
  final String label;
  final String note;
}

/// Something a transporter needs to know (travelling together, groom seat,
/// insured value per horse, nervous loader).
class TransportNeed {
  const TransportNeed(this.label, this.meta);
  final String label;
  final String meta;
}

/// A transporter's quote. Vehicle, insured value and loading time sit under the
/// price — the insured value matters more than the figure.
class TransportQuote {
  const TransportQuote({
    required this.name,
    required this.meta,
    required this.price,
    required this.expires,
    required this.facts,
  });
  final String name;
  final String meta;
  final String price;
  final String expires;
  final List<ItemFact> facts;
}
