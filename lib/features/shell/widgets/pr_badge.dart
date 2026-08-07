import 'package:flutter/material.dart';

/// Inline PR marker (`F-LOG-013` §2, docs/24-DESIGN-SYSTEM.md
/// §component-inventory).
///
/// Its own entrance transition **is** the "brief, non-blocking animation" the
/// spec asks for alongside the badge: the widget exists exactly when a record
/// exists, so its first mount already lines up with the moment one is set. No
/// separate overlay is needed, and nothing here can block input — it is a
/// small icon, never a dialog or a sheet.
class PrBadge extends StatelessWidget {
  const PrBadge({super.key, this.tooltip = 'Personal record'});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: t, child: child),
      ),
      child: Tooltip(
        message: tooltip,
        child: Icon(
          Icons.emoji_events,
          size: 18,
          color: theme.colorScheme.tertiary,
          semanticLabel: tooltip,
        ),
      ),
    );
  }
}
