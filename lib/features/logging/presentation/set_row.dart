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
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/set_numbering.dart';
import '../../settings/application/unit_preferences_provider.dart';
import 'numeric_keypad_sheet.dart';
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
    this.incrementGrams,
  });

  final WorkoutSet set;
  final SetLabel label;

  /// The matching set from last time, or null (`F-LOG-004`).
  final GhostSet? ghost;

  final List<SetField> fields;

  /// Stored `Equipment` name, for the stepper's default increment.
  final String equipment;
  final int? incrementGrams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(unitPreferencesProvider);
    final formatter = ref.watch(quantityFormatterProvider);

    final ghostText = ghost == null
        ? null
        : formatGhostSummary(ghost!, fields, formatter, prefs);

    // At large text scales the five columns cannot share a line and stay
    // legible, so the row becomes two (`F-LOG-003` acceptance, `F-A11Y-002`).
    // Shrinking the type instead would defeat the setting that asked for it.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 22;

    final numberCell = _NumberCell(
      label: label,
      onLongPress: () => unawaited(showSetTypeSheet(context, set: set)),
    );
    final noteButton = _NoteButton(set: set);
    final ghostCell = _GhostCell(text: ghostText);
    final valueCells = [
      for (final field in fields)
        _ValueCell(
          key: ValueKey('value-cell-${field.name}'),
          text: formatSetField(set, field, formatter, prefs),
          onTap: () => unawaited(
            showSetKeypad(
              context,
              set: set,
              fields: fields,
              initialField: field,
              equipment: equipment,
              incrementGrams: incrementGrams,
            ),
          ),
        ),
    ];
    final toggle = _CompletionToggle(
      set: set,
      fields: fields,
      ghost: ghost,
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
        label: _semanticLabel(formatter, prefs),
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

  void _delete(BuildContext context, WidgetRef ref) {
    final repo = ref.read(setRepositoryProvider);
    unawaited(repo.deleteSet(set.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Set ${label.text} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(repo.restoreSet(set.id)),
          ),
        ),
      );
  }

  /// What a screen reader announces (`F-A11Y-001`). The row is a grid of
  /// unlabelled numbers otherwise.
  String _semanticLabel(QuantityFormatter formatter, UnitPreferences prefs) {
    final parts = <String>[
      label.isWarmup
          ? 'Warm-up set ${label.text.substring(1)}'
          : 'Set ${label.text}',
      for (final field in fields)
        '${fieldHeader(field, prefs)} '
            '${formatSetField(set, field, formatter, prefs) ?? 'empty'}',
      set.isCompleted ? 'completed' : 'not completed',
      if (set.notes != null) 'has a note',
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
        width: 44,
        height: 48,
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
      width: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
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
  const _ValueCell({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String? text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        // The purpose-built keypad, never the system keyboard (`F-LOG-006`).
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
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
  });

  final WorkoutSet set;
  final List<SetField> fields;
  final GhostSet? ghost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      // 56 dp: hit mid-set, one-handed, with imprecise aim
      // (docs/24-DESIGN-SYSTEM.md §spacing).
      width: 56,
      height: 56,
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
  Future<void> _toggle(WidgetRef ref, bool completed) async {
    final repo = ref.read(setRepositoryProvider);
    if (!completed) return repo.uncomplete(set.id);

    final previous = ghost;
    return repo.complete(
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
