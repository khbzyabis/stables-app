import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/create_stable_screen.dart';

/// Screen 12 — My stables. One account, several stables; the list is the
/// person's real memberships from Supabase. Tap one to make it active.
class MyStablesScreen extends StatefulWidget {
  const MyStablesScreen({super.key});
  static const route = '/my-stables';

  @override
  State<MyStablesScreen> createState() => _MyStablesScreenState();
}

class _MyStablesScreenState extends State<MyStablesScreen> {
  @override
  void initState() {
    super.initState();
    // Pull the freshest membership list when this screen opens.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => SessionScope.of(context).refresh());
  }

  TagTone _tone(String role) => switch (role) {
        'Admin' => TagTone.accent,
        'Trainer' => TagTone.sage,
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
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            final stables = session.stables;
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 22, 32, 40),
              children: [
                Text(SupabaseService.displayName,
                    style: AppText.eyebrow(color: AppColors.accent700)),
                const SizedBox(height: 12),
                Text(l10n.myStables, style: AppText.heading(42, height: 1)),
                const SizedBox(height: 12),
                Text(l10n.rolePerStable,
                    style: AppText.body(17,
                        height: 1.5, color: AppColors.ink(0.65))),
                const SizedBox(height: 30),
                const Hairline(),
                if (session.loading && stables.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (stables.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text(
                      'You are not in any stable yet. Create one below and it '
                      'becomes your first group.',
                      style: AppText.body(16,
                          height: 1.5, color: AppColors.ink(0.6)),
                    ),
                  )
                else
                  for (final s in stables) ...[
                    InkWell(
                      onTap: () {
                        session.setActive(s['id'] as String);
                        Navigator.of(context).maybePop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((s['name'] as String?) ?? 'Stable',
                                      style: AppText.heading(22, height: 1.2)),
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      if ((s['city'] as String?)?.isNotEmpty ==
                                          true)
                                        s['city'],
                                      if (s['id'] == session.activeStableId)
                                        'Active',
                                    ].join(' · '),
                                    style: AppText.body(15,
                                        color: AppColors.ink(0.6)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            AppTag((s['role'] as String?) ?? 'Member',
                                tone: _tone((s['role'] as String?) ?? '')),
                          ],
                        ),
                      ),
                    ),
                    const Hairline(),
                  ],
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(CreateStableScreen.route),
                  child: Text('+ ${l10n.createAnotherStable}',
                      style: AppText.heading(17, color: AppColors.accent700)),
                ),
                const SizedBox(height: 30),
                Text(l10n.adminNoRights,
                    style: AppText.body(15,
                        height: 1.5, color: AppColors.ink(0.55))),
              ],
            );
          },
        ),
      ),
    );
  }
}
