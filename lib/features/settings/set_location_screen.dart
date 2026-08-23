import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 46 — set the stable's location. A stylised map with a draggable pin,
/// the resolved address, and a choice of how precisely to show it.
class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({super.key});
  static const route = '/set-location';

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  bool _public = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackLink(label: 'Serc'),
                  const SizedBox(height: 18),
                  Text(l10n.whereIsStable,
                      style: AppText.heading(34, height: 1.05)),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            cursorColor: AppColors.accent,
                            style: AppText.body(16),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search a place or address',
                              hintStyle:
                                  AppText.body(16, color: AppColors.ink(0.45)),
                            ),
                          ),
                        ),
                        Icon(Icons.search,
                            size: 20, color: AppColors.ink(0.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                color: AppColors.neutral200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _MapPainter()),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Pin(),
                            SizedBox(
                                height: 16,
                                child: VerticalDivider(
                                    color: AppColors.accent, width: 2)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          shape: BoxShape.circle,
                          boxShadow: AppShadow.md,
                        ),
                        child: Icon(Icons.my_location,
                            size: 21, color: AppColors.accent700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 22, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pin is here'.toUpperCase(),
                      style: AppText.eyebrow(color: AppColors.accent2700)),
                  const SizedBox(height: 8),
                  Text('Serc · Al Qudra Rd, Seih Al Salam, Dubai',
                      style: AppText.body(18, height: 1.4)),
                  const SizedBox(height: 6),
                  Text('24.8231° N, 55.2708° E',
                      style: AppText.body(14, color: AppColors.ink(0.5))),
                  const SizedBox(height: 20),
                  const Hairline(),
                  InkWell(
                    onTap: () => setState(() => _public = !_public),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _public
                                  ? AppColors.accent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _public
                                      ? AppColors.accent
                                      : AppColors.neutral400,
                                  width: 2),
                            ),
                            child: _public
                                ? const Icon(Icons.check,
                                    size: 16, color: AppColors.bg)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Show the exact pin to everyone',
                                    style: AppText.body(16, height: 1.35)),
                                const SizedBox(height: 4),
                                Text(
                                    _public
                                        ? 'Riders, staff and the vet get directions straight to the gate'
                                        : 'Only the area is shown until someone joins the stable',
                                    style: AppText.body(14,
                                        height: 1.4,
                                        color: AppColors.ink(0.5))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Hairline(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      AppButton(
                        label: l10n.saveLocation,
                        block: false,
                        minHeight: 54,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        label: l10n.directions,
                        variant: AppButtonVariant.secondary,
                        block: false,
                        minHeight: 54,
                        fontSize: 16,
                        onPressed: () {},
                      ),
                    ],
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

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        boxShadow: AppShadow.md,
      ),
      child: const Icon(Icons.home, size: 20, color: AppColors.bg),
    );
  }
}

/// A soft, abstract map: sand ground, a couple of roads and green patches.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE6DCC6));

    void road(Offset a, Offset b, Offset c, double width, Color color) {
      final p = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy);
      canvas.drawPath(
          p,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width);
    }

    road(Offset(-20, h * 0.36), Offset(w * 0.5, h * 0.29), Offset(w + 20, h * 0.39),
        26, const Color(0xFFD5C8AC));
    road(Offset(w * 0.3, -20), Offset(w * 0.37, h * 0.48), Offset(w * 0.3, h + 20),
        20, const Color(0xFFD5C8AC));
    road(Offset(w * 0.7, -20), Offset(w * 0.65, h * 0.45), Offset(w * 0.75, h + 20),
        14, const Color(0xFFDDD1B7));

    final green = Paint()..color = const Color(0xFFCFD8BD);
    canvas.drawCircle(Offset(w * 0.82, h * 0.17), 62, green);
    canvas.drawCircle(Offset(w * 0.13, h * 0.93), 70, green);

    final block = Paint()..color = const Color(0xFFDCCFB2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.42, h * 0.5, 76, 52), const Radius.circular(9)),
        block);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.24, h * 0.56, 48, 40), const Radius.circular(8)),
        block);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
