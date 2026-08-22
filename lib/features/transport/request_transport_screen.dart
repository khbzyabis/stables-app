import 'package:flutter/material.dart';

import '../../data/stable_store.dart';
import '../../data/transport_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transport.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'transport_quotes_screen.dart';

/// Screen 56 — Request transport. Two addresses as a journey, horses, and what
/// a transporter needs to know. The note under the button changes with the why.
class RequestTransportScreen extends StatefulWidget {
  const RequestTransportScreen({super.key});
  static const route = '/transport';

  @override
  State<RequestTransportScreen> createState() => _RequestTransportScreenState();
}

class _RequestTransportScreenState extends State<RequestTransportScreen> {
  int _why = 0;
  final Set<String> _horses = {'Kiki'};
  final Set<int> _needs = {0, 2};
  final _from = TextEditingController(text: 'Serc · Al Qudra Rd');
  final _to = TextEditingController(text: 'Al Qudra Arena');
  final _day = TextEditingController(text: 'Sat 29 Aug');
  final _by = TextEditingController(text: '07:30');

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _day.dispose();
    _by.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final reasons = TransportData.reasons;
    final horses = StableScope.of(context).horses;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            const BackLink(label: 'Back'),
            const SizedBox(height: 20),
            Text(l10n.pickUpDeliver, style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(l10n.transportIntro,
                  style: AppText.body(16, height: 1.5, color: AppColors.ink(0.6))),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < reasons.length; i++)
                  _Chip(
                    label: reasons[i].label,
                    selected: i == _why,
                    onTap: () => setState(() => _why = i),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _JourneyFields(from: _from, to: _to, l10n: l10n),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AppField(label: l10n.fieldDay, controller: _day)),
                const SizedBox(width: 12),
                Expanded(child: AppField(label: l10n.thereBy, controller: _by)),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.whichHorses.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in horses)
                  _Chip(
                    label: h.name,
                    selected: _horses.contains(h.name),
                    onTap: () => setState(() {
                      _horses.contains(h.name)
                          ? _horses.remove(h.name)
                          : _horses.add(h.name);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.whatToKnow.toUpperCase(), style: AppText.eyebrow()),
            const SizedBox(height: 4),
            const Hairline(),
            for (var i = 0; i < TransportData.needs.length; i++) ...[
              _NeedRow(
                need: TransportData.needs[i],
                checked: _needs.contains(i),
                onToggle: () => setState(() {
                  _needs.contains(i) ? _needs.remove(i) : _needs.add(i);
                }),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Ask 4 companies · ${_horses.length} '
                  '${_horses.length == 1 ? "horse" : "horses"}',
              minHeight: 56,
              fontSize: 17,
              onPressed: _horses.isEmpty
                  ? null
                  : () => Navigator.of(context)
                      .pushNamed(TransportQuotesScreen.route),
            ),
            const SizedBox(height: 14),
            Text(reasons[_why].note,
                style: AppText.body(14, height: 1.55, color: AppColors.ink(0.55))),
          ],
        ),
      ),
    );
  }
}

class _JourneyFields extends StatelessWidget {
  const _JourneyFields({required this.from, required this.to, required this.l10n});
  final TextEditingController from;
  final TextEditingController to;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 34),
          child: Column(
            children: [
              Container(
                width: 11, height: 11,
                decoration: const BoxDecoration(
                    color: AppColors.accent2, shape: BoxShape.circle),
              ),
              Container(width: 2, height: 70, color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(vertical: 4)),
              Container(
                width: 11, height: 11,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              AppField(label: l10n.fieldFrom, controller: from),
              const SizedBox(height: 14),
              AppField(label: l10n.fieldTo, controller: to),
            ],
          ),
        ),
      ],
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

class _NeedRow extends StatelessWidget {
  const _NeedRow(
      {required this.need, required this.checked, required this.onToggle});
  final TransportNeed need;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24, height: 24,
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
                  Text(need.label, style: AppText.body(16, height: 1.35)),
                  const SizedBox(height: 4),
                  Text(need.meta,
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
