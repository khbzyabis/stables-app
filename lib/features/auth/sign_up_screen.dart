import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/step_progress.dart';
import 'back_link.dart';
import 'verify_screen.dart';

/// Screen 03 — Sign up. Name, email, UAE phone, password. Three-step progress
/// bar. Terms and privacy are tappable links.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const route = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController(text: 'Ahmad');
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackLink(label: l10n.back),
          const SizedBox(height: 28),
          Text(l10n.yourDetails, style: AppText.heading(42, height: 1)),
          const SizedBox(height: 12),
          Text(l10n.step1of3,
              style: AppText.body(17, color: AppColors.ink(0.65))),
          const SizedBox(height: 38),
          const StepProgress(total: 3, current: 1),
          const SizedBox(height: 38),
          AppField(label: l10n.fullName, controller: _name),
          const SizedBox(height: 24),
          AppField(
            label: l10n.email,
            controller: _email,
            hintText: l10n.emailHint,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          AppField(
            label: l10n.phone,
            controller: _phone,
            hintText: l10n.phoneHint,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          AppField(
            label: l10n.password,
            controller: _password,
            hintText: l10n.passwordHint,
            obscureText: true,
          ),
          const SizedBox(height: 40),
          AppButton(
            label: l10n.sendMeCode,
            onPressed: () =>
                Navigator.of(context).pushNamed(VerifyScreen.route),
          ),
          const SizedBox(height: 18),
          _TermsNotice(l10n: l10n),
        ],
      ),
    );
  }
}

class _TermsNotice extends StatelessWidget {
  const _TermsNotice({required this.l10n});
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final link = AppText.body(13, height: 1.6, color: AppColors.accent700);
    final base = AppText.body(13, height: 1.6, color: AppColors.ink(0.65));
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: l10n.termsPrefix),
          TextSpan(text: l10n.termsOfUse, style: link),
          TextSpan(text: l10n.termsAnd),
          TextSpan(text: l10n.privacyNotice, style: link),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
