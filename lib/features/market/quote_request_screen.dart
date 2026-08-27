import 'package:flutter/material.dart';

import '../../data/orders_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'compare_quotes_screen.dart';

/// Screen 52 — Ask for a price. Request a quote from several providers at once;
/// they see how many others were asked, not who.
class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({super.key});
  static const route = '/market/ask';

  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  int _kind = 0;
  final _horses = TextEditingController(text: 'Joy, Comme Ci');
  final _when = TextEditingController(text: 'This Thursday or Friday');
  final Set<int> _asked = {0, 1};

  @override
  void dispose() {
    _horses.dispose();
    _when.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final kinds = OrdersData.quoteKinds;
    final people = OrdersData.askList;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: l10n.market),
            const SizedBox(height: 22),
            Text(l10n.askForPrice, style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(l10n.askSubtitle,
                  style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            ),
            const SizedBox(height: 24),
            Text(l10n.whatFor.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < kinds.length; i++)
                  _Chip(
                    label: kinds[i],
                    selected: i == _kind,
                    onTap: () => setState(() => _kind = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            AppField(label: l10n.whichHorses, controller: _horses),
            const SizedBox(height: 16),
            AppField(label: l10n.whenNeeded, controller: _when),
            const SizedBox(height: 24),
            Text(l10n.whoToAsk.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 4),
            const Hairline(),
            for (var i = 0; i < people.length; i++) ...[
              _AskRow(
                name: people[i].$1,
                meta: people[i].$2,
                checked: _asked.contains(i),
                onToggle: () => setState(() {
                  _asked.contains(i) ? _asked.remove(i) : _asked.add(i);
                }),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: l10n.sendRequest,
              minHeight: 56,
              fontSize: 17,
              onPressed: _asked.isEmpty
                  ? null
                  : () => Navigator.of(context)
                      .pushNamed(CompareQuotesScreen.route),
            ),
            const SizedBox(height: 14),
            Text(l10n.othersAskedNote,
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.55))),
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

class _AskRow extends StatelessWidget {
  const _AskRow({
    required this.name,
    required this.meta,
    required this.checked,
    required this.onToggle,
  });
  final String name;
  final String meta;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.body(16, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(meta,
                      style: AppText.body(13, color: AppColors.ink(0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
