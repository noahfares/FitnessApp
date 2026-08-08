import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/date_range.dart';
import '../application/date_range_provider.dart';

/// The shared range selector every chart reads from (`F-ANA-015`).
///
/// A horizontally scrolling row of choice chips rather than a
/// `SegmentedButton` — six labels including "Custom" don't fit a phone width
/// without truncation.
class DateRangeSelector extends ConsumerWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(dateRangeSelectionProvider);
    final notifier = ref.read(dateRangeSelectionProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          for (final preset in RangePreset.values) ...[
            ChoiceChip(
              label: Text(_label(preset)),
              selected: selection.preset == preset,
              onSelected: (_) => preset == RangePreset.custom
                  ? _pickCustom(context, notifier)
                  : notifier.selectPreset(preset),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }

  Future<void> _pickCustom(
    BuildContext context,
    DateRangeSelectionNotifier notifier,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;
    notifier.selectCustom(DateRange(start: picked.start, end: picked.end));
  }

  static String _label(RangePreset preset) => switch (preset) {
    RangePreset.fourWeeks => '4 weeks',
    RangePreset.threeMonths => '3 months',
    RangePreset.sixMonths => '6 months',
    RangePreset.oneYear => '1 year',
    RangePreset.allTime => 'All time',
    RangePreset.custom => 'Custom',
  };
}
