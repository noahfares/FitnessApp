import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// The large-title header shared by every bottom-tab root screen
/// (Home, Routines, History, Insights): 34/700 title, -1.02 tracking, an
/// optional caption above it, and optional trailing actions — Home's own
/// header (`F-THM-007` point 5) generalised so all four tabs read as one
/// family instead of Home alone getting the large-title treatment and the
/// rest a plain `AppBar`. Callers own their own outer padding; this widget
/// only lays out the row.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    this.caption,
    this.actions = const [],
  });

  final String title;
  final String? caption;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (caption case final caption?) ...[
                Text(
                  caption,
                  style: TextStyle(fontSize: 13, color: colors.labelSecondary),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.02,
                  height: 1.1,
                  color: colors.label,
                ),
              ),
            ],
          ),
        ),
        for (final action in actions) ...[
          const SizedBox(width: AppSpacing.sm),
          action,
        ],
      ],
    );
  }
}
