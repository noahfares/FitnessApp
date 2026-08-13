import 'package:flutter/material.dart';

import '../../../domain/catalog/muscle_taxonomy.dart';

/// One drawable region: a muscle's rough on-body position, in a fixed
/// 100×220 coordinate space. Simple rounded rectangles, not traced anatomy
/// — the "licence-clean or don't ship it" discipline `docs/40-ANALYTICS-SPEC.md`
/// §16 asks for, satisfied by drawing nothing sourced from anywhere.
class _Region {
  const _Region(this.muscle, this.rect);

  final String muscle;
  final Rect rect;
}

const List<_Region> _frontRegions = [
  _Region('chest', Rect.fromLTRB(30, 40, 70, 60)),
  _Region('frontDelts', Rect.fromLTRB(18, 36, 30, 50)),
  _Region('frontDelts', Rect.fromLTRB(70, 36, 82, 50)),
  _Region('sideDelts', Rect.fromLTRB(10, 42, 19, 56)),
  _Region('sideDelts', Rect.fromLTRB(81, 42, 90, 56)),
  _Region('biceps', Rect.fromLTRB(12, 58, 23, 86)),
  _Region('biceps', Rect.fromLTRB(77, 58, 88, 86)),
  _Region('forearms', Rect.fromLTRB(10, 88, 21, 112)),
  _Region('forearms', Rect.fromLTRB(79, 88, 90, 112)),
  _Region('abs', Rect.fromLTRB(38, 62, 62, 92)),
  _Region('obliques', Rect.fromLTRB(29, 64, 37, 90)),
  _Region('obliques', Rect.fromLTRB(63, 64, 71, 90)),
  _Region('quads', Rect.fromLTRB(30, 130, 47, 182)),
  _Region('quads', Rect.fromLTRB(53, 130, 70, 182)),
  _Region('adductors', Rect.fromLTRB(44, 132, 56, 175)),
];

const List<_Region> _backRegions = [
  _Region('traps', Rect.fromLTRB(35, 34, 65, 50)),
  _Region('rearDelts', Rect.fromLTRB(18, 36, 30, 50)),
  _Region('rearDelts', Rect.fromLTRB(70, 36, 82, 50)),
  _Region('lats', Rect.fromLTRB(25, 52, 41, 86)),
  _Region('lats', Rect.fromLTRB(59, 52, 75, 86)),
  _Region('upperBack', Rect.fromLTRB(41, 50, 59, 74)),
  _Region('lowerBack', Rect.fromLTRB(38, 76, 62, 96)),
  _Region('triceps', Rect.fromLTRB(12, 58, 23, 86)),
  _Region('triceps', Rect.fromLTRB(77, 58, 88, 86)),
  _Region('glutes', Rect.fromLTRB(33, 98, 67, 122)),
  _Region('abductors', Rect.fromLTRB(24, 98, 33, 122)),
  _Region('abductors', Rect.fromLTRB(67, 98, 76, 122)),
  _Region('hamstrings', Rect.fromLTRB(30, 124, 47, 178)),
  _Region('hamstrings', Rect.fromLTRB(53, 124, 70, 178)),
  _Region('calves', Rect.fromLTRB(32, 180, 47, 212)),
  _Region('calves', Rect.fromLTRB(53, 180, 68, 212)),
];

/// An original, non-anatomical silhouette shaded by [intensity]
/// (`F-ANA-014`, component-shape mirrors `CalendarHeatmap`'s own "two
/// states, driven by a simple map" simplicity). [intensity] is
/// [muscleHeatIntensity]'s output — 0..1, keyed by muscle name; a muscle
/// with no entry renders as untrained, not zero-and-cold.
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
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        height: _height,
        width: _height * 100 / 220,
        child: CustomPaint(
          painter: _BodyMapPainter(
            regions: view == BodyMapView.front ? _frontRegions : _backRegions,
            intensity: intensity,
            coldColor: theme.colorScheme.surfaceContainerHighest,
            hotColor: theme.colorScheme.primary,
            outlineColor: theme.colorScheme.outlineVariant,
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
    required this.coldColor,
    required this.hotColor,
    required this.outlineColor,
  });

  final List<_Region> regions;
  final Map<String, double> intensity;
  final Color coldColor;
  final Color hotColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 220;

    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Head and torso outline, purely for orientation — not a heat region.
    canvas.drawOval(
      Rect.fromLTRB(38 * scaleX, 4 * scaleY, 62 * scaleX, 30 * scaleY),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(28 * scaleX, 30 * scaleY, 72 * scaleX, 100 * scaleY),
        Radius.circular(6 * scaleX),
      ),
      outline,
    );

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
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(3 * scaleX));
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, outline);
    }
  }

  @override
  bool shouldRepaint(_BodyMapPainter oldDelegate) =>
      oldDelegate.regions != regions ||
      oldDelegate.intensity != intensity ||
      oldDelegate.coldColor != coldColor ||
      oldDelegate.hotColor != hotColor;
}
