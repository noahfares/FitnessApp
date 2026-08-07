import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../logging/presentation/numeric_keypad_sheet.dart';
import '../../logging/presentation/set_note_sheet.dart';
import '../../logging/presentation/set_type_sheet.dart';
import '../../logging/presentation/set_value_format.dart';
import '../../settings/application/unit_preferences_provider.dart';

/// One set on the edit-past-workout screen (`F-LOG-009` §1).
///
/// A trimmed-down [SetRow]: no ghost (there is nothing "last time" about
/// editing a session from six months ago) and no rest timer on the
/// completion toggle (`F-TIM-002` belongs to a session in progress, not to
/// editing one that already happened).
class HistorySetRow extends ConsumerWidget {
  const HistorySetRow({
    super.key,
    required this.set,
    required this.label,
    required this.fields,
    required this.equipment,
    this.incrementGrams,
    this.perSide = false,
  });

  final WorkoutSet set;
  final SetLabel label;
  final List<SetField> fields;
  final String equipment;
  final int? incrementGrams;

  /// The exercise's weight entry mode (`F-LOG-017` §2) — history reads the
  /// same total-grams column the live logger writes, so it must show it in
  /// the same domain or the two screens would disagree about what a set was.
  final bool perSide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(unitPreferencesProvider);
    final formatter = ref.watch(quantityFormatterProvider);

    return Dismissible(
      key: ValueKey(set.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: context.appColors.danger,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Icon(Icons.delete_outline, color: context.appColors.onDanger),
      ),
      onDismissed: (_) => _delete(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            InkWell(
              onLongPress: () => unawaited(showSetTypeSheet(context, set: set)),
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: AppSpacing.setNumberColumn,
                height: AppSpacing.minTouchTarget,
                child: Center(
                  child: Text(
                    label.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: label.isWarmup ? context.appColors.warning : null,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: AppSpacing.setNoteColumn,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                color: (set.notes?.isNotEmpty ?? false)
                    ? Theme.of(context).colorScheme.primary
                    : null,
                icon: Icon(
                  (set.notes?.isNotEmpty ?? false)
                      ? Icons.sticky_note_2
                      : Icons.sticky_note_2_outlined,
                ),
                onPressed: () => unawaited(showSetNoteSheet(context, set: set)),
              ),
            ),
            for (final field in fields)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs / 2,
                  ),
                  child: InkWell(
                    onTap: () => unawaited(
                      showSetKeypad(
                        context,
                        set: set,
                        fields: fields,
                        initialField: field,
                        equipment: equipment,
                        incrementGrams: incrementGrams,
                        perSide: perSide,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: AppSpacing.minTouchTarget,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      child: Text(
                        formatSetField(
                              set,
                              field,
                              formatter,
                              prefs,
                              perSide: perSide,
                            ) ??
                            '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: AppSpacing.setRowTouchTarget,
              height: AppSpacing.setRowTouchTarget,
              child: Checkbox(
                value: set.isCompleted,
                onChanged: (value) => unawaited(_toggle(ref, value ?? false)),
                semanticLabel: 'Complete set',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Editing a past, already-completed set can change what it holds a record
  /// for just as much as a live completion can — the cache does not know
  /// this happened somewhere other than the active session
  /// (`docs/40-ANALYTICS-SPEC.md` §4). There is no ghost or rest timer here
  /// to make a "just now" moment out of it, so this stays silent: no badge,
  /// no celebration, only the cache staying correct.
  Future<void> _toggle(WidgetRef ref, bool completed) async {
    final repo = ref.read(setRepositoryProvider);
    final records = ref.read(personalRecordRepositoryProvider);
    if (completed) {
      await repo.complete(set.id);
      await records.evaluateSet(set.id);
      return;
    }
    await repo.uncomplete(set.id);
    return records.rebuildForSet(set.id);
  }

  void _delete(BuildContext context, WidgetRef ref) {
    final repo = ref.read(setRepositoryProvider);
    final records = ref.read(personalRecordRepositoryProvider);
    unawaited(
      repo.deleteSet(set.id).then((_) => records.rebuildForSet(set.id)),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Set ${label.text} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(
              repo
                  .restoreSet(set.id)
                  .then((_) => records.rebuildForSet(set.id)),
            ),
          ),
        ),
      );
  }
}
