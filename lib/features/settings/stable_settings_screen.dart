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
import 'set_location_screen.dart';
import 'stable_language_screen.dart';

enum _LeaveState { idle, asking, left }

/// Screen 36 — a stable's settings. Shows the real stable, lets owners and
/// managers turn modules on/off for everyone, and lets anyone leave.
class StableSettingsScreen extends StatefulWidget {
  const StableSettingsScreen({super.key});
  static const route = '/stable-settings';

  @override
  State<StableSettingsScreen> createState() => _StableSettingsScreenState();
}

class _StableSettingsScreenState extends State<StableSettingsScreen> {
  _LeaveState _leave = _LeaveState.idle;
  late final Future<Map<String, bool>> _features = _loadFeatures();
  Map<String, bool> _current = const {};
  bool _leaving = false;

  bool get _isAdmin {
    final role = SessionScope.of(context).activeStable?['role'] as String?;
    return role == 'owner' || role == 'manager';
  }

  Future<Map<String, bool>> _loadFeatures() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const {};
    final f = await SupabaseService.stableFeatures(id);
    _current = Map.of(f);
    return f;
  }

  Future<void> _toggle(String key, bool value) async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return;
    setState(() => _current = {..._current, key: value});
    try {
      await SupabaseService.setStableFeature(id, key, value);
    } catch (e) {
      AppErrors.report(e);
      setState(() => _current = {..._current, key: !value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Couldn't save that toggle: $e")));
      }
    }
  }

  Future<void> _doLeave() async {
    final session = SessionScope.of(context);
    final id = session.activeStableId;
    if (id == null) return;
    setState(() => _leaving = true);
    try {
      final members = await SupabaseService.members(id);
      final me = members.firstWhere((m) => m['is_me'] == true,
          orElse: () => const {});
      final membershipId = me['membership_id'] as String?;
      if (membershipId != null) {
        await SupabaseService.removeMember(membershipId);
      }
      await session.refresh();
      if (mounted) setState(() => _leave = _LeaveState.left);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't leave: $e")));
        setState(() => _leave = _LeaveState.idle);
      }
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = SessionScope.of(context);
    final name = session.activeStableName;
    final city = session.activeStable?['city'] as String?;
    final role = (session.activeStable?['role'] as String?) ?? 'member';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
          children: [
            const BackLink(label: 'My stables'),
            const SizedBox(height: 20),
            Text(name, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text(
                [
                  if ((city ?? '').isNotEmpty) city!,
                  'you are ${_article(role)} $role',
                ].join(' · '),
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 28),

            // ---- Modules (feature toggles) ----
            Text('MODULES', style: AppText.eyebrow()),
            const SizedBox(height: 6),
            Text(
                _isAdmin
                    ? 'Turn features on or off for everyone in this stable.'
                    : 'Which features this stable uses. Only owners and managers can change these.',
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 14),
            FutureBuilder<Map<String, bool>>(
              future: _features,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  children: [
                    const Hairline(),
                    _ToggleRow(
                      title: 'Marketplace',
                      subtitle: 'Browse and order feed, tack and supplies',
                      value: _current['market'] ?? true,
                      enabled: _isAdmin,
                      onChanged: (v) => _toggle('market', v),
                    ),
                    const Hairline(),
                    _ToggleRow(
                      title: 'Transport',
                      subtitle: 'Request and compare horse transport quotes',
                      value: _current['transport'] ?? true,
                      enabled: _isAdmin,
                      onChanged: (v) => _toggle('transport', v),
                    ),
                    const Hairline(),
                    _ToggleRow(
                      title: 'Shows',
                      subtitle: 'Entries, start lists and results',
                      value: _current['shows'] ?? true,
                      enabled: _isAdmin,
                      onChanged: (v) => _toggle('shows', v),
                    ),
                    const Hairline(),
                    _ToggleRow(
                      title: 'Require approval to join',
                      subtitle: 'New joiners wait until an admin lets them in',
                      value: _current['require_approval'] ?? false,
                      enabled: _isAdmin,
                      onChanged: (v) => _toggle('require_approval', v),
                    ),
                    const Hairline(),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // ---- Other settings ----
            Text('STABLE', style: AppText.eyebrow()),
            const SizedBox(height: 8),
            const Hairline(),
            _LinkRow(
              label: 'Location',
              meta: (city ?? '').isNotEmpty ? city! : 'Set where the stable is',
              onTap: () => Navigator.of(context).pushNamed(SetLocationScreen.route),
            ),
            const Hairline(),
            _LinkRow(
              label: 'Stable language',
              meta: 'The default language for everyone',
              onTap: () =>
                  Navigator.of(context).pushNamed(StableLanguageScreen.route),
            ),
            const Hairline(),
            const SizedBox(height: 30),
            _buildLeave(context, l10n, name),
          ],
        ),
      ),
    );
  }

  String _article(String role) =>
      'aeiou'.contains(role.isEmpty ? 'x' : role[0].toLowerCase()) ? 'an' : 'a';

  Widget _buildLeave(BuildContext context, AppL10n l10n, String name) {
    switch (_leave) {
      case _LeaveState.idle:
        return GestureDetector(
          onTap: () => setState(() => _leave = _LeaveState.asking),
          child: Text(l10n.leaveStable,
              style: AppText.body(16, color: AppColors.accent700)),
        );
      case _LeaveState.asking:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leave $name?', style: AppText.heading(22)),
            const SizedBox(height: 10),
            Text(
                'You will no longer see this stable or its horses. Records you '
                'added stay in the stable. You can be invited back any time.',
                style: AppText.body(16, height: 1.55)),
            const SizedBox(height: 18),
            if (_leaving)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  AppButton(
                    label: l10n.leave,
                    block: false,
                    minHeight: 50,
                    fontSize: 16,
                    onPressed: _doLeave,
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: l10n.stay,
                    variant: AppButtonVariant.secondary,
                    block: false,
                    minHeight: 50,
                    fontSize: 16,
                    onPressed: () => setState(() => _leave = _LeaveState.idle),
                  ),
                ],
              ),
          ],
        );
      case _LeaveState.left:
        return Row(
          children: [
            AppTag(l10n.youHaveLeft, tone: TagTone.neutral),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Text(l10n.backToMyStables,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
          ],
        );
    }
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading(18, height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppText.body(14, color: AppColors.ink(0.6))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.bg,
            activeTrackColor: AppColors.accent2600,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow(
      {required this.label, required this.meta, required this.onTap});
  final String label;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 19),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.body(18, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(meta,
                      style: AppText.body(14, color: AppColors.ink(0.5))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('›', style: AppText.body(19, color: AppColors.ink(0.4))),
          ],
        ),
      ),
    );
  }
}
