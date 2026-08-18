import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/date_range.dart';
import '../application/date_range_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../l10n/app_localizations.dart';

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
              label: Text(_label(preset, context.l10n)),
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

  static String _label(RangePreset preset, AppLocalizations l10n) =>
      switch (preset) {
        RangePreset.fourWeeks => l10n.analytics4Weeks,
        RangePreset.threeMonths => l10n.analytics3Months,
        RangePreset.sixMonths => l10n.analytics6Months,
        RangePreset.oneYear => l10n.analytics1Year,
        RangePreset.allTime => l10n.analyticsAllTime,
        RangePreset.custom => 'Custom',
      };
}
