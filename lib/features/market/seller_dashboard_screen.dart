import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/photo_placeholder.dart';
import '../../widgets/photo_picker.dart';
import '../provider_app/provider_app_screen.dart';

/// Seller Dashboard — an approved seller's desktop workspace. Sidebar splits
/// Shop (orders, listings) from Services (requests), with Money and Account.
/// "Held vs payable" sits in the header on every page. Held/payable are
/// simplified for now (the full commission + payout model comes next).
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key, this.vendor});
  static const route = '/seller';

  /// The shop to show. When null, it's read from the route arguments.
  final Map<String, dynamic>? vendor;

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

enum _Sec { overview, orders, listings, requests, money, account }

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  Map<String, dynamic>? _vendor;
  _Sec _sec = _Sec.overview;

  static const _icons = {
    _Sec.overview: Icons.grid_view_rounded,
    _Sec.orders: Icons.receipt_long_outlined,
    _Sec.listings: Icons.inventory_2_outlined,
    _Sec.requests: Icons.question_answer_outlined,
    _Sec.money: Icons.payments_outlined,
    _Sec.account: Icons.badge_outlined,
  };

  // Money figures, refreshed when orders load.
  double _payable = 0, _held = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vendor ??= widget.vendor ??
        (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
  }

  String get _vendorId => _vendor?['id'] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final labels = {
      _Sec.overview: l10n.sdOverview,
      _Sec.orders: l10n.sdOrders,
      _Sec.listings: l10n.sdListings,
      _Sec.requests: l10n.sdRequests,
      _Sec.money: l10n.sdMoney,
      _Sec.account: l10n.sdAccount,
    };
    final name = (_vendor?['name'] as String?) ?? l10n.sdYourShop;
    final approved = _vendor?['approved'] as bool? ?? false;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final nav = _Nav(
          wide: wide,
          sec: _sec,
          labels: labels,
          icons: _icons,
          name: name,
          onSelect: (s) => setState(() => _sec = s),
        );
        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
                title: labels[_sec]!,
                approved: approved,
                payable: _payable,
                held: _held,
                onClose: () => Navigator.of(context).maybePop()),
            Expanded(child: _content()),
          ],
        );
        return SafeArea(
          child: wide
              ? Row(children: [nav, Expanded(child: body)])
              : Column(children: [nav, Expanded(child: body)]),
        );
      }),
    );
  }

  Widget _content() {
    switch (_sec) {
      case _Sec.overview:
        return _Overview(vendor: _vendor ?? const {});
      case _Sec.orders:
        return _Orders(
          vendorId: _vendorId,
          onMoney: (p, h) {
            if (mounted && (p != _payable || h != _held)) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => setState(() { _payable = p; _held = h; }));
            }
          },
        );
      case _Sec.listings:
        return _Listings(vendorId: _vendorId);
      case _Sec.requests:
        return _Requests(vendorId: _vendorId);
      case _Sec.money:
        return _Money(vendorId: _vendorId, payable: _payable, held: _held);
      case _Sec.account:
        return _Account(vendor: _vendor ?? const {});
    }
  }
}

