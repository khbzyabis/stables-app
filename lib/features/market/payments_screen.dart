import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'order_screen.dart';

/// Screen 59 — Your orders. Everything you've ordered from the marketplace,
/// newest first, with its current status. Tap one to see the items.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  static const route = '/market/payments';

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<List<Map<String, dynamic>>> _future = SupabaseService.myOrders();

  void _reload() => setState(() => _future = SupabaseService.myOrders());

  static (String, TagTone) _status(String s) => switch (s) {
        'accepted' => ('Accepted', TagTone.sage),
        'fulfilled' => ('Fulfilled', TagTone.sage),
        'cancelled' => ('Cancelled', TagTone.neutral),
        _ => ('Pending', TagTone.accent),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) AppErrors.report(snap.error!);
            final orders = snap.data ?? const [];
            final pending =
                orders.where((o) => o['status'] == 'pending').length;
            final spent = orders
                .where((o) => o['status'] != 'cancelled')
                .fold<double>(
                    0, (t, o) => t + ((o['total_aed'] as num?)?.toDouble() ?? 0));
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
              children: [
                const BackLink(label: 'You'),
                const SizedBox(height: 16),
                Text('Orders', style: AppText.heading(36, height: 1)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _Tile(
                            label: 'Ordered',
                            value: 'AED ${spent.toStringAsFixed(0)}')),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            _Tile(label: 'Awaiting seller', value: '$pending')),
                  ],
                ),
                const SizedBox(height: 24),
                const Hairline(),
                if (orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text(
                      "No orders yet. Anything you order in the market shows "
                      'here with its status.',
                      style: AppText.body(16,
                          height: 1.5, color: AppColors.ink(0.6)),
                    ),
                  ),
                for (final o in orders) ...[
                  _OrderRow(
                    order: o,
                    status: _status((o['status'] as String?) ?? 'pending'),
                    onReturn: _reload,
                  ),
                  const Hairline(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow(
      {required this.order, required this.status, required this.onReturn});
  final Map<String, dynamic> order;
  final (String, TagTone) status;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final total = (order['total_aed'] as num?)?.toDouble() ?? 0;
    final vendor = (order['vendor_name'] as String?) ?? 'Seller';
    final created = DateTime.tryParse((order['created_at'] as String?) ?? '');
    final when = created != null ? DateFormat.MMMd().format(created) : '';
    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(OrderScreen.route, arguments: order);
        onReturn();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor, style: AppText.body(16, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(when,
                      style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('AED ${total.toStringAsFixed(0)}',
                    style: AppText.heading(16)),
                const SizedBox(height: 6),
                AppTag(status.$1, tone: status.$2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppText.body(11,
                  color: AppColors.ink(0.5), letterSpacing: 0.6)),
          const SizedBox(height: 5),
          Text(value, style: AppText.heading(19)),
        ],
      ),
    );
  }
}
