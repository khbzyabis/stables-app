import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

enum _LeaveState { idle, asking, left }

/// Screen 36 — a stable's settings, and leaving it. Links to people, approvals,
/// invites, contacts and location; the leave flow explains what stays.
class StableSettingsScreen extends StatefulWidget {
  const StableSettingsScreen({super.key});
  static const route = '/stable-settings';

  @override
  State<StableSettingsScreen> createState() => _StableSettingsScreenState();
}

class _StableSettingsScreenState extends State<StableSettingsScreen> {
  _LeaveState _leave = _LeaveState.idle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'My stables'),
            const SizedBox(height: 20),
            Text('Serc', style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('Dubai · 14 horses · 6 people · you are an admin',
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            for (final l in CommsData.stableSettingLinks) ...[
              _LinkRow(link: l),
              const Hairline(),
            ],
            const SizedBox(height: 30),
            _buildLeave(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLeave(BuildContext context, AppL10n l10n) {
    switch (_leave) {
      case _LeaveState.idle:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text('Hand admin to someone else',
                  style: AppText.body(16, color: AppColors.ink(0.6))),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => setState(() => _leave = _LeaveState.asking),
              child: Text(l10n.leaveStable,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
          ],
        );
      case _LeaveState.asking:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leave Serc?', style: AppText.heading(22)),
            const SizedBox(height: 10),
            Text(
                'Kiki goes with you. Your training and health notes stay in the stable\'s records. You are the second of two admins, so Layal keeps it running.',
                style: AppText.body(16, height: 1.55)),
            const SizedBox(height: 18),
            Row(
              children: [
                AppButton(
                  label: l10n.leave,
                  block: false,
                  minHeight: 50,
                  fontSize: 16,
                  onPressed: () => setState(() => _leave = _LeaveState.left),
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

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link});
  final SettingLink link;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: link.route == null
          ? null
          : () => Navigator.of(context).pushNamed(link.route!),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 19),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(link.label, style: AppText.body(18, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(link.meta,
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
