import 'package:flutter_test/flutter_test.dart';
import 'package:my_stables/data/basket.dart';
import 'package:my_stables/data/portal.dart';

BasketLine _line(String vendor, double price, int qty) => BasketLine(
      productId: '$vendor-$price',
      name: 'Item',
      vendorId: vendor,
      vendorName: vendor,
      unitPrice: price,
      qty: qty,
    );

void main() {
  group('Basket money math', () {
    test('delivery is charged per seller under AED 300', () {
      final b = Basket.instance;
      b.clear();
      b.add(_line('a', 50, 1)); // vendor a: 50 -> +25 delivery
      b.add(_line('b', 40, 1)); // vendor b: 40 -> +25 delivery
      expect(b.total, 90);
      expect(b.delivery, 50); // two sellers, both under threshold
      expect(b.grandTotal, 140);
    });

    test('delivery is waived for a seller at or over AED 300', () {
      final b = Basket.instance;
      b.clear();
      b.add(_line('a', 300, 1)); // free delivery
      b.add(_line('b', 20, 1)); // still charged
      expect(b.delivery, 25);
      expect(b.grandTotal, 345);
    });

    test('count sums quantities', () {
      final b = Basket.instance;
      b.clear();
      b.add(_line('a', 10, 2));
      b.add(_line('b', 10, 3));
      expect(b.count, 5);
    });
  });

  group('Portal routing', () {
    test('paths map to the right door', () {
      expect(Portal.fromPath('/'), AppPortal.app);
      expect(Portal.fromPath('/app'), AppPortal.app);
      expect(Portal.fromPath('/sell'), AppPortal.seller);
      expect(Portal.fromPath('/admin'), AppPortal.admin);
      expect(Portal.fromPath('/anything-else'), AppPortal.app);
    });

    test('only the app and seller doors allow public sign-up', () {
      expect(Portal.allowsSignup(AppPortal.app), true);
      expect(Portal.allowsSignup(AppPortal.seller), true);
      expect(Portal.allowsSignup(AppPortal.admin), false);
    });
  });
}
