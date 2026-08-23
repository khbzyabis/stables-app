import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'invite_screen.dart';
import 'roles_screen.dart';

/// Screen 14 — People and roles. The real members of the active stable, each
/// with the role their membership carries.
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});
  static const route = '/people';

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.members(id);
  }

  TagTone _tone(String role) => switch (role) {
        'Admin' => TagTone.accent,
        'Trainer' || 'Manager' => TagTone.sage,
        _ => TagTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = SessionScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: session.activeStableName),
            const SizedBox(height: 24),
            Text(l10n.people, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text('Everyone in ${session.activeStableName}. Invite more with a code below.',
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            const Hairline(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final members = snap.data ?? const [];
                if (members.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No members yet.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  );
                }
                return Column(
                  children: [
                    for (final m in members) ...[
                      _MemberRow(
                        name: (m['name'] as String?) ?? 'Member',
                        role: (m['role'] as String?) ?? 'Member',
                        isMe: m['is_me'] == true,
                        tone: _tone,
                      ),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(InviteScreen.route);
                setState(() => _future = _load());
              },
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
    required this.name,
    required this.role,
    required this.isMe,
    required this.tone,
  });
  final String name;
  final String role;
  final bool isMe;
  final TagTone Function(String) tone;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.accent2300, shape: BoxShape.circle),
            child: Text(initial,
                style: AppText.heading(17, color: AppColors.accent2900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(isMe ? '$name (you)' : name,
                style: AppText.heading(18, height: 1.2)),
          ),
          const SizedBox(width: 10),
          AppTag(role, tone: tone(role)),
        ],
      ),
    );
  }
}
