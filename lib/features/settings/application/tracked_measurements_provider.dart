import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/tables/enums.dart';
import 'unit_preferences_provider.dart';

/// Which non-bodyweight measurement types someone tracks (`F-BOD-002`).
///
/// Scalar-shaped setting so [SharedPreferences] rather than the database,
/// same reasoning as [weekStartProvider]. Default is empty — showing all
/// twelve by default is clutter (`F-BOD-002`'s own spec) — so a fresh
/// install shows nothing until the user opts in from the body screen.
/// Bodyweight itself is never in this set: it has been always-on since
/// `F-BOD-001`, in Phase 1.
final trackedMeasurementTypesProvider =
    NotifierProvider<TrackedMeasurementTypesNotifier, Set<MeasurementType>>(
      TrackedMeasurementTypesNotifier.new,
    );

class TrackedMeasurementTypesNotifier extends Notifier<Set<MeasurementType>> {
  static const _key = 'body.trackedMeasurementTypes';

  @override
  Set<MeasurementType> build() {
    final stored = ref.watch(sharedPreferencesProvider).getStringList(_key);
    if (stored == null) return const {};
    return {for (final name in stored) ?_byName(name)};
  }

  Future<void> set(Set<MeasurementType> types) async {
    state = types;
    await ref.read(sharedPreferencesProvider).setStringList(_key, [
      for (final t in types) t.name,
    ]);
  }

  Future<void> toggle(MeasurementType type) {
    final next = {...state};
    if (!next.remove(type)) next.add(type);
    return set(next);
  }

  static MeasurementType? _byName(String name) {
    for (final type in MeasurementType.values) {
      if (type.name == name) return type;
    }
    return null;
  }
}
