import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/catalog/exercise_search.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/exercise_catalog_providers.dart';
import 'catalog_filter_bar.dart';
import 'exercise_labels.dart';

/// The exercise catalogue (`F-CAT-004`, `F-CAT-005`).
///
/// Also the only way to reach the custom-exercise editor (`F-CAT-003`), which
/// is why that feature could not close until this screen existed. Toggles to
/// the archived list, where archived exercises are restored from
/// (`F-CAT-009` §3).
class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends ConsumerState<ExerciseCatalogScreen> {
  late final TextEditingController _search = TextEditingController(
    // The filter survives leaving and returning to the screen, so the field
    // has to be seeded from it rather than starting empty (`F-CAT-005` §4).
    text: ref.read(catalogFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(catalogFilterProvider);
    final results = ref.watch(filteredExercisesProvider);
    final total = ref.watch(catalogIndexProvider).value?.total ?? 0;
    final showArchived = ref.watch(exerciseListShowArchivedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(showArchived ? 'Archived exercises' : 'Exercises'),
        actions: [
          IconButton(
            icon: Icon(
              showArchived
                  ? Icons.checklist_outlined
                  : Icons.inventory_2_outlined,
            ),
            tooltip: showArchived ? 'Active exercises' : 'Archived exercises',
            onPressed: () =>
                ref.read(exerciseListShowArchivedProvider.notifier).toggle(),
          ),
          if (!showArchived)
            IconButton(
              icon: const Icon(Icons.playlist_remove),
              tooltip: 'Archive by equipment',
              onPressed: () => unawaited(_archiveByEquipment(context, ref)),
            ),
        ],
      ),
      body: showArchived
          ? const _ArchivedExerciseList()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _search,
                    autocorrect: false,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search exercises',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: filter.query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: 'Clear search',
                              onPressed: () {
                                _search.clear();
                                ref
                                    .read(catalogFilterProvider.notifier)
                                    .setQuery('');
                              },
                            ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    // Per keystroke: there is no explicit search action
                    // (`F-CAT-004` §2).
                    onChanged: ref
                        .read(catalogFilterProvider.notifier)
                        .setQuery,
                  ),
                ),
                CatalogFilterBar(filterProvider: catalogFilterProvider),
                Expanded(
                  child: results.view(
                    (exercises) => _ExerciseList(
                      exercises: exercises,
                      total: total,
                      filter: filter,
                    ),
                    errorTitle: 'The catalogue could not be read',
                  ),
                ),
              ],
            ),
      floatingActionButton: showArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.exerciseNew),
              icon: const Icon(Icons.add),
              label: const Text('New exercise'),
            ),
    );
  }

  /// Bulk-archive by equipment (`F-CAT-009` §4) — for someone without access
  /// to, say, a cable machine, doing this one exercise at a time is exactly
  /// the busywork the feature exists to avoid.
  Future<void> _archiveByEquipment(BuildContext context, WidgetRef ref) async {
    final available =
        ref.read(catalogIndexProvider).value?.availableEquipment ??
        Equipment.values;
    final equipment = await showModalBottomSheet<Equipment>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              child: Text('Archive by equipment'),
            ),
            for (final item in available)
              ListTile(
                title: Text(item.label),
                onTap: () => Navigator.of(context).pop(item),
              ),
          ],
        ),
      ),
    );
    if (equipment == null || !context.mounted) return;

    final confirmed = await showConfirmSheet(
      context,
      title: 'Archive all ${equipment.label} exercises?',
      message:
          'Every non-archived ${equipment.label} exercise is hidden from '
          'pickers and search. History is untouched, and each can be '
          'restored individually from the archived list.',
      confirmLabel: 'Archive',
      isDestructive: false,
    );
    if (!confirmed) return;

    final count = await ref
        .read(exerciseRepositoryProvider)
        .bulkArchiveByEquipment(equipment);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'Nothing to archive.'
                : 'Archived $count ${equipment.label} exercise'
                      '${count == 1 ? '' : 's'}.',
          ),
        ),
      );
  }
}

class _ArchivedExerciseList extends ConsumerWidget {
  const _ArchivedExerciseList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(archivedExercisesProvider);
    return archived.view(
      errorTitle: 'Archived exercises could not be read',
      (rows) => rows.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nothing archived',
              message:
                  'Archived exercises stay in your history and can be '
                  'restored from here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final exercise = rows[i];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.primaryMuscle.label} · '
                    '${exercise.equipment.label}',
                  ),
                  trailing: TextButton(
                    onPressed: () => unawaited(
                      ref
                          .read(exerciseRepositoryProvider)
                          .setArchived(exercise.id, isArchived: false),
                    ),
                    child: const Text('Restore'),
                  ),
                );
              },
            ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({
    required this.exercises,
    required this.total,
    required this.filter,
  });

  final List<Exercise> exercises;
  final int total;
  final ExerciseFilter filter;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return EmptyState(
        icon: filter.isActive ? Icons.search_off : Icons.fitness_center,
        title: filter.isActive
            ? 'No exercises match'
            : 'The catalogue is empty',
        message: filter.isActive
            ? 'Try a shorter search, or clear a filter.'
            : 'Seeding runs at startup; this should not happen.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shown only when filtering, so the number means "narrowed to this"
        // rather than being permanent decoration (`F-CAT-005` acceptance).
        if (filter.isActive)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              '${exercises.length} of $total exercises',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: exercises.length,
            // Room for the FAB, so the last row is never trapped underneath it.
            padding: const EdgeInsets.only(bottom: 88),
            itemBuilder: (context, i) {
              final exercise = exercises[i];
              return _ExerciseTile(exercise: exercise);
            },
          ),
        ),
      ],
    );
  }
}

/// One row, with the favourite star that pins it to the top of every
/// unfiltered listing (`F-CAT-006` §1).
class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          exercise.isFavorite ? Icons.star : Icons.star_border,
          color: exercise.isFavorite
              ? Theme.of(context).colorScheme.tertiary
              : null,
        ),
        tooltip: exercise.isFavorite ? 'Unfavourite' : 'Favourite',
        onPressed: () => unawaited(
          ref
              .read(exerciseRepositoryProvider)
              .setFavorite(exercise.id, isFavorite: !exercise.isFavorite),
        ),
      ),
      title: Text(exercise.name),
      // Custom and seeded rows look identical here on purpose
      // (`F-CAT-003` §3) — the editor is the only place they differ.
      subtitle: Text(
        '${exercise.primaryMuscle.label} · ${exercise.equipment.label}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.show_chart),
        tooltip: 'History',
        onPressed: () => context.push(AppRoutes.exerciseDetail(exercise.id)),
      ),
      onTap: () => context.push(AppRoutes.exerciseEdit(exercise.id)),
    );
  }
}
