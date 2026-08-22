import 'package:flutter/material.dart';

import '../../data/people_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 09 — Invite people. Pick the role first; the role travels with the
/// invite. Share by link, QR, or six-character code.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  static const route = '/invite';

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  String _role = 'Rider';

  String get _code {
    // A tiny per-role code, echoing the prototype's BRAM-4R style.
    const map = {'Admin': '1A', 'Manager': '2M', 'Trainer': '3T', 'Groom': '4G', 'Owner': '5O', 'Rider': '4R'};
    return 'BRAM-${map[_role] ?? '4R'}';
  }

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
            const BackLink(label: 'Serc'),
            const SizedBox(height: 24),
            Text(l10n.inviteToStable, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.roleTravels,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 30),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in PeopleData.roles)
                  GestureDetector(
                    onTap: () => setState(() => _role = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: r == _role ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                            color: r == _role ? AppColors.accent : AppColors.divider),
                      ),
                      child: Text(r,
                          style: AppText.body(14,
                              color: r == _role ? AppColors.bg : AppColors.text)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            Text(l10n.shareAs.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 8),
            _ShareRow(
              title: l10n.inviteLink,
              subtitle: 'mystables.ae/j/${_code.toLowerCase()}',
              trailing: Text(l10n.copy,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
            const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 78, height: 78,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('QR',
                        style: AppText.body(10,
                            color: AppColors.neutral700, letterSpacing: 0.6)),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.scanAtStable, style: AppText.heading(17)),
                        const SizedBox(height: 3),
                        Text('Good for people standing in front of you.',
                            style: AppText.body(15, color: AppColors.ink(0.55))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.sixCharCode, style: AppText.heading(17)),
                  const SizedBox(height: 4),
                  Text(_code, style: AppText.body(19, letterSpacing: 3)),
                ],
              ),
            ),
            const Hairline(),
            const SizedBox(height: 30),
            Text(l10n.waitingOnThem.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 8),
            _PendingRow(who: 'layal@serc.ae', meta: 'Rider · sent yesterday', pending: l10n.pending),
            const Hairline(),
            _PendingRow(who: 'Toni', meta: 'Trainer · sent today', pending: l10n.pending),
          ],
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow(
      {required this.title, required this.subtitle, required this.trailing});
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading(17)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: AppText.body(15, color: AppColors.ink(0.55)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow(
      {required this.who, required this.meta, required this.pending});
  final String who;
  final String meta;
  final String pending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(who, style: AppText.body(16)),
                const SizedBox(height: 3),
                Text(meta, style: AppText.body(14, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppTag(pending, tone: TagTone.neutral),
        ],
      ),
    );
  }
}
