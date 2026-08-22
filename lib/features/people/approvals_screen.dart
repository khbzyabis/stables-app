import 'package:flutter/material.dart';

import '../../data/people_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 11 — Approvals. Nothing joins the stable until the admin says yes.
/// A rider joining brings their horse, and both need approval.
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});
  static const route = '/approvals';

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final _decided = <String, bool>{}; // id → approved?

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
            const BackLink(label: 'Serc'),
            const SizedBox(height: 24),
            Text(l10n.needsYou, style: AppText.heading(42, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.nothingJoins,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            const Hairline(),
            for (final r in PeopleData.requests) ...[
              _RequestRow(
                request: r,
                decided: _decided[r.id],
                onApprove: () => setState(() => _decided[r.id] = true),
                onDecline: () => setState(() => _decided[r.id] = false),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            Text('Riders can add a horse any time; it stays hidden from the stable until approved.',
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.decided,
    required this.onApprove,
    required this.onDecline,
  });
  final ApprovalRequest request;
  final bool? decided;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.kind,
              style: AppText.body(13, color: AppColors.accent700)),
          const SizedBox(height: 6),
          Text(request.title, style: AppText.heading(21, height: 1.25)),
          const SizedBox(height: 5),
          Text(request.meta,
              style: AppText.body(15, color: AppColors.ink(0.6))),
          const SizedBox(height: 16),
          if (decided == null)
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
