import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import '../home/home_screen.dart';
import 'sign_up_screen.dart';
import 'create_stable_screen.dart';

/// Screen 02 — Sign in. Email + password with a Show/Hide reveal, Apple and
/// Google, and an invite-code link. All four auth methods exist.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  static const route = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController(text: 'ahmad@serc.ae');
  final _password = TextEditingController(text: 'hayloft-1994');
  bool _revealed = false;

  // Feature-style flags; both social auth and the invite option are on here.
  static const _showSocialAuth = true;
  static const _showInviteOption = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.route,
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.welcomeBack, style: AppText.heading(42, height: 1)),
          const SizedBox(height: 12),
          Text(
            l10n.signInSubtitle,
            style: AppText.body(17, color: AppColors.ink(0.65)),
          ),
          const SizedBox(height: 48),
          AppField(
            label: l10n.email,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 26),
          AppField(
            label: l10n.password,
            controller: _password,
            obscureText: !_revealed,
            suffix: _RevealButton(
              revealed: _revealed,
              onTap: () => setState(() => _revealed = !_revealed),
              showLabel: l10n.show,
              hideLabel: l10n.hide,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _LinkText(l10n.forgotPassword, onTap: () {}),
          ),
          const SizedBox(height: 40),
          AppButton(label: l10n.signIn, onPressed: _signIn),
          const SizedBox(height: 34),
          _OrDivider(label: l10n.orDivider),
          const SizedBox(height: 26),
          if (_showSocialAuth) ...[
            AppButton(
              label: l10n.continueWithApple,
              variant: AppButtonVariant.secondary,
              minHeight: 54,
              fontSize: 16,
              icon: const Icon(Icons.apple, size: 20),
              onPressed: _signIn,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.continueWithGoogle,
              variant: AppButtonVariant.secondary,
              minHeight: 54,
              fontSize: 16,
              icon: const _GoogleGlyph(),
              onPressed: _signIn,
            ),
          ],
          const SizedBox(height: 40),
          _LinkRich(
            prefix: l10n.newHere,
            emphasis: l10n.createAnAccount,
            onTap: () =>
                Navigator.of(context).pushNamed(SignUpScreen.route),
          ),
          if (_showInviteOption) ...[
            const SizedBox(height: 10),
            _LinkText(
              l10n.haveInviteCode,
              muted: true,
              onTap: () =>
                  Navigator.of(context).pushNamed(CreateStableScreen.route),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevealButton extends StatelessWidget {
  const _RevealButton({
    required this.revealed,
    required this.onTap,
    required this.showLabel,
    required this.hideLabel,
  });

  final bool revealed;
  final VoidCallback onTap;
  final String showLabel;
  final String hideLabel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 40),
      ),
      child: Text(
        revealed ? hideLabel : showLabel,
        style: AppText.body(14, color: AppColors.accent700),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(label, style: AppText.body(13, color: AppColors.ink(0.5))),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.label,
      {required this.onTap, this.muted = false});
  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppText.body(
          muted ? 15 : 15,
          color: muted ? AppColors.ink(0.6) : AppColors.accent700,
        ),
      ),
    );
  }
}

class _LinkRich extends StatelessWidget {
  const _LinkRich({
    required this.prefix,
    required this.emphasis,
    required this.onTap,
  });
  final String prefix;
  final String emphasis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          style: AppText.body(16, color: AppColors.accent700),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: emphasis,
              style: AppText.body(16,
                  weight: FontWeight.w600, color: AppColors.accent700),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple monochrome Google glyph matching the prototype's stroked mark.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.public, size: 18);
  }
}
