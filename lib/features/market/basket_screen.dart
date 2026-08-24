import 'package:flutter/material.dart';

import '../../data/basket.dart';
import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';
import 'payments_screen.dart';

/// Screen 50 — Basket and checkout. Grouped by seller; each seller becomes its
/// own order. Payment is arranged with the seller for now (no card step yet).
class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});
  static const route = '/market/basket';

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  bool _placing = false;

  Future<void> _placeOrders() async {
    final basket = Basket.instance;
    if (basket.isEmpty) return;
    final stableId = SessionScope.of(context).activeStableId;
    setState(() => _placing = true);
    try {
      for (final entry in basket.byVendor.entries) {
        await SupabaseService.placeOrder(
          vendorId: entry.key,
          stableId: stableId,
          items: [
            for (final l in entry.value)
              {
                'product_id': l.productId,
                'name': l.name,
                'unit_price_aed': l.unitPrice,
                'qty': l.qty,
              }
          ],
        );
      }
      basket.clear();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(PaymentsScreen.route);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Order placed. The seller will confirm it.')));
      }
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't place order: $e")));
        setState(() => _placing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: Basket.instance,
          builder: (context, _) {
            final basket = Basket.instance;
            final groups = basket.byVendor;
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
              children: [
                BackLink(label: l10n.market),
                const SizedBox(height: 22),
                Text(l10n.basket, style: AppText.heading(36, height: 1)),
                const SizedBox(height: 24),
                if (basket.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text('Your basket is empty.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  )
                else ...[
                  for (final entry in groups.entries)
                    _SellerGroup(
                      vendorName: entry.value.first.vendorName,
                      lines: entry.value,
                      onChanged: () => setState(() {}),
                    ),
                  const SizedBox(height: 6),
                  _totalRow(l10n.toPay,
                      'AED ${basket.total.toStringAsFixed(0)}', true),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Payment is arranged directly with the seller for now. '
                      'Card payment is coming soon.',
                      style: AppText.body(14,
                          height: 1.5, color: AppColors.ink(0.7)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_placing)
                    const Center(child: CircularProgressIndicator())
                  else
                    AppButton(
                      label: groups.length > 1
                          ? 'Place ${groups.length} orders'
                          : 'Place order',
                      minHeight: 56,
                      fontSize: 17,
                      onPressed: _placeOrders,
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, bool strong) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: strong
                    ? AppText.heading(19)
                    : AppText.body(16, color: AppColors.ink(0.6))),
          ),
          Text(value, style: strong ? AppText.heading(19) : AppText.body(16)),
        ],
      ),
    );
  }
}

class _SellerGroup extends StatelessWidget {
  const _SellerGroup(
      {required this.vendorName, required this.lines, required this.onChanged});
  final String vendorName;
  final List<BasketLine> lines;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(vendorName.toUpperCase(), style: AppText.eyebrow()),
          ),
          const Hairline(),
          for (final l in lines) ...[
            _LineRow(line: l, onChanged: onChanged),
            const Hairline(),
          ],
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.onChanged});
  final BasketLine line;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const PhotoPlaceholder(size: 52, circle: false, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: AppText.body(16, height: 1.3)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniBtn(
                        icon: Icons.remove,
                        onTap: () {
                          Basket.instance.setQty(line.productId, line.qty - 1);
                          onChanged();
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${line.qty}', style: AppText.heading(16)),
                    ),
                    _MiniBtn(
                        icon: Icons.add,
                        onTap: () {
                          Basket.instance.setQty(line.productId, line.qty + 1);
                          onChanged();
                        }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('AED ${line.lineTotal.toStringAsFixed(0)}',
              style: AppText.body(16)),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 17, color: AppColors.text),
      ),
    );
  }
}
