import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/catalog/exercise_search.dart';

/// The live catalogue (`F-CAT-001`).
///
/// A stream, so a custom exercise created on the editor screen appears in the
/// list behind it with nothing to invalidate (docs/23-NAVIGATION.md
/// §state-management).
final exerciseCatalogProvider = StreamProvider<List<Exercise>>(
  (ref) => ref.watch(exerciseRepositoryProvider).watchAll(),
);

/// The catalogue paired with its search candidates.
///
/// Folding names and aliases to their searchable form happens **here**, once per
/// database change, rather than inside the filter — otherwise every keystroke
/// re-folds 400 rows, which is exactly the cost `F-CAT-004` budgets against.
class CatalogIndex {
  CatalogIndex(this.rows)
    : _candidates = <ExerciseCandidate>[
        for (final row in rows)
          ExerciseCandidate(
            id: row.id,
            name: row.name,
            aliases: row.aliases,
            primaryMuscle: row.primaryMuscle.name,
            equipment: row.equipment.name,
            isFavorite: row.isFavorite,
            // Recency needs logged sessions, which arrive with F-CAT-006.
          ),
      ];

  final List<Exercise> rows;
  final List<ExerciseCandidate> _candidates;

  int get total => rows.length;

  /// Facets the catalogue actually contains, so the filter sheet never offers a
  /// chip that can only ever return nothing.
  List<Muscle> get availableMuscles =>
      _sortedByName(<Muscle>{for (final row in rows) row.primaryMuscle});

  List<Equipment> get availableEquipment =>
      _sortedByName(<Equipment>{for (final row in rows) row.equipment});

  static List<T> _sortedByName<T extends Enum>(Set<T> values) =>
      values.toList()..sort((a, b) => a.name.compareTo(b.name));

  /// Filtered and ordered rows, in the order [searchExercises] decided.
  List<Exercise> apply(ExerciseFilter filter) {
    final byId = <String, Exercise>{for (final row in rows) row.id: row};
    return <Exercise>[
      for (final candidate in searchExercises(_candidates, filter))
        byId[candidate.id]!,
    ];
  }
}

final catalogIndexProvider = Provider<AsyncValue<CatalogIndex>>(
  (ref) => ref.watch(exerciseCatalogProvider).whenData(CatalogIndex.new),
);

/// Search text and facet selections (`F-CAT-004`, `F-CAT-005`).
///
/// Ephemeral UI state, held in memory only: `F-CAT-005` §4 wants filters to
/// persist within a session and reset on restart, which is precisely what *not*
/// persisting them gives.
final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, ExerciseFilter>(
      CatalogFilterNotifier.new,
    );

class CatalogFilterNotifier extends Notifier<ExerciseFilter> {
  @override
  ExerciseFilter build() => const ExerciseFilter();

  /// Called per keystroke — there is no explicit search action
  /// (`F-CAT-004` §2).
  void setQuery(String query) => state = state.copyWith(query: query);

  void toggleMuscle(Muscle muscle) => state = state.toggleMuscle(muscle.name);

  void toggleEquipment(Equipment equipment) =>
      state = state.toggleEquipment(equipment.name);

  void clearFacets() => state = state.withoutFacets;

  void clearAll() => state = const ExerciseFilter();
}

/// What the catalogue list renders.
final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final filter = ref.watch(catalogFilterProvider);
  return ref.watch(catalogIndexProvider).whenData((index) => index.apply(filter));
});
