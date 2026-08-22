import 'package:flutter/material.dart';

import '../../data/payments_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'receipt_screen.dart';

/// Screen 59 — Payments. Everything paid for, grouped by month, filtered by
/// kind. States distinguish paid, not-yet-charged, and refunded.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  static const route = '/market/payments';

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final filters = [l10n.filterAll, l10n.filterShop, l10n.filterServices, l10n.filterTransport];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            const BackLink(label: 'You'),
            const SizedBox(height: 16),
            Text(l10n.payments, style: AppText.heading(36, height: 1)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _Tile(label: l10n.thisMonth, value: PaymentsData.thisMonthTotal)),
                const SizedBox(width: 8),
                Expanded(child: _Tile(label: l10n.notSettledYet, value: PaymentsData.notSettled)),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < filters.length; i++)
                  _Chip(
                    label: filters[i],
                    selected: i == _filter,
                    onTap: () => setState(() => _filter = i),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            for (final m in PaymentsData.months) ...[
              Text(m.label.toUpperCase(), style: AppText.eyebrow()),
              const SizedBox(height: 4),
              const Hairline(),
              for (final r in m.rows) ...[
                _PaymentRow(row: r),
                const Hairline(),
              ],
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppText.body(11, color: AppColors.ink(0.5), letterSpacing: 0.6)),
          const SizedBox(height: 5),
          Text(value, style: AppText.heading(19)),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.row});
  final PaymentRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final (stateLabel, stateColor) = switch (row.state) {
      PayState.paid => (l10n.statePaid, AppColors.accent2700),
      PayState.notCharged => (l10n.stateNotCharged, AppColors.accent700),
      PayState.refunded => (l10n.stateRefunded, AppColors.ink(0.5)),
    };
    return InkWell(
      onTap: row.opensReceipt
          ? () => Navigator.of(context).pushNamed(ReceiptScreen.route)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.what, style: AppText.body(16, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(row.who,
                      style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(row.amount, style: AppText.heading(16)),
                const SizedBox(height: 4),
                Text(stateLabel, style: AppText.body(13, color: stateColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
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
          border: Border.all(color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(14, color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}
