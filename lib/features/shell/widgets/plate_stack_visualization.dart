import 'package:flutter/material.dart';

import '../../../domain/plates/plate_calculator.dart';
import '../../../core/l10n/l10n.dart';

/// To-scale, colour-coded loaded-bar drawing, one side (`F-PLT-003`).
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
  });

  final List<PlateUsage> plates;

  /// What the drawing says out loud (`F-A11Y-001`, `F-A11Y-003`). Plate colour
  /// follows the IPF convention, which is colour-only encoding by definition,
  /// so the same information has to exist in words. The caller passes it
  /// because only the caller knows the user's display unit — kilograms are the
  /// convention's units, not necessarily the reader's.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    if (plates.isEmpty) return const SizedBox.shrink();

    // Heaviest first, next to the bar sleeve — how a bar is actually loaded,
    // so the smallest plates (which hold everything on) end up outermost.
    final sorted = [...plates]
      ..sort((a, b) => b.weightGrams.compareTo(a.weightGrams));

    return Semantics(
      label: semanticsLabel ?? context.l10n.shellPlateLoadingDiagram,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 96,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(2),
                  ),
                ),
              ),
              for (final usage in sorted)
                for (var i = 0; i < usage.pairs; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: _Plate(weightGrams: usage.weightGrams),
                  ),
            ],
          ),
        ),
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
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(
        kg == kg.roundToDouble() ? '${kg.round()}' : kg.toStringAsFixed(1),
        style: TextStyle(fontSize: 9, color: _labelColor(color)),
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
