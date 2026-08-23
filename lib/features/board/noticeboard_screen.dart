import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import 'post_notice_screen.dart';

/// Screen 25 — the yard noticeboard. Pinned first, replies inline, and an
/// acknowledge affordance so the poster knows it was read.
class NoticeboardScreen extends StatefulWidget {
  const NoticeboardScreen({super.key});
  static const route = '/noticeboard';

  @override
  State<NoticeboardScreen> createState() => _NoticeboardScreenState();
}

class _NoticeboardScreenState extends State<NoticeboardScreen> {
  final _openReplies = <String>{};
  final _acked = <String>{};

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Serc'.toUpperCase(),
                          style: AppText.eyebrow(color: AppColors.accent700)),
                      const SizedBox(height: 10),
                      Text(l10n.titleNoticeboard,
                          style: AppText.heading(40, height: 1)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(PostNoticeScreen.route),
                  child: Text(l10n.post,
                      style: AppText.body(15, color: AppColors.accent700)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Hairline(),
            for (final n in CommsData.notices) ...[
              _NoticeTile(
                notice: n,
                acked: _acked.contains(n.id),
                repliesOpen: _openReplies.contains(n.id),
                onAck: () => setState(() => _acked.contains(n.id)
                    ? _acked.remove(n.id)
                    : _acked.add(n.id)),
                onToggleReplies: () => setState(() => _openReplies.contains(n.id)
                    ? _openReplies.remove(n.id)
                    : _openReplies.add(n.id)),
              ),
              const Hairline(),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.notice,
    required this.acked,
    required this.repliesOpen,
    required this.onAck,
    required this.onToggleReplies,
  });
  final Notice notice;
  final bool acked;
  final bool repliesOpen;
  final VoidCallback onAck;
  final VoidCallback onToggleReplies;

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
              if (notice.pinned) ...[
                AppTag(l10n.pinned, tone: TagTone.accent),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(notice.byline,
                    style: AppText.body(13, color: AppColors.ink(0.5))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (notice.title != null) ...[
            Text(notice.title!, style: AppText.heading(22, height: 1.2)),
            const SizedBox(height: 7),
          ],
          Text(notice.body, style: AppText.body(16, height: 1.55)),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: onAck,
                child: Text(
                    acked ? l10n.read : l10n.markRead,
                    style: AppText.body(15,
                        color: acked ? AppColors.accent2700 : AppColors.accent700)),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: onToggleReplies,
                child: Text('${notice.replies.length} ${l10n.replies}',
                    style: AppText.body(15, color: AppColors.ink(0.55))),
              ),
            ],
          ),
          if (repliesOpen && notice.replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16, left: 4),
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(color: AppColors.accent2300, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in notice.replies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.who,
                              style: AppText.body(13, color: AppColors.ink(0.5))),
                          const SizedBox(height: 3),
                          Text(r.text, style: AppText.body(15, height: 1.5)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
