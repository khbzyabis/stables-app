import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 15 — Role permissions. A plain-language legend of what each of the
/// five roles can do. Owners and managers assign roles from the People screen.
class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});
  static const route = '/people/roles';

  static const _roles = <(String, String, TagTone, String)>[
    (
      'Owner',
      'Full control',
      TagTone.accent,
      'Everything — invites, roles, stable settings, feature toggles, and '
          'closing the stable.',
    ),
    (
      'Manager',
      'Runs the day to day',
      TagTone.sage,
      'Manages people, horses, schedule, tasks and approvals. Cannot close the '
          'stable or remove an owner.',
    ),
    (
      'Vet',
      'Health',
      TagTone.sage,
      'Reads every horse and keeps the health record. Sees the schedule and '
          'noticeboard.',
    ),
    (
      'Groom',
      'Daily care',
      TagTone.neutral,
      'Daily care notes and tasks for every horse. No admin screens.',
    ),
    (
      'Rider',
      'Their horses',
      TagTone.neutral,
      'Rides and logs training for the horses they’re assigned. Reads the '
          'schedule and noticeboard.',
    ),
    (
      'Viewer',
      'Read only',
      TagTone.neutral,
      'Reads horses, the schedule and the noticeboard. Makes no changes.',
    ),
  ];

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
            BackLink(label: l10n.people),
            const SizedBox(height: 24),
            Text(l10n.roles, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(
                'Five roles, lightest to fullest access. Owners and managers set '
                "each person's role on the People screen.",
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            const Hairline(),
            for (final (title, tag, tone, body) in _roles) ...[
              _RoleBlock(title: title, tag: tag, tone: tone, body: body),
              const Hairline(),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleBlock extends StatelessWidget {
  const _RoleBlock(
      {required this.title, required this.body, this.tag, this.tone});
  final String title;
  final String body;
  final String? tag;
  final TagTone? tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppText.heading(21)),
              if (tag != null) ...[
                const SizedBox(width: 10),
                AppTag(tag!, tone: tone ?? TagTone.neutral),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: AppText.body(16, height: 1.5, color: AppColors.ink(0.7))),
        ],
      ),
    );
  }
}
