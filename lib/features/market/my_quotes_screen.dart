import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Buyer view of quote requests — services and transport. Shows the provider's
/// reply when it lands, and lets you accept or decline it.
class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({super.key});
  static const route = '/market/my-quotes';

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  late Future<List<Map<String, dynamic>>> _future =
      SupabaseService.myQuoteRequests();

  void _reload() =>
      setState(() => _future = SupabaseService.myQuoteRequests());

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
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) AppErrors.report(snap.error!);
            final quotes = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
              children: [
                const BackLink(label: 'You'),
                const SizedBox(height: 16),
                Text('My quotes', style: AppText.heading(36, height: 1)),
                const SizedBox(height: 12),
                Text('Prices you have asked providers for — services and '
                    'transport.',
                    style: AppText.body(16,
                        height: 1.5, color: AppColors.ink(0.65))),
                const SizedBox(height: 24),
                const Hairline(),
                if (quotes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('No requests yet. Ask a provider for a price '
                        'from the Market (Services) or Transport.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  ),
                for (final q in quotes) ...[
                  _QuoteRow(
                    quote: q,
                    onAccept: () => _decide(q['id'] as String, 'accepted'),
                    onDecline: () => _decide(q['id'] as String, 'declined'),
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

class _QuoteRow extends StatelessWidget {
  const _QuoteRow(
      {required this.quote, required this.onAccept, required this.onDecline});
  final Map<String, dynamic> quote;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  (String, TagTone) get _tag => switch (quote['status'] as String?) {
        'quoted' => ('Quote in', TagTone.accent),
        'accepted' => ('Accepted', TagTone.sage),
        'declined' => ('Declined', TagTone.neutral),
        _ => ('Waiting', TagTone.neutral),
      };

  @override
  Widget build(BuildContext context) {
    final status = (quote['status'] as String?) ?? 'open';
    final isTransport = quote['kind'] == 'transport';
    final vendor = (quote['vendor_name'] as String?) ?? 'Provider';
    final title = isTransport
        ? '${quote['from_loc'] ?? '?'} → ${quote['to_loc'] ?? '?'}'
        : ((quote['subject'] as String?)?.isNotEmpty == true
            ? quote['subject'] as String
            : 'Service');
    final price = (quote['quote_price'] as num?)?.toDouble();
    final note = quote['quote_note'] as String?;
    final tag = _tag;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('$vendor · $title',
                    style: AppText.heading(18, height: 1.2)),
              ),
              AppTag(tag.$1, tone: tag.$2),
            ],
          ),
          if (price != null) ...[
            const SizedBox(height: 8),
            Text('AED ${price.toStringAsFixed(0)}',
                style: AppText.heading(22)),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(note,
                  style: AppText.body(14, color: AppColors.ink(0.6))),
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
