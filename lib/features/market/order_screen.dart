import 'package:flutter/material.dart';

import '../../data/orders_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/market.dart';
import '../../models/orders.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';

/// Screen 51 — An order. A four-step timeline ending at "seller paid, once the
/// return window closes". Raising a problem opens reason chips whose placeholder
/// changes per reason; the seller answers first, then My Stables arbitrates.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  static const route = '/market/order';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _returnOpen = false;
  int _reason = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final o = OrdersData.order;
    final reasons = OrdersData.returnReasons;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
          children: [
            BackLink(label: l10n.orders),
            const SizedBox(height: 22),
            Text(o.ref, style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 9),
            Text(o.seller, style: AppText.heading(32, height: 1.05)),
            const SizedBox(height: 24),
            for (var i = 0; i < o.steps.length; i++)
              _TimelineStep(step: o.steps[i], isLast: i == o.steps.length - 1),
            const SizedBox(height: 8),
            const Hairline(),
            for (final l in o.lines) ...[
              _OrderLine(line: l),
              const Hairline(),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(o.paidLabel,
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  ),
                  Text(o.total, style: AppText.heading(17)),
                ],
              ),
            ),
            const Hairline(),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _returnOpen = !_returnOpen),
              child: Text(l10n.somethingWrong,
                  style: AppText.body(16, color: AppColors.accent700)),
            ),
            const SizedBox(height: 14),
            Text(l10n.buyAgain,
                style: AppText.body(16, color: AppColors.ink(0.6))),
            if (_returnOpen) ...[
              const SizedBox(height: 22),
              Text(l10n.whatIsWrong.toUpperCase(), style: AppText.eyebrow()),
              const SizedBox(height: 11),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < reasons.length; i++)
                    _ReasonChip(
                      label: reasons[i].label,
                      selected: i == _reason,
                      onTap: () => setState(() => _reason = i),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                cursorColor: AppColors.accent,
                style: AppText.body(16, height: 1.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.neutral100,
                  hintText: reasons[_reason].placeholder,
                  hintStyle: AppText.body(16, height: 1.5, color: AppColors.ink(0.45)),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.sendToMyStables,
                minHeight: 52,
                fontSize: 16,
                onPressed: () => setState(() => _returnOpen = false),
              ),
              const SizedBox(height: 14),
              Text(l10n.sellerAnswersFirst,
                  style: AppText.body(14, height: 1.55, color: AppColors.ink(0.55))),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});
  final OrderStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 13,
                height: 13,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.done ? AppColors.accent2 : AppColors.bg,
                  border: Border.all(
                    color: step.done ? AppColors.accent2 : AppColors.ink(0.35),
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.divider),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: AppText.body(17, height: 1.3).copyWith(
                        color: step.done ? AppColors.text : AppColors.ink(0.6),
                      )),
                  const SizedBox(height: 4),
                  Text(step.when,
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({required this.line});
  final BasketLine line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const PhotoPlaceholder(size: 52, circle: false, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: AppText.body(16, height: 1.3)),
                const SizedBox(height: 4),
                Text(line.detail,
                    style: AppText.body(13, color: AppColors.ink(0.5))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(line.price, style: AppText.body(16)),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip(
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
