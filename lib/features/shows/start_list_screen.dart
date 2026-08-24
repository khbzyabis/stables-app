import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 55 — the start list: everyone entered in this show, in order, with
/// their time. Entries from your own stable are highlighted.
class StartListScreen extends StatefulWidget {
  const StartListScreen({super.key});
  static const route = '/start-list';

  @override
  State<StartListScreen> createState() => _StartListScreenState();
}

class _StartListScreenState extends State<StartListScreen> {
  Map<String, dynamic>? _show;
  Future<List<Map<String, dynamic>>>? _entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_show != null) return;
    _show = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    final id = _show?['id'] as String?;
    _entries = id == null
        ? Future.value(const [])
        : SupabaseService.showEntries(id);
  }

  @override
  Widget build(BuildContext context) {
    final name = (_show?['name'] as String?) ?? 'Show';
    final me = SupabaseService.displayName;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
          children: [
            const BackLink(label: 'Show'),
            const SizedBox(height: 16),
            Text('Start list', style: AppText.heading(34, height: 1.05)),
            const SizedBox(height: 6),
            Text(name, style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _entries,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) AppErrors.report(snap.error!);
                final entries = (snap.data ?? const [])
                    .where((e) => e['status'] != 'withdrawn')
                    .toList();
                if (entries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('Nobody is entered yet.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      _StartRow(
                        no: i + 1,
                        entry: entries[i],
                        mine: (entries[i]['rider_name'] as String?) == me,
                      ),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text('Order follows entry time where given, then when each was '
                'entered. Times can move on the day.',
                style: AppText.body(13, height: 1.5, color: AppColors.ink(0.5))),
          ],
        ),
      ),
    );
  }
}

class _StartRow extends StatelessWidget {
  const _StartRow({required this.no, required this.entry, required this.mine});
  final int no;
  final Map<String, dynamic> entry;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final rider = (entry['rider_name'] as String?) ?? '';
    final horse = (entry['horse_name'] as String?) ?? 'Horse';
    final at = entry['at_time'] as String?;
    return Container(
      color: mine ? AppColors.accent200.withValues(alpha: 0.5) : null,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text('$no',
                style: AppText.heading(18, color: AppColors.ink(0.5))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(horse, style: AppText.heading(18, height: 1.2)),
                if (rider.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(rider,
                      style: AppText.body(14, color: AppColors.ink(0.55))),
                ],
              ],
            ),
          ),
          if (mine) ...[
            const AppTag('You', tone: TagTone.accent),
            const SizedBox(width: 10),
          ],
          if (at != null && at.isNotEmpty)
            Text(at, style: AppText.heading(16)),
        ],
      ),
    );
  }
}
