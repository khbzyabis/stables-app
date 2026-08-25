import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/errors.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_tag.dart';

/// The Provider App — the phone side for an on-the-ground provider (farrier,
/// vet, physio, transporter). It answers one question: what am I doing next,
/// and did I get paid for the last one. Five tabs: Today, Requests, Orders,
/// Chat, Money. The heavy things — listings, disputes, the full ledger — stay
/// on the web Seller Dashboard.
class ProviderAppScreen extends StatefulWidget {
  const ProviderAppScreen({super.key});
  static const route = '/provider-app';

  @override
  State<ProviderAppScreen> createState() => _ProviderAppScreenState();
}

class _ProviderAppScreenState extends State<ProviderAppScreen> {
  Map<String, dynamic>? _vendor;
  int _tab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vendor ??= (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?) ??
        const {};
  }

  String get _vid => _vendor?['id'] as String? ?? '';

  static const _icons = [
    Icons.wb_sunny_outlined,
    Icons.mark_email_unread_outlined,
    Icons.inventory_2_outlined,
    Icons.forum_outlined,
    Icons.payments_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final tabs = [
      l10n.paTabToday,
      l10n.paTabRequests,
      l10n.paTabOrders,
      l10n.paTabChat,
      l10n.paTabMoney,
    ];
    final v = _vendor ?? const {};
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            _TodayTab(vendor: v),
            _RequestsTab(vendorId: _vid),
            _OrdersTab(vendorId: _vid),
            _ChatTab(vendorId: _vid),
            _MoneyTab(vendorId: _vid),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => _tab = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_icons[i],
                                size: 23,
                                color: i == _tab
                                    ? AppColors.accent700
                                    : AppColors.ink(0.5)),
                            const SizedBox(height: 5),
                            Text(tabs[i],
                                style: AppText.body(11,
                                    color: i == _tab
                                        ? AppColors.accent700
                                        : AppColors.ink(0.5))),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Today -----------------------------------------------------------------
class _TodayTab extends StatefulWidget {
  const _TodayTab({required this.vendor});
  final Map<String, dynamic> vendor;
  @override
  State<_TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<_TodayTab> {
  late Future<List<Map<String, dynamic>>> _jobs;
  late Future<List<Map<String, dynamic>>> _requests;

  String get _vid => widget.vendor['id'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _jobs = SupabaseService.providerJobs(_vid);
    _requests = SupabaseService.vendorQuoteRequests(_vid);
  }

  void _reload() => setState(() {
        _jobs = SupabaseService.providerJobs(_vid);
        _requests = SupabaseService.vendorQuoteRequests(_vid);
      });

  bool _isToday(String? d) {
    if (d == null) return false;
    final day = DateTime.tryParse(d);
    if (day == null) return false;
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _jobs,
      builder: (context, jobSnap) {
        final jobs = jobSnap.data ?? const [];
        final booked = jobs
            .where((j) => j['status'] == 'accepted')
            .fold<double>(
                0, (t, j) => t + ((j['quote_price'] as num?)?.toDouble() ?? 0));
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _requests,
          builder: (context, reqSnap) {
            final l10n = AppL10n.of(context);
            final toAnswer = (reqSnap.data ?? const [])
                .where((r) => r['status'] == 'open')
                .length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              DateFormat('EEEE', l10n.localeName)
                                  .format(DateTime.now()),
                              style: AppText.eyebrow(color: AppColors.accent700)),
                          const SizedBox(height: 6),
                          Text(l10n.paTabToday,
                              style: AppText.heading(36, height: 1)),
                        ],
                      ),
                    ),
                    _Avatar(name: (widget.vendor['name'] as String?) ?? 'You'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: _MiniStat(
                          label: l10n.paBooked,
                          value: 'AED ${booked.toStringAsFixed(0)}')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MiniStat(
                          label: l10n.paToAnswer,
                          value: l10n.paNRequests(toAnswer))),
                ]),
                const SizedBox(height: 24),
                if (jobSnap.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (jobs.isEmpty)
                  Text(l10n.paNoJobs,
                      style: AppText.body(16, color: AppColors.ink(0.6)))
                else
                  for (final j in jobs) ...[
                    _JobRow(
                      job: j,
                      today: _isToday(j['scheduled_for'] as String?),
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => _FinishJobScreen(job: j)));
                        _reload();
                      },
                    ),
                    const _Line(),
                  ],
                const SizedBox(height: 22),
                AppButton(
                  label: l10n.paWhenIWork,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => _WhenIWorkScreen(vendor: widget.vendor))),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job, required this.today, required this.onTap});
  final Map<String, dynamic> job;
  final bool today;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final done = job['status'] == 'completed';
    final price = (job['quote_price'] as num?)?.toDouble() ?? 0;
    final subject = (job['subject'] as String?)?.isNotEmpty == true
        ? job['subject'] as String
        : (job['kind'] == 'transport' ? l10n.paTransport : l10n.paVisit);
    final when = job['scheduled_for'] as String?;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(job['stable_name'] as String? ?? 'A stable',
                  style: AppText.heading(19, height: 1.2)),
              const SizedBox(height: 4),
              Text('$subject · AED ${price.toStringAsFixed(0)}',
                  style: AppText.body(15, color: AppColors.ink(0.65))),
              if (when != null) ...[
                const SizedBox(height: 3),
                Text(_pretty(when),
                    style: AppText.body(13, color: AppColors.ink(0.5))),
              ],
            ]),
          ),
          if (done)
            AppTag(l10n.paDoneTag, tone: TagTone.neutral)
          else if (today)
            AppTag(l10n.paTodayTag, tone: TagTone.accent)
          else
            AppTag(l10n.paBookedTag, tone: TagTone.sage),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
        ]),
      ),
    );
  }

  String _pretty(String d) {
    final day = DateTime.tryParse(d);
    return day == null ? d : DateFormat('EEE d MMM').format(day);
  }
}

