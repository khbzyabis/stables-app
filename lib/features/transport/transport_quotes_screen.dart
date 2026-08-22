import 'package:flutter/material.dart';

import '../../data/transport_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transport.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'booked_journey_screen.dart';

/// Screen 57 — Transport quotes. Vehicle, insured value and loading time sit
/// under each price; the cheapest is insured to a fraction of the dearest, so
/// the screen says to read that line before the price.
class TransportQuotesScreen extends StatefulWidget {
  const TransportQuotesScreen({super.key});
  static const route = '/transport/quotes';

  @override
  State<TransportQuotesScreen> createState() => _TransportQuotesScreenState();
}

class _TransportQuotesScreenState extends State<TransportQuotesScreen> {
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
            const BackLink(label: 'Request'),
            const SizedBox(height: 20),
            Text('Serc to Al Qudra Arena',
                style: AppText.heading(30, height: 1.08)),
            const SizedBox(height: 8),
            Text('Two horses · Saturday, there by 07:30 · 14 km',
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            for (final q in TransportData.quotes) ...[
              _QuoteCard(quote: q, acceptLabel: l10n.acceptQuote, askLabel: l10n.askQuestion),
              const Hairline(),
            ],
            const SizedBox(height: 22),
            Text(TransportData.footnote,
                style: AppText.body(15, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard(
      {required this.quote, required this.acceptLabel, required this.askLabel});
  final TransportQuote quote;
  final String acceptLabel;
  final String askLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    Text(quote.name, style: AppText.heading(19, height: 1.2)),
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
                  Text(quote.price, style: AppText.heading(19)),
                  const SizedBox(height: 4),
                  Text(quote.expires,
                      style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final f in quote.facts)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(f.label,
                        style: AppText.body(14, color: AppColors.ink(0.5))),
                  ),
                  Expanded(
                    child: Text(f.value,
                        style: AppText.body(15, height: 1.4)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(BookedJourneyScreen.route),
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
              Text(askLabel, style: AppText.body(15, color: AppColors.ink(0.55))),
            ],
          ),
        ],
      ),
    );
  }
}