// ---- Chrome ----------------------------------------------------------------
class _Nav extends StatelessWidget {
  const _Nav(
      {required this.wide,
      required this.sec,
      required this.labels,
      required this.icons,
      required this.name,
      required this.onSelect});
  final bool wide;
  final _Sec sec;
  final Map<_Sec, String> labels;
  final Map<_Sec, IconData> icons;
  final String name;
  final ValueChanged<_Sec> onSelect;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            for (final s in _Sec.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(labels[s]!),
                  selected: s == sec,
                  showCheckmark: false,
                  onSelected: (_) => onSelect(s),
                  backgroundColor: AppColors.neutral200,
                  selectedColor: AppColors.accent,
                  labelStyle: AppText.body(14,
                      color: s == sec ? AppColors.bg : AppColors.text),
                ),
              ),
          ]),
        ),
      );
    }
    return Container(
      width: 236,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(name, style: AppText.heading(18, height: 1.1)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(AppL10n.of(context).sdSeller,
                style: AppText.eyebrow(color: AppColors.accent2700)),
          ),
          const SizedBox(height: 20),
          for (final s in _Sec.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Material(
                color: s == sec ? AppColors.accent2200 : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onSelect(s),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(children: [
                      Icon(icons[s],
                          size: 19,
                          color: s == sec
                              ? AppColors.accent2800
                              : AppColors.ink(0.5)),
                      const SizedBox(width: 12),
                      Text(labels[s]!,
                          style: AppText.body(15,
                              color: s == sec
                                  ? AppColors.text
                                  : AppColors.ink(0.7))),
                    ]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
      {required this.title,
      required this.approved,
      required this.payable,
      required this.held,
      required this.onClose});
  final String title;
  final bool approved;
  final double payable;
  final double held;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading(28, height: 1)),
                if (!approved) ...[
                  const SizedBox(height: 6),
                  AppTag(l10n.sdInReview, tone: TagTone.accent),
                ],
              ],
            ),
          ),
          _Money2(label: l10n.sdHeld, value: held),
          const SizedBox(width: 10),
          _Money2(label: l10n.sdPayable, value: payable, strong: true),
          IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: AppColors.ink(0.5))),
        ],
      ),
    );
  }
}

class _Money2 extends StatelessWidget {
  const _Money2({required this.label, required this.value, this.strong = false});
  final String label;
  final double value;
  final bool strong;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: strong ? AppColors.accent2200 : AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppText.body(10,
                  letterSpacing: 0.6, color: AppColors.ink(0.5))),
          const SizedBox(height: 3),
          Text('AED ${value.toStringAsFixed(0)}', style: AppText.heading(18)),
        ],
      ),
    );
  }
}

// ---- Overview (analytics) --------------------------------------------------
class _Overview extends StatefulWidget {
  const _Overview({required this.vendor});
  final Map<String, dynamic> vendor;
  @override
  State<_Overview> createState() => _OverviewState();
}