// ---- Finishing a job -------------------------------------------------------
class _FinishJobScreen extends StatefulWidget {
  const _FinishJobScreen({required this.job});
  final Map<String, dynamic> job;
  @override
  State<_FinishJobScreen> createState() => _FinishJobScreenState();
}

class _FinishJobScreenState extends State<_FinishJobScreen> {
  final _note = TextEditingController();
  bool _saving = false;
  DateTime? _scheduled;

  @override
  void initState() {
    super.initState();
    _note.text = (widget.job['provider_note'] as String?) ?? '';
    _scheduled = DateTime.tryParse((widget.job['scheduled_for'] as String?) ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _scheduled ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 120)),
    );
    if (d == null) return;
    setState(() => _scheduled = d);
    try {
      await SupabaseService.scheduleJob(widget.job['id'] as String, d);
    } catch (e) {
      AppErrors.report(e);
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await SupabaseService.completeJob(widget.job['id'] as String,
          note: _note.text.trim().isEmpty ? null : _note.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final job = widget.job;
    final done = job['status'] == 'completed';
    final price = (job['quote_price'] as num?)?.toDouble() ?? 0;
    final subject = (job['subject'] as String?)?.isNotEmpty == true
        ? job['subject'] as String
        : l10n.paVisit;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(l10n.paTabToday,
            style: AppText.body(15, color: AppColors.ink(0.6))),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
        children: [
          Text('${job['stable_name'] ?? 'A stable'} · AED ${price.toStringAsFixed(0)}',
              style: AppText.eyebrow(color: AppColors.accent700)),
          const SizedBox(height: 8),
          Text(subject, style: AppText.heading(30, height: 1.1)),
          if ((job['detail'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(color: AppColors.accent2300, width: 2))),
              child: Text(job['detail'] as String,
                  style: AppText.body(16, height: 1.5)),
            ),
          ],
          const SizedBox(height: 22),
          _RowTile(
            label: l10n.paWhen,
            value: _scheduled == null
                ? l10n.paSetADay
                : DateFormat('EEE d MMM').format(_scheduled!),
            onTap: done ? null : _pickDay,
          ),
          const SizedBox(height: 22),
          Text(l10n.paNoteForStable, style: AppText.eyebrow()),
          const SizedBox(height: 8),
          if (done)
            Text(
                (job['provider_note'] as String?)?.isNotEmpty == true
                    ? job['provider_note'] as String
                    : l10n.paNoNote,
                style: AppText.body(16, height: 1.5))
          else
            AppField(
              label: '',
              controller: _note,
              maxLines: 3,
              hintText: l10n.paNoteHint,
            ),
          const SizedBox(height: 24),
          if (done)
            AppTag(l10n.paCompletedTag, tone: TagTone.sage)
          else if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            AppButton(label: l10n.paMarkDone, onPressed: _finish),
          const SizedBox(height: 14),
          Text(l10n.paFinishNote,
              style: AppText.body(14, height: 1.5, color: AppColors.ink(0.55))),
        ],
      ),
    );
  }
}

