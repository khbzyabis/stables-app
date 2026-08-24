import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Manage one shop: its products (add / in-stock / remove) and the orders that
/// come in (accept, mark fulfilled, or decline).
class ProviderVendorScreen extends StatefulWidget {
  const ProviderVendorScreen({super.key});
  static const route = '/market/provider/vendor';

  @override
  State<ProviderVendorScreen> createState() => _ProviderVendorScreenState();
}

class _ProviderVendorScreenState extends State<ProviderVendorScreen> {
  Map<String, dynamic>? _vendor;
  int _tab = 0; // 0 = products, 1 = orders
  Future<List<Map<String, dynamic>>>? _products;
  Future<List<Map<String, dynamic>>>? _orders;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vendor != null) return;
    _vendor = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _reloadProducts();
    _reloadOrders();
  }

  String get _vendorId => _vendor?['id'] as String? ?? '';

  void _reloadProducts() => setState(
      () => _products = SupabaseService.vendorProducts(_vendorId));
  void _reloadOrders() =>
      setState(() => _orders = SupabaseService.vendorOrders(_vendorId));

  Future<void> _addProduct() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _NewProductSheet(vendorId: _vendorId),
    );
    if (ok == true) _reloadProducts();
  }

  Future<void> _advance(String orderId, String status) async {
    try {
      await SupabaseService.setOrderStatus(orderId, status);
      _reloadOrders();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't update: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (_vendor?['name'] as String?) ?? 'Shop';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackLink(label: 'My shops'),
                  const SizedBox(height: 16),
                  Text(name, style: AppText.heading(34, height: 1.05)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _TabBtn(
                          label: 'Products',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0)),
                      const SizedBox(width: 10),
                      _TabBtn(
                          label: 'Orders',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1)),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Expanded(
              child: _tab == 0 ? _productsView() : _ordersView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _products,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final products = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          children: [
            const Hairline(),
            if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('No products yet. Add your first below.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
              ),
            for (final p in products) ...[
              _ProductRow(
                product: p,
                onToggle: (v) async {
                  try {
                    await SupabaseService.setProductStock(p['id'] as String, v);
                    _reloadProducts();
                  } catch (e) {
                    AppErrors.report(e);
                  }
                },
                onDelete: () async {
                  try {
                    await SupabaseService.deleteProduct(p['id'] as String);
                    _reloadProducts();
                  } catch (e) {
                    AppErrors.report(e);
                  }
                },
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            AppButton(label: 'Add a product', onPressed: _addProduct),
          ],
        );
      },
    );
  }

  Widget _ordersView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final orders = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          children: [
            const Hairline(),
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('No orders yet.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
              ),
            for (final o in orders) ...[
              _IncomingOrder(order: o, onAdvance: _advance),
              const Hairline(),
            ],
          ],
        );
      },
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border:
              Border.all(color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.heading(15,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow(
      {required this.product, required this.onToggle, required this.onDelete});
  final Map<String, dynamic> product;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final price = (product['price_aed'] as num?)?.toDouble() ?? 0;
    final inStock = product['in_stock'] as bool? ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((product['name'] as String?) ?? 'Product',
                    style: AppText.body(17, height: 1.3)),
                const SizedBox(height: 4),
                Text(
                    'AED ${price.toStringAsFixed(0)}'
                    '${(product['category'] as String?) != null ? ' · ${product['category']}' : ''}',
                    style: AppText.body(14, color: AppColors.ink(0.55))),
              ],
            ),
          ),
          Column(
            children: [
              Text(inStock ? 'In stock' : 'Hidden',
                  style: AppText.body(12, color: AppColors.ink(0.5))),
              Switch(
                value: inStock,
                onChanged: onToggle,
                activeThumbColor: AppColors.bg,
                activeTrackColor: AppColors.accent2600,
              ),
            ],
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: AppColors.ink(0.5)),
          ),
        ],
      ),
    );
  }
}

class _IncomingOrder extends StatelessWidget {
  const _IncomingOrder({required this.order, required this.onAdvance});
  final Map<String, dynamic> order;
  final Future<void> Function(String orderId, String status) onAdvance;

  (String, TagTone) get _tag => switch (order['status'] as String?) {
        'accepted' => ('Accepted', TagTone.sage),
        'fulfilled' => ('Fulfilled', TagTone.sage),
        'cancelled' => ('Cancelled', TagTone.neutral),
        _ => ('Pending', TagTone.accent),
      };

  @override
  Widget build(BuildContext context) {
    final id = order['id'] as String;
    final status = (order['status'] as String?) ?? 'pending';
    final total = (order['total_aed'] as num?)?.toDouble() ?? 0;
    final created = DateTime.tryParse((order['created_at'] as String?) ?? '');
    final when = created != null ? DateFormat.MMMd().format(created) : '';
    final tag = _tag;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('AED ${total.toStringAsFixed(0)} · $when',
                    style: AppText.heading(18)),
              ),
              AppTag(tag.$1, tone: tag.$2),
            ],
          ),
          if (status == 'pending' || status == 'accepted') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (status == 'pending')
                  AppButton(
                    label: 'Accept',
                    block: false,
                    minHeight: 42,
                    fontSize: 15,
                    onPressed: () => onAdvance(id, 'accepted'),
                  ),
                if (status == 'accepted')
                  AppButton(
                    label: 'Mark fulfilled',
                    block: false,
                    minHeight: 42,
                    fontSize: 15,
                    onPressed: () => onAdvance(id, 'fulfilled'),
                  ),
                const SizedBox(width: 10),
                AppButton(
                  label: 'Decline',
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 42,
                  fontSize: 15,
                  onPressed: () => onAdvance(id, 'cancelled'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NewProductSheet extends StatefulWidget {
  const _NewProductSheet({required this.vendorId});
  final String vendorId;

  @override
  State<_NewProductSheet> createState() => _NewProductSheetState();
}

class _NewProductSheetState extends State<_NewProductSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _unit = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Feed';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _unit.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = double.tryParse(_price.text.trim());
    if (_name.text.trim().isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('A name and a valid price are needed.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.addProduct(
        vendorId: widget.vendorId,
        name: _name.text.trim(),
        priceAed: price,
        category: _category,
        unit: _unit.text.trim(),
        description: _desc.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't add: $e")));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 22,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New product', style: AppText.heading(24)),
          const SizedBox(height: 18),
          AppField(label: 'Name', controller: _name),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: AppField(
                      label: 'Price (AED)',
                      controller: _price,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: AppField(label: 'Unit (e.g. 20 kg)', controller: _unit)),
            ],
          ),
          const SizedBox(height: 16),
          Text('CATEGORY', style: AppText.eyebrow()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in SupabaseService.marketCategories)
                GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: c == _category
                          ? AppColors.accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: c == _category
                              ? AppColors.accent
                              : AppColors.divider),
                    ),
                    child: Text(c,
                        style: AppText.body(14,
                            color: c == _category
                                ? AppColors.bg
                                : AppColors.text)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppField(label: 'Description', controller: _desc, maxLines: 2),
          const SizedBox(height: 22),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: 'Add product', onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
