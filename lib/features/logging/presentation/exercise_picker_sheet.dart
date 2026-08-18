import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../catalog/application/exercise_catalog_providers.dart';
import '../../catalog/presentation/catalog_filter_bar.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/empty_state.dart';
import '../../../core/l10n/l10n.dart';

/// Multi-select exercise picker (`F-LOG-002`).
///
/// A bottom sheet rather than a page: it lands the interaction in the thumb
/// zone and keeps the session visible behind it, which is the whole reason the
/// navigation doc specifies sheets for pickers (docs/23-NAVIGATION.md).
///
/// Returns the chosen exercise ids in tick order, or null if dismissed.
Future<List<String>?> showExercisePicker(BuildContext context, WidgetRef ref) {
  // A picker opened mid-session must start clean; a filter left on from last
  // time would silently hide exercises.
  ref.read(pickerSelectionProvider.notifier).clear();
  ref.read(pickerFilterProvider.notifier).clearAll();

  return showModalBottomSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _ExercisePickerSheet(),
  );
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(pickerResultsProvider);
    final selection = ref.watch(pickerSelectionProvider);

    return SafeArea(
      child: SizedBox(
        // Tall enough to browse, short enough that the session stays visible
        // behind it.
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _search,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: context.l10n.catalogSearchExercises,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: ref.read(pickerFilterProvider.notifier).setQuery,
              ),
            ),
            CatalogFilterBar(filterProvider: pickerFilterProvider),
            Expanded(
              child: results.view(
                errorTitle: context.l10n.loggingExercisesCouldNotBeRead,
                (exercises) {
                  if (exercises.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: context.l10n.loggingNoExercisesMatch,
                    );
                  }
                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, i) {
                      final exercise = exercises[i];
                      return CheckboxListTile(
                        value: selection.contains(exercise.id),
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.primaryMuscle.label} · '
                          '${exercise.equipment.label}',
                        ),
                        onChanged: (_) => ref
                            .read(pickerSelectionProvider.notifier)
                            .toggle(exercise.id),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: FilledButton(
                // Two taps to here from the active workout, one to confirm —
                // the three-tap budget in `F-LOG-002`.
                onPressed: selection.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(selection),
                child: Text(
                  selection.isEmpty
                      ? context.l10n.loggingAddExercises
                      : context.l10n.loggingAddCount(selection.length),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
