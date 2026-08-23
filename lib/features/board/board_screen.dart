import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 62 — the My Stables board. Platform notices and paid placements.
/// Read-only; anything urgent also arrives as a notification.
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});
  static const route = '/board';

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final posts = _filter == 'All'
        ? CommsData.board
        : CommsData.board.where((p) => p.kind == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Shows'),
            const SizedBox(height: 16),
            Text(l10n.notices, style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 8),
            Text("From My Stables. Your own yard's board is under Board.",
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in CommsData.boardFilters)
                  _Chip(
                    label: f,
                    selected: f == _filter,
                    onTap: () => setState(() => _filter = f),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Hairline(),
            for (final p in posts) ...[
              _BoardTile(post: p),
              const Hairline(),
            ],
            const SizedBox(height: 18),
            Text(
                'Only My Stables posts here. You cannot reply, but anything urgent also arrives as a notification.',
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.5))),
          ],
        ),
      ),
    );
  }
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({required this.post});
  final BoardPost post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (post.pinned) ...[
                AppTag(l10n.pinned, tone: TagTone.accent),
                const SizedBox(width: 9),
              ],
              _KindPill(post.kind),
              const SizedBox(width: 9),
              Text(post.when,
                  style: AppText.body(13, color: AppColors.ink(0.5))),
            ],
          ),
          const SizedBox(height: 9),
          Text(post.title, style: AppText.heading(20, height: 1.25)),
          const SizedBox(height: 7),
          Text(post.body, style: AppText.body(16, height: 1.6)),
          if (post.hasImage) ...[
            const SizedBox(height: 12),
            Container(
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('IMAGE',
                  style: AppText.body(10, color: AppColors.neutral700)),
            ),
          ],
          const SizedBox(height: 11),
          Text(post.reach, style: AppText.body(14, color: AppColors.ink(0.5))),
        ],
      ),
    );
  }
}

class _KindPill extends StatelessWidget {
  const _KindPill(this.kind);
  final String kind;

  @override
  Widget build(BuildContext context) {
    final accent = kind == 'Advert';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? AppColors.accent100 : AppColors.accent2100,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(kind.toUpperCase(),
          style: AppText.body(10,
              letterSpacing: 0.8,
              color: accent ? AppColors.accent800 : AppColors.accent2800)),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(14,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}
