import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/analytics/date_range.dart';

/// The shared range selector's state (`F-ANA-015`).
///
/// In-memory only — the spec asks for it to persist "across screens within a
/// session", not across app restarts the way a real setting would, so this
/// is a plain [Notifier] rather than the `SharedPreferences`-backed pattern
/// `e1rmFormulaProvider`/`rpeSettingsProvider` use.
final dateRangeSelectionProvider =
    NotifierProvider<DateRangeSelectionNotifier, RangeSelection>(
      DateRangeSelectionNotifier.new,
    );

class RangeSelection {
  const RangeSelection({required this.preset, this.custom});

  final RangePreset preset;

  /// Only meaningful when [preset] is [RangePreset.custom].
  final DateRange? custom;

  static const RangeSelection defaultSelection = RangeSelection(
    preset: RangePreset.threeMonths,
  );
}

class DateRangeSelectionNotifier extends Notifier<RangeSelection> {
  @override
  RangeSelection build() => RangeSelection.defaultSelection;

  void selectPreset(RangePreset preset) {
    state = RangeSelection(preset: preset, custom: state.custom);
  }

  void selectCustom(DateRange range) {
    state = RangeSelection(preset: RangePreset.custom, custom: range);
  }
}
