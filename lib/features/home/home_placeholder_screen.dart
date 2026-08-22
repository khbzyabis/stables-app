import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';

/// Foundation placeholder for the post-auth app. The home screen, the yard and
/// the tab bar (screens 6+) are not part of this first pass.
///
/// It doubles as a live demonstration of the i18n + RTL scaffolding: picking a
/// language switches the whole app, and Arabic/Urdu mirror the layout.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});
  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final controller = LocaleScope.of(context);
    final current = controller.locale.languageCode;

    final languages = <(String code, String name)>[
      ('en', l10n.langEnglish),
      ('ar', l10n.langArabic),
      ('hi', l10n.langHindi),
      ('ur', l10n.langUrdu),
      ('bn', l10n.langBengali),
      ('ne', l10n.langNepali),
    ];

    return AppScreen(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOUNDATION', style: AppText.eyebrow()),
          const SizedBox(height: 10),
          Text(l10n.welcomeBack, style: AppText.heading(34, height: 1.05)),
          const SizedBox(height: 12),
          Text(
            'Auth flow complete. Home, the yard and the market come next.',
            style: AppText.body(16, color: AppColors.ink(0.6)),
          ),
          const SizedBox(height: 34),
          Text(l10n.language.toUpperCase(), style: AppText.eyebrow()),
          const SizedBox(height: 12),
          HairlineList(
            children: [
              for (final (code, name) in languages)
                _LanguageRow(
                  name: name,
                  selected: code == current,
                  isRtl: code == 'ar' || code == 'ur',
                  onTap: () => controller.setLocale(Locale(code)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.name,
    required this.selected,
    required this.isRtl,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final bool isRtl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppText.heading(19,
                    weight: selected ? FontWeight.w600 : FontWeight.w500),
              ),
            ),
            if (isRtl) ...[
              const AppTag('RTL', tone: TagTone.neutral),
              const SizedBox(width: 12),
            ],
            if (selected)
              const Icon(Icons.check, color: AppColors.accent2600, size: 22),
          ],
        ),
      ),
    );
  }
}
