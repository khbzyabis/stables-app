import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'seller_dashboard_screen.dart';
import 'seller_apply_screen.dart';

/// Seller dashboard — the shops you run. Create a vendor, then manage its
/// products and incoming orders. Anything you list appears in the marketplace.
class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});
  static const route = '/market/provider';

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  late Future<List<Map<String, dynamic>>> _future = SupabaseService.myVendors();

  void _reload() => setState(() => _future = SupabaseService.myVendors());

  Future<void> _newVendor() async {
    await Navigator.of(context).pushNamed(SellerApplyScreen.route);
    _reload();
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
            final vendors = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 40),
              children: [
                const BackLink(label: 'You'),
                const SizedBox(height: 16),
                Text('Sell on the market', style: AppText.heading(34, height: 1.05)),
                const SizedBox(height: 12),
                Text(
                    'Set up a shop, add products, and take orders from stables '
                    'across My Stables.',
                    style: AppText.body(16,
                        height: 1.5, color: AppColors.ink(0.65))),
                const SizedBox(height: 26),
                const Hairline(),
                if (vendors.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text("You don't run a shop yet. Create one to start listing.",
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  ),
                for (final v in vendors) ...[
                  _VendorRow(
                    vendor: v,
                    onReturn: _reload,
                  ),
                  const Hairline(),
                ],
                const SizedBox(height: 26),
                AppButton(label: 'Apply to sell', onPressed: _newVendor),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VendorRow extends StatelessWidget {
  const _VendorRow({required this.vendor, required this.onReturn});
  final Map<String, dynamic> vendor;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final bits = <String>[
      if ((vendor['kind'] as String?)?.isNotEmpty == true) vendor['kind'] as String,
      if ((vendor['city'] as String?)?.isNotEmpty == true) vendor['city'] as String,
    ];
    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(SellerDashboardScreen.route, arguments: vendor);
        onReturn();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((vendor['name'] as String?) ?? 'Shop',
                      style: AppText.heading(20)),
                  if (bits.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(bits.join(' · '),
                        style: AppText.body(14, color: AppColors.ink(0.55))),
                  ],
                ],
              ),
            ),
            AppTag(
              (vendor['approved'] as bool? ?? false) ? 'Live' : 'In review',
              tone: (vendor['approved'] as bool? ?? false)
                  ? TagTone.sage
                  : TagTone.accent,
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
          ],
        ),
      ),
    );
  }
}
