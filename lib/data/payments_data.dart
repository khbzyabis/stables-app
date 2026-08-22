import '../models/market.dart' show BasketLine, ItemFact;

enum PayState { paid, notCharged, refunded }

class PaymentRow {
  const PaymentRow({
    required this.what,
    required this.who,
    required this.amount,
    required this.state,
    this.opensReceipt = false,
  });
  final String what;
  final String who;
  final String amount;
  final PayState state;
  final bool opensReceipt;
}

class PaymentMonth {
  const PaymentMonth(this.label, this.rows);
  final String label;
  final List<PaymentRow> rows;
}

class ReceiptGroup {
  const ReceiptGroup(this.seller, this.lines);
  final String seller;
  final List<BasketLine> lines; // detail doubles as qty via name
}

class ReceiptTotal {
  const ReceiptTotal(this.label, this.value, {this.strong = false, this.muted = false});
  final String label;
  final String value;
  final bool strong;
  final bool muted;
}

/// Sample payments/receipt content for the foundation (server data in production).
abstract final class PaymentsData {
  static const thisMonthTotal = 'AED 1,669';
  static const notSettled = 'AED 1,200';

  static const months = <PaymentMonth>[
    PaymentMonth('August', [
      PaymentRow(what: 'Snaffle, hoof oil, chaff', who: 'Al Suwaidi · Desert Feed Co.', amount: 'AED 469', state: PayState.paid, opensReceipt: true),
      PaymentRow(what: 'Front shoes, two horses', who: 'Hamad Al Suwaidi', amount: 'AED 560', state: PayState.notCharged),
      PaymentRow(what: 'Transport to Al Qudra', who: 'Gulf Horse Transport', amount: 'AED 640', state: PayState.notCharged),
    ]),
    PaymentMonth('July', [
      PaymentRow(what: 'Feed balancer ×2', who: 'Al Suwaidi', amount: 'AED 390', state: PayState.paid),
      PaymentRow(what: 'Physio visit', who: 'Marina Physio', amount: 'AED 300', state: PayState.refunded),
    ]),
  ];

  static const receiptGroups = <ReceiptGroup>[
    ReceiptGroup('Al Suwaidi', [
      BasketLine(name: 'Loose ring snaffle', detail: '×1 · 115 mm mouthpiece', price: 'AED 210.00'),
      BasketLine(name: 'Hoof oil and brush', detail: '×1', price: 'AED 85.00'),
    ]),
    ReceiptGroup('Desert Feed Co.', [
      BasketLine(name: 'Chaff, low sugar', detail: '×2 · their own delivery', price: 'AED 124.00'),
    ]),
  ];

  static const receiptTotals = <ReceiptTotal>[
    ReceiptTotal('Items', 'AED 419.00'),
    ReceiptTotal('Delivery · one per seller', 'AED 50.00'),
    ReceiptTotal('VAT included at 5%', 'AED 22.33', muted: true),
    ReceiptTotal('Paid', 'AED 469.00', strong: true),
  ];

  static const trn = 'My Stables FZ-LLC · Dubai · TRN 100412887600003';

  static const failedFacts = <ItemFact>[
    ItemFact('Attempted', 'AED 469 · card ending 8842'),
    ItemFact('Taken', 'Nothing'),
    ItemFact('Reason given', 'Refused by your bank, no reason sent'),
    ItemFact('Your basket', 'Still there, both sellers'),
  ];
}
