import 'package:flutter/material.dart';

import '../../data/shows_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import 'receipt_screen.dart';

/// Screen 61 — straight after paying. Two sellers, two deliveries; the money
/// sits with My Stables until the return window closes.
class PaidScreen extends StatelessWidget {
  const PaidScreen({super.key});
  static const route = '/paid';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.accent2, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 28, color: AppColors.bg),
            ),
            const SizedBox(height: 26),
            Text('Paid · AED 469', style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 10),
            Text(
                'Card ending 8842. Both sellers have been told and the yard knows a delivery is coming.',
                style: AppText.body(17, height: 1.55, color: AppColors.ink(0.7))),
            const SizedBox(height: 28),
            Text('Arriving separately'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 4),
            const Hairline(),
            for (final d in ShowsData.paidDeliveries) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 17),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.local_shipping_outlined,
                          size: 21, color: AppColors.accent700),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.seller, style: AppText.heading(18)),
                          const SizedBox(height: 5),
                          Text(d.what,
                              style: AppText.body(14, color: AppColors.ink(0.6))),
                          const SizedBox(height: 5),
                          Text(d.when,
                              style:
                                  AppText.body(14, color: AppColors.accent700)),
                        ],
                      ),
                    ),
                    Text('›', style: AppText.body(19, color: AppColors.ink(0.4))),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What happens now'.toUpperCase(),
                      style: AppText.eyebrow()),
                  const SizedBox(height: 8),
                  Text(
                      'Neither seller has the money yet. It sits with My Stables until the return window closes on 1 September, so if something is wrong you are not chasing anyone.',
                      style: AppText.body(15, height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            AppButton(
              label: l10n.seeReceipt,
              onPressed: () =>
                  Navigator.of(context).pushNamed(ReceiptScreen.route),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.backToMarket,
              variant: AppButtonVariant.secondary,
              minHeight: 52,
              fontSize: 16,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 18),
            Text(
                'Rasil gets a note on the yard board so someone is there to take them in.',
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}