// ---- Requests --------------------------------------------------------------
class _RequestsTab extends StatefulWidget {
  const _RequestsTab({required this.vendorId});
  final String vendorId;
  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.vendorQuoteRequests(widget.vendorId);
  void _reload() =>
      setState(() => _f = SupabaseService.vendorQuoteRequests(widget.vendorId));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        final all = snap.data ?? const [];
        final l10n = AppL10n.of(context);
        final open = all
            .where((r) => r['status'] == 'open' || r['status'] == 'quoted')
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
          children: [
            Text(l10n.paTabRequests, style: AppText.heading(34, height: 1)),
            const SizedBox(height: 20),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (open.isEmpty)
              Text(l10n.paNoRequests,
                  style: AppText.body(16, color: AppColors.ink(0.6)))
            else
              for (final r in open) ...[
                _RequestRow(
                  req: r,
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _RequestScreen(req: r)));
                    _reload();
                  },
                ),
                const _Line(),
              ],
          ],
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.req, required this.onTap});
  final Map<String, dynamic> req;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final quoted = req['status'] == 'quoted';
    final isTransport = req['kind'] == 'transport';
    final title = isTransport
        ? '${l10n.paTransport}: ${req['from_loc'] ?? '?'} → ${req['to_loc'] ?? '?'}'
        : ((req['subject'] as String?)?.isNotEmpty == true
            ? req['subject'] as String
            : l10n.paServiceRequest);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.heading(18, height: 1.2)),
              const SizedBox(height: 4),
              Text(req['stable_name'] as String? ?? l10n.paFactStable,
                  style: AppText.body(14, color: AppColors.ink(0.6))),
            ]),
          ),
          AppTag(quoted ? l10n.paQuotedTag : l10n.paNewTag,
              tone: quoted ? TagTone.sage : TagTone.accent),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
        ]),
      ),
    );
  }
}

class _RequestScreen extends StatefulWidget {
  const _RequestScreen({required this.req});
  final Map<String, dynamic> req;
  @override
  State<_RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<_RequestScreen> {
  final _price = TextEditingController();
  bool _busy = false;
  String? _outcome;

  @override
  void initState() {
    super.initState();
    final p = (widget.req['quote_price'] as num?)?.toDouble();
    if (p != null) _price.text = p.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final price = double.tryParse(_price.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).paEnterPrice)));
      return;
    }
    setState(() => _busy = true);
    try {
      await SupabaseService.submitQuote(widget.req['id'] as String, price, null);
      if (mounted) setState(() => _outcome = 'quoted');
    } catch (e) {
      AppErrors.report(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    try {
      await SupabaseService.declineQuote(widget.req['id'] as String);
      if (mounted) setState(() => _outcome = 'declined');
    } catch (e) {
      AppErrors.report(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final r = widget.req;
    final isTransport = r['kind'] == 'transport';
    final title = isTransport
        ? l10n.paTransport
        : ((r['subject'] as String?)?.isNotEmpty == true
            ? r['subject'] as String
            : l10n.paServiceRequest);
    final facts = <(String, String)>[
      (l10n.paFactStable, r['stable_name'] as String? ?? l10n.paFactStable),
      if (isTransport) (l10n.paFactFrom, (r['from_loc'] as String?) ?? '—'),
      if (isTransport) (l10n.paFactTo, (r['to_loc'] as String?) ?? '—'),
      if ((r['on_day'] as String?)?.isNotEmpty == true)
        (l10n.paFactDay, r['on_day'] as String),
      if (r['horses'] != null) (l10n.paFactHorses, '${r['horses']}'),
    ];
    final answered = _outcome != null;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(l10n.paTabRequests,
            style: AppText.body(15, color: AppColors.ink(0.6))),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
        children: [
          Text(title, style: AppText.heading(30, height: 1.1)),
          const SizedBox(height: 18),
          for (final f in facts) ...[
            const _Line(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 96,
                    child: Text(f.$1,
                        style: AppText.body(15, color: AppColors.ink(0.55)))),
                Expanded(child: Text(f.$2, style: AppText.body(16, height: 1.4))),
              ]),
            ),
          ],
          const _Line(),
          if ((r['detail'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(left: 14),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(color: AppColors.accent2300, width: 2))),
              child: Text(r['detail'] as String,
                  style: AppText.body(16, height: 1.6)),
            ),
          ],
          const SizedBox(height: 26),
          if (answered) ...[
            AppTag(_outcome == 'quoted' ? l10n.paQuoteSentTag : l10n.paDeclinedTag,
                tone: _outcome == 'quoted' ? TagTone.sage : TagTone.neutral),
            const SizedBox(height: 12),
            Text(
                _outcome == 'quoted'
                    ? l10n.paQuoteSentNote
                    : l10n.paDeclinedNote,
                style: AppText.body(15, height: 1.5, color: AppColors.ink(0.6))),
          ] else ...[
            Text(l10n.paYourPrice, style: AppText.eyebrow()),
            const SizedBox(height: 8),
            AppField(
                label: '',
                controller: _price,
                keyboardType: TextInputType.number),
            const SizedBox(height: 18),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else ...[
              AppButton(label: l10n.paSendPrice, onPressed: _send),
              const SizedBox(height: 12),
              AppButton(
                  label: l10n.paCannotTake,
                  variant: AppButtonVariant.secondary,
                  onPressed: _decline),
            ],
            const SizedBox(height: 14),
            Text(l10n.paPriceFootnote,
                style: AppText.body(14, height: 1.5, color: AppColors.ink(0.55))),
          ],
        ],
      ),
    );
  }
}