class _OverviewState extends State<_Overview> {
  String get _vid => widget.vendor['id'] as String? ?? '';
  late final Future<List<Map<String, dynamic>>> _orders =
      SupabaseService.vendorOrders(_vid);
  late final Future<List<Map<String, dynamic>>> _products =
      SupabaseService.vendorProducts(_vid);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final approved = widget.vendor['approved'] as bool? ?? false;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, oSnap) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _products,
          builder: (context, pSnap) {
            final orders = oSnap.data ?? const [];
            final products = pSnap.data ?? const [];
            final loading = oSnap.connectionState == ConnectionState.waiting ||
                pSnap.connectionState == ConnectionState.waiting;

            // Figures
            final now = DateTime.now();
            final from30 = now.subtract(const Duration(days: 30));
            double sales30 = 0, payable = 0, held = 0, allTime = 0;
            int orders30 = 0;
            final byMonth = <String, double>{};
            for (final o in orders) {
              if (o['status'] == 'cancelled') continue;
              final net = SupabaseService.orderNet(o);
              final st = SupabaseService.orderMoneyState(o);
              if (st == 'payable') payable += net;
              if (st == 'held' || st == 'disputed') held += net;
              allTime += net;
              final created =
                  DateTime.tryParse((o['created_at'] as String?) ?? '');
              if (created != null) {
                if (created.isAfter(from30)) {
                  sales30 += net;
                  orders30 += 1;
                }
                final key =
                    '${created.year}-${created.month.toString().padLeft(2, '0')}';
                byMonth[key] = (byMonth[key] ?? 0) + net;
              }
            }
            final liveListings =
                products.where((p) => (p['in_stock'] as bool?) ?? true).length;
            final lowStock = products.where((p) {
              final q = p['stock_qty'] as int?;
              return q != null && q <= 3;
            }).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
              children: [
                if (!approved) _pendingBanner(l10n),
                if (!approved) const SizedBox(height: 16),
                if (loading)
                  const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()))
                else ...[
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    _kpi('Sales · 30 days', 'AED ${sales30.toStringAsFixed(0)}'),
                    _kpi('Orders · 30 days', '$orders30'),
                    _kpi('Payable now', 'AED ${payable.toStringAsFixed(0)}',
                        bg: AppColors.accent2200),
                    _kpi('Held', 'AED ${held.toStringAsFixed(0)}'),
                    _kpi('Live listings', '$liveListings'),
                    _kpi('All-time earned', 'AED ${allTime.toStringAsFixed(0)}'),
                  ]),
                  if (lowStock > 0) ...[
                    const SizedBox(height: 14),
                    _note('$lowStock ${lowStock == 1 ? 'product is' : 'products are'} '
                        'low on stock — top them up in Listings.',
                        AppColors.accent700),
                  ],
                  const SizedBox(height: 22),
                  Text('SALES BY MONTH', style: AppText.eyebrow()),
                  const SizedBox(height: 12),
                  _MiniBars(byMonth: byMonth),
                  const SizedBox(height: 24),
                  _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.sdHowMoney, style: AppText.heading(18)),
                        const SizedBox(height: 8),
                        Text('${l10n.sdBullet2} ${l10n.sdBullet4}',
                            style: AppText.body(14,
                                height: 1.5, color: AppColors.ink(0.65))),
                      ])),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _pendingBanner(AppL10n l10n) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.accent2200,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.accent2800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('In review — not live yet',
                  style: AppText.heading(16)),
              const SizedBox(height: 3),
              Text('Buyers can\'t see your shop until an operator approves it. '
                  'You can set up your listings and prices while you wait.',
                  style: AppText.body(13, height: 1.4, color: AppColors.ink(0.7))),
            ]),
          ),
        ]),
      );

  Widget _kpi(String label, String value, {Color? bg}) => Container(
        width: 168,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: bg ?? AppColors.surface,
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppText.heading(24, height: 1)),
          const SizedBox(height: 5),
          Text(label, style: AppText.body(12, color: AppColors.ink(0.6))),
        ]),
      );

  Widget _note(String s, Color c) =>
      Text(s, style: AppText.body(13, height: 1.4, color: c));
}

/// A tiny dependency-free bar chart of the last six months of net sales.
class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.byMonth});
  final Map<String, double> byMonth;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = <(String, double)>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      const names = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      months.add((names[d.month - 1], byMonth[key] ?? 0));
    }
    final max = months.fold<double>(1, (m, e) => e.$2 > m ? e.$2 : m);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final m in months)
            Expanded(
              child: Column(children: [
                Text(m.$2 >= 1 ? m.$2.toStringAsFixed(0) : '',
                    style: AppText.body(10, color: AppColors.ink(0.5))),
                const SizedBox(height: 4),
                Container(
                  height: 90 * (m.$2 / max).clamp(0.02, 1.0),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: m.$2 > 0 ? AppColors.accent : AppColors.neutral200,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(m.$1, style: AppText.body(11, color: AppColors.ink(0.55))),
              ]),
            ),
        ],
      ),
    );
  }
}

// ---- Orders ----------------------------------------------------------------
class _Orders extends StatefulWidget {
  const _Orders({required this.vendorId, required this.onMoney});
  final String vendorId;
  final void Function(double payable, double held) onMoney;
  @override
  State<_Orders> createState() => _OrdersState();
}

