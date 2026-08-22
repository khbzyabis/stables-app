import '../models/market.dart';
import '../models/orders.dart';

/// Sample order/quote content for the foundation (server data in production).
abstract final class OrdersData {
  static const order = Order(
    ref: 'Order #4022 · 18 August',
    seller: 'Al Suwaidi',
    total: 'AED 320',
    paidLabel: 'Paid 18 Aug · includes AED 25 delivery',
    steps: [
      OrderStep(title: 'Paid', when: '18 August, 09:12 · receipt MS-8841', done: true),
      OrderStep(title: 'Packed by Al Suwaidi', when: '18 August, 16:40', done: true),
      OrderStep(title: 'Delivered to Serc', when: 'Wednesday, before noon', done: false),
      OrderStep(title: 'Seller paid', when: '1 September, once the return window closes', done: false),
    ],
    lines: [
      BasketLine(name: 'Loose ring snaffle', detail: '115 mm mouthpiece', price: 'AED 210'),
      BasketLine(name: 'Hoof oil and brush', detail: 'One', price: 'AED 85'),
    ],
  );

  static const returnReasons = <ReturnReason>[
    ReturnReason('Not what was described', 'The mouthpiece measures 125 mm, the listing said 115 mm.'),
    ReturnReason('Damaged', 'Photograph it before you unpack any further.'),
    ReturnReason('Never arrived', 'Marked delivered on 20 Aug. Nobody at the yard signed for it.'),
    ReturnReason('Wrong item', 'Say what arrived instead.'),
  ];

  static const quoteKinds = ['Front shoes', 'Full set', 'Trim', 'Opinion wanted'];

  static const askList = <(String, String)>[
    ('Hamad Al Suwaidi', 'Your farrier · 6 km · usually answers in a day'),
    ('Rashid Bin Omar', 'Farrier · 14 km · 4.6'),
    ('Gulf Hoofcare', 'Farrier · 18 km · 4.4'),
    ('Ali Rahman', 'Equine dentist · not a farrier'),
  ];

  static const quotes = <Quote>[
    Quote(id: 'q1', name: 'Hamad Al Suwaidi', meta: 'Your farrier · 38 visits here', range: 'AED 520 – 640', expires: 'Expires in 3 days', note: 'Can do Thursday afternoon. Comme Ci has just come off box rest, so I would rather look before I shoe.'),
    Quote(id: 'q2', name: 'Rashid Bin Omar', meta: 'Farrier · 4.6 · never been here', range: 'AED 480 – 520', expires: 'Expires in 2 days', note: 'Friday morning only. Price holds for both horses if they are done together.'),
    Quote(id: 'q3', name: 'Gulf Hoofcare', meta: 'Farrier · 4.4 · never been here', range: 'AED 600 – 700', expires: 'Expires tomorrow', note: 'Thursday or Friday. Remedial work extra if needed.'),
  ];
}
