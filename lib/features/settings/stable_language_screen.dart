import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 43 — the stable's default language, and who reads what. A new person
/// gets the default before they choose their own.
class StableLanguageScreen extends StatefulWidget {
  const StableLanguageScreen({super.key});
  static const route = '/stable-language';

  @override
  State<StableLanguageScreen> createState() => _StableLanguageScreenState();
}

class _StableLanguageScreenState extends State<StableLanguageScreen> {
  static const _chips = [
    'English',
    'العربية',
    'हिन्दी',
    'اردو',
    'বাংলা',
    'नेपाली'
  ];
  String _default = 'English';
  bool _ownChoice = true;

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
            const BackLink(label: 'Serc'),
            const SizedBox(height: 20),
            Text(l10n.stableLanguage, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('What a new person gets before they choose their own.',
                style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _chips)
                  _Chip(
                    label: c,
                    selected: c == _default,
                    onTap: () => setState(() => _default = c),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const Hairline(),
            InkWell(
              onTap: () => setState(() => _ownChoice = !_ownChoice),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _ownChoice ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _ownChoice
                                ? AppColors.accent
                                : AppColors.neutral400,
                            width: 2),
                      ),
                      child: _ownChoice
                          ? const Icon(Icons.check,
                              size: 16, color: AppColors.bg)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Let people choose their own',
                              style: AppText.body(17, height: 1.35)),
                          const SizedBox(height: 4),
                          Text(
                              _ownChoice
                                  ? 'On · each person picks under You, then Language'
                                  : 'Off · everyone reads the stable default',
                              style: AppText.body(14,
                                  color: AppColors.ink(0.5))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Hairline(),
            const SizedBox(height: 30),
            Text('Who reads what'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 4),
            const Hairline(),
            for (final p in CommsData.peopleLangs) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: AppText.body(17, height: 1.3)),
                          const SizedBox(height: 3),
                          Text(p.role,
                              style: AppText.body(14, color: AppColors.ink(0.5))),
                        ],
                      ),
                    ),
                    Text(p.lang, style: AppText.body(16)),
                  ],
                ),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 20),
            Text('A notice written once reaches all five in their own language.',
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.55))),
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