class _OrdersState extends State<_Orders> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.vendorOrders(widget.vendorId);
  void _reload() =>
      setState(() => _f = SupabaseService.vendorOrders(widget.vendorId));

  Future<void> _advance(String id, String status) async {
    try {
      await SupabaseService.setOrderStatus(id, status);
      _reload();
    } catch (e) {
      AppErrors.report(e);
    }
  }

  Future<void> _respond(String disputeId) async {
    final ctrl = TextEditingController();
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text(l10n.sdYourSide, style: AppText.heading(22)),
        content:
            AppField(label: l10n.sdWhatHappened, controller: ctrl, maxLines: 3),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.oCancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.oSend)),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      try {
        await SupabaseService.sellerRespondDispute(disputeId, ctrl.text.trim());
        _reload();
      } catch (e) {
        AppErrors.report(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final orders = snap.data ?? const [];
        // Real ledger: sum each order's net by where its money sits.
        double payable = 0, held = 0;
        for (final o in orders) {
          final state = SupabaseService.orderMoneyState(o);
          final net = SupabaseService.orderNet(o);
          if (state == 'payable') payable += net;
          if (state == 'held' || state == 'disputed') held += net;
        }
        widget.onMoney(payable, held);
        if (orders.isEmpty) {
          return _pad(Text(AppL10n.of(context).sdNoOrders,
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          children: [
            for (final o in orders) ...[
              _card(_OrderRow(order: o, onAdvance: _advance, onRespond: _respond)),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow(
      {required this.order, required this.onAdvance, required this.onRespond});
  final Map<String, dynamic> order;
  final Future<void> Function(String, String) onAdvance;
  final Future<void> Function(String) onRespond;

  String? get _openDisputeId {
    final ds = (order['disputes'] as List?) ?? const [];
    for (final d in ds) {
      if ((d as Map)['status'] == 'open') return d['id'] as String?;
    }
    return null;
  }

  // The money state drives the tag on the right — held / payable / paid…
  (String, TagTone) _moneyTag(String state, AppL10n l10n) => switch (state) {
        'payable' => (l10n.sdTagPayable, TagTone.sage),
        'paid' => (l10n.sdTagPaid, TagTone.neutral),
        'refunded' => (l10n.sdTagRefunded, TagTone.neutral),
        'disputed' => (l10n.sdTagDisputed, TagTone.accent),
        'cancelled' => (l10n.sdTagCancelled, TagTone.neutral),
        _ => (l10n.sdTagHeld, TagTone.outline),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final id = order['id'] as String;
    final status = (order['status'] as String?) ?? 'pending';
    final net = SupabaseService.orderNet(order);
    final total = (order['total_aed'] as num?)?.toDouble() ?? 0;
    final fee = (order['commission_aed'] as num?)?.toDouble() ?? 0;
    final state = SupabaseService.orderMoneyState(order);
    final tag = _moneyTag(state, l10n);
    final line = switch (state) {
      'held' => status == 'fulfilled'
          ? l10n.sdLineDelivered
          : l10n.sdLineHeldUntil,
      'payable' => l10n.sdLineClears,
      'paid' => l10n.sdLinePaid,
      'refunded' => l10n.sdLineRefunded,
      'disputed' => l10n.sdLineReturn,
      'cancelled' => l10n.sdTagCancelled,
      _ => status,
    };
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AED ${net.toStringAsFixed(0)}', style: AppText.heading(18)),
          const SizedBox(height: 4),
          Text('$line · ${l10n.sdBuyerPaid} AED ${total.toStringAsFixed(0)} · ${l10n.sdFee} AED ${fee.toStringAsFixed(0)}',
              style: AppText.body(13, color: AppColors.ink(0.55))),
        ]),
      ),
      AppTag(tag.$1, tone: tag.$2),
      if (state == 'disputed' && _openDisputeId != null) ...[
        const SizedBox(width: 10),
        AppButton(
          label: l10n.sdRespond,
          variant: AppButtonVariant.secondary,
          block: false,
          minHeight: 40,
          fontSize: 14,
          onPressed: () => onRespond(_openDisputeId!),
        ),
      ] else if (status == 'pending' || status == 'accepted') ...[
        const SizedBox(width: 10),
        AppButton(
          label: status == 'pending' ? l10n.sdAccept : l10n.sdMarkDelivered,
          block: false,
          minHeight: 40,
          fontSize: 14,
          onPressed: () =>
              onAdvance(id, status == 'pending' ? 'accepted' : 'fulfilled'),
        ),
      ],
    ]);
  }
}

// ---- Listings --------------------------------------------------------------
class _Listings extends StatefulWidget {
  const _Listings({required this.vendorId});
  final String vendorId;
  @override
  State<_Listings> createState() => _ListingsState();
}

class _ListingsState extends State<_Listings> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.vendorProducts(widget.vendorId);
  double _rate = 8;
  void _reload() =>
      setState(() => _f = SupabaseService.vendorProducts(widget.vendorId));

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  Future<void> _loadRate() async {
    try {
      final r = await SupabaseService.goodsRate();
      if (mounted) setState(() => _rate = r);
    } catch (_) {
      // Keep the 8% default if the rate can't be read.
    }
  }

  Future<void> _add() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _NewProductSheet(vendorId: widget.vendorId),
    );
    if (ok == true) _reload();
  }

  Widget _stockLabel(int? qty) {
    if (qty == null) {
      return Text('Stock: not tracked · tap to set',
          style: AppText.body(12, color: AppColors.accent700));
    }
    final low = qty <= 3;
    return Text('Stock: $qty${low ? ' · low' : ''} · tap to change',
        style: AppText.body(12,
            color: low ? AppColors.accent700 : AppColors.ink(0.5)));
  }

  Future<void> _editStock(Map<String, dynamic> p) async {
    final ctrl = TextEditingController(
        text: (p['stock_qty'] as int?)?.toString() ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text('Stock on hand', style: AppText.heading(20)),
        content: AppField(
            label: 'Quantity (leave empty for untracked)',
            controller: ctrl,
            keyboardType: TextInputType.number),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result == null) return;
    try {
      await SupabaseService.setProductStockQty(
          p['id'] as String, result.isEmpty ? null : int.tryParse(result));
      _reload();
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        final l10n = AppL10n.of(context);
        final products = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          children: [
            AppButton(label: l10n.sdAddProduct, onPressed: _add),
            const SizedBox(height: 16),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator()),
            for (final p in products) ...[
              _card(Row(children: [
                PhotoPlaceholder(
                    size: 48,
                    circle: false,
                    radius: 12,
                    url: p['image_url'] as String?),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((p['name'] as String?) ?? 'Product',
                            style: AppText.body(16)),
                        const SizedBox(height: 3),
                        Text(
                            'AED ${((p['price_aed'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)} · ${l10n.sdYouReceive} AED ${(((p['price_aed'] as num?)?.toDouble() ?? 0) * (1 - _rate / 100)).toStringAsFixed(0)} (${l10n.sdAfterPct(_rate.toStringAsFixed(0))})',
                            style: AppText.body(13, color: AppColors.ink(0.55))),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _editStock(p),
                          child: _stockLabel(p['stock_qty'] as int?),
                        ),
                      ]),
                ),
                Switch(
                  value: p['in_stock'] as bool? ?? true,
                  onChanged: (v) async {
                    try {
                      await SupabaseService.setProductStock(
                          p['id'] as String, v);
                      _reload();
                    } catch (e) {
                      AppErrors.report(e);
                    }
                  },
                  activeThumbColor: AppColors.bg,
                  activeTrackColor: AppColors.accent2600,
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await SupabaseService.deleteProduct(p['id'] as String);
                      _reload();
                    } catch (e) {
                      AppErrors.report(e);
                    }
                  },
                  icon: Icon(Icons.delete_outline, color: AppColors.ink(0.5)),
                ),
              ])),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

