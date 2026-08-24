import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 11 — Approvals. When a stable requires approval, people who redeem an
/// invite land here as "pending" until an owner or manager lets them in.
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});
  static const route = '/approvals';

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late final Future<List<Map<String, dynamic>>> _future = _load();
  final _decided = <String, bool>{}; // membership_id → approved?
  final _busy = <String>{};

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.pendingMembers(id);
  }

  Future<void> _decide(Map<String, dynamic> member, bool approve) async {
    final id = member['membership_id'] as String;
    setState(() => _busy.add(id));
    try {
      if (approve) {
        await SupabaseService.approveMember(id);
      } else {
        await SupabaseService.removeMember(id);
      }
      if (mounted) setState(() => _decided[id] = approve);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't update: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
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
            Text(l10n.needsYou, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.nothingJoins,
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
                final pending = snap.data ?? const [];
                if (pending.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text(
                      "Nobody's waiting. When approval is required, new joiners "
                      'appear here for you to let in.',
                      style: AppText.body(16,
                          height: 1.5, color: AppColors.ink(0.6)),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final m in pending) ...[
                      _RequestRow(
                        member: m,
                        decided: _decided[m['membership_id']],
                        busy: _busy.contains(m['membership_id']),
                        onApprove: () => _decide(m, true),
                        onDecline: () => _decide(m, false),
                      ),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Approval is set per stable — turn it on under Stable settings. '
              'With it off, invited people join straight away.',
              style: AppText.body(15, height: 1.5, color: AppColors.ink(0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.member,
    required this.decided,
    required this.busy,
    required this.onApprove,
    required this.onDecline,
  });
  final Map<String, dynamic> member;
  final bool? decided;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final name = (member['name'] as String?) ?? 'Someone';
    final email = member['email'] as String?;
    final role = (member['role'] as String?) ?? 'groom';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wants to join · $role',
              style: AppText.body(13, color: AppColors.accent700)),
          const SizedBox(height: 6),
          Text(name, style: AppText.heading(21, height: 1.25)),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(email, style: AppText.body(15, color: AppColors.ink(0.6))),
          ],
          const SizedBox(height: 16),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4)),
            )
          else if (decided == null)
            Row(
              children: [
                AppButton(
                  label: l10n.approve,
                  block: false,
                  minHeight: 46,
                  fontSize: 16,
                  onPressed: onApprove,
                ),
                const SizedBox(width: 10),
                AppButton(
                  label: l10n.decline,
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 46,
                  fontSize: 16,
                  onPressed: onDecline,
                ),
              ],
            )
          else
            AppTag(decided! ? l10n.approved : l10n.declined,
                tone: decided! ? TagTone.sage : TagTone.neutral),
        ],
      ),
    );
  }
}
