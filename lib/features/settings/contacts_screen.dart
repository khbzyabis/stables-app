import 'package:flutter/material.dart';
import '../../data/errors.dart';

import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 38 — the stable's contacts. Real, shared with everyone in the stable.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  static const route = '/contacts';

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final id = SessionScope.of(context).activeStableId;
    if (id == null) return const [];
    return SupabaseService.contacts(id);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _add() async {
    final stableId = SessionScope.of(context).activeStableId;
    if (stableId == null) return;
    final r = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _AddContactSheet(),
    );
    if (r == null) return;
    try {
      await SupabaseService.addContact(
        stableId: stableId,
        name: r['name'] ?? '',
        role: r['role'],
        phone: r['phone'],
        nextNote: r['next'],
      );
      _reload();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

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
            final contacts = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
              children: [
                BackLink(label: session.activeStableName),
                const SizedBox(height: 20),
                Text(l10n.contacts, style: AppText.heading(40, height: 1)),
                const SizedBox(height: 10),
                Text('Everyone at the stable can see and call these.',
                    style: AppText.body(16, color: AppColors.ink(0.6))),
                const SizedBox(height: 24),
                const Hairline(),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()))
                else if (contacts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    child: Text(
                        'No contacts yet. Add your farrier, vet, dentist or feed merchant below.',
                        style: AppText.body(16, color: AppColors.ink(0.6))),
                  )
                else
                  for (final c in contacts) ...[
                    _ContactRow(contact: c),
                    const Hairline(),
                  ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _add,
                  child: Text('+ ${l10n.addContact}',
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact});
  final Map<String, dynamic> contact;

  @override
  Widget build(BuildContext context) {
    final role = contact['role'] as String?;
    final phone = contact['phone'] as String?;
    final sub = [role, phone].where((e) => e != null && e.isNotEmpty).join(' · ');
    final next = contact['next_note'] as String?;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((contact['name'] as String?) ?? '',
                    style: AppText.heading(20, height: 1.2)),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(sub,
                      style: AppText.body(15, color: AppColors.ink(0.55))),
                ],
                if (next != null && next.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(next,
                      style: AppText.body(15, color: AppColors.accent700)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet();
  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _phone = TextEditingController();
  final _next = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _phone.dispose();
    _next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add a contact', style: AppText.heading(26)),
          const SizedBox(height: 18),
          _Field(controller: _name, hint: 'Name'),
          const SizedBox(height: 12),
          _Field(controller: _role, hint: 'Role (Farrier, Vet, …)'),
          const SizedBox(height: 12),
          _Field(
              controller: _phone,
              hint: 'Phone',
              keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _Field(controller: _next, hint: 'Next visit / note (optional)'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              if (_name.text.trim().isEmpty) return;
              Navigator.of(context).pop({
                'name': _name.text.trim(),
                'role': _role.text.trim(),
                'phone': _phone.text.trim(),
                'next': _next.text.trim(),
              });
            },
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.controller, required this.hint, this.keyboard});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      cursorColor: AppColors.accent,
      style: AppText.body(17),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.neutral100,
        hintText: hint,
        hintStyle: AppText.body(16, color: AppColors.ink(0.45)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }
}