// ---- Requests --------------------------------------------------------------
class _Requests extends StatefulWidget {
  const _Requests({required this.vendorId});
  final String vendorId;
  @override
  State<_Requests> createState() => _RequestsState();
}

class _RequestsState extends State<_Requests> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.vendorQuoteRequests(widget.vendorId);
  void _reload() =>
      setState(() => _f = SupabaseService.vendorQuoteRequests(widget.vendorId));

  Future<void> _quote(String id) async {
    final priceC = TextEditingController();
    final noteC = TextEditingController();
    final l10n = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text(l10n.sdSendQuote, style: AppText.heading(22)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          AppField(
              label: l10n.sdPriceAed,
              controller: priceC,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          AppField(label: l10n.sdNote, controller: noteC),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.oCancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.oSend)),
        ],
      ),
    );
    if (ok == true) {
      final price = double.tryParse(priceC.text.trim());
      if (price != null) {
        try {
          await SupabaseService.submitQuote(id, price, noteC.text.trim());
          _reload();
        } catch (e) {
          AppErrors.report(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        final reqs = snap.data ?? const [];
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reqs.isEmpty) {
          return _pad(Text(AppL10n.of(context).sdNoRequests,
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          children: [
            for (final r in reqs) ...[
              _card(_ReqRow(req: r, onQuote: () => _quote(r['id'] as String))),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ReqRow extends StatelessWidget {
  const _ReqRow({required this.req, required this.onQuote});
  final Map<String, dynamic> req;
  final VoidCallback onQuote;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final status = (req['status'] as String?) ?? 'open';
    final isTransport = req['kind'] == 'transport';
    final title = isTransport
        ? '${l10n.sdTransport}: ${req['from_loc'] ?? '?'} → ${req['to_loc'] ?? '?'}'
        : ((req['subject'] as String?)?.isNotEmpty == true
            ? req['subject'] as String
            : l10n.sdServiceRequest);
    final price = (req['quote_price'] as num?)?.toDouble();
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.heading(17)),
          if (price != null) ...[
            const SizedBox(height: 4),
            Text('${l10n.sdYourQuote}: AED ${price.toStringAsFixed(0)}',
                style: AppText.body(13, color: AppColors.accent700)),
          ],
        ]),
      ),
      if (status == 'open')
        AppButton(
            label: l10n.sdSendQuote,
            block: false,
            minHeight: 40,
            fontSize: 14,
            onPressed: onQuote)
      else
        AppTag(status == 'accepted' ? l10n.sdAccepted : l10n.sdQuoted,
            tone: TagTone.sage),
    ]);
  }
}

// ---- Money -----------------------------------------------------------------
class _Money extends StatefulWidget {
  const _Money(
      {required this.vendorId, required this.payable, required this.held});
  final String vendorId;
  final double payable;
  final double held;
  @override
  State<_Money> createState() => _MoneyState();
}

class _MoneyState extends State<_Money> {
  late final Future<List<Map<String, dynamic>>> _payouts =
      SupabaseService.vendorPayouts(widget.vendorId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        Row(children: [
          Expanded(
              child:
                  _big(l10n.sdPayableNow, widget.payable, AppColors.accent2200)),
          const SizedBox(width: 12),
          Expanded(child: _big(l10n.sdHeld, widget.held, AppColors.neutral100)),
        ]),
        const SizedBox(height: 16),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.sdHowPayout, style: AppText.heading(18)),
          const SizedBox(height: 6),
          Text(l10n.sdPayoutBody,
              style: AppText.body(15, height: 1.5, color: AppColors.ink(0.7))),
        ])),
        const SizedBox(height: 20),
        Text(l10n.sdPayouts, style: AppText.eyebrow()),
        const SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _payouts,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = snap.data ?? const [];
            if (rows.isEmpty) {
              return _card(Text(l10n.sdNoPayouts,
                  style: AppText.body(15, color: AppColors.ink(0.6))));
            }
            return Column(children: [
              for (final p in rows) ...[
                _card(_PayoutRow(payout: p)),
                const SizedBox(height: 10),
              ],
            ]);
          },
        ),
      ],
    );
  }

  Widget _big(String label, double v, Color bg) => Container(
        padding: const EdgeInsets.all(20),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AED ${v.toStringAsFixed(0)}', style: AppText.heading(30)),
          const SizedBox(height: 5),
          Text(label, style: AppText.body(14, color: AppColors.ink(0.6))),
        ]),
      );
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.payout});
  final Map<String, dynamic> payout;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final net = (payout['net_aed'] as num?)?.toDouble() ?? 0;
    final refunds = (payout['refunds_aed'] as num?)?.toDouble() ?? 0;
    final fee = (payout['fee_aed'] as num?)?.toDouble() ?? 0;
    final paidOn = (payout['paid_on'] as String?) ?? '';
    final paid = payout['status'] == 'paid';
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AED ${net.toStringAsFixed(0)}', style: AppText.heading(18)),
          const SizedBox(height: 4),
          Text('${paid ? l10n.sdPaid : l10n.sdDue} $paidOn · ${l10n.sdFee} AED ${fee.toStringAsFixed(0)}'
              '${refunds > 0 ? ' · ${l10n.sdRefunds} AED ${refunds.toStringAsFixed(0)}' : ''}',
              style: AppText.body(13, color: AppColors.ink(0.55))),
        ]),
      ),
      AppTag(paid ? l10n.sdPaid : l10n.sdDue,
          tone: paid ? TagTone.neutral : TagTone.sage),
    ]);
  }
}

