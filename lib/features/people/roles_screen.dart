import 'package:flutter/material.dart';

import '../../data/people_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 15 — Role permissions. Admin and manager sit above the rest; the
/// manager's permissions are the admin's to set.
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});
  static const route = '/people/roles';

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final Set<int> _perms = {0, 2};

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
            Text(l10n.rolesIntro,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            const Hairline(),
            _RoleBlock(
              title: 'Admin',
              tag: l10n.fullControl,
              tone: TagTone.accent,
              body: 'Everything, including inviting other admins and closing the stable.',
            ),
            const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Manager', style: AppText.heading(21)),
                      const SizedBox(width: 10),
                      AppTag(l10n.youChoose, tone: TagTone.sage),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Runs the day to day. Pick what that includes.',
                      style: AppText.body(16, height: 1.5, color: AppColors.ink(0.7))),
                  const SizedBox(height: 16),
                  for (var i = 0; i < PeopleData.managerPerms.length; i++)
                    _PermRow(
                      label: PeopleData.managerPerms[i],
                      checked: _perms.contains(i),
                      onToggle: () => setState(() {
                        _perms.contains(i) ? _perms.remove(i) : _perms.add(i);
                      }),
                    ),
                ],
              ),
            ),
            const Hairline(),
            _RoleBlock(
              title: 'Trainer',
              body: 'Logs training for assigned horses. Reads the noticeboard.',
            ),
            const Hairline(),
            _RoleBlock(
              title: 'Groom',
              body: 'Daily care notes for every horse in the stable. No admin screens.',
            ),
            const Hairline(),
            _RoleBlock(
              title: 'Owner and rider',
              body: 'Their own horses only, once approved. Riders can be assigned horses they do not own.',
            ),
            const Hairline(),
          ],
        ),
      ),
    );
  }
}

class _RoleBlock extends StatelessWidget {
  const _RoleBlock({required this.title, required this.body, this.tag, this.tone});
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

class _PermRow extends StatelessWidget {
  const _PermRow(
      {required this.label, required this.checked, required this.onToggle});
  final String label;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked ? AppColors.accent2600 : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: checked ? AppColors.accent2600 : AppColors.ink(0.35),
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 16, color: AppColors.bg)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppText.body(16, height: 1.4))),
          ],
        ),
      ),
    );
  }
}
