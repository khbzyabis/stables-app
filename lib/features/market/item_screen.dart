import 'package:flutter/material.dart';

import '../../data/market_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';
import 'basket_screen.dart';

/// Screen 49 — An item. Measurements are stated explicitly, size is a chip, and
/// a mismatch is refunded.
class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});
  static const route = '/market/item';

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  String _size = '125 mm';
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final facts = MarketData.itemFacts(_size);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
              child: BackLink(label: l10n.market),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(32, 18, 32, 0),
              child: const PhotoPlaceholder(
                  size: 230, circle: false, radius: 26),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 22, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loose ring snaffle',
                      style: AppText.heading(30, height: 1.1)),
                  const SizedBox(height: 8),
                  Text('Al Suwaidi · farriery and supplies · 4.8',
                      style: AppText.body(15, color: AppColors.ink(0.6))),
                  const SizedBox(height: 16),
                  Text('AED 210', style: AppText.heading(28)),
                  const SizedBox(height: 22),
                  Text('MOUTHPIECE', style: AppText.eyebrow()),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      for (final z in MarketData.bitSizes) ...[
                        _SizeChip(
                          label: z,
                          selected: z == _size,
                          onTap: () => setState(() => _size = z),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Hairline(),
                  for (final f in facts) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(f.label,
                                style: AppText.body(15, color: AppColors.ink(0.55))),
                          ),
                          Expanded(
                            child: Text(f.value,
                                style: AppText.body(16, height: 1.45)),
                          ),
                        ],
                      ),
                    ),
                    const Hairline(),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    'German stainless, 16 mm barrel. The measurement above is the mouthpiece across, taken flat. If it arrives different from what is written here, say so and you will get your money back.',
                    style: AppText.body(16, height: 1.65),
                  ),
                  const SizedBox(height: 26),
                  AppButton(
                    label: _added
                        ? l10n.inYourBasket
                        : l10n.addToBasketSize(_size),
                    minHeight: 56,
                    fontSize: 17,
                    onPressed: () => setState(() => _added = true),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(BasketScreen.route),
                        child: Text(l10n.basketWithCount(_added ? 4 : 3),
                            style: AppText.body(16, color: AppColors.accent700)),
                      ),
                      const SizedBox(width: 24),
                      Text(l10n.askTheSeller,
                          style: AppText.body(16, color: AppColors.ink(0.6))),
                    ],
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

class _SizeChip extends StatelessWidget {
  const _SizeChip(
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
          color: selected ? AppColors.accent2 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.accent2 : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(14,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}
