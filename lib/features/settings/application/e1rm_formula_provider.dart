import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/analytics/e1rm.dart';
import 'unit_preferences_provider.dart';

/// The e1RM formula preference (`F-SET-006`). Epley is the default.
///
/// Scalar setting, so [SharedPreferences] rather than the database, same
/// reasoning as [rpeSettingsProvider].
final e1rmFormulaProvider = NotifierProvider<E1rmFormulaNotifier, E1rmFormula>(
  E1rmFormulaNotifier.new,
);

class E1rmFormulaNotifier extends Notifier<E1rmFormula> {
  static const _key = 'analytics.e1rmFormula';

  @override
  E1rmFormula build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    if (stored == null) return E1rmFormula.epley;
    for (final formula in E1rmFormula.values) {
      if (formula.name == stored) return formula;
    }
    // An unrecognised stored value means a downgrade or a corrupt write; the
    // default is a better answer than throwing.
    return E1rmFormula.epley;
  }

  Future<void> set(E1rmFormula formula) async {
    state = formula;
    await ref.read(sharedPreferencesProvider).setString(_key, formula.name);
  }
}