// ---- Orders to pack --------------------------------------------------------
class _OrdersTab extends StatefulWidget {
  const _OrdersTab({required this.vendorId});
  final String vendorId;
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.vendorOrders(widget.vendorId);
  void _reload() =>
      setState(() => _f = SupabaseService.vendorOrders(widget.vendorId));

  Future<void> _advance(String id, String status) async {
    try {
      await SupabaseService.setOrderStatus(id, status);
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
        final all = snap.data ?? const [];
        final l10n = AppL10n.of(context);
        final toPack = all
            .where((o) => o['status'] == 'pending' || o['status'] == 'accepted')
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
          children: [
            Text(l10n.paToPack, style: AppText.heading(34, height: 1)),
            const SizedBox(height: 8),
            Text(l10n.paToPackSub,
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 22),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (toPack.isEmpty)
              Text(l10n.paNoPack,
                  style: AppText.body(16, color: AppColors.ink(0.6)))
            else
              for (final o in toPack) ...[
                _PackRow(order: o, onAdvance: _advance),
                const _Line(),
              ],
          ],
        );
      },
    );
  }
}

class _PackRow extends StatefulWidget {
  const _PackRow({required this.order, required this.onAdvance});
  final Map<String, dynamic> order;
  final Future<void> Function(String, String) onAdvance;
  @override
  State<_PackRow> createState() => _PackRowState();
}

class _PackRowState extends State<_PackRow> {
  late final Future<List<Map<String, dynamic>>> _items =
      SupabaseService.orderItems(widget.order['id'] as String);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final o = widget.order;
    final status = (o['status'] as String?) ?? 'pending';
    final total = (o['total_aed'] as num?)?.toDouble() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('AED ${total.toStringAsFixed(0)}',
                  style: AppText.heading(19))),
          AppTag(status == 'accepted' ? l10n.paAcceptedTag : l10n.paNewTag,
              tone: status == 'accepted' ? TagTone.sage : TagTone.accent),
        ]),
        const SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _items,
          builder: (context, snap) {
            final items = snap.data ?? const [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final i in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      SizedBox(
                          width: 28,
                          child: Text('${(i['qty'] as num?)?.toInt() ?? 1}×',
                              style: AppText.body(15, color: AppColors.ink(0.5)))),
                      Expanded(
                          child: Text((i['name'] as String?) ?? 'Item',
                              style: AppText.body(16))),
                    ]),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          label: status == 'pending' ? l10n.paAcceptOrder : l10n.paMarkPacked,
          minHeight: 46,
          fontSize: 15,
          onPressed: () => widget.onAdvance(
              o['id'] as String, status == 'pending' ? 'accepted' : 'fulfilled'),
        ),
      ]),
    );
  }
}

