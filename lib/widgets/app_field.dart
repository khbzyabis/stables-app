import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A labelled input. The label is a sage uppercase eyebrow; the input fill is
/// neutral-100 with a transparent border and a pill radius (per the design's
/// rule: input fills are neutral-100 with a transparent border, not an
/// outlined box).
class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textStyle,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextStyle? textStyle;
  final bool autofocus;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Text(label.toUpperCase(), style: AppText.eyebrow()),
        ),
        Stack(
          children: [
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              autofocus: autofocus,
              textAlign: textAlign,
              cursorColor: AppColors.accent,
              style: textStyle ?? AppText.body(17, height: 1.2),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.neutral100,
                hintText: hintText,
                hintStyle: AppText.body(17, color: AppColors.ink(0.45)),
                constraints: const BoxConstraints(minHeight: 56),
                contentPadding: EdgeInsets.only(
                  left: 18,
                  right: suffix != null ? 76 : 18,
                  top: 16,
                  bottom: 16,
                ),
                border: _border(Colors.transparent),
                enabledBorder: _border(Colors.transparent),
                focusedBorder: _border(AppColors.accent),
              ),
            ),
            if (suffix != null)
              PositionedDirectional(
                end: 8,
                top: 8,
                bottom: 8,
                child: suffix!,
              ),
          ],
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: BorderSide(color: color, width: color == AppColors.accent ? 1.5 : 1),
      );
}
