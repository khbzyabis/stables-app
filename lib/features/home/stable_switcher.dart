import 'package:flutter/material.dart';

import '../../data/session.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_tag.dart';
import '../auth/create_stable_screen.dart';

/// A quick stable switcher — works the same on phone and web. Lists the
/// stables the signed-in person belongs to, tap one to make it active, or
/// create another. Each stable keeps its own horses, board, tasks and
/// schedule, so switching swaps the whole app to that stable's data.
Future<void> showStableSwitcher(BuildContext context) {
  final session = SessionScope.of(context);
  // Freshen the membership list as the sheet opens.
  session.refresh();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.warmWhite,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            final stables = session.stables;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
                  child: Text('Your stables',
                      style: AppText.heading(24, height: 1)),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    children: [
                      if (stables.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Text(
                            'You are not in any stable yet. Create your first one below.',
                            style: AppText.body(15, color: AppColors.ink(0.6)),
                          ),
                        )
                      else
                        for (final s in stables)
                          _StableRow(
                            name: (s['name'] as String?) ?? 'Stable',
                            city: (s['city'] as String?)?.trim() ?? '',
                            role: (s['role'] as String?) ?? '',
                            active: s['id'] == session.activeStableId,
                            onTap: () {
                              session.setActive(s['id'] as String);
                              Navigator.of(sheetCtx).pop();
                            },
                          ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Material(
                    color: AppColors.accent100,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(context)
                            .pushNamed(CreateStableScreen.route);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: Row(
                          children: [
                            const Icon(Icons.add,
                                size: 20, color: AppColors.accent800),
                            const SizedBox(width: 10),
                            Text('New stable',
                                style: AppText.body(16,
                                    weight: FontWeight.w600,
                                    color: AppColors.accent800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _StableRow extends StatelessWidget {
  const _StableRow({
    required this.name,
    required this.city,
    required this.role,
    required this.active,
    required this.onTap,
  });
  final String name;
  final String city;
  final String role;
  final bool active;
  final VoidCallback onTap;

  static String _prettyRole(String role) =>
      role.isEmpty ? role : role[0].toUpperCase() + role.substring(1);

  static TagTone _tone(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
      case 'manager':
      case 'admin':
        return TagTone.accent;
      case 'groom':
      case 'vet':
      case 'rider':
      case 'trainer':
        return TagTone.sage;
      default:
        return TagTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: active ? AppColors.bg : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: active ? AppColors.divider : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent100,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.characters.isEmpty
                        ? 'S'
                        : name.characters.first.toUpperCase(),
                    style: AppText.heading(17, color: AppColors.accent700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.heading(17, height: 1.1)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (role.isNotEmpty) ...[
                            AppTag(_prettyRole(role), tone: _tone(role)),
                            const SizedBox(width: 8),
                          ],
                          if (city.isNotEmpty)
                            Flexible(
                              child: Text(city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body(13,
                                      color: AppColors.ink(0.55))),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (active)
                  const Icon(Icons.check_circle,
                      size: 22, color: AppColors.accent)
                else
                  Icon(Icons.circle_outlined,
                      size: 22, color: AppColors.ink(0.25)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
