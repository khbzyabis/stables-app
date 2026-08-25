import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';

/// Stables Admin Console — the platform operator's desktop dashboard. A dark
/// sidebar of sections; the content area shows platform-wide data (across every
/// stable and seller) via operator-only reads. Responsive: the sidebar becomes
/// a top nav on narrow screens.
class ConsoleScreen extends StatefulWidget {
  const ConsoleScreen({super.key});
  static const route = '/console';

  @override
  State<ConsoleScreen> createState() => _ConsoleScreenState();
}

enum _Section {
  overview,
  applications,
  sellers,
  stables,
  disputes,
  payouts,
  fees,
  announcements
}

class _ConsoleScreenState extends State<ConsoleScreen> {
  _Section _section = _Section.overview;

  static const _labels = {
    _Section.overview: 'Overview',
    _Section.applications: 'Applications',
    _Section.sellers: 'Sellers',
    _Section.stables: 'Stables',
    _Section.disputes: 'Disputes',
    _Section.payouts: 'Payouts',
    _Section.fees: 'Fees',
    _Section.announcements: 'Announcements',
  };
  static const _icons = {
    _Section.overview: Icons.grid_view_rounded,
    _Section.applications: Icons.assignment_outlined,
    _Section.sellers: Icons.storefront_outlined,
    _Section.stables: Icons.holiday_village_outlined,
    _Section.disputes: Icons.gavel_outlined,
    _Section.payouts: Icons.account_balance_outlined,
    _Section.fees: Icons.percent_outlined,
    _Section.announcements: Icons.campaign_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          return SafeArea(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Sidebar(
                        section: _section,
                        onSelect: (s) => setState(() => _section = s),
                      ),
                      Expanded(child: _content()),
                    ],
                  )
                : Column(
                    children: [
                      _TopNav(
                        section: _section,
                        onSelect: (s) => setState(() => _section = s),
                      ),
                      Expanded(child: _content()),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(_labels[_section]!,
                    style: AppText.heading(30, height: 1)),
              ),
              IconButton(
                tooltip: 'Back to app',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.close, color: AppColors.ink(0.5)),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_section) {
            _Section.overview => const _OverviewView(),
            _Section.applications => const _ApplicationsView(),
            _Section.sellers => const _SellersView(),
            _Section.stables => const _StablesView(),
            _Section.disputes => const _DisputesView(),
            _Section.payouts => const _PayoutsView(),
            _Section.fees => const _FeesView(),
            _Section.announcements => const _AnnouncementsView(),
          },
        ),
      ],
    );
  }
}

// ---- Navigation ------------------------------------------------------------
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.section, required this.onSelect});
  final _Section section;
  final ValueChanged<_Section> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.neutral900,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle)),
                const SizedBox(width: 9),
                Text('My Stables',
                    style: AppText.heading(16, color: AppColors.neutral100)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('OPERATOR',
                style: AppText.body(11,
                    letterSpacing: 1.4, color: AppColors.neutral400)),
          ),
          const SizedBox(height: 22),
          for (final s in _Section.values)
            _NavItem(
              label: _ConsoleScreenState._labels[s]!,
              icon: _ConsoleScreenState._icons[s]!,
              active: s == section,
              onTap: () => onSelect(s),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.label,
      required this.icon,
      required this.active,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.neutral800 : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    size: 19,
                    color: active ? AppColors.accent300 : AppColors.neutral400),
                const SizedBox(width: 12),
                Text(label,
                    style: AppText.body(15,
                        color: active
                            ? AppColors.neutral100
                            : AppColors.neutral300)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.section, required this.onSelect});
  final _Section section;
  final ValueChanged<_Section> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral900,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            for (final s in _Section.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_ConsoleScreenState._labels[s]!),
                  selected: s == section,
                  onSelected: (_) => onSelect(s),
                  showCheckmark: false,
                  backgroundColor: AppColors.neutral800,
                  selectedColor: AppColors.accent,
                  labelStyle: AppText.body(14,
                      color: s == section
                          ? AppColors.bg
                          : AppColors.neutral200),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---- Overview --------------------------------------------------------------
