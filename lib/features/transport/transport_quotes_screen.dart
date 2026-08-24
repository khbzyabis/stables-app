import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 57 — your transport requests and the transporters' replies. Accept a
/// quote when one lands.
class TransportQuotesScreen extends StatefulWidget {
  const TransportQuotesScreen({super.key});
  static const route = '/transport/quotes';

  @override
  State<TransportQuotesScreen> createState() => _TransportQuotesScreenState();
}

class _TransportQuotesScreenState extends State<TransportQuotesScreen> {
  late Future<List<Map<String, dynamic>>> _future =
      SupabaseService.myQuoteRequests(kind: 'transport');

  void _reload() => setState(
      () => _future = SupabaseService.myQuoteRequests(kind: 'transport'));

  Future<void> _decide(String id, String status) async {
    try {
      await SupabaseService.setQuoteStatus(id, status);
      _reload();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't update: $e")));
      }
    }
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
            if (snap.hasError) AppErrors.report(snap.error!);
            final reqs = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 44),
              children: [
                const BackLink(label: 'Back'),
                const SizedBox(height: 18),
                Text('Transport', style: AppText.heading(34, height: 1.05)),
                const SizedBox(height: 8),
                Text('Your requests, and the price each transporter sends back.',
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
                    _RequestRow(
                      req: r,
                      onAccept: () => _decide(r['id'] as String, 'accepted'),
                      onDecline: () => _decide(r['id'] as String, 'declined'),
                    ),
                    const Hairline(),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow(
      {required this.req, required this.onAccept, required this.onDecline});
  final Map<String, dynamic> req;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  (String, TagTone) get _tag => switch (req['status'] as String?) {
        'quoted' => ('Quote in', TagTone.accent),
        'accepted' => ('Accepted', TagTone.sage),
        'declined' => ('Declined', TagTone.neutral),
        _ => ('Waiting on quote', TagTone.neutral),
      };

  @override
  Widget build(BuildContext context) {
    final status = (req['status'] as String?) ?? 'open';
    final vendor = (req['vendor_name'] as String?) ?? 'Transporter';
    final price = (req['quote_price'] as num?)?.toDouble();
    final note = req['quote_note'] as String?;
    final tag = _tag;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${req['from_loc']}  →  ${req['to_loc']}',
                    style: AppText.heading(19, height: 1.25)),
              ),
              const SizedBox(width: 10),
              AppTag(tag.$1, tone: tag.$2),
            ],
          ),
          const SizedBox(height: 5),
          Text(vendor, style: AppText.body(14, color: AppColors.ink(0.55))),
          if ((req['on_day'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 3),
            Text(req['on_day'] as String,
                style: AppText.body(14, color: AppColors.ink(0.5))),
          ],
          if (price != null) ...[
            const SizedBox(height: 8),
            Text('AED ${price.toStringAsFixed(0)}', style: AppText.heading(22)),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(note, style: AppText.body(14, color: AppColors.ink(0.6))),
            ],
          ],
          if (status == 'quoted') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                AppButton(
                  label: 'Accept',
                  block: false,
                  minHeight: 44,
                  fontSize: 15,
                  onPressed: onAccept,
                ),
                const SizedBox(width: 10),
                AppButton(
                  label: 'Decline',
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 44,
                  fontSize: 15,
                  onPressed: onDecline,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
