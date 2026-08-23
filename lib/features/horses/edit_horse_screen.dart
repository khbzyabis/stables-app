import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

enum _MoveState { idle, asking, sent }

/// Screen 63 — edit a horse, and move her to another stable. Moving needs both
/// admins to agree; until then nothing changes.
class EditHorseScreen extends StatefulWidget {
  const EditHorseScreen({super.key});
  static const route = '/edit-horse';

  @override
  State<EditHorseScreen> createState() => _EditHorseScreenState();
}

class _EditHorseScreenState extends State<EditHorseScreen> {
  _MoveState _move = _MoveState.idle;
  final _name = TextEditingController(text: 'Kiki');
  final _age = TextEditingController(text: '9');
  final _height = TextEditingController(text: '16.1 hh');
  final _box = TextEditingController(text: '7');
  final _stable = TextEditingController(text: 'Al Marmoom Equestrian');

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _box.dispose();
    _stable.dispose();
    super.dispose();
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
            const BackLink(label: 'Kiki'),
            const SizedBox(height: 18),
            Text(l10n.editHorse, style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: AppColors.neutral300, shape: BoxShape.circle),
                  child: Text('PHOTO',
                      style: AppText.body(10, color: AppColors.neutral700)),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {},
                  child: Text(l10n.changePhoto,
                      style: AppText.body(16, color: AppColors.accent700)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppField(label: l10n.detailName, controller: _name),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppField(label: l10n.detailAge, controller: _age)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        AppField(label: l10n.detailHeight, controller: _height)),
              ],
            ),
            const SizedBox(height: 16),
            AppField(label: l10n.detailBox, controller: _box),
            const SizedBox(height: 24),
            AppButton(label: l10n.save, onPressed: () {}),
            const SizedBox(height: 30),
            const Hairline(),
            const SizedBox(height: 22),
            Text('Leaving Serc'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 12),
            _buildMove(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildMove(BuildContext context, AppL10n l10n) {
    switch (_move) {
      case _MoveState.idle:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _move = _MoveState.asking),
              child: Text(l10n.moveHorse,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {},
              child: Text('Mark as sold or retired',
                  style: AppText.body(15, color: AppColors.ink(0.55))),
            ),
          ],
        );
      case _MoveState.asking:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppField(label: l10n.whichStable, controller: _stable),
            const SizedBox(height: 18),
            const Hairline(),
            for (final (what, value) in HorseDetailData.moveEffects) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(what,
                            style: AppText.body(16, height: 1.4))),
                    const SizedBox(width: 14),
                    Text(value,
                        textAlign: TextAlign.right,
                        style: AppText.body(15,
                            color: value == 'Stay here'
                                ? AppColors.accent700
                                : AppColors.ink(0.6))),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                AppButton(
                  label: l10n.askStable,
                  block: false,
                  minHeight: 52,
                  fontSize: 16,
                  onPressed: () => setState(() => _move = _MoveState.sent),
                ),
                const SizedBox(width: 10),
                AppButton(
                  label: l10n.keepHer,
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 52,
                  fontSize: 16,
                  onPressed: () => setState(() => _move = _MoveState.idle),
                ),
              ],
            ),
          ],
        );
      case _MoveState.sent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTag(l10n.waitingBothAdmins, tone: TagTone.accent),
            const SizedBox(height: 14),
            Text(l10n.moveSentBody,
                style: AppText.body(16, height: 1.6, color: AppColors.ink(0.75))),
          ],
        );
    }
  }
}