// ---- Chat ------------------------------------------------------------------
class _ChatTab extends StatefulWidget {
  const _ChatTab({required this.vendorId});
  final String vendorId;
  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.providerThreads(widget.vendorId);
  void _reload() =>
      setState(() => _f = SupabaseService.providerThreads(widget.vendorId));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _f,
      builder: (context, snap) {
        if (snap.hasError) AppErrors.report(snap.error!);
        final l10n = AppL10n.of(context);
        final threads = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
          children: [
            Text(l10n.paTabChat, style: AppText.heading(34, height: 1)),
            const SizedBox(height: 20),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (threads.isEmpty)
              Text(l10n.paNoChat,
                  style: AppText.body(16, color: AppColors.ink(0.6)))
            else
              for (final t in threads) ...[
                InkWell(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _ThreadScreen(
                            vendorId: widget.vendorId,
                            stableId: t['stable_id'] as String,
                            stableName: t['stable_name'] as String? ?? 'Stable')));
                    _reload();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(children: [
                      _Avatar(name: (t['stable_name'] as String?) ?? 'S'),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['stable_name'] as String? ?? 'Stable',
                                  style: AppText.heading(18)),
                              const SizedBox(height: 3),
                              Text(
                                  (t['last_body'] as String?)?.isNotEmpty == true
                                      ? t['last_body'] as String
                                      : l10n.paSayHello,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body(14,
                                      color: AppColors.ink(0.55))),
                            ]),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
                    ]),
                  ),
                ),
                const _Line(),
              ],
          ],
        );
      },
    );
  }
}

class _ThreadScreen extends StatefulWidget {
  const _ThreadScreen(
      {required this.vendorId,
      required this.stableId,
      required this.stableName});
  final String vendorId;
  final String stableId;
  final String stableName;
  @override
  State<_ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<_ThreadScreen> {
  final _input = TextEditingController();
  late Future<List<Map<String, dynamic>>> _f =
      SupabaseService.threadMessages(widget.vendorId, widget.stableId);
  bool _sending = false;

  void _reload() => setState(() =>
      _f = SupabaseService.threadMessages(widget.vendorId, widget.stableId));

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await SupabaseService.sendProviderMessage(
          widget.vendorId, widget.stableId, body);
      _input.clear();
      _reload();
    } catch (e) {
      AppErrors.report(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = SupabaseService.currentUser?.id;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(widget.stableName, style: AppText.heading(20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _f,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data ?? const [];
                if (msgs.isEmpty) {
                  return Center(
                      child: Text(AppL10n.of(context).paNoMessages,
                          style: AppText.body(15, color: AppColors.ink(0.5))));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    for (final m in msgs) _bubble(m, m['sender_id'] == me),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppL10n.of(context).paMessageStable(widget.stableName),
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4)))
                    : IconButton.filled(
                        onPressed: _send,
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.accent),
                        icon: Icon(Icons.arrow_forward, color: AppColors.bg),
                      ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> m, bool mine) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: mine ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text((m['body'] as String?) ?? '',
            style: AppText.body(16,
                height: 1.4, color: mine ? AppColors.bg : AppColors.text)),
      ),
    );
  }
}

// ---- Money -----------------------------------------------------------------
class _MoneyTab extends StatefulWidget {
  const _MoneyTab({required this.vendorId});
  final String vendorId;
  @override
  State<_MoneyTab> createState() => _MoneyTabState();
}

