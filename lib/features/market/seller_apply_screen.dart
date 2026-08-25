import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'provider_vendor_screen.dart';

/// Apply to sell (P0a–P0c). Pick trades, upload the papers each needs, accept
/// the seller agreement. Submitting creates a pending shop the operator reviews.
class SellerApplyScreen extends StatefulWidget {
  const SellerApplyScreen({super.key});
  static const route = '/market/apply';

  @override
  State<SellerApplyScreen> createState() => _SellerApplyScreenState();
}

class _SellerApplyScreenState extends State<SellerApplyScreen> {
  int _step = 0;
  final _name = TextEditingController();
  final _location = TextEditingController(text: 'Dubai');
  final _trades = <String>{};
  final _uploaded = <String, String>{}; // doc_id → storage_path
  final _labels = <String, String>{}; // doc_id → label
  final _uploading = <String>{};
  bool _agreement = false;
  bool _submitting = false;
  Map<String, dynamic>? _createdVendor;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _docs => SupabaseService.requiredDocs(_trades);
  bool get _allDocsIn => _docs.every((d) => _uploaded.containsKey(d['id']));

  Future<void> _pickDoc(String docId, String label) async {
    setState(() => _uploading.add(docId));
    try {
      final picked = await FilePicker.platform.pickFiles(withData: true);
      final file = picked?.files.firstOrNull;
      if (file?.bytes != null) {
        final path = await SupabaseService.uploadSellerDoc(
            fileName: file!.name, bytes: file.bytes!);
        setState(() {
          _uploaded[docId] = path;
          _labels[docId] = label;
        });
      }
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppL10n.of(context).saCouldntUpload('$e'))));
      }
    } finally {
      if (mounted) setState(() => _uploading.remove(docId));
    }
  }

  Future<void> _submit() async {
    if (!_agreement) return;
    setState(() => _submitting = true);
    try {
      final res = await SupabaseService.submitSellerApplication(
        tradingName: _name.text.trim(),
        trades: _trades,
        location: _location.text.trim(),
        docs: [
          for (final d in _docs)
            if (_uploaded[d['id']] != null)
              {
                'doc_type': d['id'],
                'label': d['label'],
                'storage_path': _uploaded[d['id']],
              }
        ],
      );
      if (mounted) {
        setState(() {
          _createdVendor = res['vendor'] as Map<String, dynamic>?;
          _step = 2;
        });
      }
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppL10n.of(context).saCouldntSend('$e'))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: switch (_step) {
          0 => _trades0(),
          1 => _papers1(),
          _ => _waiting2(),
        },
      ),
    );
  }

  Widget _bars(int active) => Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= active ? AppColors.accent : AppColors.neutral300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 6),
            ],
          ],
        ),
      );

  // ---- Step 1: trades --------------------------------------------------
  Widget _trades0() {
    final l10n = AppL10n.of(context);
    final canContinue = _trades.isNotEmpty && _name.text.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
      children: [
        BackLink(label: l10n.sellOnTheMarket),
        const SizedBox(height: 18),
        Text(l10n.saStepOf(1), style: AppText.eyebrow(color: AppColors.accent700)),
        const SizedBox(height: 10),
        Text(l10n.saWhatDoYouDo, style: AppText.heading(34, height: 1.05)),
        const SizedBox(height: 10),
        Text(l10n.saWhatSub,
            style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
        const SizedBox(height: 24),
        _bars(0),
        const Hairline(),
        for (final t in SupabaseService.sellerTrades) ...[
          _CheckRow(
            label: t['label']!,
            sub: t['needs']!,
            checked: _trades.contains(t['id']),
            onTap: () => setState(() {
              _trades.contains(t['id'])
                  ? _trades.remove(t['id'])
                  : _trades.add(t['id']!);
            }),
          ),
          const Hairline(),
        ],
        const SizedBox(height: 22),
        AppField(label: l10n.saTradingName, controller: _name),
        const SizedBox(height: 16),
        AppField(label: l10n.saWhereYouWork, controller: _location),
        const SizedBox(height: 26),
        AppButton(
          label: _trades.isEmpty
              ? l10n.saPickWhat
              : l10n.saContinueTrades(_trades.length),
          onPressed: canContinue ? () => setState(() => _step = 1) : null,
        ),
        const SizedBox(height: 14),
        Text(l10n.saVerifiedNote,
            style: AppText.body(14, height: 1.5, color: AppColors.ink(0.55))),
      ],
    );
  }

  // ---- Step 2: papers + agreement -------------------------------------
  Widget _papers1() {
    final l10n = AppL10n.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
      children: [
        GestureDetector(
          onTap: () => setState(() => _step = 0),
          child: Text('← ${l10n.saBack}',
              style: AppText.body(15, color: AppColors.ink(0.55))),
        ),
        const SizedBox(height: 18),
        Text(l10n.saStepOf(2), style: AppText.eyebrow(color: AppColors.accent700)),
        const SizedBox(height: 10),
        Text(l10n.saYourPapers, style: AppText.heading(34, height: 1.05)),
        const SizedBox(height: 10),
        Text(l10n.saPapersSub,
            style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
        const SizedBox(height: 24),
        _bars(1),
        for (final d in _docs) ...[
          _DocRow(
            label: d['label']!,
            meta: _uploaded.containsKey(d['id'])
                ? l10n.saUploaded
                : d['meta']!,
            done: _uploaded.containsKey(d['id']),
            busy: _uploading.contains(d['id']),
            doneTag: l10n.saDoneTag,
            neededTag: l10n.saNeededTag,
            onTap: () => _pickDoc(d['id']!, d['label']!),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        const Hairline(),
        InkWell(
          onTap: () => setState(() => _agreement = !_agreement),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(checked: _agreement),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(text: l10n.saAcceptPre),
                        TextSpan(
                            text: l10n.saSellerAgreement,
                            style: TextStyle(color: AppColors.accent700)),
                      ]), style: AppText.body(16, height: 1.4)),
                      const SizedBox(height: 5),
                      Text(l10n.saAgreementSub,
                          style: AppText.body(14,
                              height: 1.45, color: AppColors.ink(0.55))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Hairline(),
        const SizedBox(height: 22),
        if (_submitting)
          const Center(child: CircularProgressIndicator())
        else
          AppButton(
            label: l10n.saSend,
            onPressed: (_agreement && _allDocsIn) ? _submit : null,
          ),
        if (!_agreement) ...[
          const SizedBox(height: 12),
          Text(l10n.saAcceptToSend,
              style: AppText.body(14, color: AppColors.accent700)),
        ] else if (!_allDocsIn) ...[
          const SizedBox(height: 12),
          Text(l10n.saUploadAllToSend,
              style: AppText.body(14, color: AppColors.accent700)),
        ],
      ],
    );
  }

  // ---- Step 3: submitted ----------------------------------------------
  Widget _waiting2() {
    final l10n = AppL10n.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent2, width: 4),
          ),
          child: const Icon(Icons.check, color: AppColors.accent2600),
        ),
        const SizedBox(height: 26),
        Text(l10n.saWithMyStables, style: AppText.heading(34, height: 1.05)),
        const SizedBox(height: 12),
        Text(l10n.saSentBody,
            style: AppText.body(17, height: 1.55, color: AppColors.ink(0.7))),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.saInMeantime, style: AppText.eyebrow()),
              const SizedBox(height: 7),
              Text(l10n.saMeantimeBody, style: AppText.body(16, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: l10n.saSetUpShop,
          onPressed: () {
            if (_createdVendor != null) {
              Navigator.of(context).pushReplacementNamed(
                  ProviderVendorScreen.route,
                  arguments: _createdVendor);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Center(
            child: Text(l10n.saBackToShops,
                style: AppText.body(16, color: AppColors.accent700)),
          ),
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(
      {required this.label,
      required this.sub,
      required this.checked,
      required this.onTap});
  final String label;
  final String sub;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            _Box(checked: checked),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.body(17, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(sub,
                      style: AppText.body(14, color: AppColors.ink(0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow(
      {required this.label,
      required this.meta,
      required this.done,
      required this.busy,
      required this.doneTag,
      required this.neededTag,
      required this.onTap});
  final String label;
  final String meta;
  final bool done;
  final bool busy;
  final String doneTag;
  final String neededTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
            style: done ? BorderStyle.solid : BorderStyle.none,
          ),
          color: done ? Colors.transparent : AppColors.neutral100,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: done ? AppColors.accent2 : AppColors.neutral200,
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2))
                  : Icon(done ? Icons.check : Icons.add,
                      color: done ? AppColors.bg : AppColors.accent700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.body(17, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(meta,
                      style: AppText.body(14, color: AppColors.ink(0.6))),
                ],
              ),
            ),
            Text(done ? doneTag : neededTag,
                style: AppText.body(11,
                    letterSpacing: 0.6,
                    color: done ? AppColors.accent2700 : AppColors.neutral700)),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? AppColors.accent2600 : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? AppColors.accent2600 : AppColors.ink(0.35),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 16, color: AppColors.bg)
          : null,
    );
  }
}
