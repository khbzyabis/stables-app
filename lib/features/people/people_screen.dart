import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'approvals_screen.dart';
import 'invite_screen.dart';
import 'roles_screen.dart';

/// Screen 14 — People and roles. The real members of the active stable, each
/// with the role their membership carries. Owners and managers can tap a member
/// to change their role or remove them.
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

  void _reload() => setState(() => _future = _load());

  bool get _isAdmin {
    final role = SessionScope.of(context).activeStable?['role'] as String?;
    return role == 'owner' || role == 'manager';
  }

  static TagTone _tone(String role) => switch (role.toLowerCase()) {
        'owner' => TagTone.accent,
        'manager' || 'vet' => TagTone.sage,
        _ => TagTone.neutral,
      };

  Future<void> _editMember(Map<String, dynamic> member) async {
    final result = await showModalBottomSheet<_MemberAction>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _RoleSheet(member: member),
    );
    if (result == null) return;
    try {
      if (result.remove) {
        await SupabaseService.removeMember(member['membership_id'] as String);
      } else if (result.role != null) {
        await SupabaseService.updateMemberRole(
            member['membership_id'] as String, result.role!);
      }
      _reload();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't update: $e")));
      }
    }
  }

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
            Text(
                _isAdmin
                    ? 'Everyone in ${session.activeStableName}. Tap a member to change their role.'
                    : 'Everyone in ${session.activeStableName}.',
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
                final all = snap.data ?? const [];
                final active =
                    all.where((m) => m['status'] != 'pending').toList();
                final pending = all.length - active.length;
                if (active.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No members yet.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  );
                }
                return Column(
                  children: [
                    for (final m in active) ...[
                      _MemberRow(
                        member: m,
                        canEdit: _isAdmin && m['is_me'] != true,
                        onTap: () => _editMember(m),
                      ),
                      const Hairline(),
                    ],
                    if (pending > 0) ...[
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context)
                              .pushNamed(ApprovalsScreen.route);
                          _reload();
                        },
                        child: Text(
                          '$pending waiting to join — review',
                          style: AppText.heading(16, color: AppColors.accent700),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(InviteScreen.route);
                _reload();
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
  const _MemberRow(
      {required this.member, required this.canEdit, required this.onTap});
  final Map<String, dynamic> member;
  final bool canEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = (member['name'] as String?) ?? 'Member';
    final role = (member['role'] as String?) ?? 'member';
    final isMe = member['is_me'] == true;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return InkWell(
      onTap: canEdit ? onTap : null,
      child: Padding(
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
            AppTag(_cap(role), tone: _PeopleScreenState._tone(role)),
            if (canEdit) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: AppColors.ink(0.4), size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

String _cap(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

class _MemberAction {
  const _MemberAction({this.role, this.remove = false});
  final String? role;
  final bool remove;
}

class _RoleSheet extends StatelessWidget {
  const _RoleSheet({required this.member});
  final Map<String, dynamic> member;

  @override
  Widget build(BuildContext context) {
    final name = (member['name'] as String?) ?? 'Member';
    final current = (member['role'] as String?) ?? 'groom';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppText.heading(24, height: 1.1)),
            const SizedBox(height: 4),
            Text('Set their role in this stable',
                style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 16),
            for (final role in SupabaseService.roles)
              InkWell(
                onTap: () =>
                    Navigator.of(context).pop(_MemberAction(role: role)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(_cap(role),
                              style: AppText.heading(18,
                                  weight: role == current
                                      ? FontWeight.w700
                                      : FontWeight.w500))),
                      if (role == current)
                        const Icon(Icons.check,
                            color: AppColors.accent2600, size: 22),
                    ],
                  ),
                ),
              ),
            const Hairline(),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(const _MemberAction(remove: true)),
              child: Text('Remove from stable',
                  style: AppText.heading(17, color: AppColors.accent700)),
            ),
          ],
        ),
      ),
    );
  }
}
