import 'package:flutter/material.dart';

import '../../data/market_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/market.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import 'basket_screen.dart';
import 'item_screen.dart';
import 'quote_request_screen.dart';

/// Screen 48 — Market (Shop). Browse by group; every seller is operator-approved.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  static const route = '/market';

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _cat = 'Tack';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = MarketData.catalogue[_cat] ?? const [];

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.deliversTo('Serc'),
                                style: AppText.eyebrow(color: AppColors.accent700)),
                            const SizedBox(height: 9),
                            Text(l10n.market, style: AppText.heading(36, height: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _BasketButton(
                        count: 3,
                        onTap: () =>
                            Navigator.of(context).pushNamed(BasketScreen.route),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in MarketData.categories)
                        _CatChip(
                          label: c,
                          selected: c == _cat,
                          onTap: () => setState(() => _cat = c),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(32, 22, 32, 0),
                children: [
                  const Hairline(),
                  for (final item in items) ...[
                    _ItemRow(item: item),
                    const Hairline(),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(l10n.everyApproved,
                        style: AppText.body(14, height: 1.5, color: AppColors.ink(0.5))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketButton extends StatelessWidget {
  const _BasketButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              color: AppColors.accent700, size: 22),
          const SizedBox(width: 7),
          Text('$count', style: AppText.heading(15, color: AppColors.accent700)),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(14,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final MarketItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.isService) {
          Navigator.of(context).pushNamed(QuoteRequestScreen.route);
        } else {
          Navigator.of(context).pushNamed(ItemScreen.route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const PhotoPlaceholder(size: 64, circle: false, radius: 16),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppText.body(17, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(item.seller,
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.price, style: AppText.heading(17)),
                const SizedBox(height: 3),
                Text(item.meta,
                    style: AppText.body(13, color: AppColors.ink(0.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
