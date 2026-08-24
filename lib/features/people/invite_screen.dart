import 'dart:math';

import 'package:flutter/material.dart';
import '../../data/errors.dart';
import 'package:flutter/services.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 09 — Invite people. Pick the role, generate a real code tied to this
/// stable, and share it. Whoever enters it joins with that role.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  static const route = '/invite';

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  String _role = 'groom';
  String? _code;
  bool _busy = false;

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _makeCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    final s = List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
    return 'BRAM-$s'.substring(0, 9); // e.g. BRAM-4RT9
  }

  Future<void> _generate() async {
    final stableId = SessionScope.of(context).activeStableId;
    final messenger = ScaffoldMessenger.of(context);
    if (stableId == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Create a stable first.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final code = _makeCode();
      await SupabaseService.createInvite(
          stableId: stableId, role: _role, code: code);
      setState(() => _code = code);
    } catch (e) {
      AppErrors.report(e);
      messenger.showSnackBar(SnackBar(content: Text('Could not create: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
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
            Text(l10n.inviteToStable, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.roleTravels,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 30),
            Text('Role'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in SupabaseService.invitableRoles)
                  GestureDetector(
                    onTap: () => setState(() {
                      _role = r;
                      _code = null; // a new role needs a new code
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: r == _role ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                            color:
                                r == _role ? AppColors.accent : AppColors.divider),
                      ),
                      child: Text(_cap(r),
                          style: AppText.body(14,
                              color: r == _role ? AppColors.bg : AppColors.text)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            if (_code == null) ...[
              AppButton(
                label: _busy ? 'Creating…' : 'Create invite code',
                onPressed: _busy ? null : _generate,
              ),
              const SizedBox(height: 14),
              Text(
                'The code carries the ${_cap(_role)} role. Share it with the person you '
                'want to join — they enter it when they sign in.',
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.6)),
              ),
            ] else ...[
              Text('Share this code'.toUpperCase(), style: AppText.eyebrow()),
              const SizedBox(height: 12),
              _CodeCard(code: _code!, role: _role),
              const SizedBox(height: 16),
              _ShareRow(
                title: 'Invite link',
                subtitle: 'mystables.ae/j/${_code!.toLowerCase()}',
                onCopy: () {
                  Clipboard.setData(ClipboardData(
                      text: 'https://mystables.ae/j/${_code!.toLowerCase()}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied.')));
                },
              ),
              const Hairline(),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _code = null),
                child: Text('Create another',
                    style: AppText.body(16, color: AppColors.accent700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.role});
  final String code;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.accent2200,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$role invite'.toUpperCase(),
              style: AppText.eyebrow(color: AppColors.accent2800)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: AppText.heading(30, letterSpacing: 2)),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied.')));
                },
                child: Text('Copy',
                    style: AppText.body(16, color: AppColors.accent700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow(
      {required this.title, required this.subtitle, required this.onCopy});
  final String title;
  final String subtitle;
  final VoidCallback onCopy;

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
          GestureDetector(
            onTap: onCopy,
            child: Text('Copy',
                style: AppText.body(16, color: AppColors.accent700)),
          ),
        ],
      ),
    );
  }
}
