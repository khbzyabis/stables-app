import 'package:flutter/material.dart';

import '../../data/basket.dart';
import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import 'basket_screen.dart';
import 'item_screen.dart';

/// Screen 48 — Market (Shop). Browse real products by category, across every
/// approved vendor. Sellers list products from the provider dashboard.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  static const route = '/market';

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _cat = 'Feed';
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() => SupabaseService.marketProducts(_cat);

  void _select(String c) {
    setState(() {
      _cat = c;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final stableName = SessionScope.of(context).activeStableName;

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
                            Text(l10n.deliversTo(stableName),
                                style: AppText.eyebrow(color: AppColors.accent700)),
                            const SizedBox(height: 9),
                            Text(l10n.market, style: AppText.heading(36, height: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _BasketButton(
                        onTap: () async {
                          await Navigator.of(context)
                              .pushNamed(BasketScreen.route);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in SupabaseService.marketCategories)
                        _CatChip(
                          label: c,
                          selected: c == _cat,
                          onTap: () => _select(c),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) AppErrors.report(snap.error!);
                  final items = snap.data ?? const [];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(32, 22, 32, 0),
                    children: [
                      const Hairline(),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: Text(
                            'Nothing in $_cat yet. Sellers add products from '
                            '"Sell on the market" (under You). Anything they '
                            'list shows up here.',
                            style: AppText.body(16,
                                height: 1.5, color: AppColors.ink(0.6)),
                          ),
                        ),
                      for (final item in items) ...[
                        _ItemRow(
                          item: item,
                          onReturn: () => setState(() {}),
                        ),
                        const Hairline(),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(l10n.everyApproved,
                            style: AppText.body(14,
                                height: 1.5, color: AppColors.ink(0.5))),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketButton extends StatelessWidget {
  const _BasketButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Basket.instance,
      builder: (context, _) {
        final count = Basket.instance.count;
        return GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  color: AppColors.accent700, size: 22),
              const SizedBox(width: 7),
              Text('$count',
                  style: AppText.heading(15, color: AppColors.accent700)),
            ],
          ),
        );
      },
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
  const _ItemRow({required this.item, required this.onReturn});
  final Map<String, dynamic> item;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final price = (item['price_aed'] as num?)?.toDouble() ?? 0;
    final unit = item['unit'] as String?;
    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(ItemScreen.route, arguments: item);
        onReturn();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            PhotoPlaceholder(
                size: 64,
                circle: false,
                radius: 16,
                url: item['image_url'] as String?),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((item['name'] as String?) ?? 'Product',
                      style: AppText.body(17, height: 1.3)),
                  const SizedBox(height: 4),
                  Text((item['vendor_name'] as String?) ?? 'Seller',
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('AED ${price.toStringAsFixed(0)}',
                    style: AppText.heading(17)),
                if (unit != null && unit.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(unit, style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
