import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/catalog/exercise_search.dart';
import '../application/exercise_catalog_providers.dart';
import 'exercise_labels.dart';

/// The filter type shared by the catalogue screen and the exercise picker.
typedef CatalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, ExerciseFilter>;

/// Active facets, each removable in one tap (`F-CAT-005` §3).
///
/// Parameterised by which filter it drives, so the catalogue and the picker
/// share the controls without sharing the selections (`F-LOG-002` §4).
class CatalogFilterBar extends ConsumerWidget {
  const CatalogFilterBar({required this.filterProvider, super.key});

  final CatalogFilterProvider filterProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

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
            onPressed: () => showCatalogFilterSheet(context, filterProvider),
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
Future<void> showCatalogFilterSheet(
  BuildContext context,
  CatalogFilterProvider filterProvider,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _FilterSheet(filterProvider: filterProvider),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet({required this.filterProvider});

  final CatalogFilterProvider filterProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(catalogIndexProvider).value;
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
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
                  for (final muscle
                      in index?.availableMuscles ?? const <Muscle>[])
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