class _MoneyTabState extends State<_MoneyTab> {
  late final Future<List<Map<String, dynamic>>> _orders =
      SupabaseService.vendorOrders(widget.vendorId);
  late final Future<List<Map<String, dynamic>>> _jobs =
      SupabaseService.providerJobs(widget.vendorId);
  late final Future<List<Map<String, dynamic>>> _payouts =
      SupabaseService.vendorPayouts(widget.vendorId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, oSnap) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _jobs,
          builder: (context, jSnap) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _payouts,
              builder: (context, pSnap) {
                final orders = oSnap.data ?? const [];
                final jobs = jSnap.data ?? const [];
                final payouts = pSnap.data ?? const [];

                double payable = 0, held = 0;
                for (final o in orders) {
                  final st = SupabaseService.orderMoneyState(o);
                  final net = SupabaseService.orderNet(o);
                  if (st == 'payable') payable += net;
                  if (st == 'held' || st == 'disputed') held += net;
                }
                // Completed services settle immediately — count them payable.
                final services = jobs
                    .where((j) => j['status'] == 'completed')
                    .fold<double>(0,
                        (t, j) => t + ((j['quote_price'] as num?)?.toDouble() ?? 0));
                final nextPayout = payable + services;
                final lastPaid = payouts
                    .where((p) => p['status'] == 'paid')
                    .fold<double>(
                        0, (t, p) => t + ((p['net_aed'] as num?)?.toDouble() ?? 0));

                final loading = oSnap.connectionState ==
                        ConnectionState.waiting ||
                    jSnap.connectionState == ConnectionState.waiting;
                final l10n = AppL10n.of(context);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
                  children: [
                    Text(l10n.paTabMoney, style: AppText.heading(34, height: 1)),
                    const SizedBox(height: 22),
                    if (loading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      Text(l10n.paNextPayout, style: AppText.eyebrow()),
                      const SizedBox(height: 8),
                      Text('AED ${nextPayout.toStringAsFixed(0)}',
                          style: AppText.heading(46, height: 1)),
                      const SizedBox(height: 10),
                      Text(l10n.paPayoutNote,
                          style: AppText.body(16, color: AppColors.accent700)),
                      const SizedBox(height: 26),
                      _MoneyRow(
                          label: l10n.paHeldRow,
                          value: held,
                          quiet: true),
                      _MoneyRow(label: l10n.paReadyRow, value: payable),
                      _MoneyRow(label: l10n.paServicesRow, value: services),
                      _MoneyRow(
                          label: l10n.paPaidRow, value: lastPaid, quiet: true),
                      const SizedBox(height: 22),
                      Text(l10n.paMoneyFootnote,
                          style: AppText.body(14,
                              height: 1.5, color: AppColors.ink(0.6))),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow(
      {required this.label, required this.value, this.quiet = false});
  final String label;
  final double value;
  final bool quiet;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _Line(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: AppText.body(16,
                      color: quiet ? AppColors.ink(0.55) : AppColors.text))),
          Text('AED ${value.toStringAsFixed(0)}',
              style: quiet
                  ? AppText.body(16, color: AppColors.ink(0.55))
                  : AppText.heading(18)),
        ]),
      ),
    ]);
  }
}

// ---- When I work -----------------------------------------------------------
class _WhenIWorkScreen extends StatefulWidget {
  const _WhenIWorkScreen({required this.vendor});
  final Map<String, dynamic> vendor;
  @override
  State<_WhenIWorkScreen> createState() => _WhenIWorkScreenState();
}

class _WhenIWorkScreenState extends State<_WhenIWorkScreen> {
  // 2024-01-07 is a Sunday; day d maps to that week so the name localises.
  String _dayName(int d, String locale) =>
      DateFormat('EEEE', locale).format(DateTime(2024, 1, 7 + d));
  Map<int, bool> _open = {for (var d = 0; d < 7; d++) d: true};
  int _cap = 6;
  late Future<List<Map<String, dynamic>>> _away;
  bool _loading = true;