// ---- Account ---------------------------------------------------------------
class _Account extends StatelessWidget {
  const _Account({required this.vendor});
  final Map<String, dynamic> vendor;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final trades = (vendor['trades'] as List?)?.cast<String>() ?? const [];
    final approved = vendor['approved'] as bool? ?? false;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        _ShopPhotoCard(vendor: vendor),
        const SizedBox(height: 14),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((vendor['name'] as String?) ?? l10n.sdYourShop,
              style: AppText.heading(20)),
          const SizedBox(height: 6),
          Text(approved ? l10n.sdApprovedLive : l10n.sdInReviewShort,
              style: AppText.body(14,
                  color: approved ? AppColors.accent2700 : AppColors.accent700)),
          const SizedBox(height: 16),
          Text(l10n.sdApprovedFor, style: AppText.eyebrow()),
          const SizedBox(height: 8),
          if (trades.isEmpty)
            Text(l10n.sdNoTrades,
                style: AppText.body(14, color: AppColors.ink(0.5)))
          else
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in trades) AppTag(t, tone: TagTone.sage)
            ]),
        ])),
        const SizedBox(height: 14),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.sdOnTheRoad, style: AppText.heading(18)),
          const SizedBox(height: 6),
          Text(l10n.sdOnRoadBody,
              style: AppText.body(14, height: 1.5, color: AppColors.ink(0.65))),
          const SizedBox(height: 14),
          AppButton(
            label: l10n.sdOpenProviderApp,
            variant: AppButtonVariant.secondary,
            block: false,
            onPressed: () => Navigator.of(context).pushNamed(
                ProviderAppScreen.route,
                arguments: vendor),
          ),
        ])),
        const SizedBox(height: 14),
        AppButton(
          label: 'Sign out',
          variant: AppButtonVariant.secondary,
          block: false,
          onPressed: () => SupabaseService.signOut(),
        ),
      ],
    );
  }
}

