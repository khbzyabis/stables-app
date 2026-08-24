import 'package:flutter/material.dart';

import '../../data/basket.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../../widgets/photo_placeholder.dart';
import '../auth/back_link.dart';
import 'basket_screen.dart';

/// Screen 49 — A product. Real details from the marketplace; add it to the
/// basket in the quantity you want.
class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});
  static const route = '/market/item';

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Map<String, dynamic>? _product;
  int _qty = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _product ??= (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
  }

  void _add() {
    final p = _product!;
    Basket.instance.add(BasketLine(
      productId: p['id'] as String,
      name: (p['name'] as String?) ?? 'Product',
      vendorId: p['vendor_id'] as String,
      vendorName: (p['vendor_name'] as String?) ?? 'Seller',
      unitPrice: (p['price_aed'] as num?)?.toDouble() ?? 0,
      unit: p['unit'] as String?,
      qty: _qty,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $_qty to your basket')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final p = _product ?? const {};
    final price = (p['price_aed'] as num?)?.toDouble() ?? 0;
    final name = (p['name'] as String?) ?? 'Product';
    final vendor = (p['vendor_name'] as String?) ?? 'Seller';
    final city = p['vendor_city'] as String?;
    final unit = p['unit'] as String?;
    final desc = p['description'] as String?;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
              child: BackLink(label: l10n.market),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(32, 18, 32, 0),
              child: const PhotoPlaceholder(size: 230, circle: false, radius: 26),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 22, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.heading(30, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                      [vendor, if ((city ?? '').isNotEmpty) city!].join(' · '),
                      style: AppText.body(15, color: AppColors.ink(0.6))),
                  const SizedBox(height: 16),
                  Text('AED ${price.toStringAsFixed(0)}',
                      style: AppText.heading(28)),
                  if (unit != null && unit.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('per $unit',
                        style: AppText.body(14, color: AppColors.ink(0.55))),
                  ],
                  const SizedBox(height: 24),
                  const Hairline(),
                  const SizedBox(height: 20),
                  if (desc != null && desc.isNotEmpty) ...[
                    Text(desc, style: AppText.body(16, height: 1.65)),
                    const SizedBox(height: 24),
                  ],
                  // Quantity stepper.
                  Row(
                    children: [
                      Text('QUANTITY', style: AppText.eyebrow()),
                      const Spacer(),
                      _StepBtn(
                          icon: Icons.remove,
                          onTap: () =>
                              setState(() => _qty = _qty > 1 ? _qty - 1 : 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text('$_qty', style: AppText.heading(20)),
                      ),
                      _StepBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _qty += 1)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  AppButton(
                    label: 'Add to basket · AED ${(price * _qty).toStringAsFixed(0)}',
                    minHeight: 56,
                    fontSize: 17,
                    onPressed: _add,
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(BasketScreen.route)
                        .then((_) => setState(() {})),
                    child: AnimatedBuilder(
                      animation: Basket.instance,
                      builder: (context, _) => Text(
                          l10n.basketWithCount(Basket.instance.count),
                          style:
                              AppText.body(16, color: AppColors.accent700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 20, color: AppColors.text),
      ),
    );
  }
}
