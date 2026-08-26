import 'package:flutter/material.dart';

import '../../data/basket.dart';
import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/photo_placeholder.dart';
import 'basket_screen.dart';
import 'item_screen.dart';
import 'market_screen.dart';

/// A single shop's storefront for buyers: the vendor's details and everything
/// it lists. Goods shops show products to add to the basket; service providers
/// show an Ask-for-a-price button.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  static const route = '/market/shop';

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Map<String, dynamic>? _vendor;
  Future<List<Map<String, dynamic>>>? _products;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vendor != null) return;
    _vendor = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    final id = _vendor!['id'] as String?;
    if (id != null && !_isService) {
      _products = SupabaseService.shopProducts(id);
    }
  }

  bool get _isService => (_vendor?['kind'] as String?) == 'Services';

  @override
  Widget build(BuildContext context) {
    final v = _vendor ?? const {};
    final name = (v['name'] as String?) ?? 'Shop';
    final city = (v['city'] as String?) ?? '';
    final kind = (v['kind'] as String?) ?? '';
    final about = (v['about'] as String?) ?? '';
    final sub = [city, kind].where((s) => s.isNotEmpty).join(' · ');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _Circle(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  if (!_isService)
                    _BasketButton(onTap: () async {
                      await Navigator.of(context).pushNamed(BasketScreen.route);
                      setState(() {});
                    }),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                children: [
                  // Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE7C9A9), Color(0xFFD69A68)],
                        ),
                      ),
                      child: (v['image_url'] as String?)?.isNotEmpty == true
                          ? Image.network(v['image_url'] as String,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, _, _) => const SizedBox())
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(name, style: AppText.heading(30, height: 1)),
                      ),
                      const SizedBox(width: 12),
                      AppTag(
                        (v['approved'] as bool? ?? true) ? 'Live' : 'In review',
                        tone: TagTone.sage,
                      ),
                    ],
                  ),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(sub,
                        style: AppText.body(15, color: AppColors.ink(0.6))),
                  ],
                  if (about.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(about,
                        style: AppText.body(15,
                            height: 1.5, color: AppColors.ink(0.75))),
                  ],
                  const SizedBox(height: 22),
                  if (_isService)
                    _ServiceBody(vendor: v)
                  else
                    _ProductsBody(future: _products),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceBody extends StatelessWidget {
  const _ServiceBody({required this.vendor});
  final Map<String, dynamic> vendor;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This is a service provider.',
            style: AppText.body(15, color: AppColors.ink(0.7))),
        const SizedBox(height: 6),
        Text('Send them what you need and they’ll reply with a price.',
            style: AppText.body(15, height: 1.5, color: AppColors.ink(0.6))),
        const SizedBox(height: 20),
        AppButton(
          label: 'Ask for a price',
          onPressed: () => showMarketQuoteSheet(
              context, vendor, SessionScope.of(context).activeStableId),
        ),
      ],
    );
  }
}

class _ProductsBody extends StatelessWidget {
  const _ProductsBody({required this.future});
  final Future<List<Map<String, dynamic>>>? future;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final items = snap.data ?? const [];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('Nothing listed yet.',
                style: AppText.body(15, color: AppColors.ink(0.55))),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRODUCTS',
                style: AppText.eyebrow(color: AppColors.ink(0.5))),
            const SizedBox(height: 12),
            for (final item in items) ...[
              _ShopItemRow(item: item),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ShopItemRow extends StatelessWidget {
  const _ShopItemRow({required this.item});
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    final price = (item['price_aed'] as num?)?.toDouble() ?? 0;
    final unit = item['unit'] as String?;
    return AppCard(
      onTap: () =>
          Navigator.of(context).pushNamed(ItemScreen.route, arguments: item),
      padding: const EdgeInsets.all(14),
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
                    style: AppText.body(17, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if ((item['category'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(item['category'] as String,
                      style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
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
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warmWhite,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 20, color: AppColors.text)),
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
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: AppColors.warmWhite, shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    color: AppColors.accent700, size: 21),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
