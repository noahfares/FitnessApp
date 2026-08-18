import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/catalog/muscle_taxonomy.dart';

/// One drawable region: a muscle's rough on-body position, in a fixed
/// 100×220 coordinate space. An original geometric diagram — capsules,
/// blobs and ovals built from plain shape primitives, not traced anatomy —
/// the "licence-clean or don't ship it" discipline `docs/40-ANALYTICS-SPEC.md`
/// §16 asks for, satisfied by drawing nothing sourced from anywhere.
class _Region {
  const _Region(this.muscle, this.rect, {this.radius, this.oval = false});

  final String muscle;
  final Rect rect;

  /// Corner radius for a rounded-rect region. Null and [oval] false paints a
  /// gently rounded default; a radius of half the shorter side reads as a
  /// capsule (limbs), a smaller one as a soft-cornered blob (torso muscles).
  final double? radius;

  /// True draws a true ellipse (shoulders, glutes) instead of a rounded rect.
  final bool oval;
}

/// A tapered capsule — flat sides, fully round ends — the shape a limb
/// muscle (biceps, calves, hamstrings) actually reads as at this scale.
_Region _capsule(String muscle, double l, double t, double r, double b) {
  final rect = Rect.fromLTRB(l, t, r, b);
  return _Region(muscle, rect, radius: rect.shortestSide / 2);
}

/// A softer-cornered blob — pecs, lats, abs, glutes.
_Region _blob(
  String muscle,
  double l,
  double t,
  double r,
  double b, {
  double radius = 8,
}) => _Region(muscle, Rect.fromLTRB(l, t, r, b), radius: radius);

/// A true ellipse — deltoids, the shoulder caps' own muscle.
_Region _oval(String muscle, double cx, double cy, double rx, double ry) =>
    _Region(
      muscle,
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      oval: true,
    );

// Shared limb geometry both views draw identically — an arm and a leg look
// the same from the front and the back at this level of abstraction; only
// which muscle is "hot" on them differs.
const _armL = (
  shoulder: (16.0, 36.0, 8.0),
  upper: (9.0, 38.0, 23.0, 82.0),
  lower: (8.0, 82.0, 21.0, 112.0),
);
const _armR = (
  shoulder: (84.0, 36.0, 8.0),
  upper: (77.0, 38.0, 91.0, 82.0),
  lower: (79.0, 82.0, 92.0, 112.0),
);
const _legL = (
  thigh: (28.0, 128.0, 48.0, 180.0),
  calf: (30.0, 180.0, 46.0, 214.0),
);
const _legR = (
  thigh: (52.0, 128.0, 72.0, 180.0),
  calf: (54.0, 180.0, 70.0, 214.0),
);

final List<_Region> _frontRegions = [
  _blob('chest', 32, 40, 68, 61, radius: 11),
  _oval('frontDelts', 18, 43, 7, 9),
  _oval('frontDelts', 82, 43, 7, 9),
  _oval('sideDelts', 11, 38, 5, 7),
  _oval('sideDelts', 89, 38, 5, 7),
  _capsule(
    'biceps',
    _armL.upper.$1,
    _armL.upper.$2,
    _armL.upper.$3,
    _armL.upper.$4,
  ),
  _capsule(
    'biceps',
    _armR.upper.$1,
    _armR.upper.$2,
    _armR.upper.$3,
    _armR.upper.$4,
  ),
  _capsule(
    'forearms',
    _armL.lower.$1,
    _armL.lower.$2,
    _armL.lower.$3,
    _armL.lower.$4,
  ),
  _capsule(
    'forearms',
    _armR.lower.$1,
    _armR.lower.$2,
    _armR.lower.$3,
    _armR.lower.$4,
  ),
  _blob('abs', 41, 64, 59, 96, radius: 7),
  _capsule('obliques', 32, 66, 40, 94),
  _capsule('obliques', 60, 66, 68, 94),
  _capsule(
    'quads',
    _legL.thigh.$1,
    _legL.thigh.$2,
    _legL.thigh.$3,
    _legL.thigh.$4,
  ),
  _capsule(
    'quads',
    _legR.thigh.$1,
    _legR.thigh.$2,
    _legR.thigh.$3,
    _legR.thigh.$4,
  ),
  _capsule('adductors', 46, 130, 54, 174),
];

