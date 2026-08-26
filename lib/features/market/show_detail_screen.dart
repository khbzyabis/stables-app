import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// A rider's view of one operator-created show: the details and a live status.
class ShowDetailScreen extends StatelessWidget {
  const ShowDetailScreen({super.key});
  static const route = '/market/show';

  @override
  Widget build(BuildContext context) {
    final show = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    final title = (show['title'] as String?) ?? 'Show';
    final venue = (show['venue'] as String?)?.trim() ?? '';
    final when = (show['when_text'] as String?)?.trim() ?? '';
    final desc = (show['description'] as String?)?.trim() ?? '';
    final status = (show['status'] as String?)?.trim() ?? '';
    final meta = [venue, when].where((s) => s.isNotEmpty).join(' · ');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: AppColors.warmWhite,
                shape: const CircleBorder(),
                elevation: 2,
                shadowColor: const Color(0x33140E06),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.arrow_back,
                          size: 20, color: AppColors.text)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent2700, AppColors.accent2900],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 16, color: AppColors.accent2200),
                    const SizedBox(width: 7),
                    Text('SHOW',
                        style: AppText.body(11.5,
                            color: AppColors.accent2200, letterSpacing: 1)),
                  ]),
                  const SizedBox(height: 10),
                  Text(title,
                      style: AppText.heading(28,
                          color: AppColors.neutral100, height: 1.05)),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(meta,
                        style: AppText.body(15, color: AppColors.accent2200)),
                  ],
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                                color: Color(0xFF9BD46B),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(status,
                              style: AppText.body(13,
                                  color: AppColors.neutral100)),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('DETAILS', style: AppText.eyebrow(color: AppColors.ink(0.5))),
              const SizedBox(height: 10),
              Text(desc,
                  style:
                      AppText.body(16, height: 1.6, color: AppColors.ink(0.85))),
            ],
          ],
        ),
      ),
    );
  }
}
