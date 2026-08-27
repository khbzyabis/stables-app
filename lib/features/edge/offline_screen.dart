import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';

class _OffTask {
  const _OffTask(this.id, this.label, this.meta, this.time);
  final String id;
  final String label;
  final String meta;
  final String time;
}

/// Screen 65 — no signal in the barn. Ticks are kept on the phone and sent when
/// signal returns; a dark banner makes the offline state unmistakable.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});
  static const route = '/offline';

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  static const _tasks = <_OffTask>[
    _OffTask('o1', 'Morning feed, all 14 horses', 'Saved on this phone', '06:30'),
    _OffTask('o2', 'Turn out the front six', 'Saved on this phone', '07:15'),
    _OffTask('o3', 'Tack up Joy for flatwork', 'Saved on this phone', '08:45'),
    _OffTask('o4', 'Poultice Comme Ci, left fore', 'Sam · by Friday', '10:00'),
    _OffTask('o5', 'Sweep the yard', 'Ahmad · daily', '12:00'),
    _OffTask('o6', 'Evening feed', 'Ahmad · daily', '17:00'),
  ];
  final _done = <String>{'o1', 'o2', 'o3'};

  @override
  Widget build(BuildContext context) {
    final queued = _done.length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.neutral800,
            padding: const EdgeInsets.fromLTRB(32, 60, 32, 14),
            child: Row(
              children: [
                Icon(Icons.wifi_off,
                    size: 18, color: AppColors.neutral100),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                      'No signal · ${queued == 0 ? 'nothing waiting' : '$queued ticks saved on this phone'}',
                      style: AppText.body(14,
                          height: 1.35, color: AppColors.neutral100)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(32, 22, 32, 40),
              children: [
                Text('Rasil · groom · Tuesday',
                    style: AppText.body(13, color: AppColors.accent700)),
                const SizedBox(height: 8),
                Text('Your tasks', style: AppText.heading(32, height: 1.05)),
                const SizedBox(height: 8),
                Text('$queued of 6 done · $queued waiting to send',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
                const SizedBox(height: 22),
                const Hairline(),
                for (final t in _tasks) ...[
                  _TaskRow(
                    task: t,
                    done: _done.contains(t.id),
                    onTap: () => setState(() => _done.contains(t.id)
                        ? _done.remove(t.id)
                        : _done.add(t.id)),
                  ),
                  const Hairline(),
                ],
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                      'Keep working. Ticks are kept on the phone and sent the moment you have signal again. Nothing is lost if the app closes.',
                      style: AppText.body(15, height: 1.6)),
                ),
                const SizedBox(height: 24),
                Text('Not available offline'.toUpperCase(),
                    style: AppText.eyebrow()),
                const SizedBox(height: 10),
                Opacity(
                  opacity: 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The market, quotes and payments',
                          style: AppText.body(15)),
                      const SizedBox(height: 9),
                      Text('Messages to the stable', style: AppText.body(15)),
                      const SizedBox(height: 9),
                      Text('Anything a vet or farrier wrote today',
                          style: AppText.body(15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.done, required this.onTap});
  final _OffTask task;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(task.label,
                      style: AppText.body(17,
                              color:
                                  done ? AppColors.ink(0.45) : AppColors.text)
                          .copyWith(
                              decoration:
                                  done ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: 3),
                  Text(task.meta,
                      style: AppText.body(14, color: AppColors.ink(0.5))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(task.time,
                style: AppText.body(14, color: AppColors.ink(0.45))),
          ],
        ),
      ),
    );
  }
}
