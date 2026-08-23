import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 57 — the stable's transport requests. Each saved request waits on
/// transporters to quote (quotes arrive from the provider app).
class TransportQuotesScreen extends StatefulWidget {
  const TransportQuotesScreen({super.key});
  static const route = '/transport/quotes';

  @override
  State<TransportQuotesScreen> createState() => _TransportQuotesScreenState();
}

class _TransportQuotesScreenState extends State<TransportQuotesScreen> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.transportRequests(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            final reqs = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                const BackLink(label: 'Back'),
                const SizedBox(height: 18),
                Text('Transport', style: AppText.heading(34, height: 1.05)),
                const SizedBox(height: 8),
                Text('Your requests. Transporters quote on each one.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
                const SizedBox(height: 22),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (reqs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('No requests yet.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  )
                else
                  for (final r in reqs) ...[
                    _RequestRow(req: r),
                    const Hairline(),
                  ],
                const SizedBox(height: 22),
                Text(
                    'Quotes come back from transport companies through their own app. When one arrives you can accept it here.',
                    style: AppText.body(14,
                        height: 1.55, color: AppColors.ink(0.5))),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.req});
  final Map<String, dynamic> req;

  @override
  Widget build(BuildContext context) {
    final horses = (req['horses'] as List?)?.join(', ') ?? '';
    final when = [req['on_day'], req['there_by']]
        .where((e) => e != null && (e as String).isNotEmpty)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                    '${req['from_loc']}  →  ${req['to_loc']}',
                    style: AppText.heading(19, height: 1.25)),
              ),
              const SizedBox(width: 10),
              AppTag((req['status'] as String?) ?? 'Waiting on quotes',
                  tone: TagTone.accent),
            ],
          ),
          const SizedBox(height: 6),
          if (horses.isNotEmpty)
            Text(horses, style: AppText.body(15, color: AppColors.ink(0.6))),
          if (when.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(when, style: AppText.body(14, color: AppColors.ink(0.5))),
          ],
        ],
      ),
    );
  }
}
