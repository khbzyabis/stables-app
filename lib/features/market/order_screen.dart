import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen — one order's detail: the items, the total, the status, and (while
/// it's still pending) a way to cancel it.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  static const route = '/market/order';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Map<String, dynamic>? _order;
  Future<List<Map<String, dynamic>>>? _items;
  bool _cancelling = false;
  String _status = 'pending';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order != null) return;
    _order = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _status = (_order?['status'] as String?) ?? 'pending';
    final id = _order?['id'] as String?;
    _items = id == null
        ? Future.value(const <Map<String, dynamic>>[])
        : SupabaseService.orderItems(id);
  }

  Future<void> _cancel() async {
    final id = _order?['id'] as String?;
    if (id == null) return;
    setState(() => _cancelling = true);
    try {
      await SupabaseService.cancelOrder(id);
      if (mounted) setState(() => _status = 'cancelled');
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't cancel: $e")));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  (String, TagTone) get _statusTag => switch (_status) {
        'accepted' => ('Accepted', TagTone.sage),
        'fulfilled' => ('Fulfilled', TagTone.sage),
        'cancelled' => ('Cancelled', TagTone.neutral),
        _ => ('Pending', TagTone.accent),
      };

  @override
  Widget build(BuildContext context) {
    final order = _order ?? const {};
    final vendor = (order['vendor_name'] as String?) ?? 'Seller';
    final total = (order['total_aed'] as num?)?.toDouble() ?? 0;
    final created = DateTime.tryParse((order['created_at'] as String?) ?? '');
    final when = created != null ? DateFormat.yMMMMd().format(created) : '';
    final tag = _statusTag;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            const BackLink(label: 'Orders'),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: Text(vendor, style: AppText.heading(32, height: 1.05))),
                AppTag(tag.$1, tone: tag.$2),
              ],
            ),
            const SizedBox(height: 8),
            Text(when, style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _items,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snap.data ?? const [];
                return Column(
                  children: [
                    for (final i in items) ...[
                      _ItemLine(item: i),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('Total', style: AppText.heading(19))),
                Text('AED ${total.toStringAsFixed(0)}',
                    style: AppText.heading(19)),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Payment is arranged with the seller for now. Card payment is '
                'coming soon.',
                style: AppText.body(14, height: 1.5, color: AppColors.ink(0.7)),
              ),
            ),
            const SizedBox(height: 24),
            if (_status == 'pending') ...[
              if (_cancelling)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(
                  label: 'Cancel this order',
                  variant: AppButtonVariant.secondary,
                  onPressed: _cancel,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final price = (item['unit_price_aed'] as num?)?.toDouble() ?? 0;
    final qty = (item['qty'] as num?)?.toInt() ?? 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text('${(item['name'] as String?) ?? 'Item'}  ×$qty',
                style: AppText.body(16, height: 1.3)),
          ),
          const SizedBox(width: 12),
          Text('AED ${(price * qty).toStringAsFixed(0)}',
              style: AppText.body(16)),
        ],
      ),
    );
  }
}