class _OverviewView extends StatefulWidget {
  const _OverviewView();
  @override
  State<_OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<_OverviewView> {
  late final Future<Map<String, dynamic>> _f = SupabaseService.adminOverview();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final d = snap.data ?? const {};
        if (d.isEmpty) {
          return _PadBody(child: Text(
              'No data — or this account is not an operator.',
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        int n(String k) => (d[k] as num?)?.toInt() ?? 0;
        final tiles = <(String, String)>[
          ('Stables', '${n('stables')}'),
          ('People', '${n('people')}'),
          ('Horses', '${n('horses')}'),
          ('Applications waiting', '${n('apps_pending')}'),
          ('Live sellers', '${n('sellers_live')} / ${n('sellers_total')}'),
          ('Open orders', '${n('orders_open')} / ${n('orders_total')}'),
        ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [for (final t in tiles) _Kpi(label: t.$1, value: t.$2)],
            ),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.heading(32, height: 1)),
          const SizedBox(height: 6),
          Text(label, style: AppText.body(14, color: AppColors.ink(0.6))),
        ],
      ),
    );
  }
}

// ---- Applications ----------------------------------------------------------
class _ApplicationsView extends StatefulWidget {
  const _ApplicationsView();
  @override
  State<_ApplicationsView> createState() => _ApplicationsViewState();
}

