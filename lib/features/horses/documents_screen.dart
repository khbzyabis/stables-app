import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 34 — a horse's documents. Real files uploaded to storage; tap one to
/// open it. Only members of the stable can see or add them.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});
  static const route = '/documents';

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  Map<String, dynamic> _horse = const {};
  Future<List<Map<String, dynamic>>>? _future;
  bool _uploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _horse = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
    _future ??= _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final id = _horse['id'] as String?;
    if (id == null) return const [];
    return SupabaseService.documents(id);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _add() async {
    final stableId = _horse['stable_id'] as String?;
    final horseId = _horse['id'] as String?;
    if (stableId == null || horseId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not read that file.')));
      return;
    }
    setState(() => _uploading = true);
    try {
      await SupabaseService.addDocument(
        horseId: horseId,
        stableId: stableId,
        name: file.name,
        fileName: file.name,
        bytes: bytes,
      );
      _reload();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _open(String path) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await SupabaseService.documentUrl(path);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            final docs = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: (_horse['name'] as String?) ?? 'Horse'),
                const SizedBox(height: 20),
                Text(l10n.documents, style: AppText.heading(40, height: 1)),
                const SizedBox(height: 10),
                Text('Passport, insurance, vaccination card, x-rays — shared with the stable.',
                    style: AppText.body(16,
                        height: 1.5, color: AppColors.ink(0.6))),
                const SizedBox(height: 24),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text('No documents yet. Add the first one below.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  )
                else
                  for (final d in docs) ...[
                    _DocRow(doc: d, onTap: () => _open(d['storage_path'])),
                    const Hairline(),
                  ],
                const SizedBox(height: 24),
                if (_uploading)
                  Row(
                    children: [
                      const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2)),
                      const SizedBox(width: 12),
                      Text('Uploading…',
                          style: AppText.body(16, color: AppColors.ink(0.6))),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _add,
                    child: Text('+ ${l10n.addDocument}',
                        style:
                            AppText.heading(17, color: AppColors.accent700)),
                  ),
                const SizedBox(height: 20),
                Text('Only people in this stable can open these.',
                    style: AppText.body(14,
                        height: 1.5, color: AppColors.ink(0.5))),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.doc, required this.onTap});
  final Map<String, dynamic> doc;
  final VoidCallback onTap;

  String get _ext {
    final name = (doc['name'] as String?) ?? '';
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot + 1).toUpperCase() : 'FILE';
  }

  @override
  Widget build(BuildContext context) {
    final status = (doc['status'] as String?) ?? 'On file';
    final tone = switch (status) {
      'Expiring' => TagTone.accent,
      'Current' => TagTone.sage,
      _ => TagTone.neutral,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 17),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 54,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_ext,
                  style: AppText.body(10, color: AppColors.neutral700)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text((doc['name'] as String?) ?? '',
                  style: AppText.body(18, height: 1.3)),
            ),
            const SizedBox(width: 12),
            AppTag(status, tone: tone),
          ],
        ),
      ),
    );
  }
}