final List<_Region> _backRegions = [
  _blob('traps', 38, 27, 62, 51, radius: 9),
  _oval('rearDelts', 18, 43, 7, 9),
  _oval('rearDelts', 82, 43, 7, 9),
  _blob('lats', 23, 48, 42, 90, radius: 12),
  _blob('lats', 58, 48, 77, 90, radius: 12),
  _blob('upperBack', 42, 47, 58, 76, radius: 8),
  _blob('lowerBack', 38, 78, 62, 100, radius: 8),
  _capsule(
    'triceps',
    _armL.upper.$1,
    _armL.upper.$2,
    _armL.upper.$3,
    _armL.upper.$4,
  ),
  _capsule(
    'triceps',
    _armR.upper.$1,
    _armR.upper.$2,
    _armR.upper.$3,
    _armR.upper.$4,
  ),
  _blob('glutes', 29, 118, 71, 142, radius: 16),
  _capsule('abductors', 19, 120, 29, 146),
  _capsule('abductors', 71, 120, 81, 146),
  _capsule(
    'hamstrings',
    _legL.thigh.$1,
    _legL.thigh.$2,
    _legL.thigh.$3,
    _legL.thigh.$4,
  ),
  _capsule(
    'hamstrings',
    _legR.thigh.$1,
    _legR.thigh.$2,
    _legR.thigh.$3,
    _legR.thigh.$4,
  ),
  _capsule(
    'calves',
    _legL.calf.$1,
    _legL.calf.$2,
    _legL.calf.$3,
    _legL.calf.$4,
  ),
  _capsule(
    'calves',
    _legR.calf.$1,
    _legR.calf.$2,
    _legR.calf.$3,
    _legR.calf.$4,
  ),
];

/// A muscular figure shaded by [intensity] (`F-ANA-014`, component-shape
/// mirrors `CalendarHeatmap`'s own "two states, driven by a simple map"
/// simplicity). [intensity] is [muscleHeatIntensity]'s output — 0..1, keyed
/// by muscle name; a muscle with no entry renders as untrained, not
/// zero-and-cold.
class BodyMapHeatOverlay extends StatelessWidget {
  const BodyMapHeatOverlay({
    required this.view,
    required this.intensity,
    super.key,
  });

  final BodyMapView view;
  final Map<String, double> intensity;

  /// A fixed height rather than filling the available width, the same fix
  /// `F-ROU-011`'s own routine-preview chart needed: an unbounded-width
  /// portrait shape (100:220) stretched across a phone-width column would be
  /// taller than the viewport, starving whatever the list renders below it
  /// — caught here by this feature's own widget test, not just inferred.
  static const double _height = 240;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Spoken alternative for a drawing (`F-A11Y-001`). Ordered hottest first
    // and cut at three: the point of the overlay is which areas are working
    // hardest, and a listener reading out twenty regions has been told nothing.
    final ranked = intensity.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final hottest = ranked.take(3).map((e) => e.key).join(', ');
    final viewName = view == BodyMapView.front ? 'Front' : 'Back';

