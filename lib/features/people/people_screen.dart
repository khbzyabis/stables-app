import 'package:flutter/material.dart';

import '../../data/people_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'invite_screen.dart';
import 'roles_screen.dart';

/// Screen 14 — People and roles. Tap someone to change their role or remove
/// them. Role is per membership.
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});
  static const route = '/people';

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  int? _open;
  final _roleOf = <String, String>{};

  TagTone _tone(String role) => switch (role) {
        'Admin' => TagTone.accent,
        'Trainer' || 'Manager' => TagTone.sage,
        _ => TagTone.neutral,
      };

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
            Text(l10n.people, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.peopleIntro,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            const Hairline(),
            for (var i = 0; i < PeopleData.members.length; i++) ...[
              _MemberRow(
                member: PeopleData.members[i],
                role: _roleOf[PeopleData.members[i].name] ??
                    PeopleData.members[i].role,
                open: _open == i,
                tone: _tone,
                onTap: () => setState(() => _open = _open == i ? null : i),
                onPickRole: (r) => setState(
                    () => _roleOf[PeopleData.members[i].name] = r),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(InviteScreen.route),
              child: Text('+ ${l10n.inviteSomeone}',
                  style: AppText.heading(17, color: AppColors.accent700)),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(RolesScreen.route),
              child: Text(l10n.whatEachRole,
                  style: AppText.body(16, color: AppColors.ink(0.6))),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.role,
    required this.open,
    required this.tone,
    required this.onTap,
    required this.onPickRole,
  });
  final Member member;
  final String role;
  final bool open;
  final TagTone Function(String) tone;
  final VoidCallback onTap;
  final ValueChanged<String> onPickRole;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: AppColors.accent2300, shape: BoxShape.circle),
                  child: Text(member.initial,
                      style: AppText.heading(17, color: AppColors.accent2900)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: AppText.heading(18, height: 1.2)),
                      const SizedBox(height: 3),
                      Text(member.meta,
                          style: AppText.body(14, color: AppColors.ink(0.55))),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppTag(role, tone: tone(role)),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.roleInThisStable.toUpperCase(), style: AppText.eyebrow()),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in PeopleData.roles)
                      GestureDetector(
                        onTap: () => onPickRole(r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: r == role ? AppColors.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: r == role ? AppColors.accent : AppColors.divider),
                          ),
                          child: Text(r,
                              style: AppText.body(15,
                                  color: r == role ? AppColors.bg : AppColors.text)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(l10n.removeFromStable,
                    style: AppText.body(15, color: AppColors.accent700)),
              ],
            ),
          ),
      ],
    );
  }
}