  String get _vid => widget.vendor['id'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _cap = (widget.vendor['daily_cap'] as num?)?.toInt() ?? 6;
    _away = SupabaseService.timeAway(_vid);
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await SupabaseService.availability(_vid);
      if (mounted) setState(() { _open = a; _loading = false; });
    } catch (e) {
      AppErrors.report(e);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(int dow) async {
    final next = !(_open[dow] ?? true);
    setState(() => _open[dow] = next);
    try {
      await SupabaseService.setAvailabilityDay(_vid, dow, next);
    } catch (e) {
      AppErrors.report(e);
    }
  }

  Future<void> _setCap(int delta) async {
    final next = (_cap + delta).clamp(1, 30);
    setState(() => _cap = next);
    try {
      await SupabaseService.setDailyCap(_vid, next);
    } catch (e) {
      AppErrors.report(e);
    }
  }

  Future<void> _addAway() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (range == null) return;
    try {
      await SupabaseService.addTimeAway(_vid, range.start, range.end);
      setState(() => _away = SupabaseService.timeAway(_vid));
    } catch (e) {
      AppErrors.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(l10n.paTabToday,
            style: AppText.body(15, color: AppColors.ink(0.6))),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
              children: [
                Text(l10n.paWhenIWork, style: AppText.heading(34, height: 1.05)),
                const SizedBox(height: 10),
                Text(l10n.paWhenSub,
                    style: AppText.body(16, color: AppColors.ink(0.6))),
                const SizedBox(height: 22),
                for (var d = 0; d < 7; d++) ...[
                  const _Line(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Expanded(
                          child: Text(_dayName(d, l10n.localeName),
                              style: AppText.heading(17,
                                  color: (_open[d] ?? true)
                                      ? AppColors.text
                                      : AppColors.ink(0.4)))),
                      Text((_open[d] ?? true) ? l10n.paWorking : l10n.paOff,
                          style: AppText.body(14, color: AppColors.ink(0.5))),
                      Switch(
                        value: _open[d] ?? true,
                        onChanged: (_) => _toggle(d),
                        activeThumbColor: AppColors.bg,
                        activeTrackColor: AppColors.accent2600,
                      ),
                    ]),
                  ),
                ],
                const _Line(),
                const SizedBox(height: 26),
                Text(l10n.paHorsesPerDay,
                    style: AppText.eyebrow(color: AppColors.accent2700)),
                const SizedBox(height: 12),
                Row(children: [
                  _CapBtn(icon: Icons.remove, onTap: () => _setCap(-1)),
                  SizedBox(
                      width: 56,
                      child: Text('$_cap',
                          textAlign: TextAlign.center,
                          style: AppText.heading(24))),
                  _CapBtn(icon: Icons.add, onTap: () => _setCap(1)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(l10n.paCapNote,
                          style:
                              AppText.body(14, color: AppColors.ink(0.6)))),
                ]),
                const SizedBox(height: 28),
                Text(l10n.paAway,
                    style: AppText.eyebrow(color: AppColors.accent2700)),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _away,
                  builder: (context, snap) {
                    final rows = snap.data ?? const [];
                    return Column(children: [
                      for (final r in rows) ...[
                        const _Line(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${_fmt(r['start_date'])} – ${_fmt(r['end_date'])}',
                                        style: AppText.body(16)),
                                    const SizedBox(height: 3),
                                    Text(l10n.paAwaySub,
                                        style: AppText.body(13,
                                            color: AppColors.ink(0.5))),
                                  ]),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await SupabaseService.removeTimeAway(
                                      r['id'] as String);
                                  setState(() => _away =
                                      SupabaseService.timeAway(_vid));
                                } catch (e) {
                                  AppErrors.report(e);
                                }
                              },
                              child: Text(l10n.paRemove,
                                  style: AppText.body(14,
                                      color: AppColors.ink(0.55))),
                            ),
                          ]),
                        ),
                      ],
                      const _Line(),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _addAway,
                          child: Text(l10n.paAddAway,
                              style: AppText.heading(16,
                                  color: AppColors.accent700)),
                        ),
                      ),
                    ]);
                  },
                ),
              ],
            ),
    );
  }

  String _fmt(dynamic d) {
    final day = DateTime.tryParse(d as String? ?? '');
    return day == null ? '$d' : DateFormat('d MMM').format(day);
  }
}

// ---- Small shared bits -----------------------------------------------------
class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.divider);
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration:
          const BoxDecoration(color: AppColors.accent2300, shape: BoxShape.circle),
      child: Text(initial,
          style: AppText.heading(16, color: AppColors.accent2900)),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.neutral100, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: AppText.body(10,
                letterSpacing: 0.6, color: AppColors.ink(0.5))),
        const SizedBox(height: 5),
        Text(value, style: AppText.heading(19)),
      ]),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Text(label, style: AppText.body(15, color: AppColors.ink(0.6))),
          const Spacer(),
          Text(value, style: AppText.body(16)),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppColors.ink(0.4)),
          ],
        ]),
      ),
    );
  }
}

class _CapBtn extends StatelessWidget {
  const _CapBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, color: AppColors.text),
      ),
    );
  }
}
