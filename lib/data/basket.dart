import 'package:flutter/widgets.dart';

/// One line in the shopping basket.
class BasketLine {
  BasketLine({
    required this.productId,
    required this.name,
    required this.vendorId,
    required this.vendorName,
    required this.unitPrice,
    this.qty = 1,
    this.unit,
  });

  final String productId;
  final String name;
  final String vendorId;
  final String vendorName;
  final double unitPrice;
  final String? unit;
  int qty;

  double get lineTotal => unitPrice * qty;
}

/// A tiny in-memory basket shared across the market screens. It's a singleton
/// ChangeNotifier so any screen can read/observe it without threading it
/// through constructors. Cleared once an order is placed.
class Basket extends ChangeNotifier {
  Basket._();
  static final Basket instance = Basket._();

  final List<BasketLine> _lines = [];
  List<BasketLine> get lines => List.unmodifiable(_lines);

  int get count => _lines.fold(0, (n, l) => n + l.qty);
  double get total => _lines.fold(0.0, (t, l) => t + l.lineTotal);
  bool get isEmpty => _lines.isEmpty;

  /// Lines grouped by vendor — each vendor becomes its own order.
  Map<String, List<BasketLine>> get byVendor {
    final map = <String, List<BasketLine>>{};
    for (final l in _lines) {
      (map[l.vendorId] ??= []).add(l);
    }
    return map;
  }

  void add(BasketLine line) {
    final existing = _lines
        .where((l) => l.productId == line.productId)
        .cast<BasketLine?>()
        .firstWhere((_) => true, orElse: () => null);
    if (existing != null) {
      existing.qty += line.qty;
    } else {
      _lines.add(line);
    }
    notifyListeners();
  }

  void setQty(String productId, int qty) {
    final line = _lines.cast<BasketLine?>().firstWhere(
        (l) => l?.productId == productId,
        orElse: () => null);
    if (line == null) return;
    if (qty <= 0) {
      _lines.removeWhere((l) => l.productId == productId);
    } else {
      line.qty = qty;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _lines.removeWhere((l) => l.productId == productId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
