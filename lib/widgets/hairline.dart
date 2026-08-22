import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// A 1px hairline. The layout rule that matters most in this system:
/// rows are separated by hairlines, not cards.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent),
      child: Container(height: 1, color: AppColors.divider),
    );
  }
}

/// A list of rows separated by hairlines, with a leading and trailing hairline —
/// the canonical pattern:
///
/// ```
/// <hairline> row <hairline> row <hairline>
/// ```
///
/// No card borders, no shadows, no rounded containers around items.
class HairlineList extends StatelessWidget {
  const HairlineList({
    super.key,
    required this.children,
    this.leading = true,
    this.trailing = true,
    this.indent = 0,
  });

  final List<Widget> children;
  final bool leading;
  final bool trailing;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (leading) rows.add(const Hairline());
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      final isLast = i == children.length - 1;
      if (!isLast) {
        rows.add(Hairline(indent: indent));
      } else if (trailing) {
        rows.add(const Hairline());
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}
