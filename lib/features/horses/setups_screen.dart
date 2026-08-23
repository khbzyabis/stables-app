import 'package:flutter/material.dart';

import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 22 — a horse's setups, one per activity. Slots are filled from the
/// stable's tack box; save makes the choice the default for that activity.
class SetupsScreen extends StatefulWidget {
  const SetupsScreen({super.key});
  static const route = '/setups';

  static const activities = ['Flatwork', 'Jumping', 'Hacking', 'Lunging'];
  static const slots = <(String, String, String)>[
    ('bridle', 'Bridle', 'Bridles'),
    ('noseband', 'Noseband', 'Nosebands'),
    ('bit', 'Bit', 'Bits'),
    ('reins', 'Reins', 'Reins'),
    ('saddle', 'Saddle', 'Saddles and girths'),
    ('boots', 'Boots', 'Boots and bandages'),
  ];

  @override
  State<SetupsScreen> createState() => _SetupsScreenState();
}

class _SetupsScreenState extends State<SetupsScreen> {
  Map<String, dynamic> _horse = const {};
  Future<void>? _future;

  String _activity = 'Flatwork';
  String? _openSlot;
  bool _busy = false;

  // group name -> list of tack item names
  final Map<String, List<String>> _tackByGroup = {};
  // activity -> saved slots
  final Map<String, Map<String, String>> _saved = {};
  // current editing values for the selected activity
  Map<String, String> _values = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _horse = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _future ??= _load();
  }

  Future<void> _load() async {
    final stableId = _horse['stable_id'] as String?;
    final horseId = _horse['id'] as String?;
    if (stableId == null || horseId == null) return;
    final tack = await SupabaseService.tackItems(stableId);
    _tackByGroup.clear();
    for (final t in tack) {
      (_tackByGroup[t['group_name'] as String? ?? 'Other'] ??= [])
          .add(t['name'] as String? ?? '');
    }
    final setups = await SupabaseService.horseSetups(horseId);
    _saved.clear();
    for (final s in setups) {
      final slots = (s['slots'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString())) ??
          <String, String>{};
      _saved[s['activity'] as String] = slots;
    }
    _values = Map<String, String>.from(_saved[_activity] ?? {});
  }

  bool get _dirty {
    final saved = _saved[_activity] ?? const {};
    if (_values.length != saved.length) return true;
    for (final e in _values.entries) {
      if (saved[e.key] != e.value) return true;
    }
    return false;
  }

  void _pickActivity(String a) => setState(() {
        _activity = a;
        _values = Map<String, String>.from(_saved[a] ?? {});
        _openSlot = null;
      });

  Future<void> _save() async {
    final stableId = _horse['stable_id'] as String?;
    final horseId = _horse['id'] as String?;
    if (stableId == null || horseId == null) return;
    setState(() => _busy = true);
    try {
      await SupabaseService.saveSetup(
        horseId: horseId,
        stableId: stableId,
        activity: _activity,
        slots: _values,
      );
      setState(() => _saved[_activity] = Map<String, String>.from(_values));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<void>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final noTack = _tackByGroup.isEmpty;
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: (_horse['name'] as String?) ?? 'Horse'),
                const SizedBox(height: 20),
                Text('Setups', style: AppText.heading(40, height: 1)),
                const SizedBox(height: 12),
                Text('Pick an activity and set the kit for it. Fills from the tack box.',
                    style: AppText.body(17,
                        height: 1.5, color: AppColors.ink(0.65))),
                const SizedBox(height: 26),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in SetupsScreen.activities)
                      _Chip(
                        label: a,
                        selected: a == _activity,
                        onTap: () => _pickActivity(a),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                if (noTack)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        'Add tack to the tack box first — then you can pick it for each slot here.',
                        style: AppText.body(15,
                            height: 1.5, color: AppColors.ink(0.6))),
                  ),
                Row(
                  children: [
                    AppTag(_saved.containsKey(_activity) ? 'Saved' : 'Not set',
                        tone: _saved.containsKey(_activity)
                            ? TagTone.sage
                            : TagTone.neutral),
                  ],
                ),
                const SizedBox(height: 14),
                const Hairline(),
                for (final (key, label, group) in SetupsScreen.slots) ...[
                  _SlotTile(
                    label: label,
                    value: _values[key] ?? '—',
                    open: _openSlot == key,
                    options: [..._tackByGroup[group] ?? const [], 'None'],
                    onToggle: () =>
                        setState(() => _openSlot = _openSlot == key ? null : key),
                    onPick: (v) => setState(() {
                      _values[key] = v;
                      _openSlot = null;
                    }),
                  ),
                  const Hairline(),
                ],
                const SizedBox(height: 22),
                if (_dirty)
                  AppButton(
                    label: _busy ? 'Saving…' : 'Make this the default',
                    onPressed: _busy ? null : _save,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.label,
    required this.value,
    required this.open,
    required this.options,
    required this.onToggle,
    required this.onPick,
  });
  final String label;
  final String value;
  final bool open;
  final List<String> options;
  final VoidCallback onToggle;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
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
                    child:
                        Text(label.toUpperCase(), style: AppText.eyebrow())),
                Expanded(child: Text(value, style: AppText.body(17))),
                Text(open ? 'Done' : 'Change',
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
                for (final o in options)
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
