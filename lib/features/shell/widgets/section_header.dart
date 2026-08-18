import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A grouped-list section header: uppercase, 13/600, +0.04em tracking,
/// `labelSecondary` — the Apple-style pass's replacement for `titleMedium`
/// section titles.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.52,
        color: colors.labelSecondary,
      ),
    );
  }
}
