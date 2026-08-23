import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../../widgets/step_progress.dart';
import '../home/home_screen.dart';
import 'back_link.dart';

enum _Setup { create, join }

/// Screen 05 — Create or join a stable. Two exclusive options; the CTA label
/// and the legal line change with the choice.
class CreateStableScreen extends StatefulWidget {
  const CreateStableScreen({super.key});
  static const route = '/create-stable';

  @override
  State<CreateStableScreen> createState() => _CreateStableScreenState();
}

class _CreateStableScreenState extends State<CreateStableScreen> {
  _Setup _setup = _Setup.create;
  final _stableName = TextEditingController();
  final _inviteCode = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _stableName.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = SessionScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_setup == _Setup.join) {
      final code = _inviteCode.text.trim();
      if (code.isEmpty) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Enter the invite code.')));
        return;
      }
      setState(() => _busy = true);
      try {
        final stable = await SupabaseService.redeemInvite(code);
        await session.refresh();
        session.setActive(stable['id'] as String);
        if (!mounted) return;
        navigator.pushNamedAndRemoveUntil(HomeScreen.route, (r) => false);
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(_clean(e))));
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    final name = _stableName.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Give your stable a name.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await session.createStable(name, null);
      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(HomeScreen.route, (r) => false);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Could not create the stable: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('PostgrestException(message: ', '').split(',').first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isCreate = _setup == _Setup.create;
    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackLink(label: l10n.back),
          const SizedBox(height: 28),
          Text(l10n.yourStable, style: AppText.heading(42, height: 1)),
          const SizedBox(height: 12),
          Text(l10n.step3of3,
              style: AppText.body(17, color: AppColors.ink(0.65))),
          const SizedBox(height: 34),
          const StepProgress(total: 3, current: 3),
          const SizedBox(height: 34),
          const Hairline(),
          _ChoiceRow(
            selected: isCreate,
            onTap: () => setState(() => _setup = _Setup.create),
            title: l10n.createStable,
            description: l10n.createStableDesc,
            trailing: AppTag(l10n.roleAdmin, tone: TagTone.sage),
          ),
          const Hairline(),
          _ChoiceRow(
            selected: !isCreate,
            onTap: () => setState(() => _setup = _Setup.join),
            title: l10n.joinStable,
            description: l10n.joinStableDesc,
          ),
          const Hairline(),
          const SizedBox(height: 38),
          if (isCreate) ...[
            AppField(label: l10n.stableName, controller: _stableName),
            const SizedBox(height: 24),
            _LocationField(label: l10n.location, hint: l10n.pinItOnMap),
          ] else
            AppField(
              label: l10n.inviteCode,
              controller: _inviteCode,
              hintText: l10n.inviteCodeHint,
              textStyle: AppText.body(22, height: 1.2, letterSpacing: 3),
            ),
          const SizedBox(height: 40),
          AppButton(
            label: _busy
                ? 'Creating…'
                : (isCreate ? l10n.createStableCta : l10n.joinStableCta),
            onPressed: _busy ? null : _submit,
          ),
          const SizedBox(height: 16),
          Text(
            isCreate ? l10n.createLegal : l10n.joinLegal,
            textAlign: TextAlign.center,
            style: AppText.body(13, height: 1.6, color: AppColors.ink(0.65)),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.selected,
    required this.onTap,
    required this.title,
    required this.description,
    this.trailing,
  });

  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: selected ? 1 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: AppText.heading(22)),
                  if (trailing != null) ...[
                    const SizedBox(width: 14),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: 7),
              Text(
                description,
                style: AppText.body(15, height: 1.45, color: AppColors.ink(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({required this.label, required this.hint});
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Text(label.toUpperCase(), style: AppText.eyebrow()),
        ),
        Material(
          color: AppColors.neutral100,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsetsDirectional.only(start: 16, end: 18),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.accent200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        size: 18, color: AppColors.accent700),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      hint,
                      style: AppText.body(17, color: AppColors.ink(0.55)),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
