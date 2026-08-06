import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/catalog/exercise_search.dart';
import '../application/exercise_catalog_providers.dart';
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
          const _FilterBar(),
          Expanded(
            child: results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, _) => _CatalogMessage(
                icon: Icons.error_outline,
                title: 'The catalogue could not be read',
                detail: '$error',
              ),
              data: (exercises) => _ExerciseList(
                exercises: exercises,
                total: total,
                filter: filter,
              ),
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

/// Active facets, each removable in one tap (`F-CAT-005` §3).
class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogFilterProvider);
    final notifier = ref.read(catalogFilterProvider.notifier);

    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        children: [
          ActionChip(
            avatar: const Icon(Icons.tune, size: 18),
            label: Text(
              filter.hasFacets ? 'Filters (${filter.facetCount})' : 'Filters',
            ),
            onPressed: () => _showFilterSheet(context),
          ),
          for (final muscle in Muscle.values)
            if (filter.muscles.contains(muscle.name))
              _RemovableFacet(
                label: muscle.label,
                onRemoved: () => notifier.toggleMuscle(muscle),
              ),
          for (final item in Equipment.values)
            if (filter.equipment.contains(item.name))
              _RemovableFacet(
                label: item.label,
                onRemoved: () => notifier.toggleEquipment(item),
              ),
          if (filter.hasFacets)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Center(
                child: TextButton(
                  onPressed: notifier.clearFacets,
                  child: const Text('Clear'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RemovableFacet extends StatelessWidget {
  const _RemovableFacet({required this.label, required this.onRemoved});

  final String label;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: InputChip(
        label: Text(label),
        onDeleted: onRemoved,
        deleteIcon: const Icon(Icons.close, size: 18),
      ),
    );
  }
}

/// Chips for every facet the catalogue actually contains.
///
/// A sheet rather than an always-visible chip row: 21 muscles and 8 equipment
/// types would push the list itself off the screen.
Future<void> _showFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(catalogIndexProvider).value;
    final filter = ref.watch(catalogFilterProvider);
    final notifier = ref.read(catalogFilterProvider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            0,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter', style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: filter.hasFacets ? notifier.clearFacets : null,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Muscle', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final muscle in index?.availableMuscles ?? const <Muscle>[])
                    FilterChip(
                      label: Text(muscle.label),
                      selected: filter.muscles.contains(muscle.name),
                      onSelected: (_) => notifier.toggleMuscle(muscle),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Equipment', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final item
                      in index?.availableEquipment ?? const <Equipment>[])
                    FilterChip(
                      label: Text(item.label),
                      selected: filter.equipment.contains(item.name),
                      onSelected: (_) => notifier.toggleEquipment(item),
                    ),
                ],
              ),
            ],
          ),
        ),
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
      return _CatalogMessage(
        icon: filter.isActive ? Icons.search_off : Icons.fitness_center,
        title: filter.isActive
            ? 'No exercises match'
            : 'The catalogue is empty',
        detail: filter.isActive
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
                onTap: () =>
                    context.push(AppRoutes.exerciseEdit(exercise.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
