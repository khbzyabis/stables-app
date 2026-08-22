import '../models/market.dart';

/// Sample market content for the foundation (server data in production). Every
/// seller here is approved by the operator before anything appears.
abstract final class MarketData {
  static const categories = ['Feed', 'Tack', 'Hoofcare', 'Rugs', 'Services'];

  static const catalogue = <String, List<MarketItem>>{
    'Feed': [
      MarketItem(name: 'Feed balancer, 20 kg', seller: 'Al Suwaidi', price: 'AED 195', meta: '8 in stock'),
      MarketItem(name: 'Chaff, low sugar', seller: 'Desert Feed Co.', price: 'AED 62', meta: 'Delivers Wed'),
      MarketItem(name: 'Electrolyte sachets ×20', seller: 'Al Suwaidi', price: 'AED 130', meta: 'Checked by hand'),
      MarketItem(name: 'Soaked hay, bale', seller: 'Desert Feed Co.', price: 'AED 45', meta: 'From 10 bales'),
    ],
    'Tack': [
      MarketItem(name: 'Loose ring snaffle', seller: 'Al Suwaidi', price: 'AED 210', meta: '6 in stock'),
      MarketItem(name: 'Grackle noseband', seller: 'Al Suwaidi', price: 'AED 275', meta: '3 left'),
      MarketItem(name: 'Rubber reins', seller: 'Marina Saddlery', price: 'AED 115', meta: 'In stock'),
      MarketItem(name: 'Brushing boots, pair', seller: 'Al Suwaidi', price: 'AED 170', meta: '24 in stock'),
    ],
    'Hoofcare': [
      MarketItem(name: 'Hoof oil and brush', seller: 'Al Suwaidi', price: 'AED 85', meta: '40 in stock'),
      MarketItem(name: 'Poultice, box of 4', seller: 'Al Suwaidi', price: 'AED 96', meta: '12 in stock'),
    ],
    'Rugs': [
      MarketItem(name: 'Summer sheet', seller: 'Marina Saddlery', price: 'AED 260', meta: '6 ft 3 to 7 ft'),
      MarketItem(name: 'Fly mask', seller: 'Marina Saddlery', price: 'AED 95', meta: 'In stock'),
    ],
    'Services': [
      MarketItem(name: 'Hamad Al Suwaidi', seller: 'Farrier · 6 km · quotes in a day', price: 'From 260', meta: 'Ask for a price', isService: true),
      MarketItem(name: 'Dr Farah Nasser', seller: 'Vet · visits Thursdays', price: 'From 400', meta: 'Ask for a price', isService: true),
      MarketItem(name: 'Marina Physio', seller: 'Physiotherapist · 22 km', price: 'From 300', meta: 'Ask for a price', isService: true),
    ],
  };

  static const bitSizes = ['115 mm', '125 mm', '135 mm'];

  static List<ItemFact> itemFacts(String bitSize) => [
        ItemFact('Mouthpiece', '$bitSize across, taken flat'),
        const ItemFact('Barrel', '16 mm, German stainless'),
        const ItemFact('Delivery', 'To Serc, Wednesday'),
        const ItemFact('Returns', '14 days · you keep the money until then'),
      ];

  static List<BasketGroup> basketGroups(String bitSize) => [
        BasketGroup(
          seller: 'Al Suwaidi',
          delivery: 'Delivers to Serc on Wednesday · AED 25 delivery',
          lines: [
            BasketLine(name: 'Loose ring snaffle', detail: '$bitSize mouthpiece', price: 'AED 210'),
            const BasketLine(name: 'Hoof oil and brush', detail: 'One', price: 'AED 85'),
          ],
        ),
        const BasketGroup(
          seller: 'Desert Feed Co.',
          delivery: 'Delivers to Serc on Wednesday · AED 25 delivery',
          lines: [BasketLine(name: 'Chaff, low sugar ×2', detail: 'Two sacks', price: 'AED 124')],
        ),
      ];

  static const payMethods = <PayMethod>[
    PayMethod(id: 'card', label: 'Card ending 8842', meta: 'Ahmad · saved'),
    PayMethod(id: 'apple', label: 'Apple Pay', meta: 'Face ID'),
    PayMethod(id: 'stable', label: 'Charge to the stable', meta: 'Layal approves it · admins only'),
  ];

  static const basketTotal = 'AED 469';
  static const totalItems = 'AED 419';
  static const totalDelivery = 'AED 50';
}
