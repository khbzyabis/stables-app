import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../auth/back_link.dart';

/// Screen 21 — add an item to the tack box. Name and group are enough; the
/// rest is optional. A photo helps a new groom find it.
class AddTackItemScreen extends StatefulWidget {
  const AddTackItemScreen({super.key});
  static const route = '/add-tack-item';

  @override
  State<AddTackItemScreen> createState() => _AddTackItemScreenState();
}

class _AddTackItemScreenState extends State<AddTackItemScreen> {
  String _group = 'Nosebands';
  bool _busy = false;
  final _name = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final stableId = SessionScope.of(context).activeStableId;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Name the item.')));
      return;
    }
    if (stableId == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Create a stable first.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await SupabaseService.addTackItem(
        stableId: stableId,
        group: _group,
        name: name,
        note: _note.text.trim(),
      );
      navigator.pop();
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

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
            const BackLink(label: 'Cancel'),
            const SizedBox(height: 24),
            Text(l10n.newItem, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 28),
            Text(l10n.group.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in HorseDetailData.tackGroups)
                  _Chip(
                    label: g.name,
                    selected: g.name == _group,
                    onTap: () => setState(() => _group = g.name),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            AppField(
                label: l10n.nameIt,
                controller: _name,
                hintText: 'Grackle noseband'),
            const SizedBox(height: 28),
            Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: AppColors.accent2400,
                        width: 2,
                        style: BorderStyle.solid),
                  ),
                  child: Icon(Icons.photo_camera_outlined,
                      color: AppColors.accent2700, size: 26),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.addPhoto,
                        style: AppText.heading(17, color: AppColors.accent700)),
                    const SizedBox(height: 4),
                    Text('Helps a new groom find it',
                        style: AppText.body(14, color: AppColors.ink(0.5))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            AppField(
                label: l10n.noteIfAny,
                controller: _note,
                hintText: 'Size, colour, where it hangs'),
            const SizedBox(height: 34),
            AppButton(
              label: _busy ? 'Saving…' : l10n.saveToTackBox,
              onPressed: _busy ? null : _save,
            ),
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
