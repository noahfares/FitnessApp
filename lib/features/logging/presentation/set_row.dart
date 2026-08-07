import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/unit_preferences.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/set_repository.dart';
import '../../../domain/logging/rpe.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../settings/application/rpe_settings_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/pr_badge.dart';
import '../../timing/application/rest_timer_providers.dart';
import '../application/personal_record_providers.dart';
import 'numeric_keypad_sheet.dart';
import 'rpe_sheet.dart';
import 'set_note_sheet.dart';
import 'set_type_sheet.dart';
import 'set_value_format.dart';

/// One set (`F-LOG-003`) — the most-used widget in the app by an enormous
/// margin, and the reason for most of the constraints elsewhere.
///
/// Columns: number/type · ghost · the tracking type's fields · completion.
/// Everything it shows comes from the row it is given; it holds no state, so a
/// kill between two taps costs nothing (`F-LOG-007`).
class SetRow extends ConsumerWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.label,
    required this.ghost,
    required this.fields,
    required this.equipment,
    required this.restSeconds,
    required this.exerciseId,
    this.perSide = false,
    this.incrementGrams,
  });

  final WorkoutSet set;
  final SetLabel label;

  /// Which cached PR records to check this row against (`F-LOG-013` §2).
  final String exerciseId;

  /// The matching set from last time, or null (`F-LOG-004`).
  final GhostSet? ghost;

  final List<SetField> fields;

  /// Stored `Equipment` name, for the stepper's default increment.
  final String equipment;
  final int? incrementGrams;

  /// The rest this exercise gets, already resolved (`F-TIM-005`). Passed in
  /// rather than looked up per row: it is the same for every set of the
  /// exercise, and resolving it here would do it once per row per rebuild.
  final int restSeconds;

  /// The exercise's weight entry mode (`F-LOG-017` §2).
  final bool perSide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(unitPreferencesProvider);
    final formatter = ref.watch(quantityFormatterProvider);
    final rpeSettings = ref.watch(rpeSettingsProvider);
    final recordSetIds = ref.watch(recordSetIdsProvider(exerciseId)).value;
    final isRecord = recordSetIds?.contains(set.id) ?? false;

    final ghostText = ghost == null
        ? null
        : formatGhostSummary(
            ghost!,
            fields,
            formatter,
            prefs,
            perSide: perSide,
          );

    // At large text scales the five columns cannot share a line and stay
    // legible, so the row becomes two (`F-LOG-003` acceptance, `F-A11Y-002`).
    // Shrinking the type instead would defeat the setting that asked for it.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 22;

    final numberCell = _NumberCell(
      label: label,
      onLongPress: () => unawaited(showSetTypeSheet(context, set: set)),
    );
    final noteButton = _NoteButton(set: set);
    final rpeCell = rpeSettings.enabled
        ? _RpeCell(
            key: const ValueKey('rpe-cell'),
            set: set,
            displayMode: rpeSettings.displayMode,
          )
        : null;
    final prBadge = isRecord ? const PrBadge() : null;
    final ghostCell = _GhostCell(text: ghostText);
    final valueCells = [
      for (final field in fields)
        _ValueCell(
          key: ValueKey('value-cell-${field.name}'),
          text: formatSetField(set, field, formatter, prefs, perSide: perSide),
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
        ),
    ];
    final toggle = _CompletionToggle(
      set: set,
      fields: fields,
      ghost: ghost,
      restSeconds: restSeconds,
    );

    // Swipe to delete, with undo (`F-LOG-003` §6). Undo is a field update
    // rather than a resurrection because the delete is a tombstone (ADR-0008).
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
      child: Semantics(
        container: true,
        label: _semanticLabel(formatter, prefs, rpeSettings, isRecord),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        numberCell,
                        noteButton,
                        ?rpeCell,
                        ?prBadge,
                        Expanded(child: ghostCell),
                      ],
                    ),
                    Row(
                      children: [
                        for (final cell in valueCells) Expanded(child: cell),
                        toggle,
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    numberCell,
                    noteButton,
                    ?rpeCell,
                    ?prBadge,
                    Expanded(flex: 3, child: ghostCell),
                    for (final cell in valueCells)
                      Expanded(flex: 2, child: cell),
                    toggle,
                  ],
                ),
        ),
      ),
    );
  }

  /// A deleted or restored set can only ever demote or reinstate a cached
  /// record, never patch it (`docs/40-ANALYTICS-SPEC.md` §4 rule 4) — so
  /// either direction gets a full rebuild for the exercise, not an attempt to
  /// reason about what the delete/undo did to the cache in place.
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

  /// What a screen reader announces (`F-A11Y-001`). The row is a grid of
  /// unlabelled numbers otherwise.
  String _semanticLabel(
    QuantityFormatter formatter,
    UnitPreferences prefs,
    RpeSettings rpeSettings,
    bool isRecord,
  ) {
    final parts = <String>[
      label.isWarmup
          ? 'Warm-up set ${label.text.substring(1)}'
          : 'Set ${label.text}',
      for (final field in fields)
        '${fieldHeader(field, prefs, perSide: field == SetField.weight && perSide)} '
            '${formatSetField(set, field, formatter, prefs, perSide: perSide) ?? 'empty'}',
      if (rpeSettings.enabled)
        switch (displayRpe(set.rpe, rpeSettings.displayMode)) {
          null => 'no ${rpeSettings.displayMode.name.toUpperCase()} logged',
          final value =>
            '${rpeSettings.displayMode.name.toUpperCase()} ${formatRpeValue(value)}',
        },
      set.isCompleted ? 'completed' : 'not completed',
      if (set.notes != null) 'has a note',
      // Colour and an icon alone are not indicators (`F-A11Y-003`) — the
      // badge's tooltip says the same thing visually, this says it to a
      // screen reader.
      if (isRecord) 'personal record',
    ];
    return parts.join(', ');
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({required this.label, required this.onLongPress});

  final SetLabel label;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Warm-ups are visually quieter because they count for nothing
    // (`F-LOG-005` §4) — the colour and the letter say the same thing twice,
    // which is deliberate: colour alone is not an indicator (`F-A11Y-003`).
    final colour = label.isWarmup
        ? context.appColors.warning
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: AppSpacing.setNumberColumn,
        height: AppSpacing.minTouchTarget,
        child: Center(
          child: Text(
            label.badge == null ? label.text : '${label.text}${label.badge}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colour,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// Per-set note (`F-LOG-023` §2–§3).
///
/// A fixed-width icon, never a field: the note must be reachable without ever
/// competing with weight, reps or the completion toggle for space.
class _NoteButton extends ConsumerWidget {
  const _NoteButton({required this.set});

  final WorkoutSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNote = set.notes != null && set.notes!.isNotEmpty;
    return SizedBox(
      width: AppSpacing.setNoteColumn,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSpacing.setNoteColumn,
          minHeight: AppSpacing.minTouchTarget,
        ),
        tooltip: hasNote ? 'Edit note' : 'Add note',
        iconSize: 18,
        color: hasNote ? Theme.of(context).colorScheme.primary : null,
        icon: Icon(
          hasNote ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
        ),
        onPressed: () => unawaited(showSetNoteSheet(context, set: set)),
      ),
    );
  }
}

