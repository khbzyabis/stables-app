import 'package:flutter/material.dart';

import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/photo_placeholder.dart';
import 'documents_screen.dart';
import 'edit_horse_screen.dart';
import 'feed_chart_screen.dart';
import 'health_screen.dart';
import 'progress_screen.dart';
import 'setups_screen.dart';
import 'tack_box_screen.dart';
import 'training_screen.dart';

/// Screen 32 — a horse's record. A hero, its key facts, and the horse's
/// records as warm-white cards (daily care as a grid, kit & papers as rows) —
/// matching the home hub so the app reads as one system.
class HorseRecordScreen extends StatefulWidget {
  const HorseRecordScreen({super.key});
  static const route = '/horse-record';

  @override
  State<HorseRecordScreen> createState() => _HorseRecordScreenState();
}

class _HorseRecordScreenState extends State<HorseRecordScreen> {
  Map<String, dynamic>? _horse;
  Future<_CareCounts>? _counts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_horse == null) {
      _horse = (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?) ??
          const {};
      final id = _horse!['id'] as String?;
      if (id != null) _counts = _loadCounts(id);
    }
  }

  // Best-effort at-a-glance counts. Any failure just hides that line.
  Future<_CareCounts> _loadCounts(String horseId) async {
    Future<int> count(Future<List<dynamic>> f) async {
      try {
        return (await f).length;
      } catch (_) {
        return -1; // unknown → line hidden
      }
    }

    final health = await count(SupabaseService.healthEntries(horseId));
    final training = await count(SupabaseService.trainingSessions(horseId));
    final feed = await count(SupabaseService.feedItems(horseId));
    return _CareCounts(health: health, training: training, feed: feed);
  }

  Future<void> _openEdit() async {
    final result = await Navigator.of(context)
        .pushNamed(EditHorseScreen.route, arguments: _horse);
    if (!mounted) return;
    if (result == 'removed') {
      Navigator.of(context).pop('removed');
    } else if (result is Map<String, dynamic>) {
      setState(() => _horse = result);
    }
  }

  void _open(String route) =>
      Navigator.of(context).pushNamed(route, arguments: _horse);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final horse = _horse ?? const {};
    final name = (horse['name'] as String?) ?? 'Horse';
    final well = (horse['status'] as String?) != 'watch';

    final facts = <(String, String)>[
      for (final k in ['breed', 'age', 'height', 'sex'])
        if ((horse[k] as String?)?.isNotEmpty == true)
          (k[0].toUpperCase() + k.substring(1), horse[k] as String),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Soft sage wash behind the hero.
          Positioned(
            top: -90,
            right: -110,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                  color: AppColors.accent2200, shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
              children: [
                // Top bar: back + edit.
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _EditButton(label: l10n.editDetails, onTap: _openEdit),
                  ],
                ),
                const SizedBox(height: 6),
                // Hero.
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                  child: Row(
                    children: [
                      PhotoPlaceholder(
                          size: 96,
                          circle: false,
                          radius: 26,
                          url: horse['photo_url'] as String?),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppText.heading(34, height: 1)),
                            if ((horse['box'] as String?)?.isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 7),
                              Text('Box ${horse['box']}',
                                  style: AppText.body(15,
                                      color: AppColors.ink(0.6))),
                            ],
                            const SizedBox(height: 12),
                            _StatusPill(
                                label:
                                    well ? l10n.statusWell : l10n.statusWatch,
                                well: well),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Facts strip.
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    child: Row(
                      children: [
                        for (final (label, value) in facts)
                          Expanded(
                            child: Column(
                              children: [
                                Text(label.toUpperCase(),
                                    style: AppText.body(10.5,
                                        color: AppColors.ink(0.55),
                                        letterSpacing: 1.2)),
                                const SizedBox(height: 5),
                                Text(value,
                                    style: AppText.heading(17),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                // Daily care grid.
                _SectionLabel('Daily care'),
                FutureBuilder<_CareCounts>(
                  future: _counts,
                  builder: (context, snap) {
                    final c = snap.data;
                    return Column(
                      children: [
                        Row(children: [
                          Expanded(
                            child: _CareCard(
                              icon: Icons.favorite_border,
                              tone: _Tone.terra,
                              title: l10n.sectionHealth,
                              caption: 'Vet, farrier & jabs',
                              glance: _n(c?.health, 'note', 'notes'),
                              onTap: () => _open(HealthScreen.route),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _CareCard(
                              icon: Icons.show_chart,
                              tone: _Tone.sage,
                              title: l10n.sectionTraining,
                              caption: 'Sessions & how they went',
                              glance: _n(c?.training, 'session', 'sessions'),
                              onTap: () => _open(TrainingScreen.route),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                            child: _CareCard(
                              icon: Icons.restaurant_outlined,
                              tone: _Tone.sage,
                              title: l10n.feedChart,
                              caption: 'What goes in the bucket',
                              glance: _n(c?.feed, 'item', 'items'),
                              onTap: () => _open(FeedChartScreen.route),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _CareCard(
                              icon: Icons.insights_outlined,
                              tone: _Tone.terra,
                              title: l10n.howItIsGoing,
                              caption: 'Work over time',
                              glance: null,
                              onTap: () => _open(ProgressScreen.route),
                            ),
                          ),
                        ]),
                      ],
                    );
                  },
                ),
                // Kit & papers rows.
                _SectionLabel('Kit & papers'),
                _RefRow(
                  icon: Icons.layers_outlined,
                  tone: _Tone.sage,
                  title: l10n.setups,
                  sub: 'Tack per activity',
                  onTap: () => _open(SetupsScreen.route),
                ),
                const SizedBox(height: 12),
                _RefRow(
                  icon: Icons.work_outline,
                  tone: _Tone.terra,
                  title: l10n.tack,
                  sub: 'The kit',
                  onTap: () => _open(TackBoxScreen.route),
                ),
                const SizedBox(height: 12),
                _RefRow(
                  icon: Icons.description_outlined,
                  tone: _Tone.sage,
                  title: l10n.documents,
                  sub: 'Passport, insurance, jabs',
                  onTap: () => _open(DocumentsScreen.route),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // "3 notes" / "1 session" / null when unknown or empty.
  String? _n(int? count, String one, String many) {
    if (count == null || count < 0) return null;
    if (count == 0) return null;
    return '$count ${count == 1 ? one : many}';
  }
}

class _CareCounts {
  const _CareCounts(
      {required this.health, required this.training, required this.feed});
  final int health;
  final int training;
  final int feed;
}

enum _Tone { terra, sage }

Color _toneBg(_Tone t) =>
    t == _Tone.terra ? const Color(0xFFF3DDC9) : AppColors.accent2200;
Color _toneFg(_Tone t) =>
    t == _Tone.terra ? AppColors.accent700 : AppColors.accent2700;

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 26, 2, 12),
        child: Text(text.toUpperCase(),
            style: AppText.eyebrow(color: AppColors.ink(0.5))),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.well});
  final String label;
  final bool well;
  @override
  Widget build(BuildContext context) {
    final bg = well ? AppColors.accent2200 : const Color(0xFFF4E2C4);
    final fg = well ? AppColors.accent2700 : const Color(0xFF8A5A12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(label, style: AppText.body(13, color: fg)),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warmWhite,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warmWhite,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 17, color: AppColors.accent700),
              const SizedBox(width: 7),
              Text(label,
                  style: AppText.body(14, color: AppColors.accent700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  const _CareCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.caption,
    required this.glance,
    required this.onTap,
  });
  final IconData icon;
  final _Tone tone;
  final String title;
  final String caption;
  final String? glance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _toneBg(tone), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: _toneFg(tone), size: 24),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppText.heading(18, height: 1.1)),
          const SizedBox(height: 3),
          Text(caption, style: AppText.body(12.5, color: AppColors.ink(0.55))),
          if (glance != null) ...[
            const SizedBox(height: 10),
            Text(glance!,
                style: AppText.body(12.5, color: AppColors.accent700)),
          ],
        ],
      ),
    );
  }
}

class _RefRow extends StatelessWidget {
  const _RefRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.sub,
    required this.onTap,
  });
  final IconData icon;
  final _Tone tone;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _toneBg(tone), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _toneFg(tone), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.heading(16)),
              const SizedBox(height: 2),
              Text(sub, style: AppText.body(12.5, color: AppColors.ink(0.55))),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
      ]),
    );
  }
}
