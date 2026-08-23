import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 34 — documents, where expiry is the point. Only the owner and admins
/// can open them; a reminder lands a month before anything expires.
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});
  static const route = '/documents';

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
            const BackLink(label: 'Kiki'),
            const SizedBox(height: 20),
            Text(l10n.documents, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('Only Ahmad and the admins can open these.',
                style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            for (final d in HorseDetailData.documents) ...[
              _DocRow(doc: d),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {},
              child: Text('+ ${l10n.addDocument}',
                  style: AppText.heading(17, color: AppColors.accent700)),
            ),
            const SizedBox(height: 20),
            Text('You get a reminder a month before anything expires.',
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.doc});
  final HorseDoc doc;

  @override
  Widget build(BuildContext context) {
    final tone = switch (doc.status) {
      'Expiring' => TagTone.accent,
      'Current' => TagTone.sage,
      _ => TagTone.neutral,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 54,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(doc.ext,
                style: AppText.body(10, color: AppColors.neutral700)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name, style: AppText.body(18, height: 1.3)),
                const SizedBox(height: 4),
                Text(doc.meta,
                    style: AppText.body(14, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppTag(doc.status, tone: tone),
        ],
      ),
    );
  }
}
