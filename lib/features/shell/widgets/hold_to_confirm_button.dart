import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// A press-and-hold destructive action, for the one confirmation in the app
/// that a single sweaty tap must not be able to trigger: discarding a whole
/// in-progress workout (`F-LOG-022` §2). A tap-to-confirm sheet is one
/// mis-tap away from the same outcome it is meant to prevent; holding for a
/// fixed duration is not.
///
/// Releasing early cancels and the fill resets — there is no partial credit.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    required this.label,
    required this.onConfirmed,
    this.holdDuration = const Duration(seconds: 1, milliseconds: 200),
    super.key,
  });

  final String label;
  final VoidCallback onConfirmed;
  final Duration holdDuration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.holdDuration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onConfirmed();
        });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onLongPressStart: (_) => _controller.forward(from: 0),
      onLongPressEnd: (_) => _controller.reverse(),
      onLongPressCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          height: AppSpacing.minTouchTarget,
          decoration: BoxDecoration(
            color: colors.danger,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _controller.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.onDanger.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                _controller.value == 0
                    ? 'Hold to ${widget.label.toLowerCase()}'
                    : widget.label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colors.onDanger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