/// Perceived effort, tucked beside the note button rather than in the value
/// columns (`F-LOG-014` §3) — the row has no room to spare, and this is
/// invisible until the setting turns it on.
class _RpeCell extends StatelessWidget {
  const _RpeCell({super.key, required this.set, required this.displayMode});

  final WorkoutSet set;
  final RpeDisplayMode displayMode;

  @override
  Widget build(BuildContext context) {
    final value = displayRpe(set.rpe, displayMode);
    return SizedBox(
      width: AppSpacing.setRpeColumn,
      height: AppSpacing.minTouchTarget,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => unawaited(showRpeSheet(context, set: set)),
        child: Center(
          child: Text(
            value == null ? '—' : formatRpeValue(value),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: value == null
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostCell extends StatelessWidget {
  const _GhostCell({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      // A first-ever session shows an empty ghost, not a zero and not an error
      // (`F-LOG-004` acceptance).
      text ?? '—',
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: context.appColors.ghost,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({super.key, required this.text, required this.onTap});

  final String? text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
      child: InkWell(
        // The purpose-built keypad, never the system keyboard (`F-LOG-006`).
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: AppSpacing.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Text(
            text ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// The completion toggle (`F-LOG-003` §3).
class _CompletionToggle extends ConsumerWidget {
  const _CompletionToggle({
    required this.set,
    required this.fields,
    required this.ghost,
    required this.restSeconds,
  });

  final WorkoutSet set;
  final List<SetField> fields;
  final GhostSet? ghost;
  final int restSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      // Bigger than the 48 dp minimum: hit mid-set, one-handed, with imprecise
      // aim (docs/24-DESIGN-SYSTEM.md §spacing).
      width: AppSpacing.setRowTouchTarget,
      height: AppSpacing.setRowTouchTarget,
      child: Checkbox(
        value: set.isCompleted,
        onChanged: (value) => unawaited(_toggle(ref, value ?? false)),
        semanticLabel: 'Complete set',
      ),
    );
  }

  /// Completing an empty row **adopts the ghost values** (`F-LOG-003` §4).
  ///
  /// "Same as last time" is the common case in any programme built on
  /// progressive overload, and making it cost one tap is the single reason the
  /// ghost exists. Only genuinely empty fields are adopted — a typed value is
  /// never overwritten.
  ///
  /// The rest timer hangs off this seam (`F-TIM-002`): a completion starts it,
  /// and un-ticking the set that started it takes it back. The timer is nudged
  /// before the write is awaited, because the countdown starts when the bar is
  /// racked, not when SQLite says so.
  Future<void> _toggle(WidgetRef ref, bool completed) async {
    final repo = ref.read(setRepositoryProvider);
    final timer = ref.read(restTimerProvider.notifier);
    final records = ref.read(personalRecordRepositoryProvider);

    if (!completed) {
      timer.cancelForSet(set.id);
      await repo.uncomplete(set.id);
      // Un-ticking a set that held a record demotes it the same way deleting
      // one does (§4 rule 4) — only a rebuild knows the next-best value.
      return records.rebuildForSet(set.id);
    }

    timer.startForSet(setId: set.id, seconds: restSeconds);

    final previous = ghost;
    await repo.complete(
      set.id,
      weightGrams: _adopt(
        fields.contains(SetField.weight),
        set.weightGrams,
        previous?.weightGrams,
      ),
      reps: _adopt(fields.contains(SetField.reps), set.reps, previous?.reps),
      distanceMetres: _adopt(
        fields.contains(SetField.distance),
        set.distanceMetres,
        previous?.distanceMetres,
      ),
      durationSeconds: _adopt(
        fields.contains(SetField.duration),
        set.durationSeconds,
        previous?.durationSeconds,
      ),
    );
    // The badge is the celebration (`PrBadge`'s own entrance animation) — no
    // separate handling of the result is needed here; the cache write alone
    // is what makes it appear.
    await records.evaluateSet(set.id);
  }

  static Value<int?> _adopt(bool applies, int? current, int? ghost) {
    if (!applies || current != null || ghost == null) {
      return const Value.absent();
    }
    return Value(ghost);
  }
}

/// Adds a set, pre-filled from the one above it (`F-LOG-003` §5).
class AddSetButton extends ConsumerWidget {
  const AddSetButton({super.key, required this.workoutExerciseId});

  final String workoutExerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => unawaited(
          ref.read(setRepositoryProvider).addSet(workoutExerciseId),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add set'),
      ),
    );
  }
}
