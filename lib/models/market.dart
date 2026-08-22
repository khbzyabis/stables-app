/// A market listing. Services (farrier, vet, physio) are quote-based rather
/// than fixed-price, so they route to "ask for a price" instead of the basket.
class MarketItem {
  const MarketItem({
    required this.name,
    required this.seller,
    required this.price,
    required this.meta,
    this.isService = false,
  });

  final String name;
  final String seller;
  final String price;
  final String meta;
  final bool isService;
}

/// A fact row on an item page — measurements are stated explicitly, never implied.
class ItemFact {
  const ItemFact(this.label, this.value);
  final String label;
  final String value;
}

/// One line in the basket.
class BasketLine {
  const BasketLine({required this.name, required this.detail, required this.price});
  final String name;
  final String detail;
  final String price;
}

/// The basket is grouped by seller — each seller's delivery is separate and
/// separately priced. Deliveries are never merged.
class BasketGroup {
  const BasketGroup({
    required this.seller,
    required this.delivery,
    required this.lines,
  });
  final String seller;
  final String delivery;
  final List<BasketLine> lines;
}

/// A payment method. "Charge to the stable" needs admin approval.
class PayMethod {
  const PayMethod({required this.id, required this.label, required this.meta});
  final String id;
  final String label;
  final String meta;
}