    return Semantics(
      label: hottest.isEmpty
          ? '$viewName body map. Nothing trained in this range.'
          : '$viewName body map. Most trained: $hottest.',
      image: true,
      child: ExcludeSemantics(
        child: Center(
          child: SizedBox(
            height: _height,
            width: _height * 100 / 220,
            child: CustomPaint(
              painter: _BodyMapPainter(
                regions: view == BodyMapView.front
                    ? _frontRegions
                    : _backRegions,
                intensity: intensity,
                skinColor: colors.surface,
                coldColor: colors.chartInactive,
                hotColor: colors.tint,
                outlineColor: colors.separator,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.regions,
    required this.intensity,
    required this.skinColor,
    required this.coldColor,
    required this.hotColor,
    required this.outlineColor,
  });

  final List<_Region> regions;
  final Map<String, double> intensity;

  /// The figure's own "skin" — the body outline's fill, a shade quieter than
  /// any trained-muscle colour so the silhouette reads as a body first and a
  /// heat map second.
  final Color skinColor;
  final Color coldColor;
  final Color hotColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 220;
    Offset p(double x, double y) => Offset(x * scaleX, y * scaleY);

    final skin = Paint()..color = skinColor;
    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Head.
    canvas.drawOval(
      Rect.fromCenter(
        center: p(50, 14),
        width: 22 * scaleX,
        height: 26 * scaleY,
      ),
      skin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: p(50, 14),
        width: 22 * scaleX,
        height: 26 * scaleY,
      ),
      outline,
    );

    // Neck.
    final neck = Path()
      ..moveTo(p(45, 25).dx, p(45, 25).dy)
      ..lineTo(p(55, 25).dx, p(55, 25).dy)
      ..lineTo(p(58, 32).dx, p(58, 32).dy)
      ..lineTo(p(42, 32).dx, p(42, 32).dy)
      ..close();
    canvas.drawPath(neck, skin);

    // Torso + hips — one continuous silhouette, shoulders tapering to the
    // waist and flaring back out for the hips.
    final torso = Path()
      ..moveTo(p(22, 34).dx, p(22, 34).dy)
      ..cubicTo(
        p(14, 38).dx,
        p(14, 38).dy,
        p(12, 55).dx,
        p(12, 55).dy,
        p(16, 70).dx,
        p(16, 70).dy,
      )
      ..cubicTo(
        p(18, 85).dx,
        p(18, 85).dy,
        p(24, 95).dx,
        p(24, 95).dy,
        p(30, 100).dx,
        p(30, 100).dy,
      )
      ..lineTo(p(30, 118).dx, p(30, 118).dy)
      ..cubicTo(
        p(24, 122).dx,
        p(24, 122).dy,
        p(20, 128).dx,
        p(20, 128).dy,
        p(22, 134).dx,
        p(22, 134).dy,
      )
      ..lineTo(p(78, 134).dx, p(78, 134).dy)
      ..cubicTo(
        p(80, 128).dx,
        p(80, 128).dy,
        p(76, 122).dx,
        p(76, 122).dy,
        p(70, 118).dx,
        p(70, 118).dy,
      )
      ..lineTo(p(70, 100).dx, p(70, 100).dy)
      ..cubicTo(
        p(76, 95).dx,
        p(76, 95).dy,
        p(82, 85).dx,
        p(82, 85).dy,
        p(84, 70).dx,
        p(84, 70).dy,
      )
      ..cubicTo(
        p(88, 55).dx,
        p(88, 55).dy,
        p(86, 38).dx,
        p(86, 38).dy,
        p(78, 34).dx,
        p(78, 34).dy,
      )
      ..cubicTo(
        p(70, 28).dx,
        p(70, 28).dy,
        p(60, 26).dx,
        p(60, 26).dy,
        p(50, 26).dx,
        p(50, 26).dy,
      )
      ..cubicTo(
        p(40, 26).dx,
        p(40, 26).dy,
        p(30, 28).dx,
        p(30, 28).dy,
        p(22, 34).dx,
        p(22, 34).dy,
      )
      ..close();
    canvas.drawPath(torso, skin);
    canvas.drawPath(torso, outline);

    // Arms and legs — capsules, so a limb reads as a limb before any muscle
    // colour lands on top of it.
    for (final side in [_armL, _armR]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: p(side.shoulder.$1, side.shoulder.$2),
          width: side.shoulder.$3 * 2 * scaleX,
          height: side.shoulder.$3 * 2 * scaleY,
        ),
        skin,
      );
      _drawCapsule(canvas, p, scaleX, scaleY, side.upper, skin, outline);
      _drawCapsule(canvas, p, scaleX, scaleY, side.lower, skin, outline);
    }
    for (final side in [_legL, _legR]) {
      _drawCapsule(canvas, p, scaleX, scaleY, side.thigh, skin, outline);
      _drawCapsule(canvas, p, scaleX, scaleY, side.calf, skin, outline);
    }

    // Muscle regions, shaded by trained intensity, on top of the silhouette.
    for (final region in regions) {
      final rect = Rect.fromLTRB(
        region.rect.left * scaleX,
        region.rect.top * scaleY,
        region.rect.right * scaleX,
        region.rect.bottom * scaleY,
      );
      final value = intensity[region.muscle];
      final fill = Paint()
        ..color = value == null
            ? coldColor
            : Color.lerp(coldColor, hotColor, value)!;
      if (region.oval) {
        canvas.drawOval(rect, fill);
        canvas.drawOval(rect, outline);
      } else {
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular((region.radius ?? 6) * scaleX),
        );
        canvas.drawRRect(rrect, fill);
        canvas.drawRRect(rrect, outline);
      }
    }
  }

  void _drawCapsule(
    Canvas canvas,
    Offset Function(double, double) p,
    double scaleX,
    double scaleY,
    (double, double, double, double) bounds,
    Paint fill,
    Paint stroke,
  ) {
    final rect = Rect.fromPoints(
      p(bounds.$1, bounds.$2),
      p(bounds.$3, bounds.$4),
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.shortestSide / 2),
    );
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);
  }

  @override
  bool shouldRepaint(_BodyMapPainter oldDelegate) =>
      oldDelegate.regions != regions ||
      oldDelegate.intensity != intensity ||
      oldDelegate.skinColor != skinColor ||
      oldDelegate.coldColor != coldColor ||
      oldDelegate.hotColor != hotColor;
}
