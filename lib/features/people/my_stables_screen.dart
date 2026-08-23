import 'package:flutter/material.dart';

import '../../data/people_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../edge/invite_accepted_screen.dart';

/// Screen 12 — My stables. One account, several stables; role and permissions
/// change with the stable.
class MyStablesScreen extends StatelessWidget {
  const MyStablesScreen({super.key});
  static const route = '/my-stables';

  TagTone _tone(String role) => switch (role) {
        'Admin' => TagTone.accent,
        'Trainer' => TagTone.sage,
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
          padding: const EdgeInsets.fromLTRB(32, 22, 32, 40),
          children: [
            Text('Ahmad', style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 12),
            Text(l10n.myStables, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.rolePerStable,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 30),
            const Hairline(),
            for (final s in PeopleData.stables) ...[
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: AppText.heading(22, height: 1.2)),
                            const SizedBox(height: 6),
                            Text(s.meta,
                                style: AppText.body(15, color: AppColors.ink(0.6))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppTag(s.role, tone: _tone(s.role)),
                    ],
                  ),
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 30),
            Text('+ ${l10n.createAnotherStable}',
                style: AppText.heading(17, color: AppColors.accent700)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(InviteAcceptedScreen.route),
              child: Text(l10n.joinWithCode,
                  style: AppText.body(16, color: AppColors.ink(0.6))),
            ),
            const SizedBox(height: 30),
            Text(l10n.adminNoRights,
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}
