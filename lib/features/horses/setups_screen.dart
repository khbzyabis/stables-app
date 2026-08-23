import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'setup_changed_screen.dart';

/// Screen 22 — a horse's setups, one per activity. Pick an activity and its
/// usual kit fills in; change a slot and the app offers to make it the default.
class SetupsScreen extends StatefulWidget {
  const SetupsScreen({super.key});
  static const route = '/setups';

  @override
  State<SetupsScreen> createState() => _SetupsScreenState();
}

class _SetupsScreenState extends State<SetupsScreen> {
  String _activity = 'Flatwork';
  String? _openSlot;
  late Map<String, String> _values = _defaultsFor(_activity);

  Map<String, String> _defaultsFor(String a) =>
      Map<String, String>.from(HorseDetailData.setupDefaults[a]!);

  bool get _dirty {
    final def = HorseDetailData.setupDefaults[_activity]!;
    return _values.entries.any((e) => def[e.key] != e.value);
  }

  void _pickActivity(String a) => setState(() {
        _activity = a;
        _values = _defaultsFor(a);
        _openSlot = null;
      });

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
            Text(l10n.setups, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 12),
            Text(l10n.setupsIntro,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
            const SizedBox(height: 26),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in HorseDetailData.activities)
                  _Chip(
                    label: a,
                    selected: a == _activity,
                    onTap: () => _pickActivity(a),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                AppTag(_dirty ? l10n.edited : l10n.theDefault,
                    tone: _dirty ? TagTone.accent : TagTone.sage),
                const SizedBox(width: 10),
                Text(HorseDetailData.setupUsedNotes[_activity]!,
                    style: AppText.body(14, color: AppColors.ink(0.5))),
              ],
            ),
            const SizedBox(height: 14),
            const Hairline(),
            for (final slot in HorseDetailData.slots) ...[
              _SlotTile(
                slot: slot,
                value: _values[slot.key]!,
                open: _openSlot == slot.key,
                onToggle: () => setState(() =>
                    _openSlot = _openSlot == slot.key ? null : slot.key),
                onPick: (v) => setState(() {
                  _values[slot.key] = v;
                  _openSlot = null;
                }),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            if (_dirty) ...[
              Text(l10n.setupDirtyNote,
                  style:
                      AppText.body(16, height: 1.5, color: AppColors.ink(0.7))),
              const SizedBox(height: 14),
              Row(
                children: [
                  AppButton(
                    label: l10n.makeDefault,
                    block: false,
                    minHeight: 50,
                    fontSize: 16,
                    onPressed: () =>
                        setState(() => _values = _defaultsFor(_activity)),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: l10n.undo,
                    variant: AppButtonVariant.secondary,
                    block: false,
                    minHeight: 50,
                    fontSize: 16,
                    onPressed: () =>
                        setState(() => _values = _defaultsFor(_activity)),
                  ),
                ],
              ),
            ] else
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(SetupChangedScreen.route),
                child: Text(l10n.seeWhatChanged,
                    style: AppText.body(16, color: AppColors.accent700)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.value,
    required this.open,
    required this.onToggle,
    required this.onPick,
  });
  final SetupSlot slot;
  final String value;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(slot.label.toUpperCase(),
                      style: AppText.eyebrow()),
                ),
                Expanded(child: Text(value, style: AppText.body(17))),
                Text(open ? l10n.doneLabel : l10n.change,
                    style: AppText.body(15, color: AppColors.accent700)),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in slot.options)
                  _Chip(
                    label: o,
                    selected: o == value,
                    onTap: () => onPick(o),
                  ),
              ],
            ),
          ),
      ],
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
