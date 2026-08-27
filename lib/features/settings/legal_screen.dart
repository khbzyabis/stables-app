import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../auth/back_link.dart';

/// Terms of Use and Privacy Notice. Which one shows is passed as the route
/// argument ('terms' or 'privacy'). Plain, readable, and the same in every
/// door. NOTE: this is a starting draft — have it reviewed by a lawyer for the
/// UAE before you rely on it commercially.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});
  static const route = '/legal';

  @override
  Widget build(BuildContext context) {
    final which =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? 'terms';
    final doc = which == 'privacy' ? _privacy : _terms;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 44),
          children: [
            const BackLink(label: 'Back'),
            const SizedBox(height: 18),
            Text(doc.title, style: AppText.heading(32, height: 1.05)),
            const SizedBox(height: 8),
            Text('Last updated 27 August 2026',
                style: AppText.body(13, color: AppColors.ink(0.5))),
            const SizedBox(height: 24),
            for (final s in doc.sections) ...[
              Text(s.$1, style: AppText.heading(18)),
              const SizedBox(height: 8),
              Text(s.$2,
                  style:
                      AppText.body(15.5, height: 1.6, color: AppColors.ink(0.8))),
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _Doc {
  const _Doc(this.title, this.sections);
  final String title;
  final List<(String, String)> sections;
}

const _terms = _Doc('Terms of Use', [
  (
    'Who we are',
    'My Stables is an equestrian stable-management app and marketplace operated '
        'in the United Arab Emirates. By creating an account or using the app you '
        'agree to these Terms.'
  ),
  (
    'Your account',
    'You are responsible for keeping your login details safe and for everything '
        'that happens under your account. Give us accurate information, and keep '
        'it up to date. You must be old enough to enter a binding contract.'
  ),
  (
    'Using the app',
    'Use My Stables only for lawful stable management and trade. Do not misuse '
        'the service, attempt to disrupt it, or upload content you do not have '
        'the right to share. We may suspend accounts that break these Terms.'
  ),
  (
    'The marketplace',
    'Sellers list their own products and services and are responsible for them, '
        'including accuracy, quality, pricing and fulfilment. My Stables provides '
        'the platform and payment handling; buyers and sellers contract with each '
        'other for each order.'
  ),
  (
    'Payments and payouts',
    'Buyers pay through the app. Funds for goods are held and released to the '
        'seller after the delivery window, less the platform fee; services and '
        'transport settle when the work is done. Prices shown include applicable '
        'VAT where stated. Disputes are handled through the in-app process.'
  ),
  (
    'Cancellations and refunds',
    'You may cancel an order before a seller accepts it. After that, refunds are '
        'handled case by case through the dispute process, in line with UAE '
        'consumer-protection rules.'
  ),
  (
    'Liability',
    'My Stables is provided "as is". To the extent the law allows, we are not '
        'liable for indirect or consequential loss, or for the acts of sellers '
        'or other users. Nothing here removes rights you have under UAE law.'
  ),
  (
    'Changes and contact',
    'We may update these Terms; we\'ll flag material changes in the app. Reach '
        'us at support@mystables.ae.'
  ),
]);

const _privacy = _Doc('Privacy Notice', [
  (
    'What we collect',
    'Your name, email and phone number; the stables, horses, tasks and notices '
        'you create; orders and quote requests; and basic usage and device '
        'information needed to run and improve the app.'
  ),
  (
    'How we use it',
    'To provide the service — your account, your stable\'s data, the marketplace '
        'and payments — to keep it secure, to support you, and to meet our legal '
        'and tax obligations in the UAE.'
  ),
  (
    'Who sees it',
    'People in your stable see the stable\'s shared data. Sellers see the order '
        'details they need to fulfil your order. We use trusted providers '
        '(hosting, payments, analytics) who process data on our behalf. We do '
        'not sell your personal data.'
  ),
  (
    'Storage and security',
    'Your data is stored with our cloud provider and protected with access '
        'controls and row-level security so people only see data for stables '
        'they belong to. No system is perfectly secure, but we take reasonable '
        'measures to protect it.'
  ),
  (
    'Your choices',
    'You can view and edit your profile and stable data in the app, and ask us '
        'to correct or delete your account. Some records may be kept where the '
        'law requires (for example, tax and transaction records).'
  ),
  (
    'Contact',
    'Questions or requests: privacy@mystables.ae.'
  ),
]);
