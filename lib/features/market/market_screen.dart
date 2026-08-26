import 'package:flutter/material.dart';

import '../../data/basket.dart';
import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_field.dart';
import '../../widgets/photo_placeholder.dart';
import 'basket_screen.dart';
import 'item_screen.dart';

/// Screen 48 — Market (Shop). Browse real products by category, across every
/// approved vendor. Sellers list products from the provider dashboard.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key, this.initialCategory});
  static const route = '/market';

  /// When opened from the market home, start on this category (e.g. 'Feed',
  /// 'Services'). Falls back to a route String argument, then 'Feed'.
  final String? initialCategory;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

/// Shared quote-request sheet, reused by the market home's service list.
Future<void> showMarketQuoteSheet(
    BuildContext context, Map<String, dynamic> vendor, String? stableId) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _RequestQuoteSheet(vendor: vendor, stableId: stableId),
  );
  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent. Check My quotes for the reply.'),
      ),
    );
  }
}

class _MarketScreenState extends State<MarketScreen> {
  late String _cat = widget.initialCategory ?? 'Feed';
  late Future<List<Map<String, dynamic>>> _future = _load();
  bool _readArg = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Allow passing the initial category as a route argument too.
    if (!_readArg && widget.initialCategory == null) {
      _readArg = true;
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.isNotEmpty && arg != _cat) {
        setState(() {
          _cat = arg;
          _future = _load();
        });
      }
    }
  }

  bool get _isServices => _cat == 'Services';

  Future<List<Map<String, dynamic>>> _load() => _isServices
      ? SupabaseService.vendorsOfKind('Services')
      : SupabaseService.marketProducts(_cat);

  void _select(String c) {
    setState(() {
      _cat = c;
      _future = _load();
    });
  }

  Future<void> _requestQuote(Map<String, dynamic> vendor) => showMarketQuoteSheet(
      context, vendor, SessionScope.of(context).activeStableId);

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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: AppColors.warmWhite,
                        shape: const CircleBorder(),
                        elevation: 2,
                        shadowColor: const Color(0x33140E06),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Icon(Icons.arrow_back,
                                size: 20, color: AppColors.text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.deliversTo(stableName),
                              style: AppText.eyebrow(
                                color: AppColors.accent700,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              l10n.market,
                              style: AppText.heading(36, height: 1),
                            ),
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
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: Text(
                            _isServices
                                ? 'No service providers yet. Farriers, vets and '
                                      'physios who set up a Services shop appear here.'
                                : 'Nothing in $_cat yet. Sellers add products from '
                                      '"Sell on the market" (under You). Anything '
                                      'they list shows up here.',
                            style: AppText.body(
                              16,
                              height: 1.5,
                              color: AppColors.ink(0.6),
                            ),
                          ),
                        ),
                      if (_isServices)
                        for (final v in items) ...[
                          _ServiceRow(
                            vendor: v,
                            onRequest: () => _requestQuote(v),
                          ),
                          const SizedBox(height: 10),
                        ]
                      else
                        for (final item in items) ...[
                          _ItemRow(item: item, onReturn: () => setState(() {})),
                          const SizedBox(height: 10),
                        ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          l10n.everyApproved,
                          style: AppText.body(
                            14,
                            height: 1.5,
                            color: AppColors.ink(0.5),
                          ),
                        ),
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
              const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.accent700,
                size: 22,
              ),
              const SizedBox(width: 7),
              Text(
                '$count',
                style: AppText.heading(15, color: AppColors.accent700),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
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
            color: selected ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppText.body(
            14,
            color: selected ? AppColors.bg : AppColors.text,
          ),
        ),
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
    return AppCard(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(ItemScreen.route, arguments: item);
        onReturn();
      },
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          PhotoPlaceholder(
            size: 64,
            circle: false,
            radius: 16,
            url: item['image_url'] as String?,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['name'] as String?) ?? 'Product',
                  style: AppText.body(17, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  (item['vendor_name'] as String?) ?? 'Seller',
                  style: AppText.body(14, color: AppColors.ink(0.55)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AED ${price.toStringAsFixed(0)}',
                style: AppText.heading(17),
              ),
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

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.vendor, required this.onRequest});
  final Map<String, dynamic> vendor;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final bits = [
      if ((vendor['city'] as String?)?.isNotEmpty == true) vendor['city'],
      if ((vendor['about'] as String?)?.isNotEmpty == true) vendor['about'],
    ].join(' · ');
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (vendor['name'] as String?) ?? 'Provider',
                  style: AppText.body(17, height: 1.3),
                ),
                if (bits.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bits,
                    style: AppText.body(14, color: AppColors.ink(0.55)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onRequest,
            child: Text(
              'Ask for a price',
              style: AppText.heading(15, color: AppColors.accent700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestQuoteSheet extends StatefulWidget {
  const _RequestQuoteSheet({required this.vendor, required this.stableId});
  final Map<String, dynamic> vendor;
  final String? stableId;

  @override
  State<_RequestQuoteSheet> createState() => _RequestQuoteSheetState();
}

class _RequestQuoteSheetState extends State<_RequestQuoteSheet> {
  final _subject = TextEditingController();
  final _detail = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _subject.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_subject.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Say what you need a price for.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.requestQuote(
        kind: 'service',
        vendorId: widget.vendor['id'] as String,
        stableId: widget.stableId,
        subject: _subject.text.trim(),
        detail: _detail.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't send: $e")));
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
          Text(
            'Ask ${(widget.vendor['name'] as String?) ?? 'the provider'} for a price',
            style: AppText.heading(22, height: 1.15),
          ),
          const SizedBox(height: 18),
          AppField(label: 'What do you need?', controller: _subject),
          const SizedBox(height: 16),
          AppField(
            label: 'Details (optional)',
            controller: _detail,
            maxLines: 3,
          ),
          const SizedBox(height: 22),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: 'Send request', onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