/// The shop's cover/logo — shown to buyers on the storefront and market home.
class _ShopPhotoCard extends StatefulWidget {
  const _ShopPhotoCard({required this.vendor});
  final Map<String, dynamic> vendor;
  @override
  State<_ShopPhotoCard> createState() => _ShopPhotoCardState();
}

class _ShopPhotoCardState extends State<_ShopPhotoCard> {
  late String? _url = widget.vendor['image_url'] as String?;
  bool _busy = false;

  Future<void> _pick() async {
    final id = widget.vendor['id'] as String?;
    if (id == null) return;
    setState(() => _busy = true);
    final url = await pickAndUploadPhoto(context, 'shops');
    if (url != null) {
      try {
        await SupabaseService.setVendorImage(id, url);
        widget.vendor['image_url'] = url; // keep the in-memory shop in sync
        if (mounted) setState(() => _url = url);
      } catch (e) {
        AppErrors.report(e);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Couldn't save: $e")));
        }
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return _card(Row(children: [
      _busy
          ? const SizedBox(
              width: 72,
              height: 72,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)))
          : PhotoField(
              url: _url,
              onPick: _pick,
              size: 72,
              circle: false,
              label: 'Add',
            ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop photo', style: AppText.heading(18)),
            const SizedBox(height: 5),
            Text(
                'Buyers see this on your shop page and in the market. A clear '
                'logo or storefront works best.',
                style:
                    AppText.body(13.5, height: 1.45, color: AppColors.ink(0.6))),
          ],
        ),
      ),
    ]));
  }
}

