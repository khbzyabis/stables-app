import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 27 — a horse's health record, which builds itself from entries.
/// Filter by kind; the summary at the top surfaces what is due.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  static const route = '/health';

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final log = _filter == 'All'
        ? HorseDetailData.health
        : HorseDetailData.health.where((h) => h.kind == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Kiki'),
            const SizedBox(height: 20),
            Text(l10n.sectionHealth, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 24),
            Row(
              children: const [
                _DueItem(label: 'Farrier', value: 'Thursday'),
                SizedBox(width: 26),
                _DueItem(label: 'Vaccination', value: 'In 5 weeks'),
                SizedBox(width: 26),
                _DueItem(label: 'Dentist', value: 'Not set', muted: true),
              ],
            ),
            const SizedBox(height: 26),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in HorseDetailData.healthFilters) ...[
                    _Chip(
                      label: f,
                      selected: f == _filter,
                      onTap: () => setState(() => _filter = f),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Hairline(),
            for (final h in log) ...[
              _HealthRow(entry: h),
              const Hairline(),
            ],
            if (log.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Text('Nothing of that kind on record.',
                    style: AppText.body(16, color: AppColors.ink(0.55))),
              ),
            const SizedBox(height: 28),
            AppButton(
              label: l10n.logHealth,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueItem extends StatelessWidget {
  const _DueItem(
      {required this.label, required this.value, this.muted = false});
  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.eyebrow()),
        const SizedBox(height: 6),
        Text(value,
            style: AppText.heading(19,
                color: muted ? AppColors.ink(0.5) : AppColors.text)),
      ],
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.entry});
  final HealthEntry entry;

  @override
  Widget build(BuildContext context) {
    final tone = switch (entry.kind) {
      'Vet' => TagTone.outline,
      'Farrier' => TagTone.accent,
      'Vaccination' => TagTone.sage,
      _ => TagTone.neutral,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(entry.date,
                style: AppText.body(14, height: 1.35, color: AppColors.ink(0.5))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: entry.hue, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: AppText.heading(19, height: 1.25)),
                  const SizedBox(height: 4),
                  Text(entry.note,
                      style: AppText.body(15,
                          height: 1.45, color: AppColors.ink(0.6))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppTag(entry.kind, tone: tone),
        ],
      ),
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