class _ApplicationsViewState extends State<_ApplicationsView> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.pendingApplications();

  void _reload() =>
      setState(() => _f = SupabaseService.pendingApplications());

  Future<void> _decide(String id, bool approve) async {
    try {
      await SupabaseService.decideApplication(id, approve);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(approve ? 'Approved — shop is live.' : 'Rejected.')));
      }
    } catch (e) {
      AppErrors.report(e);
    }
  }

  Future<void> _openDoc(String path) async {
    try {
      final url = await SupabaseService.sellerDocUrl(path);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final apps = snap.data ?? const [];
        if (apps.isEmpty) {
          return _PadBody(child: Text('No applications waiting.',
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            for (final a in apps) ...[
              _Card(
                child: _AppCard(
                  app: a,
                  onOpenDoc: _openDoc,
                  onApprove: () => _decide(a['id'] as String, true),
                  onReject: () => _decide(a['id'] as String, false),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

class _AppCard extends StatefulWidget {
  const _AppCard(
      {required this.app,
      required this.onOpenDoc,
      required this.onApprove,
      required this.onReject});
  final Map<String, dynamic> app;
  final ValueChanged<String> onOpenDoc;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard> {
  late final Future<List<Map<String, dynamic>>> _docs =
      SupabaseService.applicationDocuments(widget.app['id'] as String);

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final trades = (a['trades'] as List?)?.cast<String>() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((a['trading_name'] as String?) ?? 'Applicant',
            style: AppText.heading(22)),
        if ((a['location'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(a['location'] as String,
              style: AppText.body(14, color: AppColors.ink(0.55))),
        ],
        if (trades.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in trades) AppTag(t, tone: TagTone.sage)
          ]),
        ],
        const SizedBox(height: 14),
        Text('PAPERS', style: AppText.eyebrow()),
        const SizedBox(height: 4),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _docs,
          builder: (context, snap) {
            final docs = snap.data ?? const [];
            if (docs.isEmpty) {
              return Text('No papers uploaded.',
                  style: AppText.body(14, color: AppColors.ink(0.5)));
            }
            return Column(children: [
              for (final d in docs)
                InkWell(
                  onTap: d['storage_path'] == null
                      ? null
                      : () => widget.onOpenDoc(d['storage_path'] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Icon(Icons.description_outlined,
                          size: 18, color: AppColors.ink(0.5)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text((d['label'] as String?) ?? 'Document',
                              style: AppText.body(15))),
                      Text('View',
                          style:
                              AppText.body(14, color: AppColors.accent700)),
                    ]),
                  ),
                ),
            ]);
          },
        ),
        const SizedBox(height: 14),
        Row(children: [
          AppButton(
              label: 'Approve',
              block: false,
              minHeight: 44,
              fontSize: 15,
              onPressed: widget.onApprove),
          const SizedBox(width: 10),
          AppButton(
              label: 'Reject',
              variant: AppButtonVariant.secondary,
              block: false,
              minHeight: 44,
              fontSize: 15,
              onPressed: widget.onReject),
        ]),
      ],
    );
  }
}

// ---- Sellers ---------------------------------------------------------------
class _SellersView extends StatefulWidget {
  const _SellersView();
  @override
  State<_SellersView> createState() => _SellersViewState();
}

class _SellersViewState extends State<_SellersView> {
  late Future<List<Map<String, dynamic>>> _f = SupabaseService.adminSellers();
  void _reload() => setState(() => _f = SupabaseService.adminSellers());

  Future<void> _toggle(String id, bool approve) async {
    try {
      await SupabaseService.setVendorApproved(id, approve);
      _reload();
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final sellers = snap.data ?? const [];
        if (sellers.isEmpty) {
          return _PadBody(child: Text('No sellers yet.',
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            for (final v in sellers) ...[
              _Card(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((v['name'] as String?) ?? 'Shop',
                              style: AppText.heading(19)),
                          const SizedBox(height: 4),
                          Text([
                            if ((v['kind'] as String?)?.isNotEmpty == true) v['kind'],
                            if ((v['owner_email'] as String?)?.isNotEmpty == true)
                              v['owner_email'],
                            '${(v['products'] as num?)?.toInt() ?? 0} products',
                          ].join(' · '),
                              style:
                                  AppText.body(14, color: AppColors.ink(0.55))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppTag(
                        (v['approved'] as bool? ?? false) ? 'Live' : 'In review',
                        tone: (v['approved'] as bool? ?? false)
                            ? TagTone.sage
                            : TagTone.accent),
                    const SizedBox(width: 10),
                    AppButton(
                      label: (v['approved'] as bool? ?? false)
                          ? 'Suspend'
                          : 'Approve',
                      variant: (v['approved'] as bool? ?? false)
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.primary,
                      block: false,
                      minHeight: 42,
                      fontSize: 14,
                      onPressed: () => _toggle(
                          v['id'] as String, !(v['approved'] as bool? ?? false)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

// ---- Stables ---------------------------------------------------------------
class _StablesView extends StatelessWidget {
  const _StablesView();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.adminStables(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final stables = snap.data ?? const [];
        if (stables.isEmpty) {
          return _PadBody(child: Text('No stables yet.',
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            for (final s in stables) ...[
              _Card(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((s['name'] as String?) ?? 'Stable',
                              style: AppText.heading(19)),
                          if ((s['city'] as String?)?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(s['city'] as String,
                                style: AppText.body(14,
                                    color: AppColors.ink(0.55))),
                          ],
                        ],
                      ),
                    ),
                    Text(
                        '${(s['horses'] as num?)?.toInt() ?? 0} horses · '
                        '${(s['people'] as num?)?.toInt() ?? 0} people',
                        style: AppText.body(14, color: AppColors.ink(0.6))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

// ---- Announcements ---------------------------------------------------------
class _AnnouncementsView extends StatefulWidget {
  const _AnnouncementsView();
  @override
  State<_AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<_AnnouncementsView> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.allAnnouncements();
  void _reload() => setState(() => _f = SupabaseService.allAnnouncements());

  Future<void> _post() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => const _NewAnnouncementSheet(),
    );
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        final items = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            AppButton(label: 'Post an announcement', onPressed: _post),
            const SizedBox(height: 18),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator()),
            for (final a in items) ...[
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      AppTag((a['kind'] as String?) ?? 'Update',
                          tone: TagTone.neutral),
                      const Spacer(),
                      Text((a['active'] as bool? ?? true) ? 'Live' : 'Hidden',
                          style: AppText.body(12, color: AppColors.ink(0.5))),
                      Switch(
                        value: a['active'] as bool? ?? true,
                        onChanged: (v) async {
                          try {
                            await SupabaseService.setAnnouncementActive(
                                a['id'] as String, v);
                            _reload();
                          } catch (e) {
                            AppErrors.report(e);
                          }
                        },
                        activeThumbColor: AppColors.bg,
                        activeTrackColor: AppColors.accent2600,
                      ),
                      IconButton(
                        onPressed: () async {
                          try {
                            await SupabaseService.deleteAnnouncement(
                                a['id'] as String);
                            _reload();
                          } catch (e) {
                            AppErrors.report(e);
                          }
                        },
                        icon: Icon(Icons.delete_outline,
                            color: AppColors.ink(0.5)),
                      ),
                    ]),
                    Text((a['title'] as String?) ?? '',
                        style: AppText.heading(19, height: 1.25)),
                    const SizedBox(height: 6),
                    Text((a['body'] as String?) ?? '',
                        style: AppText.body(15,
                            height: 1.5, color: AppColors.ink(0.8))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

// ---- Disputes --------------------------------------------------------------
class _DisputesView extends StatefulWidget {
  const _DisputesView();
  @override
  State<_DisputesView> createState() => _DisputesViewState();
}

class _DisputesViewState extends State<_DisputesView> {
  late Future<List<Map<String, dynamic>>> _f = SupabaseService.adminDisputes();
  void _reload() => setState(() => _f = SupabaseService.adminDisputes());

  Future<void> _decide(String id, String decision) async {
    try {
      await SupabaseService.decideDispute(id, decision);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Decision recorded.')));
      }
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final rows = snap.data ?? const [];
        if (rows.isEmpty) {
          return _PadBody(child: Text('No disputes. A quiet marketplace.',
              style: AppText.body(16, color: AppColors.ink(0.6))));
        }
        final open = rows.where((d) => d['status'] == 'open').toList();
        final decided = rows.where((d) => d['status'] != 'open').toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            Text('My Stables arbitrates · services cannot be returned',
                style: AppText.body(14, color: AppColors.ink(0.55))),
            const SizedBox(height: 16),
            if (open.isNotEmpty) ...[
              Text('WAITING ON YOU', style: AppText.eyebrow()),
              const SizedBox(height: 10),
              for (final d in open) ...[
                _Card(child: _DisputeCard(dispute: d, onDecide: _decide)),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
            if (decided.isNotEmpty) ...[
              Text('DECIDED', style: AppText.eyebrow()),
              const SizedBox(height: 10),
              for (final d in decided) ...[
                _Card(child: _DisputeCard(dispute: d, onDecide: _decide)),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({required this.dispute, required this.onDecide});
  final Map<String, dynamic> dispute;
  final Future<void> Function(String, String) onDecide;

  String get _decisionLabel => switch (dispute['decision'] as String?) {
        'pay_seller' => 'Paid the seller',
        'refund_buyer' => 'Refunded the buyer',
        'split' => 'Split it',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final d = dispute;
    final id = d['id'] as String;
    final open = d['status'] == 'open';
    final o = d['orders'] as Map?;
    final net = (o?['net_aed'] as num?)?.toDouble() ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text((d['reason'] as String?) ?? 'Dispute',
              style: AppText.heading(18, height: 1.2)),
        ),
        if (open)
          const AppTag('Waiting on you', tone: TagTone.accent)
        else
          AppTag(_decisionLabel, tone: TagTone.neutral),
      ]),
      const SizedBox(height: 6),
      Text('${d['vendor_name'] ?? 'Seller'} · seller net AED ${net.toStringAsFixed(0)}',
          style: AppText.body(13, color: AppColors.ink(0.55))),
      if ((d['buyer_says'] as String?)?.isNotEmpty == true) ...[
        const SizedBox(height: 10),
        _Says(who: 'Buyer', text: d['buyer_says'] as String),
      ],
      if ((d['seller_says'] as String?)?.isNotEmpty == true) ...[
        const SizedBox(height: 8),
        _Says(who: 'Seller', text: d['seller_says'] as String),
      ],
      if (open) ...[
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          AppButton(
              label: 'Refund the buyer',
              block: false,
              minHeight: 42,
              fontSize: 14,
              onPressed: () => onDecide(id, 'refund_buyer')),
          AppButton(
              label: 'Pay the seller',
              variant: AppButtonVariant.secondary,
              block: false,
              minHeight: 42,
              fontSize: 14,
              onPressed: () => onDecide(id, 'pay_seller')),
          AppButton(
              label: 'Split it',
              variant: AppButtonVariant.secondary,
              block: false,
              minHeight: 42,
              fontSize: 14,
              onPressed: () => onDecide(id, 'split')),
        ]),
      ] else if ((d['decision_note'] as String?)?.isNotEmpty == true) ...[
        const SizedBox(height: 8),
        Text(d['decision_note'] as String,
            style: AppText.body(13, color: AppColors.ink(0.5))),
      ],
    ]);
  }
}

class _Says extends StatelessWidget {
  const _Says({required this.who, required this.text});
  final String who;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.neutral100, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(who.toUpperCase(),
            style: AppText.body(10,
                letterSpacing: 0.6, color: AppColors.ink(0.5))),
        const SizedBox(height: 3),
        Text(text, style: AppText.body(14, height: 1.4)),
      ]),
    );
  }
}

// ---- Payouts ---------------------------------------------------------------
class _PayoutsView extends StatefulWidget {
  const _PayoutsView();
  @override
  State<_PayoutsView> createState() => _PayoutsViewState();
}

class _PayoutsViewState extends State<_PayoutsView> {
  late Future<List<Map<String, dynamic>>> _f = SupabaseService.adminPayoutsDue();
  bool _running = false;
  void _reload() => setState(() => _f = SupabaseService.adminPayoutsDue());

  Future<void> _run() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text('Run the payouts?', style: AppText.heading(22)),
        content: Text(
            'This closes the current cycle: every payable order is swept into '
            'a batch per seller and marked paid. This cannot be undone.',
            style: AppText.body(15, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Run payouts')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _running = true);
    try {
      final res = await SupabaseService.runPayouts();
      final batches = (res['batches'] as num?)?.toInt() ?? 0;
      final net = (res['net_aed'] as num?)?.toDouble() ?? 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Paid $batches sellers · AED ${net.toStringAsFixed(0)}.')));
      }
      _reload();
    } catch (e) {
      AppErrors.report(e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final due = snap.data ?? const [];
        final total = due.fold<double>(
            0, (t, r) => t + ((r['net_aed'] as num?)?.toDouble() ?? 0));
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            Text('Paid twice a month, on the 1st and the 15th. Held money is '
                'still inside a return window and is not swept.',
                style: AppText.body(14, color: AppColors.ink(0.55))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppColors.accent2200,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AED ${total.toStringAsFixed(0)}',
                            style: AppText.heading(30)),
                        const SizedBox(height: 5),
                        Text('Payable now, across ${due.length} sellers',
                            style: AppText.body(14, color: AppColors.ink(0.6))),
                      ]),
                ),
              ),
              const SizedBox(width: 12),
              if (_running)
                const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator())
              else
                AppButton(
                    label: 'Run payouts',
                    block: false,
                    onPressed: due.isEmpty ? null : _run),
            ]),
            const SizedBox(height: 18),
            if (due.isEmpty)
              _Card(
                  child: Text('Nothing due. Money still in a return window '
                      'appears when its window closes.',
                      style: AppText.body(15, color: AppColors.ink(0.6))))
            else
              for (final r in due) ...[
                _Card(child: _DueRow(row: r)),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}

class _DueRow extends StatelessWidget {
  const _DueRow({required this.row});
  final Map<String, dynamic> row;
  @override
  Widget build(BuildContext context) {
    final net = (row['net_aed'] as num?)?.toDouble() ?? 0;
    final fee = (row['fee_aed'] as num?)?.toDouble() ?? 0;
    final refunds = (row['refunds_aed'] as num?)?.toDouble() ?? 0;
    final held = (row['held_aed'] as num?)?.toDouble() ?? 0;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((row['vendor_name'] as String?) ?? 'Seller',
              style: AppText.heading(18)),
          const SizedBox(height: 4),
          Text('fee AED ${fee.toStringAsFixed(0)}'
              '${refunds > 0 ? ' · refunds AED ${refunds.toStringAsFixed(0)}' : ''}'
              '${held > 0 ? ' · held AED ${held.toStringAsFixed(0)}' : ''}',
              style: AppText.body(13, color: AppColors.ink(0.55))),
        ]),
      ),
      Text('AED ${net.toStringAsFixed(0)}', style: AppText.heading(20)),
    ]);
  }
}

// ---- Payment provider settings ---------------------------------------------
class _PaymentsSettingsCard extends StatefulWidget {
  const _PaymentsSettingsCard();
  @override
  State<_PaymentsSettingsCard> createState() => _PaymentsSettingsCardState();
}

class _PaymentsSettingsCardState extends State<_PaymentsSettingsCard> {
  late Future<Map<String, dynamic>> _f = SupabaseService.platformSettings();
  static const _providers = ['mock', 'stripe', 'telr'];
  static const _labels = {
    'mock': 'Test (no real money)',
    'stripe': 'Stripe',
    'telr': 'Telr (UAE)',
  };

  Future<void> _setProvider(String p) async {
    try {
      await SupabaseService.setPaymentSettings(provider: p);
      setState(() => _f = SupabaseService.platformSettings());
      if (mounted && p != 'mock') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$p selected — deploy its Edge Function and keys to '
                'take real money.')));
      }
    } catch (e) {
      AppErrors.report(e);
    }
  }

  Future<void> _editTrn(String? current) async {
    final ctrl = TextEditingController(text: current ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text('Operator TRN', style: AppText.heading(20)),
        content: AppField(label: 'TRN (shown on receipts)', controller: ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await SupabaseService.setPaymentSettings(trn: ctrl.text.trim());
      setState(() => _f = SupabaseService.platformSettings());
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _f,
      builder: (context, snap) {
        final s = snap.data ?? const {};
        final provider = (s['payment_provider'] as String?) ?? 'mock';
        final trn = (s['trn'] as String?)?.trim() ?? '';
        final vat = (s['vat_pct'] as num?)?.toDouble() ?? 5;
        return _Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Payments', style: AppText.heading(18)),
            const SizedBox(height: 4),
            Text('How buyers pay. The provider is a seam — money flows through '
                'the same held → payable → payout ledger whichever you pick.',
                style: AppText.body(13, height: 1.5, color: AppColors.ink(0.55))),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in _providers)
                GestureDetector(
                  onTap: () => _setProvider(p),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: p == provider
                          ? AppColors.accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: p == provider
                              ? AppColors.accent
                              : AppColors.divider),
                    ),
                    child: Text(_labels[p]!,
                        style: AppText.body(14,
                            color: p == provider
                                ? AppColors.bg
                                : AppColors.text)),
                  ),
                ),
            ]),
            if (provider != 'mock') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                    '$provider is selected but takes no money until its Edge '
                    'Function and secret keys are deployed. Buyers cannot check '
                    'out until then — switch back to Test to keep trading.',
                    style: AppText.body(13,
                        height: 1.5, color: AppColors.accent700)),
              ),
            ],
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRN on receipts',
                          style: AppText.body(13, color: AppColors.ink(0.55))),
                      const SizedBox(height: 3),
                      Text(trn.isEmpty ? 'Not set' : trn,
                          style: AppText.body(16)),
                    ]),
              ),
              Text('VAT ${vat.toStringAsFixed(0)}%',
                  style: AppText.body(15, color: AppColors.ink(0.6))),
              const SizedBox(width: 12),
              AppButton(
                  label: 'Edit TRN',
                  variant: AppButtonVariant.secondary,
                  block: false,
                  minHeight: 40,
                  fontSize: 14,
                  onPressed: () => _editTrn(trn)),
            ]),
          ]),
        );
      },
    );
  }
}

