import 'package:flutter/material.dart';

import '../../data/payments_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';

/// Screen 66 — Declined card. Nothing taken, basket intact, items held two
/// hours, and nobody at the yard was told.
class DeclinedScreen extends StatelessWidget {
  const DeclinedScreen({super.key});
  static const route = '/market/declined';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.priority_high,
                  color: AppColors.accent800, size: 27),
            ),
            const SizedBox(height: 24),
            Text(l10n.cardDeclined, style: AppText.heading(32, height: 1.08)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(l10n.cardDeclinedBody,
                  style: AppText.body(17, height: 1.6, color: AppColors.ink(0.7))),
            ),
            const SizedBox(height: 26),
            const Hairline(),
            for (final f in PaymentsData.failedFacts) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 126,
                      child: Text(f.label,
                          style: AppText.body(15, color: AppColors.ink(0.55))),
                    ),
                    Expanded(
                      child: Text(f.value, style: AppText.body(16, height: 1.45)),
                    ),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            AppButton(
              label: l10n.tryAnotherCard,
              minHeight: 56,
              fontSize: 17,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.backToBasket,
              variant: AppButtonVariant.secondary,
              minHeight: 52,
              fontSize: 16,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(l10n.declinedHeld, style: AppText.body(15, height: 1.6)),
            ),
            const SizedBox(height: 20),
            Text(l10n.nobodyTold,
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}
