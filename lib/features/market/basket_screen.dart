import 'package:flutter/material.dart';

import '../../data/market_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/market.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';

/// Screen 50 — Basket and checkout. Grouped by seller; each seller's delivery
/// is separate and separately priced — deliveries are never merged. You pay the
/// platform, not the seller.
class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});
  static const route = '/market/basket';

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String _pay = 'card';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final groups = MarketData.basketGroups('125 mm');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: l10n.market),
            const SizedBox(height: 22),
            Text(l10n.basket, style: AppText.heading(36, height: 1)),
            const SizedBox(height: 24),
            for (final g in groups) _SellerGroup(group: g),
            const SizedBox(height: 6),
            _totalRow(l10n.totalItems, MarketData.totalItems, false),
            _totalRow(l10n.totalDelivery, MarketData.totalDelivery, false),
            _totalRow(l10n.toPay, MarketData.basketTotal, true),
            const SizedBox(height: 26),
            Text(l10n.payWith.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 11),
            const Hairline(),
            for (final m in MarketData.payMethods) ...[
              _PayRow(
                method: m,
                selected: _pay == m.id,
                onTap: () => setState(() => _pay = m.id),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            AppButton(
              label: l10n.payAmount(MarketData.basketTotal),
              minHeight: 56,
              fontSize: 17,
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            Text(l10n.basketTerms,
                style: AppText.body(14, height: 1.6, color: AppColors.ink(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, bool strong) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(label,
                style: strong
                    ? AppText.heading(19)
                    : AppText.body(16, color: AppColors.ink(0.6))),
          ),
          Text(value,
              style: strong ? AppText.heading(19) : AppText.body(16)),
        ],
      ),
    );
  }
}

class _SellerGroup extends StatelessWidget {
  const _SellerGroup({required this.group});
  final BasketGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(group.seller.toUpperCase(), style: AppText.eyebrow()),
          ),
          const Hairline(),
          for (final l in group.lines) ...[
            _LineRow(line: l),
            const Hairline(),
          ],
          const SizedBox(height: 9),
          Text(group.delivery,
              style: AppText.body(13, color: AppColors.ink(0.5))),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});
  final BasketLine line;

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
                const SizedBox(height: 4),
                Text(line.detail,
                    style: AppText.body(13, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(line.price, style: AppText.body(16)),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow(
      {required this.method, required this.selected, required this.onTap});
  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.ink(0.35),
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: AppText.body(16, height: 1.3)),
                  const SizedBox(height: 3),
                  Text(method.meta,
                      style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
