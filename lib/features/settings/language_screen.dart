import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// One selectable language.
class _Lang {
  const _Lang(this.code, this.native, this.meta);
  final String code;
  final String native;
  final String meta;
}

/// Screen 39 — language, per person. Tapping a row switches the whole app
/// (and mirrors the layout for Arabic and Urdu) via the shared controller.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  static const route = '/language';

  static const _langs = <_Lang>[
    _Lang('en', 'English', 'Left to right'),
    _Lang('ar', 'العربية', 'Right to left · the layout mirrors'),
    _Lang('hi', 'हिन्दी', 'Left to right'),
    _Lang('ur', 'اردو', 'Right to left · the layout mirrors'),
    _Lang('bn', 'বাংলা', 'Left to right'),
    _Lang('ne', 'नेपाली', 'Left to right'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final controller = LocaleScope.of(context);
    final current = controller.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'You'),
            const SizedBox(height: 20),
            Text(l10n.language, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('Yours only. Everyone at the stable reads in their own.',
                style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 26),
            const Hairline(),
            for (final lang in _langs) ...[
              InkWell(
                onTap: () => controller.setLocale(Locale(lang.code)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.native,
                                style: AppText.heading(
                                    lang.code == current ? 20 : 18,
                                    color: lang.code == current
                                        ? AppColors.accent700
                                        : AppColors.text)),
                            const SizedBox(height: 4),
                            Text(lang.meta,
                                style: AppText.body(14,
                                    color: AppColors.ink(0.5))),
                          ],
                        ),
                      ),
                      if (lang.code == current)
                        const Icon(Icons.check,
                            size: 20, color: AppColors.accent700),
                    ],
                  ),
                ),
              ),
              const Hairline(),
            ],
          ],
        ),
      ),
    );
  }
}
