import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen — one order's detail: the items, the total, the status, and (while
/// it's still pending) a way to cancel it.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  static const route = '/market/order';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Map<String, dynamic>? _order;
  Future<List<Map<String, dynamic>>>? _items;
  bool _cancelling = false;
  bool _returning = false;
  String _status = 'pending';
  bool _disputeRaised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order != null) return;
    _order = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _status = (_order?['status'] as String?) ?? 'pending';
    final id = _order?['id'] as String?;
    _items = id == null
        ? Future.value(const <Map<String, dynamic>>[])
        : SupabaseService.orderItems(id);
  }

  Future<void> _cancel() async {
    final id = _order?['id'] as String?;
    if (id == null) return;
    setState(() => _cancelling = true);
    try {
      await SupabaseService.cancelOrder(id);
      if (mounted) setState(() => _status = 'cancelled');
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppL10n.of(context).oCouldntCancel('$e'))));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  (String, TagTone) _statusTagFor(AppL10n l10n) => switch (_status) {
        'accepted' => (l10n.oStatusAccepted, TagTone.sage),
        'fulfilled' => (l10n.oStatusDelivered, TagTone.sage),
        'cancelled' => (l10n.oStatusCancelled, TagTone.neutral),
        _ => (l10n.oStatusPending, TagTone.accent),
      };

  bool get _hasOpenDispute {
    if (_disputeRaised) return true;
    final ds = (_order?['disputes'] as List?) ?? const [];
    return ds.any((d) => (d as Map)['status'] == 'open');
  }

  /// Goods, delivered, inside the window, nothing raised yet.
  bool get _canReturn {
    final o = _order ?? const {};
    if ((o['category_group'] as String?) != 'goods') return false;
    if (o['payout_id'] != null) return false;
    if (_hasOpenDispute) return false;
    final delivered = DateTime.tryParse((o['delivered_at'] as String?) ?? '');
    if (delivered == null) return false;
    final days = (o['return_window_days'] as num?)?.toInt() ?? 14;
    return DateTime.now().toUtc().isBefore(delivered.toUtc().add(Duration(days: days)));
  }

  Future<void> _return() async {
    final id = _order?['id'] as String?;
    if (id == null) return;
    final l10n = AppL10n.of(context);
    final reasonC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text(l10n.oReportProblem, style: AppText.heading(22)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l10n.oReportBody,
              style: AppText.body(14, height: 1.5, color: AppColors.ink(0.7))),
          const SizedBox(height: 12),
          TextField(
            controller: reasonC,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.oReportHint),
          ),
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
    if (ok != true || reasonC.text.trim().isEmpty) return;
    setState(() => _returning = true);
    try {
      await SupabaseService.raiseDispute(id, reasonC.text.trim(),
          buyerSays: reasonC.text.trim());
      if (mounted) {
        setState(() => _disputeRaised = true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.oProblemSent)));
      }
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppL10n.of(context).oCouldntSend('$e'))));
      }
    } finally {
      if (mounted) setState(() => _returning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final order = _order ?? const {};
    final vendor = (order['vendor_name'] as String?) ?? 'Seller';
    final total = (order['total_aed'] as num?)?.toDouble() ?? 0;
    final subtotal = (order['subtotal_aed'] as num?)?.toDouble() ?? total;
    final delivery = (order['delivery_aed'] as num?)?.toDouble() ?? 0;
    final created = DateTime.tryParse((order['created_at'] as String?) ?? '');
    final when = created != null
        ? DateFormat.yMMMMd(l10n.localeName).format(created)
        : '';
    final tag = _statusTagFor(l10n);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: l10n.ordersTitle),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: Text(vendor, style: AppText.heading(32, height: 1.05))),
                AppTag(tag.$1, tone: tag.$2),
              ],
            ),
            const SizedBox(height: 8),
            Text(when, style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _items,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snap.data ?? const [];
                return Column(
                  children: [
                    for (final i in items) ...[
                      _ItemLine(item: i),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _totalLine(l10n.bItems, subtotal, false),
            _totalLine(l10n.bDelivery, delivery, false, freeLabel: l10n.bFree),
            const SizedBox(height: 6),
            _totalLine(l10n.oYouPaid, total, true),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: SupabaseService.platformSettings(),
              builder: (context, snap) {
                final s = snap.data ?? const {};
                final vat = ((s['vat_pct'] as num?)?.toDouble() ?? 5)
                    .toStringAsFixed(0);
                final trn = (s['trn'] as String?)?.trim();
                return Text(
                    trn != null && trn.isNotEmpty
                        ? l10n.oVatTrn(vat, trn)
                        : l10n.oVat(vat),
                    style: AppText.body(13, color: AppColors.ink(0.5)));
              },
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _hasOpenDispute
                    ? l10n.oInfoDispute
                    : _canReturn
                        ? l10n.oInfoCanReturn
                        : l10n.oInfoDefault,
                style: AppText.body(14, height: 1.5, color: AppColors.ink(0.7)),
              ),
            ),
            const SizedBox(height: 24),
            if (_status == 'pending') ...[
              if (_cancelling)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(
                  label: l10n.oCancelOrder,
                  variant: AppButtonVariant.secondary,
                  onPressed: _cancel,
                ),
            ] else if (_canReturn) ...[
              if (_returning)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(
                  label: l10n.oReportProblem,
                  variant: AppButtonVariant.secondary,
                  onPressed: _return,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _totalLine(String label, double v, bool strong,
      {String? freeLabel}) {
    final value = (freeLabel != null && v == 0)
        ? freeLabel
        : 'AED ${v.toStringAsFixed(0)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: strong
                    ? AppText.heading(19)
                    : AppText.body(15, color: AppColors.ink(0.6)))),
        Text(value,
            style: strong ? AppText.heading(19) : AppText.body(15)),
      ]),
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final price = (item['unit_price_aed'] as num?)?.toDouble() ?? 0;
    final qty = (item['qty'] as num?)?.toInt() ?? 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text('${(item['name'] as String?) ?? 'Item'}  ×$qty',
                style: AppText.body(16, height: 1.3)),
          ),
          const SizedBox(width: 12),
          Text('AED ${(price * qty).toStringAsFixed(0)}',
              style: AppText.body(16)),
        ],
      ),
    );
  }
}
