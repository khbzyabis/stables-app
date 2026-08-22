import 'package:flutter/material.dart';

import '../../data/payments_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'order_screen.dart';

/// Screen 60 — A receipt. One payment, itemised per seller, VAT at 5% shown as
/// included, operator TRN at the foot.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});
  static const route = '/market/receipt';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: l10n.payments),
            const SizedBox(height: 20),
            Text('Receipt MS-8841 · 18 August 2026',
                style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 9),
            Text('AED 469.00', style: AppText.heading(36, height: 1)),
            const SizedBox(height: 6),
            Text('Paid by card ending 8842 · 09:12',
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            for (final g in PaymentsData.receiptGroups) ...[
              Text(g.seller.toUpperCase(), style: AppText.eyebrow()),
              const SizedBox(height: 4),
              const Hairline(),
              for (final l in g.lines) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name, style: AppText.body(16, height: 1.35)),
                            const SizedBox(height: 3),
                            Text(l.detail,
                                style: AppText.body(13, color: AppColors.ink(0.5))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(l.price, style: AppText.body(16)),
                    ],
                  ),
                ),
                const Hairline(),
              ],
              const SizedBox(height: 18),
            ],
            for (final t in PaymentsData.receiptTotals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t.label,
                          style: t.strong
                              ? AppText.heading(19)
                              : AppText.body(t.muted ? 15 : 16,
                                  color: AppColors.ink(t.muted ? 0.5 : 0.6))),
                    ),
                    Text(t.value,
                        style: t.strong
                            ? AppText.heading(19)
                            : AppText.body(t.muted ? 15 : 16,
                                color: t.muted ? AppColors.ink(0.5) : AppColors.text)),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(l10n.receiptSellersNote,
                  style: AppText.body(15, height: 1.6)),
            ),
            const SizedBox(height: 24),
            Text(l10n.sendReceiptPdf,
                style: AppText.body(16, color: AppColors.accent700)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(OrderScreen.route),
              child: Text(l10n.seeOrderDelivery,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
            const SizedBox(height: 14),
            Text(l10n.somethingWrongPayment,
                style: AppText.body(15, color: AppColors.ink(0.55))),
            const SizedBox(height: 22),
            Text(PaymentsData.trn,
                style: AppText.body(13, height: 1.55, color: AppColors.ink(0.45))),
          ],
        ),
      ),
    );
  }
}
