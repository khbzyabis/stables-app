import 'package:flutter/material.dart';

import '../../data/horse_detail_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';

/// Screen 23 — someone tacked up differently. Keep the default, or make the
/// new version the default. Shows only what changed.
class SetupChangedScreen extends StatefulWidget {
  const SetupChangedScreen({super.key});
  static const route = '/setup-changed';

  @override
  State<SetupChangedScreen> createState() => _SetupChangedScreenState();
}

class _SetupChangedScreenState extends State<SetupChangedScreen> {
  String? _result; // null = pending

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -140,
            child: Container(
              width: 330,
              height: 330,
              decoration: const BoxDecoration(
                  color: AppColors.accent200, shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Setup changed · yesterday 17:00'.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.accent700)),
                  const SizedBox(height: 14),
                  Text(l10n.setupChangedTitle,
                      style: AppText.heading(34, height: 1.05)),
                  const SizedBox(height: 14),
                  Text(l10n.setupChangedBody,
                      style: AppText.body(17,
                          height: 1.5, color: AppColors.ink(0.7))),
                  const SizedBox(height: 30),
                  const Hairline(),
                  for (final (label, was, now) in HorseDetailData.diff) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label.toUpperCase(), style: AppText.eyebrow()),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(was,
                                  style: AppText.body(17,
                                          color: AppColors.ink(0.45))
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough)),
                              const SizedBox(width: 12),
                              Text('→',
                                  style:
                                      AppText.body(15, color: AppColors.ink(0.4))),
                              const SizedBox(width: 12),
                              Text(now, style: AppText.heading(17)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Hairline(),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text('Everything else matched the default.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  ),
                  const Hairline(),
                  const Spacer(),
                  if (_result == null) ...[
                    AppButton(
                      label: l10n.makeFlatworkDefault,
                      onPressed: () =>
                          setState(() => _result = l10n.nowTheDefault),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _result = l10n.keptOldDefault),
                        child: Text(l10n.keepOldDefault,
                            style:
                                AppText.body(16, color: AppColors.accent700)),
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        AppTag(_result!, tone: TagTone.sage),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Text(l10n.backToSetups,
                              style:
                                  AppText.body(16, color: AppColors.accent700)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
