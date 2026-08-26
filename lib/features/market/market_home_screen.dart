import 'package:flutter/material.dart';

import '../../data/basket.dart';
import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'basket_screen.dart';
import 'market_screen.dart';
import 'shop_screen.dart';

/// The Market landing page — where the Market tab lands. Admin announcements,
/// shop-by-category, the shops, and the service providers. Each tap dives into
/// the browse screen or a quote request.
class MarketHomeScreen extends StatefulWidget {
  const MarketHomeScreen({super.key});
  static const route = '/market/home';

  @override
  State<MarketHomeScreen> createState() => _MarketHomeScreenState();
}

class _MarketHomeScreenState extends State<MarketHomeScreen> {
  late final Future<_MarketHomeData> _future = _load();

  Future<_MarketHomeData> _load() async {
    List<Map<String, dynamic>> ann = const [];
    List<Map<String, dynamic>> vendors = const [];
    try {
      ann = await SupabaseService.announcements();
    } catch (_) {}
    try {
      vendors = await SupabaseService.approvedVendors();
    } catch (e) {
      AppErrors.report(e);
    }
    return _MarketHomeData(announcements: ann, vendors: vendors);
  }

  void _openCategory(String category) =>
      Navigator.of(context).pushNamed(MarketScreen.route, arguments: category);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final stableName = SessionScope.of(context).activeStableName;
    final categories = SupabaseService.marketCategories
        .where((c) => c != 'Services')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_MarketHomeData>(
          future: _future,
          builder: (context, snap) {
            final data = snap.data;
            final shops =
                data?.vendors.where((v) => v['kind'] != 'Services').toList() ??
                    const [];
            final services =
                data?.vendors.where((v) => v['kind'] == 'Services').toList() ??
                    const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.deliversTo(stableName),
                              style:
                                  AppText.eyebrow(color: AppColors.accent700)),
                          const SizedBox(height: 9),
                          Text(l10n.market,
                              style: AppText.heading(34, height: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _BasketButton(onTap: () async {
                      await Navigator.of(context).pushNamed(BasketScreen.route);
                      setState(() {});
                    }),
                  ],
                ),

                // Announcements from My Stables
                if (data != null && data.announcements.isNotEmpty) ...[
                  _Label('From My Stables'),
                  for (final a in data.announcements.take(3)) ...[
                    _Announcement(a: a),
                    const SizedBox(height: 10),
                  ],
                ],

                // Shop by category
                _Label('Shop by category'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.9,
                  children: [
                    for (var i = 0; i < categories.length; i++)
                      _CategoryTile(
                        label: categories[i],
                        icon: _categoryIcon(categories[i]),
                        terra: i.isEven,
                        onTap: () => _openCategory(categories[i]),
                      ),
                  ],
                ),

                // Shops
                _Label('Shops'),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (shops.isEmpty)
                  _EmptyHint(
                      'No shops yet. Approved sellers appear here as they join.')
                else
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      itemCount: shops.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => _ShopCard(
                        vendor: shops[i],
                        onTap: () => Navigator.of(context)
                            .pushNamed(ShopScreen.route, arguments: shops[i]),
                      ),
                    ),
                  ),

                // Service providers
                _Label('Service providers'),
                if (snap.connectionState != ConnectionState.waiting &&
                    services.isEmpty)
                  _EmptyHint(
                      'No service providers yet. Farriers, vets and transport show here.')
                else
                  for (final v in services) ...[
                    _ProviderRow(
                      vendor: v,
                      onAsk: () => showMarketQuoteSheet(context, v,
                          SessionScope.of(context).activeStableId),
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _categoryIcon(String c) => switch (c) {
        'Feed' => Icons.grass_outlined,
        'Tack' => Icons.checkroom_outlined,
        'Hoofcare' => Icons.healing_outlined,
        'Rugs' => Icons.layers_outlined,
        _ => Icons.storefront_outlined,
      };
}

class _MarketHomeData {
  const _MarketHomeData({required this.announcements, required this.vendors});
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> vendors;
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 26, 2, 12),
        child: Text(text.toUpperCase(),
            style: AppText.eyebrow(color: AppColors.ink(0.5))),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text,
            style: AppText.body(14, height: 1.5, color: AppColors.ink(0.55))),
      );
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
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppColors.warmWhite, shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    color: AppColors.accent700, size: 22),
                if (count > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      child: Text('$count',
                          textAlign: TextAlign.center,
                          style: AppText.heading(10, color: AppColors.bg)),
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

class _Announcement extends StatelessWidget {
  const _Announcement({required this.a});
  final Map<String, dynamic> a;
  @override
  Widget build(BuildContext context) {
    final pinned = a['pinned'] == true;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: pinned ? const Color(0xFFE6C39F) : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined,
                  size: 16, color: AppColors.accent700),
              const SizedBox(width: 7),
              Text('Announcement',
                  style: AppText.body(11.5,
                      color: AppColors.accent700, letterSpacing: 0.6)),
              if (pinned) ...[
                const Spacer(),
                Icon(Icons.push_pin, size: 13, color: AppColors.accent700),
              ],
            ],
          ),
          if ((a['title'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 9),
            Text(a['title'] as String, style: AppText.heading(17, height: 1.2)),
          ],
          if ((a['body'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 5),
            Text(a['body'] as String,
                style:
                    AppText.body(14, height: 1.5, color: AppColors.ink(0.8))),
          ],
          const SizedBox(height: 9),
          Text('My Stables',
              style: AppText.body(12, color: AppColors.ink(0.5))),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(
      {required this.label,
      required this.icon,
      required this.terra,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool terra;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final bg = terra ? const Color(0xFFF3DDC9) : AppColors.accent2200;
    final fg = terra ? AppColors.accent700 : AppColors.accent2700;
    return Material(
      color: AppColors.warmWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: fg, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: AppText.heading(16), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.vendor, required this.onTap});
  final Map<String, dynamic> vendor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final kind = (vendor['kind'] as String?) ?? '';
    final city = (vendor['city'] as String?) ?? '';
    final sub = [city, kind].where((s) => s.isNotEmpty).join(' · ');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 158,
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 74,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE7C9A9), Color(0xFFD69A68)]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((vendor['name'] as String?) ?? 'Shop',
                      style: AppText.heading(16, height: 1.15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(sub,
                        style: AppText.body(12.5, color: AppColors.ink(0.55)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.vendor, required this.onAsk});
  final Map<String, dynamic> vendor;
  final VoidCallback onAsk;
  @override
  Widget build(BuildContext context) {
    final bits = [
      if ((vendor['city'] as String?)?.isNotEmpty == true) vendor['city'],
      if ((vendor['about'] as String?)?.isNotEmpty == true) vendor['about'],
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFF3DDC9),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(Icons.handshake_outlined,
                color: AppColors.accent700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((vendor['name'] as String?) ?? 'Provider',
                    style: AppText.heading(16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (bits.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(bits,
                      style: AppText.body(12.5, color: AppColors.ink(0.55)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: const Color(0xFFF3DDC9),
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onAsk,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                child: Text('Ask price',
                    style: AppText.body(13, color: AppColors.accent700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
