import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'section_header.dart';

/// A grouped `surface` card of [AppleListRow]/[AppleSwitchRow] children, the
/// iOS-Settings-style building block behind every settings screen —
/// `surface`, radius 20, a hairline `separator` between rows and none after
/// the last. [header] renders as a [SectionHeader] above the card, matching
/// the handoff's uppercase section titles.
class AppleListSection extends StatelessWidget {
  const AppleListSection({required this.children, this.header, super.key});

  final String? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header case final header?) ...[
          SectionHeader(header),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Divider(height: 1, color: colors.separator),
                  ),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One navigable row inside an [AppleListSection]: optional leading icon,
/// title/subtitle, and a trailing chevron (or a custom [trailing] widget in
/// its place). Press dims the row rather than tinting it — the grouped card
/// itself already carries the tint.
class AppleListRow extends StatefulWidget {
  const AppleListRow({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  State<AppleListRow> createState() => _AppleListRowState();
}

class _AppleListRowState extends State<AppleListRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 11,
      ),
      child: Row(
        children: [
          if (widget.icon case final icon?) ...[
            Icon(icon, size: 20, color: colors.tint),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 17,
                    letterSpacing: -0.17,
                    color: colors.label,
                  ),
                ),
                if (widget.subtitle case final subtitle?) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.labelSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing case final trailing?) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing,
          ],
          if (widget.showChevron && widget.onTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, size: 19, color: colors.labelTertiary),
          ],
        ],
      ),
    );
    if (widget.onTap == null) return row;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1,
        duration: const Duration(milliseconds: 200),
        child: row,
      ),
    );
  }
}

/// A row with a trailing switch instead of a chevron.
class AppleSwitchRow extends StatelessWidget {
  const AppleSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppleListRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      showChevron: false,
      // Tapping anywhere on the row toggles it, not only the thumb itself —
      // the same forgiving hit target `SwitchListTile` gives for free.
      onTap: () => onChanged(!value),
      trailing: IgnorePointer(
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: colors.tint,
        ),
      ),
    );
  }
}

/// One row of a checkmark-style radio list inside an [AppleListSection] —
/// the iOS convention for a longer list of mutually-exclusive options, where
/// a [SegmentedTrack] would be too many pills for one row.
class AppleRadioRow extends StatelessWidget {
  const AppleRadioRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppleListRow(
      title: title,
      subtitle: subtitle,
      showChevron: false,
      onTap: onTap,
      trailing: selected ? Icon(Icons.check, color: colors.tint) : null,
    );
  }
}

/// A pill-track segmented control: `surface` track, `surfaceRaised` thumb —
/// the shape behind Insights' Top set/e1RM/Volume switcher and onboarding's
/// appearance/unit pickers alike.
class SegmentedTrack<T> extends StatelessWidget {
  const SegmentedTrack({
    required this.selected,
    required this.segments,
    required this.onChanged,
    super.key,
  });

  final T selected;
  final List<({T value, String label})> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(segment.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 36,
                  decoration: BoxDecoration(
                    color: segment.value == selected
                        ? colors.surfaceRaised
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: segment.value == selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    segment.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: segment.value == selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: segment.value == selected
                          ? colors.label
                          : colors.labelSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
