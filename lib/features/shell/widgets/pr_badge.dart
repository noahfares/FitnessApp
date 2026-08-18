import 'package:flutter/material.dart';

import '../../../core/a11y/motion.dart';
import '../../../core/l10n/l10n.dart';

/// Inline PR marker (`F-LOG-013` §2, docs/24-DESIGN-SYSTEM.md
/// §component-inventory).
///
/// Its own entrance transition **is** the "brief, non-blocking animation" the
/// spec asks for alongside the badge: the widget exists exactly when a record
/// exists, so its first mount already lines up with the moment one is set. No
/// separate overlay is needed, and nothing here can block input — it is a
/// small icon, never a dialog or a sheet.
///
/// Under reduce motion the badge simply *is* there, with no entrance
/// (`F-A11Y-005`): the record still shows, which is the part that carries
/// meaning — only the flourish is dropped.
class PrBadge extends StatelessWidget {
  const PrBadge({super.key, this.tooltip});

  /// Null uses the generic label; a localised default cannot be `const`.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tooltip = this.tooltip ?? context.l10n.shellPersonalRecord;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motionDuration(context, const Duration(milliseconds: 350)),
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
