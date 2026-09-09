/// An odometer-style number: each digit rolls independently from its
/// previous value to its new one, all landing at the same instant
/// (`F-LOG-024`).
///
/// A deliberate, narrow exception to docs/24-DESIGN-SYSTEM.md's "mid-set,
/// animation is latency" rule — requested explicitly for this one cell, kept
/// inside that doc's own 150–250 ms sparing budget, and, like every other
/// animation in the app, gone entirely under reduce motion
/// (`core/a11y/motion.dart`): the new value still appears instantly, only
/// the roll is dropped.
library;

import 'package:flutter/material.dart';

import '../a11y/motion.dart';

class RollingNumber extends StatefulWidget {
  const RollingNumber({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  /// The number to display. Negative values show a static leading `-`; only
  /// the digits roll.
  final int value;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _fromValue;

  @override
  void initState() {
    super.initState();
    _fromValue = widget.value;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..value = 1
      ..addStatusListener(_onStatusChanged);
  }

  @override
  void didUpdateWidget(covariant RollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    _controller.duration = widget.duration;
    if (prefersReducedMotion(context)) {
      setState(() {
        _fromValue = widget.value;
        _controller.value = 1;
      });
      return;
    }
    _fromValue = oldWidget.value;
    _controller
      ..value = 0
      ..forward();
  }

  // Once a roll lands, drop the padding that made room for a digit the two
  // values didn't share (e.g. 99 -> 100) so the cell returns to its natural
  // width rather than keeping a permanent blank column.
  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _fromValue != widget.value) {
      setState(() => _fromValue = widget.value);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    final digitSize = painter.size;

    final negative = widget.value < 0 || _fromValue < 0;
    final from = _fromValue.abs().toString();
    final to = widget.value.abs().toString();
    final width = from.length > to.length ? from.length : to.length;
    final fromDigits = from.padLeft(width);
    final toDigits = to.padLeft(width);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (negative) Text('-', style: widget.style),
          for (var i = 0; i < width; i++)
            _DigitReel(
              from: fromDigits[i],
              to: toDigits[i],
              t: _controller.value,
              style: widget.style,
              size: digitSize,
            ),
        ],
      ),
    );
  }
}

class _DigitReel extends StatelessWidget {
  const _DigitReel({
    required this.from,
    required this.to,
    required this.t,
    required this.style,
    required this.size,
  });

  /// A digit `0`–`9`, or a space when this column has no digit on that side
  /// (the number just grew or shrank a place).
  final String from;
  final String to;
  final double t;
  final TextStyle style;
  final Size size;

  @override
  Widget build(BuildContext context) {
    if (from == to) return _glyph(to);
    if (from == ' ') return Opacity(opacity: t, child: _glyph(to));
    if (to == ' ') return Opacity(opacity: 1 - t, child: _glyph(from));

    // Both sides are real digits at this place value: roll the strip through
    // the straight-line path between them — never wrapping through 9→0,
    // since a single column only ever spans the two digits it was asked to.
    final position = int.parse(from) + (int.parse(to) - int.parse(from)) * t;
    return ClipRect(
      // Keyed so a mid-roll digit is distinguishable from a settled one
      // without inferring it from which glyphs happen to be in the tree —
      // every 0-9 glyph is always present here, just clipped.
      key: const ValueKey('rolling-digit-strip'),
      child: SizedBox(
        width: size.width,
        height: size.height,
        // The ten-glyph strip is taller than this box by design — an
        // `OverflowBox` lets it lay out at its natural size instead of being
        // squeezed into one digit's height, which is what a plain `SizedBox`
        // around the `Column` would do (and `ClipRect` alone doesn't fix:
        // clipping is a paint-time crop, not a layout constraint).
        child: OverflowBox(
          maxHeight: double.infinity,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, -position * size.height),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [for (var d = 0; d <= 9; d++) _glyph('$d')],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glyph(String char) => SizedBox(
    width: size.width,
    height: size.height,
    child: Text(char, textAlign: TextAlign.center, style: style),
  );
}
