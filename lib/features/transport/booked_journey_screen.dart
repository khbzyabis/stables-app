import 'package:flutter/material.dart';

import '../../data/transport_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 58 — The booked journey. Lands on the stable's calendar with loading
/// time, gate code, driver, vehicle, insured value and cost. Passports and
/// vaccination cards go to the carrier automatically; health notes do not.
class BookedJourneyScreen extends StatelessWidget {
  const BookedJourneyScreen({super.key});
  static const route = '/transport/booked';

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
            const BackLink(label: 'Saturday'),
            const SizedBox(height: 18),
            Row(
              children: [
                const AppTag('Transport', tone: TagTone.sage),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l10n.onYardSchedule,
                      style: AppText.body(13, color: AppColors.ink(0.55))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Gulf Horse Transport · Saturday',
                style: AppText.heading(30, height: 1.08)),
            const SizedBox(height: 22),
            _stop(
              time: '06:15 · loading at Serc',
              detail: 'Rasil has them ready from 05:45. Gate code 4417.',
              done: true,
              isLast: false,
            ),
            _stop(
              time: '07:15 · Al Qudra Arena',
              detail: 'Fifteen minutes before your collecting ring time.',
              done: false,
              isLast: true,
            ),
            const SizedBox(height: 20),
            const Hairline(),
            for (final f in TransportData.journeyFacts) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 112,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.callDriver,
                    minHeight: 54,
                    fontSize: 16,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                AppButton(
                  label: l10n.messageLabel,
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 54,
                  fontSize: 16,
                  onPressed: () {},
                ),
              ],
            ),
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
                  Text(l10n.sentWithBooking.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.ink(0.5))),
                  const SizedBox(height: 7),
                  Text(
                    'Passports and vaccination cards for both horses went to Gulf Horse Transport automatically. They cannot see health notes or training records.',
                    style: AppText.body(15, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(l10n.addReturnJourney,
                style: AppText.body(16, color: AppColors.accent700)),
            const SizedBox(height: 12),
            Text(l10n.cancelFree,
                style: AppText.body(15, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }

  Widget _stop({
    required String time,
    required String detail,
    required bool done,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12, height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.accent2 : AppColors.accent,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.divider)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: AppText.heading(20, height: 1.2)),
                  const SizedBox(height: 5),
                  Text(detail,
                      style: AppText.body(15, height: 1.5, color: AppColors.ink(0.6))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
