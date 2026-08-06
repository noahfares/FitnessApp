import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../domain/catalog/exercise_search.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/exercise_catalog_providers.dart';
import 'catalog_filter_bar.dart';
import 'exercise_labels.dart';

/// The exercise catalogue (`F-CAT-004`, `F-CAT-005`).
///
/// Also the only way to reach the custom-exercise editor (`F-CAT-003`), which
/// is why that feature could not close until this screen existed.
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

    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Column(
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
                          ref.read(catalogFilterProvider.notifier).setQuery('');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              // Per keystroke: there is no explicit search action
              // (`F-CAT-004` §2).
              onChanged: ref.read(catalogFilterProvider.notifier).setQuery,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.exerciseNew),
        icon: const Icon(Icons.add),
        label: const Text('New exercise'),
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
              return ListTile(
                title: Text(exercise.name),
                // Custom and seeded rows look identical here on purpose
                // (`F-CAT-003` §3) — the editor is the only place they differ.
                subtitle: Text(
                  '${exercise.primaryMuscle.label} · '
                  '${exercise.equipment.label}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.exerciseEdit(exercise.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}
