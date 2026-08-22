import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/step_progress.dart';
import 'back_link.dart';
import 'create_stable_screen.dart';

/// Screen 04 — Verify. Six-digit SMS code, one box per digit, resend
/// countdown. Digits, times and money stay left-to-right even in RTL.
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static const route = '/verify';

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  // Prototype shows "417" entered with the cursor on the 4th box.
  final _digits = ['4', '1', '7', '', '', ''];
  final _activeIndex = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    const phone = '+971 50 123 4567';
    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackLink(label: l10n.back),
          const SizedBox(height: 28),
          Text(l10n.checkYourPhone, style: AppText.heading(42, height: 1)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              l10n.codeSentTo(phone),
              style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65)),
            ),
          ),
          const SizedBox(height: 38),
          const StepProgress(total: 3, current: 2),
          const SizedBox(height: 52),
          // Digits box row — always LTR.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                for (var i = 0; i < 6; i++) ...[
                  Expanded(
                    child: _DigitBox(
                      value: _digits[i],
                      active: i == _activeIndex,
                    ),
                  ),
                  if (i != 5) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.resendIn('0:42'),
              style: AppText.body(15, color: AppColors.accent700),
            ),
          ),
          const SizedBox(height: 40),
          AppButton(
            label: l10n.verify,
            onPressed: () =>
                Navigator.of(context).pushNamed(CreateStableScreen.route),
          ),
        ],
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({required this.value, required this.active});
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(22),
          border: active
              ? Border.all(color: AppColors.accent, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: active && value.isEmpty
            ? Container(width: 2, height: 30, color: AppColors.accent)
            : Text(
                value,
                style: AppText.heading(30),
              ),
      ),
    );
  }
}
