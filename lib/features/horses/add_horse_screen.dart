import 'package:flutter/material.dart';
import '../../data/errors.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_picker.dart';
import '../auth/back_link.dart';

/// Screen 07 — Add a horse. Deliberately minimal: a name is all that is
/// required. Age, breed, sex, height, box and notes are optional, revealed
/// only when the person chooses to add them.
class AddHorseScreen extends StatefulWidget {
  const AddHorseScreen({super.key});
  static const route = '/add-horse';

  @override
  State<AddHorseScreen> createState() => _AddHorseScreenState();
}

class _AddHorseScreenState extends State<AddHorseScreen> {
  final _name = TextEditingController();
  final _detailControllers = <String, TextEditingController>{};
  final _open = <String>{};

  List<(String key, String Function(AppL10n) label, String Function(AppL10n) hint)>
      get _defs => [
            ('age', (l) => l.detailAge, (l) => l.detailAgeHint),
            ('breed', (l) => l.detailBreed, (l) => l.detailBreedHint),
            ('sex', (l) => l.detailSex, (l) => l.detailSexHint),
            ('height', (l) => l.detailHeight, (l) => l.detailHeightHint),
            ('box', (l) => l.detailBox, (l) => l.detailBoxHint),
            ('notes', (l) => l.detailNotes, (l) => l.detailNotesHint),
          ];

  @override
  void dispose() {
    _name.dispose();
    for (final c in _detailControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _saving = false;
  String? _photoUrl;
  bool _photoBusy = false;

  TextEditingController _controllerFor(String key) =>
      _detailControllers.putIfAbsent(key, TextEditingController.new);

  Future<void> _pickPhoto() async {
    setState(() => _photoBusy = true);
    final url = await pickAndUploadPhoto(context, 'horses');
    if (!mounted) return;
    setState(() {
      _photoBusy = false;
      if (url != null) _photoUrl = url;
    });
  }

  Future<void> _save() async {
    final stableId = SessionScope.of(context).activeStableId;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    if (stableId == null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Create a stable first, then add horses to it.')));
      return;
    }
    String? v(String k) {
      final t = _detailControllers[k]?.text.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    setState(() => _saving = true);
    try {
      await SupabaseService.addHorse(
        stableId: stableId,
        name: name,
        age: v('age'),
        breed: v('breed'),
        sex: v('sex'),
        height: v('height'),
        box: v('box'),
        notes: v('notes'),
        photoUrl: _photoUrl,
      );
      navigator.pop();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't save — $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackLink(label: l10n.cancel),
          const SizedBox(height: 28),
          Text(l10n.addAHorse, style: AppText.heading(42, height: 1)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(l10n.addHorseSubtitle,
                style: AppText.body(17, height: 1.5, color: AppColors.ink(0.65))),
          ),
          const SizedBox(height: 34),
          PhotoField(
            url: _photoUrl,
            busy: _photoBusy,
            onPick: _pickPhoto,
            label: l10n.addAPhoto,
          ),
          const SizedBox(height: 34),
          AppField(label: l10n.labelName, controller: _name, hintText: l10n.nameHint),
          const SizedBox(height: 40),
          Text(l10n.detailsIfYouWant.toUpperCase(), style: AppText.eyebrow()),
          const SizedBox(height: 6),
          const Hairline(),
          for (final (key, label, hint) in _defs) ...[
            _DetailRow(
              label: label(l10n),
              open: _open.contains(key),
              onToggle: () => setState(() {
                _open.contains(key) ? _open.remove(key) : _open.add(key);
              }),
              controller: _controllerFor(key),
              hint: hint(l10n),
            ),
            const Hairline(),
          ],
          const SizedBox(height: 40),
          AppButton(
            label: l10n.saveHorse,
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(height: 16),
          Text(l10n.fillLater,
              textAlign: TextAlign.center,
              style: AppText.body(14, height: 1.5, color: AppColors.ink(0.55))),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.open,
    required this.onToggle,
    required this.controller,
    required this.hint,
  });
  final String label;
  final bool open;
  final VoidCallback onToggle;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 19),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppText.body(17))),
                Text(open ? '–' : '+',
                    style: AppText.body(22, color: AppColors.ink(0.5))),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              controller: controller,
              cursorColor: AppColors.accent,
              style: AppText.body(17, height: 1.2),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.neutral100,
                hintText: hint,
                hintStyle: AppText.body(17, color: AppColors.ink(0.45)),
                constraints: const BoxConstraints(minHeight: 52),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: _b(Colors.transparent),
                enabledBorder: _b(Colors.transparent),
                focusedBorder: _b(AppColors.accent),
              ),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder _b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: BorderSide(
            color: c, width: c == AppColors.accent ? 1.5 : 1),
      );
}
