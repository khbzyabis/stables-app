import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'report_problem_screen.dart';

/// Screen 44 — help. Answers first, then a way through: report a problem, or
/// ask the stable admin.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  static const route = '/help';

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _open;

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
            const BackLink(label: 'You'),
            const SizedBox(height: 20),
            Text(l10n.help, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('Most of it is answered here. If not, we read every message.',
                style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 26),
            const Hairline(),
            for (var i = 0; i < CommsData.help.length; i++) ...[
              _HelpTile(
                item: CommsData.help[i],
                open: _open == i,
                onTap: () => setState(() => _open = _open == i ? null : i),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 30),
            AppButton(
              label: l10n.somethingWrong,
              onPressed: () =>
                  Navigator.of(context).pushNamed(ReportProblemScreen.route),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Ask Ahmad at Serc instead',
              variant: AppButtonVariant.secondary,
              minHeight: 52,
              fontSize: 16,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            Text(
                'We reply within a working day. For a horse that needs a vet now, call the vet — the number is under Contacts.',
                style: AppText.body(15, height: 1.55, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile(
      {required this.item, required this.open, required this.onTap});
  final HelpItem item;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.question, style: AppText.body(17, height: 1.4)),
                  if (open) ...[
                    const SizedBox(height: 10),
                    Text(item.answer,
                        style: AppText.body(16,
                            height: 1.6, color: AppColors.ink(0.7))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(open ? '–' : '+',
                style: AppText.body(20, color: AppColors.ink(0.45))),
          ],
        ),
      ),
    );
  }
}
