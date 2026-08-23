import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';
import 'add_tack_item_screen.dart';

/// Screen 20 — the stable's tack box. Real items, grouped. Kit named here can
/// be put on a horse's setup so the groom tacks up the right things.
class TackBoxScreen extends StatefulWidget {
  const TackBoxScreen({super.key});
  static const route = '/tack-box';

  @override
  State<TackBoxScreen> createState() => _TackBoxScreenState();
}

class _TackBoxScreenState extends State<TackBoxScreen> {
  String? _openGroup;
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.tackItems(id);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = SessionScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            final items = snap.data ?? const [];
            // Group by group_name, preserving order.
            final groups = <String, List<Map<String, dynamic>>>{};
            for (final it in items) {
              (groups[it['group_name'] as String? ?? 'Other'] ??= []).add(it);
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: session.activeStableName),
                const SizedBox(height: 20),
                Text(l10n.tackBox, style: AppText.heading(40, height: 1)),
                const SizedBox(height: 12),
                Text(l10n.tackBoxIntro,
                    style: AppText.body(17,
                        height: 1.5, color: AppColors.ink(0.65))),
                const SizedBox(height: 26),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text(
                        'No tack yet. Add your first item below — bridles, bits, boots, rugs.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  )
                else
                  for (final entry in groups.entries) ...[
                    _GroupTile(
                      name: entry.key,
                      items: entry.value,
                      open: _openGroup == entry.key,
                      onTap: () => setState(() =>
                          _openGroup = _openGroup == entry.key ? null : entry.key),
                    ),
                    const Hairline(),
                  ],
                const SizedBox(height: 26),
                GestureDetector(
                  onTap: () async {
                    await Navigator.of(context)
                        .pushNamed(AddTackItemScreen.route);
                    _reload();
                  },
                  child: Text('+ ${l10n.addItem}',
                      style: AppText.heading(17, color: AppColors.accent700)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile(
      {required this.name,
      required this.items,
      required this.open,
      required this.onTap});
  final String name;
  final List<Map<String, dynamic>> items;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final summary =
        '${items.length} item${items.length == 1 ? '' : 's'} · ${items.first['name']}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppText.heading(21)),
                      const SizedBox(height: 4),
                      Text(summary,
                          style:
                              AppText.body(15, color: AppColors.ink(0.55))),
                    ],
                  ),
                ),
                Text(open ? '–' : '+',
                    style: AppText.body(22, color: AppColors.ink(0.45))),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final it in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 7, right: 12),
                          decoration: const BoxDecoration(
                              color: AppColors.accent2500,
                              shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((it['name'] as String?) ?? '',
                                  style: AppText.body(17)),
                              if ((it['note'] as String?)?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 2),
                                Text(it['note'] as String,
                                    style: AppText.body(14,
                                        color: AppColors.ink(0.5))),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
