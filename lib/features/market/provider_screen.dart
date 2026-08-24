import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'provider_vendor_screen.dart';

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
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => const _NewVendorSheet(),
    );
    if (created == true) _reload();
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
                AppButton(label: 'Create a shop', onPressed: _newVendor),
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
            .pushNamed(ProviderVendorScreen.route, arguments: vendor);
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
            Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
          ],
        ),
      ),
    );
  }
}

class _NewVendorSheet extends StatefulWidget {
  const _NewVendorSheet();

  @override
  State<_NewVendorSheet> createState() => _NewVendorSheetState();
}

class _NewVendorSheetState extends State<_NewVendorSheet> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _about = TextEditingController();
  String _kind = 'Feed';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Give the shop a name.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.createVendor(
        name: _name.text.trim(),
        kind: _kind,
        city: _city.text.trim(),
        about: _about.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't create: $e")));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 22,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New shop', style: AppText.heading(24)),
          const SizedBox(height: 18),
          AppField(label: 'Shop name', controller: _name),
          const SizedBox(height: 16),
          Text('CATEGORY', style: AppText.eyebrow()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in SupabaseService.marketCategories)
                GestureDetector(
                  onTap: () => setState(() => _kind = c),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: c == _kind ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: c == _kind
                              ? AppColors.accent
                              : AppColors.divider),
                    ),
                    child: Text(c,
                        style: AppText.body(14,
                            color:
                                c == _kind ? AppColors.bg : AppColors.text)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppField(label: 'City', controller: _city),
          const SizedBox(height: 16),
          AppField(label: 'About', controller: _about, maxLines: 2),
          const SizedBox(height: 22),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: 'Create shop', onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