// ---- shared ----------------------------------------------------------------
Widget _card(Widget child) => Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16)),
        child: child,
      );
    });

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.fromLTRB(28, 20, 28, 0), child: child);

class _NewProductSheet extends StatefulWidget {
  const _NewProductSheet({required this.vendorId});
  final String vendorId;
  @override
  State<_NewProductSheet> createState() => _NewProductSheetState();
}

class _NewProductSheetState extends State<_NewProductSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _unit = TextEditingController();
  final _stock = TextEditingController();
  String _category = 'Feed';
  String? _imageUrl;
  bool _imgBusy = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _unit.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _imgBusy = true);
    try {
      final picked =
          await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      final f = picked?.files.firstOrNull;
      if (f?.bytes != null) {
        _imageUrl = await SupabaseService.uploadPhoto(
            folder: 'products', fileName: f!.name, bytes: f.bytes!);
      }
    } catch (e) {
      AppErrors.report(e);
    } finally {
      if (mounted) setState(() => _imgBusy = false);
    }
  }

  Future<void> _save() async {
    final price = double.tryParse(_price.text.trim());
    if (_name.text.trim().isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).sdNamePriceNeeded)));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.addProduct(
        vendorId: widget.vendorId,
        name: _name.text.trim(),
        priceAed: price,
        category: _category,
        unit: _unit.text.trim(),
        imageUrl: _imageUrl,
        stockQty: int.tryParse(_stock.text.trim()),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: EdgeInsets.only(
          left: 28,
          right: 28,
          top: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sdNewProduct, style: AppText.heading(24)),
          const SizedBox(height: 16),
          Row(children: [
            PhotoPlaceholder(size: 56, circle: false, radius: 12, url: _imageUrl),
            const SizedBox(width: 14),
            if (_imgBusy)
              const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
            else
              GestureDetector(
                onTap: _pickImage,
                child: Text(_imageUrl == null ? l10n.sdAddPhoto : l10n.sdChangePhoto,
                    style: AppText.body(16, color: AppColors.accent700)),
              ),
          ]),
          const SizedBox(height: 16),
          AppField(label: l10n.sdName, controller: _name),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: AppField(
                    label: l10n.sdPriceAed,
                    controller: _price,
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: AppField(label: l10n.sdUnit, controller: _unit)),
            const SizedBox(width: 12),
            Expanded(
                child: AppField(
                    label: 'Stock',
                    controller: _stock,
                    keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in SupabaseService.marketCategories)
              GestureDetector(
                onTap: () => setState(() => _category = c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                  decoration: BoxDecoration(
                    color: c == _category ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                        color: c == _category
                            ? AppColors.accent
                            : AppColors.divider),
                  ),
                  child: Text(c,
                      style: AppText.body(14,
                          color: c == _category ? AppColors.bg : AppColors.text)),
                ),
              ),
          ]),
          const SizedBox(height: 20),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: l10n.sdAddProductBtn, onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
