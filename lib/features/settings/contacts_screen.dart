import 'package:flutter/material.dart';

import '../../data/comms_data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 38 — the stable's contacts. Farrier, vet, dentist and the rest.
/// Everyone at the stable can call these.
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});
  static const route = '/contacts';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 84, 32, 44),
          children: [
            const BackLink(label: 'Serc'),
            const SizedBox(height: 20),
            Text(l10n.contacts, style: AppText.heading(40, height: 1)),
            const SizedBox(height: 10),
            Text('Everyone at the stable can call these.',
                style: AppText.body(16, color: AppColors.ink(0.6))),
            const SizedBox(height: 24),
            const Hairline(),
            for (final c in CommsData.contacts) ...[
              _ContactRow(contact: c),
              const Hairline(),
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {},
              child: Text('+ ${l10n.addContact}',
                  style: AppText.heading(17, color: AppColors.accent700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: AppText.heading(20, height: 1.2)),
                const SizedBox(height: 4),
                Text('${contact.role} · ${contact.phone}',
                    style: AppText.body(15, color: AppColors.ink(0.55))),
                const SizedBox(height: 8),
                Text(contact.next,
                    style: AppText.body(15, color: AppColors.accent700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _RoundIcon(icon: Icons.call_outlined),
          const SizedBox(width: 8),
          _RoundIcon(icon: Icons.chat_bubble_outline),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, size: 19, color: AppColors.accent700),
    );
  }
}
