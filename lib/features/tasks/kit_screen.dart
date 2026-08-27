import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';

class _KitItem {
  const _KitItem(this.id, this.name, this.detail);
  final String id;
  final String name;
  final String detail;
}

/// Screen 24 — today's kit, as the groom sees it. Named from the horse's setup
/// so the right things go on; tick each as it is prepared.
class KitScreen extends StatefulWidget {
  const KitScreen({super.key});
  static const route = '/kit';

  @override
  State<KitScreen> createState() => _KitScreenState();
}

class _KitScreenState extends State<KitScreen> {
  static const _items = <_KitItem>[
    _KitItem('k1', 'Brown snaffle bridle', 'Full size'),
    _KitItem('k2', 'Loose ring snaffle', '13.5 cm'),
    _KitItem('k3', 'Grackle noseband', 'Not the cavesson'),
    _KitItem('k4', 'Rubber grip reins', 'Brown'),
    _KitItem('k5', 'Woolly girth sleeve', 'Over the girth'),
    _KitItem('k6', 'Front boots', 'Navy pair'),
  ];
  final _done = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            Text('Tuesday 17:00 · Riding'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent700)),
            const SizedBox(height: 10),
            Text('Joy, for Ahmad', style: AppText.heading(40, height: 1.05)),
            const SizedBox(height: 8),
            Text('Box 7 · tack box on the right',
                style: AppText.body(17, color: AppColors.ink(0.6))),
            const SizedBox(height: 22),
            Text('${_done.length} of ${_items.length} ready.',
                style: AppText.body(16, height: 1.5, color: AppColors.ink(0.7))),
            const SizedBox(height: 24),
            const Hairline(),
            for (final it in _items) ...[
              _KitRow(
                item: it,
                done: _done.contains(it.id),
                onTap: () => setState(() => _done.contains(it.id)
                    ? _done.remove(it.id)
                    : _done.add(it.id)),
              ),
              const Hairline(),
            ],
            const SizedBox(height: 26),
            Text('From Ahmad'.toUpperCase(),
                style: AppText.eyebrow(color: AppColors.accent2700)),
            const SizedBox(height: 8),
            Text('Ghazal\'s bridle is in the same box — do not swap the bits.',
                style: AppText.body(17, height: 1.5)),
            const SizedBox(height: 32),
            AppButton(
              label: 'Kit ready',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _KitRow extends StatelessWidget {
  const _KitRow({required this.item, required this.done, required this.onTap});
  final _KitItem item;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? AppColors.accent2 : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: done ? AppColors.accent2 : AppColors.neutral400,
                    width: 2),
              ),
              child: done
                  ? const Icon(Icons.check, size: 17, color: AppColors.bg)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppText.body(17,
                          color: done ? AppColors.ink(0.45) : AppColors.text)
                          .copyWith(
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null)),
                  const SizedBox(height: 3),
                  Text(item.detail,
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
