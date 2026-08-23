import 'package:flutter/material.dart';
import '../../data/errors.dart';

import '../../data/comms_data.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 26 — post a notice. Choose who sees it, whether it pins, and whether
/// people are asked to confirm they read it.
class PostNoticeScreen extends StatefulWidget {
  const PostNoticeScreen({super.key});
  static const route = '/post-notice';

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  String _audience = 'Everyone';
  bool _pin = false;
  bool _ask = false;
  bool _busy = false;
  final _body = TextEditingController();

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final stableId = SessionScope.of(context).activeStableId;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final body = _body.text.trim();
    if (body.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Write the notice first.')));
      return;
    }
    if (stableId == null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Create a stable first, then post to it.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await SupabaseService.postNotice(
          stableId: stableId, body: body, pinned: _pin);
      navigator.pop();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not post: $e')));
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
            Text(l10n.newNotice, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 28),
            Text(l10n.notice.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _body,
                maxLines: 4,
                cursorColor: AppColors.accent,
                style: AppText.body(17, height: 1.5),
                decoration: InputDecoration.collapsed(
                  hintText:
                      'Hay delivery Wednesday — keep the top gateway clear.',
                  hintStyle: AppText.body(17, color: AppColors.ink(0.45)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(l10n.whoSeesIt.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in CommsData.audiences)
                  _Chip(
                    label: a,
                    selected: a == _audience,
                    onTap: () => setState(() => _audience = a),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            const Hairline(),
            _CheckRow(
              label: l10n.pinToTop,
              value: _pin,
              onTap: () => setState(() => _pin = !_pin),
            ),
            const Hairline(),
            _CheckRow(
              label: l10n.askConfirmRead,
              value: _ask,
              onTap: () => setState(() => _ask = !_ask),
            ),
            const Hairline(),
            const SizedBox(height: 34),
            AppButton(
              label: _busy ? 'Posting…' : l10n.postNotice,
              onPressed: _busy ? null : _post,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: value ? AppColors.accent : AppColors.neutral400,
                    width: 2),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: AppColors.bg)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppText.body(17))),
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
