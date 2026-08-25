import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _tab = 0; // 0 = applications, 1 = announcements
  Future<List<Map<String, dynamic>>>? _apps;
  Future<List<Map<String, dynamic>>>? _announcements;

  @override
  void initState() {
    super.initState();
    _reloadApps();
    _reloadAnnouncements();
  }

  void _reloadApps() =>
      setState(() => _apps = SupabaseService.pendingApplications());
  void _reloadAnnouncements() =>
      setState(() => _announcements = SupabaseService.allAnnouncements());

  Future<void> _decideApp(String id, bool approve) async {
    try {
      await SupabaseService.decideApplication(id, approve);
      _reloadApps();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(approve ? 'Approved — the shop is live.' : 'Rejected.')));
      }
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
                          label: 'Applications',
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
            Expanded(child: _tab == 0 ? _applicationsView() : _announcementsView()),
          ],
        ),
      ),
    );
  }

  Widget _applicationsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _apps,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final apps = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          children: [
            Text('Seller applications waiting for review',
                style: AppText.body(15, color: AppColors.ink(0.6))),
            const SizedBox(height: 14),
            const Hairline(),
            if (apps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Text('Nothing waiting. New applications appear here.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
              ),
            for (final a in apps) ...[
              _ApplicationRow(
                app: a,
                onApprove: () => _decideApp(a['id'] as String, true),
                onReject: () => _decideApp(a['id'] as String, false),
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

class _ApplicationRow extends StatefulWidget {
  const _ApplicationRow(
      {required this.app, required this.onApprove, required this.onReject});
  final Map<String, dynamic> app;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  State<_ApplicationRow> createState() => _ApplicationRowState();
}

class _ApplicationRowState extends State<_ApplicationRow> {
  late final Future<List<Map<String, dynamic>>> _docs =
      SupabaseService.applicationDocuments(widget.app['id'] as String);

  Future<void> _openDoc(String path) async {
    try {
      final url = await SupabaseService.sellerDocUrl(path);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't open: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final trades = (a['trades'] as List?)?.cast<String>() ?? const [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((a['trading_name'] as String?) ?? 'Applicant',
              style: AppText.heading(20)),
          if ((a['location'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(a['location'] as String,
                style: AppText.body(14, color: AppColors.ink(0.55))),
          ],
          if (trades.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in trades) AppTag(t, tone: TagTone.sage)],
            ),
          ],
          const SizedBox(height: 12),
          Text('PAPERS', style: AppText.eyebrow()),
          const SizedBox(height: 6),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _docs,
            builder: (context, snap) {
              final docs = snap.data ?? const [];
              if (docs.isEmpty) {
                return Text('No papers uploaded.',
                    style: AppText.body(14, color: AppColors.ink(0.5)));
              }
              return Column(
                children: [
                  for (final d in docs)
                    InkWell(
                      onTap: d['storage_path'] == null
                          ? null
                          : () => _openDoc(d['storage_path'] as String),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.description_outlined,
                                size: 18, color: AppColors.ink(0.5)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text((d['label'] as String?) ?? 'Document',
                                    style: AppText.body(15))),
                            Text('View',
                                style: AppText.body(14,
                                    color: AppColors.accent700)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AppButton(
                label: 'Approve',
                block: false,
                minHeight: 44,
                fontSize: 15,
                onPressed: widget.onApprove,
              ),
              const SizedBox(width: 10),
              AppButton(
                label: 'Reject',
                variant: AppButtonVariant.secondary,
                block: false,
                minHeight: 44,
                fontSize: 15,
                onPressed: widget.onReject,
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
