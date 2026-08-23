import 'package:flutter/material.dart';

import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/step_progress.dart';
import 'back_link.dart';
import 'sign_in_screen.dart';

/// Screen 04 — Confirm your email. After sign-up Supabase sends a confirmation
/// link; the person opens it, then comes back and signs in.
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static const route = '/verify';

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool _resending = false;

  @override
  Widget build(BuildContext context) {
    final email =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'your email';
    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackLink(label: 'Back'),
          const SizedBox(height: 28),
          Text('Check your email', style: AppText.heading(42, height: 1)),
          const SizedBox(height: 14),
          Text(
            'We sent a confirmation link to $email. Open it to confirm your '
            'account, then come back and sign in.',
            style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65)),
          ),
          const SizedBox(height: 38),
          const StepProgress(total: 3, current: 2),
          const SizedBox(height: 44),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: AppColors.accent200, shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      size: 22, color: AppColors.accent700),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'The link opens in your browser and confirms this email. '
                    'It can take a minute to arrive — check spam too.',
                    style: AppText.body(14,
                        height: 1.45, color: AppColors.ink(0.6)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          AppButton(
            label: 'I have confirmed — sign in',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              SignInScreen.route,
              (r) => false,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: _resending
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _resending = true);
                      try {
                        await SupabaseService.resendConfirmation(email);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Confirmation resent.')),
                        );
                      } catch (_) {
                      } finally {
                        if (mounted) setState(() => _resending = false);
                      }
                    },
              child: Text(
                _resending ? 'Resending…' : 'Resend the email',
                style: AppText.body(15, color: AppColors.accent700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
