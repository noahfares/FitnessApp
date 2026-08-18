import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/plates/plate_calculator.dart';
import '../../../core/l10n/l10n.dart';

/// To-scale, colour-coded loaded-bar drawing (`F-PLT-003`).
///
/// Colours follow the real IPF plate convention (25 kg red, 20 kg blue,
/// 15 kg yellow, 10 kg green, 5 kg white, 2.5 kg black, smaller chrome) —
/// bucketed by canonical kilograms regardless of the display unit, since the
/// convention itself is defined in kilograms and a pound-configured
/// inventory still uses plates that are these same physical sizes. Far
/// faster to read mid-set than the number list beside it.
class PlateStackVisualization extends StatelessWidget {
  const PlateStackVisualization({
    super.key,
    required this.plates,
    this.semanticsLabel,
    this.fullBar = false,
  });

  final List<PlateUsage> plates;

  /// What the drawing says out loud (`F-A11Y-001`, `F-A11Y-003`). Plate colour
  /// follows the IPF convention, which is colour-only encoding by definition,
  /// so the same information has to exist in words. The caller passes it
  /// because only the caller knows the user's display unit — kilograms are the
  /// convention's units, not necessarily the reader's.
  final String? semanticsLabel;

  /// Draws a full symmetric barbell — both sleeves and the shaft, with the
  /// same plates mirrored on each side — rather than the single loaded side.
  /// Both halves carry the identical [plates] list, since a bar is always
  /// loaded evenly.
  final bool fullBar;

  static const Color _sleeve = Color(0xFFC7C7CC);
  static const Color _plateBorder = Color(0x2E000000); // rgba(0,0,0,0.18)

  @override
  Widget build(BuildContext context) {
    if (plates.isEmpty) return const SizedBox.shrink();

    // Heaviest first, next to the bar sleeve — how a bar is actually loaded,
    // so the smallest plates (which hold everything on) end up outermost.
    final sorted = [...plates]
      ..sort((a, b) => b.weightGrams.compareTo(a.weightGrams));
    final colors = context.appColors;

    // Flat, heaviest-first list of individual plate weights for one side —
    // built once, then laid out (and mirrored) below.
    final weights = <int>[
      for (final usage in sorted)
        for (var i = 0; i < usage.pairs; i++) usage.weightGrams,
    ];
    Widget sideRow(Iterable<int> ordered) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, weight) in ordered.indexed)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
            child: _Plate(weightGrams: weight),
          ),
      ],
    );

    final sleeve = Container(
      width: 14,
      height: 20,
      decoration: const BoxDecoration(color: _sleeve),
    );
    final leftSleeve = Container(
      width: 14,
      height: 20,
      decoration: const BoxDecoration(
        color: _sleeve,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(2)),
      ),
    );
    final rightSleeve = Container(
      width: 14,
      height: 20,
      decoration: const BoxDecoration(
        color: _sleeve,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
      ),
    );

    final drawing = fullBar
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mirrored: same plates, heaviest still nearest the sleeve.
              sideRow(weights.reversed),
              leftSleeve,
              Container(
                width: 76,
                height: 9,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colors.barShaftStart, colors.barShaftEnd],
                  ),
                ),
              ),
              rightSleeve,
              sideRow(weights),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [sleeve, sideRow(weights)],
          );

    return Semantics(
      label: semanticsLabel ?? context.l10n.shellPlateLoadingDiagram,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(height: 100, child: Center(child: drawing)),
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.weightGrams});

  final int weightGrams;

  @override
  Widget build(BuildContext context) {
    final kg = weightGrams / 1000;
    // Height scales with plate size within a fixed, legible band — a 1.25 kg
    // change plate must never draw taller than a 25 kg one.
    final height = (36 + kg * 2.2).clamp(36.0, 92.0);
    final color = _plateColor(kg);
    return Container(
      width: 22,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: PlateStackVisualization._plateBorder),
      ),
      child: Text(
        kg == kg.roundToDouble() ? '${kg.round()}' : kg.toStringAsFixed(1),
        style: TextStyle(
          fontSize: 9,
          color: _labelColor(color),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  static Color _plateColor(double kg) {
    if (kg >= 22.5) return const Color(0xFFD32F2F); // 25 kg — red
    if (kg >= 17.5) return const Color(0xFF1976D2); // 20 kg — blue
    if (kg >= 12.5) return const Color(0xFFFBC02D); // 15 kg — yellow
    if (kg >= 7.5) return const Color(0xFF388E3C); // 10 kg — green
    if (kg >= 3.75) return const Color(0xFFF5F5F5); // 5 kg — white
    if (kg >= 1.875) return const Color(0xFF212121); // 2.5 kg — black
    return const Color(0xFFBDBDBD); // sub-1.25 kg micro plates — chrome
  }

  static Color _labelColor(Color plate) =>
      plate.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
