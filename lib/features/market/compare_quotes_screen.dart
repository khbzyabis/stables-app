import 'package:flutter/material.dart';

import '../../data/orders_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/orders.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 53 — Compare quotes. Ranges, not figures; different expiry dates.
/// Accepting one books the slot and lapses the others.
class CompareQuotesScreen extends StatefulWidget {
  const CompareQuotesScreen({super.key});
  static const route = '/market/quotes';

  @override
  State<CompareQuotesScreen> createState() => _CompareQuotesScreenState();
}

class _CompareQuotesScreenState extends State<CompareQuotesScreen> {
  String? _accepted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final quotes = OrdersData.quotes;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: l10n.askForPrice),
            const SizedBox(height: 22),
            Text('Front shoes, two horses',
                style: AppText.heading(32, height: 1.05)),
            const SizedBox(height: 8),
            Text(l10n.askedFarriers,
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 26),
            const Hairline(),
            for (final q in quotes) ...[
              _QuoteCard(
                quote: q,
                accepted: _accepted == q.id,
                lapsed: _accepted != null && _accepted != q.id,
                onAccept: () => setState(() => _accepted = q.id),
                acceptLabel: l10n.acceptQuote,
                bookedLabel: l10n.quoteBooked,
                declineLabel: l10n.notThisTime,
              ),
              const Hairline(),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.accepted,
    required this.lapsed,
    required this.onAccept,
    required this.acceptLabel,
    required this.bookedLabel,
    required this.declineLabel,
  });
  final Quote quote;
  final bool accepted;
  final bool lapsed;
  final VoidCallback onAccept;
  final String acceptLabel;
  final String bookedLabel;
  final String declineLabel;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: lapsed ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
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
                      Text(quote.name, style: AppText.heading(20, height: 1.2)),
                      const SizedBox(height: 5),
                      Text(quote.meta,
                          style: AppText.body(14, color: AppColors.ink(0.55))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(quote.range, style: AppText.heading(19)),
                    const SizedBox(height: 4),
                    Text(quote.expires,
                        style: AppText.body(13, color: AppColors.ink(0.5))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(quote.note,
                style: AppText.body(15, height: 1.55, color: AppColors.ink(0.75))),
            const SizedBox(height: 14),
            if (accepted)
              Text(bookedLabel,
                  style: AppText.heading(15, color: AppColors.accent2700))
            else
              Row(
                children: [
                  GestureDetector(
                    onTap: lapsed ? null : onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(acceptLabel,
                          style: AppText.heading(15, color: AppColors.bg)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(declineLabel,
                      style: AppText.body(15, color: AppColors.ink(0.5))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
