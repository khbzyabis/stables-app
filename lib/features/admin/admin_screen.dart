import 'package:flutter/material.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Operator console — approve shops waiting to join the marketplace and post
/// the "From My Stables" announcements everyone sees. Only platform operators
/// (rows in app_admins) reach this.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const route = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0; // 0 = vendors, 1 = announcements
  Future<List<Map<String, dynamic>>>? _vendors;
  Future<List<Map<String, dynamic>>>? _announcements;

  @override
  void initState() {
    super.initState();
    _reloadVendors();
    _reloadAnnouncements();
  }

  void _reloadVendors() =>
      setState(() => _vendors = SupabaseService.pendingVendors());
  void _reloadAnnouncements() =>
      setState(() => _announcements = SupabaseService.allAnnouncements());

  Future<void> _decideVendor(String id, bool approved) async {
    try {
      await SupabaseService.setVendorApproved(id, approved);
      _reloadVendors();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't update: $e")));
      }
    }
  }

  Future<void> _newAnnouncement() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => const _NewAnnouncementSheet(),
    );
    if (ok == true) _reloadAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackLink(label: 'You'),
                  const SizedBox(height: 16),
                  Text('Operator console',
                      style: AppText.heading(32, height: 1.05)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _TabBtn(
                          label: 'Shops',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0)),
                      const SizedBox(width: 10),
                      _TabBtn(
                          label: 'Announcements',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1)),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Expanded(child: _tab == 0 ? _vendorsView() : _announcementsView()),
          ],
        ),
      ),
    );
  }

  Widget _vendorsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _vendors,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final vendors = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          children: [
            Text('Shops waiting for approval',
                style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 14),
            const Hairline(),
            if (vendors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Text('Nothing waiting. New shops appear here to review.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
              ),
            for (final v in vendors) ...[
              _VendorRow(
                vendor: v,
                onApprove: () => _decideVendor(v['id'] as String, true),
                onReject: () => _decideVendor(v['id'] as String, false),
              ),
              const Hairline(),
            ],
          ],
        );
      },
    );
  }

  Widget _announcementsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _announcements,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final items = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          children: [
            const Hairline(),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('No announcements yet.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
              ),
            for (final a in items) ...[
              _AnnouncementRow(
                item: a,
                onToggle: (v) async {
                  try {
                    await SupabaseService.setAnnouncementActive(
                        a['id'] as String, v);
                    _reloadAnnouncements();
                  } catch (e) {
                    AppErrors.report(e);
                  }
                },
                onDelete: () async {
                  try {
                    await SupabaseService.deleteAnnouncement(a['id'] as String);
                    _reloadAnnouncements();
                  } catch (e) {
                    AppErrors.report(e);
                  }
                },
              ),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            AppButton(label: 'Post an announcement', onPressed: _newAnnouncement),
          ],
        );
      },
    );
  }
}

class _VendorRow extends StatelessWidget {
  const _VendorRow(
      {required this.vendor, required this.onApprove, required this.onReject});
  final Map<String, dynamic> vendor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final bits = [
      if ((vendor['kind'] as String?)?.isNotEmpty == true) vendor['kind'],
      if ((vendor['city'] as String?)?.isNotEmpty == true) vendor['city'],
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((vendor['name'] as String?) ?? 'Shop',
              style: AppText.heading(20)),
          if (bits.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(bits, style: AppText.body(14, color: AppColors.ink(0.55))),
          ],
          if ((vendor['about'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(vendor['about'] as String,
                style: AppText.body(15, height: 1.4, color: AppColors.ink(0.7))),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              AppButton(
                label: 'Approve',
                block: false,
                minHeight: 44,
                fontSize: 15,
                onPressed: onApprove,
              ),
              const SizedBox(width: 10),
              AppButton(
                label: 'Reject',
                variant: AppButtonVariant.secondary,
                block: false,
                minHeight: 44,
                fontSize: 15,
                onPressed: onReject,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow(
      {required this.item, required this.onToggle, required this.onDelete});
  final Map<String, dynamic> item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final active = item['active'] as bool? ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppTag((item['kind'] as String?) ?? 'Update',
                  tone: TagTone.neutral),
              const Spacer(),
              Text(active ? 'Live' : 'Hidden',
                  style: AppText.body(12, color: AppColors.ink(0.5))),
              Switch(
                value: active,
                onChanged: onToggle,
                activeThumbColor: AppColors.bg,
                activeTrackColor: AppColors.accent2600,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: AppColors.ink(0.5)),
              ),
            ],
          ),
          Text((item['title'] as String?) ?? '',
              style: AppText.heading(19, height: 1.25)),
          const SizedBox(height: 6),
          Text((item['body'] as String?) ?? '',
              style: AppText.body(15, height: 1.5, color: AppColors.ink(0.8))),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border:
              Border.all(color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label,
            style: AppText.heading(15,
                color: selected ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

class _NewAnnouncementSheet extends StatefulWidget {
  const _NewAnnouncementSheet();

  @override
  State<_NewAnnouncementSheet> createState() => _NewAnnouncementSheetState();
}

class _NewAnnouncementSheetState extends State<_NewAnnouncementSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _kind = 'Update';
  bool _pinned = false;
  bool _saving = false;

  static const _kinds = ['Update', 'Show', 'Advert'];

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A title and a message are needed.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.addAnnouncement(
        title: _title.text.trim(),
        body: _body.text.trim(),
        kind: _kind,
        pinned: _pinned,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't post: $e")));
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
          Text('New announcement', style: AppText.heading(24)),
          const SizedBox(height: 18),
          AppField(label: 'Title', controller: _title),
          const SizedBox(height: 16),
          AppField(label: 'Message', controller: _body, maxLines: 3),
          const SizedBox(height: 16),
          Text('KIND', style: AppText.eyebrow()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final k in _kinds)
                GestureDetector(
                  onTap: () => setState(() => _kind = k),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: k == _kind ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color:
                              k == _kind ? AppColors.accent : AppColors.divider),
                    ),
                    child: Text(k,
                        style: AppText.body(14,
                            color: k == _kind ? AppColors.bg : AppColors.text)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v ?? false),
                activeColor: AppColors.accent,
              ),
              Text('Pin to the top', style: AppText.body(15)),
            ],
          ),
          const SizedBox(height: 12),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: 'Post announcement', onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