// ---- Fees ------------------------------------------------------------------
class _FeesView extends StatefulWidget {
  const _FeesView();
  @override
  State<_FeesView> createState() => _FeesViewState();
}

class _FeesViewState extends State<_FeesView> {
  late Future<List<Map<String, dynamic>>> _f = SupabaseService.commissionRates();
  void _reload() => setState(() => _f = SupabaseService.commissionRates());

  Future<void> _edit(Map<String, dynamic> rate) async {
    final ctrl = TextEditingController(
        text: ((rate['rate_pct'] as num?)?.toDouble() ?? 0).toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg,
        title: Text('${rate['label']} commission', style: AppText.heading(20)),
        content: AppField(
            label: 'Rate (%)',
            controller: ctrl,
            keyboardType: TextInputType.number),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final pct = double.tryParse(ctrl.text.trim());
    if (pct == null) return;
    try {
      await SupabaseService.setCommissionRate(
          rate['category_group'] as String, pct);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rate updated.')));
      }
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) AppErrors.report(snap.error!);
        final rates = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          children: [
            const _PaymentsSettingsCard(),
            const SizedBox(height: 22),
            Text('COMMISSION', style: AppText.eyebrow()),
            const SizedBox(height: 10),
            Text('What My Stables keeps. A change is told to sellers before the '
                'period it applies to; money already held pays out at the old '
                'rate.',
                style: AppText.body(14, height: 1.5, color: AppColors.ink(0.55))),
            const SizedBox(height: 16),
            for (final r in rates) ...[
              _Card(child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((r['label'] as String?) ?? '',
                            style: AppText.heading(18)),
                        const SizedBox(height: 3),
                        Text((r['detail'] as String?) ?? '',
                            style:
                                AppText.body(13, color: AppColors.ink(0.55))),
                        if ((r['note'] as String?)?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(r['note'] as String,
                              style: AppText.body(12, color: AppColors.ink(0.45))),
                        ],
                      ]),
                ),
                Text('${((r['rate_pct'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}%',
                    style: AppText.heading(24)),
                const SizedBox(width: 8),
                AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.secondary,
                    block: false,
                    minHeight: 40,
                    fontSize: 14,
                    onPressed: () => _edit(r)),
              ])),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

// ---- Shared bits -----------------------------------------------------------
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _PadBody extends StatelessWidget {
  const _PadBody({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 0), child: child);
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
          pinned: _pinned);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 28,
          right: 28,
          top: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22),
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
          Wrap(spacing: 8, children: [
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
                        color: k == _kind ? AppColors.accent : AppColors.divider),
                  ),
                  child: Text(k,
                      style: AppText.body(14,
                          color: k == _kind ? AppColors.bg : AppColors.text)),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Checkbox(
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v ?? false),
                activeColor: AppColors.accent),
            Text('Pin to the top', style: AppText.body(15)),
          ]),
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
