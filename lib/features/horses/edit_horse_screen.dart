import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_picker.dart';
import '../auth/back_link.dart';

/// Screen 63 — edit a real horse: change details, flag as one-to-watch, or
/// remove it from the stable. Saves back to Supabase.
class EditHorseScreen extends StatefulWidget {
  const EditHorseScreen({super.key});
  static const route = '/edit-horse';

  @override
  State<EditHorseScreen> createState() => _EditHorseScreenState();
}

class _EditHorseScreenState extends State<EditHorseScreen> {
  late final Map<String, dynamic> _horse;
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _age;
  late final TextEditingController _sex;
  late final TextEditingController _height;
  late final TextEditingController _box;
  late final TextEditingController _notes;
  late bool _watch;
  String? _photoUrl;
  bool _photoBusy = false;
  bool _saving = false;
  bool _removing = false;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    _horse = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    String v(String k) => (_horse[k] as String?) ?? '';
    _name = TextEditingController(text: v('name'));
    _breed = TextEditingController(text: v('breed'));
    _age = TextEditingController(text: v('age'));
    _sex = TextEditingController(text: v('sex'));
    _height = TextEditingController(text: v('height'));
    _box = TextEditingController(text: v('box'));
    _notes = TextEditingController(text: v('notes'));
    _watch = (_horse['status'] as String?) == 'watch';
    _photoUrl = _horse['photo_url'] as String?;
  }

  Future<void> _pickPhoto() async {
    setState(() => _photoBusy = true);
    final url = await pickAndUploadPhoto(context, 'horses');
    if (!mounted) return;
    setState(() {
      _photoBusy = false;
      if (url != null) _photoUrl = url;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _sex.dispose();
    _height.dispose();
    _box.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? get _id => _horse['id'] as String?;

  Future<void> _save() async {
    final id = _id;
    if (id == null) return;
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A name is needed.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await SupabaseService.updateHorse(
        id,
        name: _name.text.trim(),
        breed: _breed.text.trim(),
        age: _age.text.trim(),
        sex: _sex.text.trim(),
        height: _height.text.trim(),
        box: _box.text.trim(),
        notes: _notes.text.trim(),
        status: _watch ? 'watch' : 'well',
        photoUrl: _photoUrl,
      );
      if (mounted) Navigator.of(context).pop(updated);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't save: $e")));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _remove() async {
    final id = _id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text('Remove ${_name.text.trim()}?',
            style: AppText.heading(22)),
        content: Text(
            'This removes the horse and its record from the stable. This '
            "can't be undone.",
            style: AppText.body(16, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Keep', style: AppText.body(16)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Remove',
                style: AppText.heading(16, color: AppColors.accent700)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _removing = true);
    try {
      await SupabaseService.deleteHorse(id);
      if (mounted) Navigator.of(context).pop('removed');
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't remove: $e")));
        setState(() => _removing = false);
      }
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
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
          children: [
            BackLink(label: _name.text.trim().isEmpty ? 'Horse' : _name.text.trim()),
            const SizedBox(height: 18),
            Text(l10n.editHorse, style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 22),
            PhotoField(
              url: _photoUrl,
              busy: _photoBusy,
              onPick: _pickPhoto,
            ),
            const SizedBox(height: 22),
            AppField(label: l10n.detailName, controller: _name),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppField(label: 'Breed', controller: _breed)),
                const SizedBox(width: 12),
                Expanded(child: AppField(label: l10n.detailAge, controller: _age)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppField(label: 'Sex', controller: _sex)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        AppField(label: l10n.detailHeight, controller: _height)),
              ],
            ),
            const SizedBox(height: 16),
            AppField(label: l10n.detailBox, controller: _box),
            const SizedBox(height: 16),
            AppField(label: 'Notes', controller: _notes, maxLines: 3),
            const SizedBox(height: 24),
            // Status toggle.
            Text('STATUS', style: AppText.eyebrow()),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatusChip(
                  label: l10n.statusWell,
                  selected: !_watch,
                  tone: TagTone.sage,
                  onTap: () => setState(() => _watch = false),
                ),
                const SizedBox(width: 10),
                _StatusChip(
                  label: l10n.statusWatch,
                  selected: _watch,
                  tone: TagTone.accent,
                  onTap: () => setState(() => _watch = true),
                ),
              ],
            ),
            const SizedBox(height: 26),
            if (_saving)
              const Center(child: CircularProgressIndicator())
            else
              AppButton(label: l10n.save, onPressed: _save),
            const SizedBox(height: 30),
            const Hairline(),
            const SizedBox(height: 22),
            if (_removing)
              const Center(child: CircularProgressIndicator())
            else
              GestureDetector(
                onTap: _remove,
                child: Text('Remove from stable',
                    style: AppText.body(16, color: AppColors.accent700)),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.tone,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final TagTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent2300 : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent2600 : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: AppText.heading(16,
                weight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
