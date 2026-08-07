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

/// The most recent session each exercise was performed in (`F-CAT-006` §2).
final lastUsedAtProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(setRepositoryProvider).watchLastUsedAtByExercise(),
);

/// The catalogue paired with its search candidates.
///
/// Folding names and aliases to their searchable form happens **here**, once per
/// database change, rather than inside the filter — otherwise every keystroke
/// re-folds 400 rows, which is exactly the cost `F-CAT-004` budgets against.
class CatalogIndex {
  CatalogIndex(this.rows, {Map<String, int> lastUsedAt = const {}})
    : _candidates = <ExerciseCandidate>[
        for (final row in rows)
          ExerciseCandidate(
            id: row.id,
            name: row.name,
            aliases: row.aliases,
            primaryMuscle: row.primaryMuscle.name,
            equipment: row.equipment.name,
            isFavorite: row.isFavorite,
            lastUsedAt: lastUsedAt[row.id],
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

final catalogIndexProvider = Provider<AsyncValue<CatalogIndex>>((ref) {
  final lastUsedAt = ref.watch(lastUsedAtProvider).value ?? const {};
  return ref
      .watch(exerciseCatalogProvider)
      .whenData((rows) => CatalogIndex(rows, lastUsedAt: lastUsedAt));
});

/// Archived exercises, alphabetical — the "show archived" list
/// (`F-CAT-009` §3), where archiving is undone from.
final archivedExercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref
      .watch(exerciseRepositoryProvider)
      .watchAll(includeArchived: true)
      .map((rows) => rows.where((e) => e.archivedAt != null).toList());
});

/// Whether the catalogue screen is showing the archived list instead of the
/// live one (`F-CAT-009` §3). Ephemeral — resets to the live list on leaving
/// the screen, the same reasoning as `RoutineListShowArchivedNotifier`.
final exerciseListShowArchivedProvider =
    NotifierProvider<ExerciseListShowArchivedNotifier, bool>(
      ExerciseListShowArchivedNotifier.new,
    );

class ExerciseListShowArchivedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

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

/// The picker's own filter (`F-LOG-002` §4).
///
/// Separate state from [catalogFilterProvider] deliberately: leaving a filter
/// on while browsing the catalogue must not silently narrow what the picker
/// offers mid-session, which is the kind of thing that reads as "the app lost
/// an exercise".
final pickerFilterProvider =
    NotifierProvider<CatalogFilterNotifier, ExerciseFilter>(
      CatalogFilterNotifier.new,
    );

/// Exercises ticked in the picker, in the order they were ticked — that is the
/// order they are appended to the session in (`F-LOG-002` §3).
final pickerSelectionProvider =
    NotifierProvider<PickerSelectionNotifier, List<String>>(
      PickerSelectionNotifier.new,
    );

class PickerSelectionNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void toggle(String exerciseId) {
    final next = List<String>.of(state);
    if (!next.remove(exerciseId)) next.add(exerciseId);
    state = next;
  }

  void clear() => state = const [];
}

AsyncValue<List<Exercise>> _resultsFor(Ref ref, ExerciseFilter filter) =>
    ref.watch(catalogIndexProvider).whenData((index) => index.apply(filter));

/// What the catalogue list renders.
final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>(
  (ref) => _resultsFor(ref, ref.watch(catalogFilterProvider)),
);

/// What the picker sheet renders.
final pickerResultsProvider = Provider<AsyncValue<List<Exercise>>>(
  (ref) => _resultsFor(ref, ref.watch(pickerFilterProvider)),
);
