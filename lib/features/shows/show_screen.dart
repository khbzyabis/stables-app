import 'package:flutter/material.dart';

import '../../data/shows_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'start_list_screen.dart';

/// Screen 54 — a single show. Tick the classes to enter, pick the horse (with
/// an honest warning per horse), and the fee totals up.
class ShowScreen extends StatefulWidget {
  const ShowScreen({super.key});
  static const route = '/show';

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  final _picked = <String>{'c2'};
  String _horse = 'Kiki';

  int get _total => ShowsData.classes
      .where((c) => _picked.contains(c.id))
      .fold(0, (n, c) => n + c.fee);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final warn = ShowsData.entryHorses
        .firstWhere((h) => h.name == _horse,
            orElse: () => ShowsData.entryHorses.first)
        .warn;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Shows'),
            const SizedBox(height: 16),
            Text('Saturday 29 August · Al Qudra Arena'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 9),
            Text('Al Qudra Spring Tour, leg 1',
                style: AppText.heading(32, height: 1.08)),
            const SizedBox(height: 22),
            const Hairline(),
            for (final (label, value) in ShowsData.showFacts) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 118,
                      child: Text(label,
                          style: AppText.body(15, color: AppColors.ink(0.55))),
                    ),
                    Expanded(
                        child: Text(value,
                            style: AppText.body(16, height: 1.45))),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            Text('Classes'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 4),
            const Hairline(),
            for (final c in ShowsData.classes) ...[
              _ClassRow(
                cls: c,
                on: _picked.contains(c.id),
                onTap: () => setState(() => _picked.contains(c.id)
                    ? _picked.remove(c.id)
                    : _picked.add(c.id)),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            Text('On which horse'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in ShowsData.entryHorses)
                  _Chip(
                    label: h.name,
                    selected: h.name == _horse,
                    onTap: () => setState(() => _horse = h.name),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(warn,
                style: AppText.body(14, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            AppButton(
              label: _picked.isEmpty
                  ? l10n.pickAClass
                  : 'Enter $_horse · AED $_total',
              onPressed: _picked.isEmpty
                  ? null
                  : () =>
                      Navigator.of(context).pushNamed(StartListScreen.route),
            ),
            const SizedBox(height: 14),
            Text(
                'Entries close Thursday at noon, and withdrawals after that are not refunded.',
                style: AppText.body(14, height: 1.6, color: AppColors.ink(0.6))),
          ],
        ),
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.cls, required this.on, required this.onTap});
  final ShowClass cls;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: on ? AppColors.accent : AppColors.neutral400,
                    width: 2),
              ),
              child: on
                  ? const Icon(Icons.check, size: 16, color: AppColors.bg)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls.name, style: AppText.body(17, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(cls.meta,
                      style: AppText.body(14, color: AppColors.ink(0.5))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('AED ${cls.fee}', style: AppText.body(16)),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent2 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.accent2 : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.body(14,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}
