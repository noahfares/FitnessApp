import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ids/uuid.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import 'exercise_labels.dart';

/// Create or edit an exercise (`F-CAT-003`).
///
/// One screen for both, because a custom exercise and a seeded one are the same
/// row: editing either goes through `ExerciseRepository`, which stamps
/// `updated_at` on every write. That stamp is what stops the next re-seed from
/// clobbering an edit to a built-in exercise (`F-CAT-001`).
class ExerciseEditorScreen extends ConsumerStatefulWidget {
  const ExerciseEditorScreen({this.exerciseId, super.key});

  /// Null for a new custom exercise.
  final String? exerciseId;

  bool get isNew => exerciseId == null;

  @override
  ConsumerState<ExerciseEditorScreen> createState() =>
      _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends ConsumerState<ExerciseEditorScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _aliasInput = TextEditingController();

  List<String> _aliases = <String>[];

  Muscle _primaryMuscle = Muscle.chest;
  Set<Muscle> _secondaryMuscles = <Muscle>{};
  Equipment _equipment = Equipment.barbell;
  TrackingType _trackingType = TrackingType.weightReps;

  /// Null for a new exercise until the equipment picks a sensible default
  /// (`F-LOG-017` §2) — resolved in [_save], not here, so changing equipment
  /// before saving keeps proposing the right default rather than freezing
  /// whatever [_equipment] happened to be on first build.
  WeightEntryMode? _weightEntryMode;

  /// Null means "use the global setting, then the built-in for this kind of
  /// exercise" (`F-TIM-005`).
  int? _defaultRestSeconds;

  /// The row being edited, once loaded. Null while loading and for a new one.
  Exercise? _existing;
  bool _loading = true;
  bool _saving = false;
  bool _duplicateName = false;

  /// Guards against an earlier duplicate-name check landing after a later one
  /// and overwriting its answer with a stale result.
  int _nameCheckToken = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    _aliasInput.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.exerciseId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }

    final row = await ref.read(exerciseRepositoryProvider).findById(id);
    if (!mounted) return;
    setState(() {
      _existing = row;
      _loading = false;
      if (row != null) {
        _name.text = row.name;
        _primaryMuscle = row.primaryMuscle;
        _secondaryMuscles = <Muscle>{
          for (final name in row.secondaryMuscles)
            if (_muscleByName(name) case final Muscle muscle) muscle,
        };
        _equipment = row.equipment;
        _trackingType = row.trackingType;
        _defaultRestSeconds = row.defaultRestSeconds;
        _weightEntryMode = row.weightEntryMode;
        _notes.text = row.notes ?? '';
        _aliases = List<String>.of(row.aliases);
      }
    });
  }

  /// Null for a name this build does not know — a row written by a newer
  /// version, which must be dropped rather than silently mapped to some other
  /// muscle and then saved back that way.
  static Muscle? _muscleByName(String name) {
    for (final muscle in Muscle.values) {
      if (muscle.name == name) return muscle;
    }
    return null;
  }

  /// Warns, never blocks: "Bench Press (Smith)" is a legitimate second row with
  /// almost the same name (`F-CAT-003` §4).
  Future<void> _checkDuplicate(String name) async {
    final token = ++_nameCheckToken;
    final exists = await ref
        .read(exerciseRepositoryProvider)
        .nameExists(name, excludingId: widget.exerciseId);
    if (!mounted || token != _nameCheckToken) return;
    setState(() => _duplicateName = exists);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    final repo = ref.read(exerciseRepositoryProvider);
    final secondary = [for (final m in _secondaryMuscles) m.name];
    final weightEntryMode =
        _weightEntryMode ?? defaultWeightEntryModeFor(_equipment);
    final notes = _notes.text.trim();

    if (widget.isNew) {
      // The id is generated here rather than by the database so it exists
      // before the insert completes (ADR-0008).
      await repo.createCustom(
        id: newUuidV4(),
        name: name,
        primaryMuscle: _primaryMuscle,
        equipment: _equipment,
        trackingType: _trackingType,
        secondaryMuscles: _secondaryMuscles.toList(),
        aliases: _aliases,
        notes: notes.isEmpty ? null : notes,
        defaultRestSeconds: _defaultRestSeconds,
        weightEntryMode: weightEntryMode,
      );
    } else {
      await repo.update(
        widget.exerciseId!,
        ExercisesCompanion(
          name: Value(name),
          primaryMuscle: Value(_primaryMuscle),
          secondaryMuscles: Value(secondary),
          equipment: Value(_equipment),
          trackingType: Value(_trackingType),
          aliases: Value(_aliases),
          notes: Value(notes.isEmpty ? null : notes),
          defaultRestSeconds: Value(_defaultRestSeconds),
          weightEntryMode: Value(weightEntryMode),
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Deletion is refused while history references the exercise, and archiving
  /// is offered instead — otherwise a past session loses the name of what was
  /// done (`F-CAT-003` §2).
  Future<void> _delete() async {
    final id = widget.exerciseId!;
    final repo = ref.read(exerciseRepositoryProvider);
    final name = _existing?.name ?? 'this exercise';

    if (await repo.hasHistory(id)) {
      if (!mounted) return;
      final archive = await showConfirmSheet(
        context,
        title: 'Used in past workouts',
        message:
            '$name appears in workouts you have already logged, so it cannot '
            'be deleted without breaking that history.\n\n'
            'Archiving hides it from pickers and leaves your history intact.',
        confirmLabel: 'Archive instead',
        cancelLabel: 'Cancel',
        isDestructive: false,
      );
      if (archive) await _setArchived(true);
      return;
    }

    if (!mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete $name?',
      message:
          'It will be removed from the catalogue. Nothing else is '
          'affected — this exercise has never been logged.',
      cancelLabel: 'Cancel',
    );
    if (!confirmed) return;

    await repo.delete(id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Trimmed, de-duplicated case-insensitively, and cleared from the input
  /// once accepted — the same "type and commit" shape as the alias search it
  /// feeds (`F-CAT-008` §3).
  void _addAlias(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final exists = _aliases.any(
      (a) => a.toLowerCase() == trimmed.toLowerCase(),
    );
    setState(() {
      if (!exists) _aliases = [..._aliases, trimmed];
      _aliasInput.clear();
    });
  }

  Future<void> _setArchived(bool archived) async {
    await ref
        .read(exerciseRepositoryProvider)
        .setArchived(widget.exerciseId!, isArchived: archived);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: LoadingView());
    }

    if (!widget.isNew && _existing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise')),
        body: const Center(child: Text('This exercise no longer exists.')),
      );
    }

    final existing = _existing;
    final isArchived = existing?.archivedAt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New exercise' : 'Edit exercise'),
        actions: [
          if (!widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _saving ? null : () => unawaited(_delete()),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          // The one place a custom exercise is distinguishable from a seeded
          // one (`F-CAT-003` §3).
          if (existing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                existing.isCustom
                    ? 'Custom exercise'
                    : 'Built-in exercise — your edits survive catalogue updates',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          TextField(
            controller: _name,
            autofocus: widget.isNew,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              border: const OutlineInputBorder(),
              helperText: _duplicateName
                  ? 'Another exercise already has this name. That is allowed.'
                  : null,
              helperMaxLines: 2,
              helperStyle: TextStyle(color: theme.colorScheme.tertiary),
            ),
            onChanged: (value) {
              setState(() {});
              unawaited(_checkDuplicate(value));
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<Muscle>(
            initialValue: _primaryMuscle,
            decoration: const InputDecoration(
              labelText: 'Primary muscle',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final muscle in Muscle.values)
                DropdownMenuItem(value: muscle, child: Text(muscle.label)),
            ],
            onChanged: (muscle) {
              if (muscle != null) setState(() => _primaryMuscle = muscle);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<Equipment>(
            initialValue: _equipment,
            decoration: const InputDecoration(
              labelText: 'Equipment',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final item in Equipment.values)
                DropdownMenuItem(value: item, child: Text(item.label)),
            ],
            onChanged: (item) {
              if (item != null) setState(() => _equipment = item);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<TrackingType>(
            initialValue: _trackingType,
            decoration: const InputDecoration(
              labelText: 'Tracking',
              border: OutlineInputBorder(),
              helperText: 'Decides which inputs the logger shows.',
            ),
            items: [
              for (final type in TrackingType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (type) {
              if (type != null) setState(() => _trackingType = type);
            },
          ),
          if (setFieldsFor(_trackingType.name).contains(SetField.weight)) ...[
            const SizedBox(height: AppSpacing.lg),
            // Storage is always total (`F-LOG-017` §1) — this only decides how
            // the set row types and shows it.
            DropdownButtonFormField<WeightEntryMode>(
              initialValue:
                  _weightEntryMode ?? defaultWeightEntryModeFor(_equipment),
              decoration: const InputDecoration(
                labelText: 'Weight entry',
                border: OutlineInputBorder(),
                helperText: 'Per side is doubled and stored as total load.',
              ),
              items: const [
                DropdownMenuItem(
                  value: WeightEntryMode.total,
                  child: Text('Total load'),
                ),
                DropdownMenuItem(
                  value: WeightEntryMode.perSide,
                  child: Text('Per side'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) setState(() => _weightEntryMode = mode);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          // The per-exercise override in the middle of `F-TIM-005`'s
          // resolution order. Left on "Default" it changes nothing, which is
          // what almost every exercise wants.
          DropdownButtonFormField<int>(
            initialValue: _defaultRestSeconds ?? 0,
            decoration: const InputDecoration(
              labelText: 'Rest timer',
              border: OutlineInputBorder(),
              helperText: 'Overrides the global default for this exercise.',
            ),
            items: [
              const DropdownMenuItem(value: 0, child: Text('Default')),
              for (final seconds in restDurationChoices)
                DropdownMenuItem(
                  value: seconds,
                  child: Text(formatRestDuration(seconds)),
                ),
            ],
            onChanged: (seconds) => setState(
              () => _defaultRestSeconds = (seconds ?? 0) == 0 ? null : seconds,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Secondary muscles', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final muscle in Muscle.values)
                if (muscle != _primaryMuscle)
                  FilterChip(
                    label: Text(muscle.label),
                    selected: _secondaryMuscles.contains(muscle),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _secondaryMuscles.add(muscle);
                      } else {
                        _secondaryMuscles.remove(muscle);
                      }
                    }),
                  ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _notes,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              helperText:
                  'Seat height, pin position, grip width — visible '
                  'inline during a session.',
              helperMaxLines: 2,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Aliases', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Other names this is searchable by — "RDL" for Romanian Deadlift.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final alias in _aliases)
                InputChip(
                  label: Text(alias),
                  onDeleted: () => setState(() => _aliases.remove(alias)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _aliasInput,
            decoration: InputDecoration(
              hintText: 'Add an alias',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add alias',
                onPressed: () => _addAlias(_aliasInput.text),
              ),
            ),
            onSubmitted: _addAlias,
          ),
          if (!widget.isNew) ...[
            const Divider(height: AppSpacing.xxl),
            OutlinedButton.icon(
              onPressed: _saving
                  ? null
                  : () => unawaited(_setArchived(!isArchived)),
              icon: Icon(
                isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              label: Text(isArchived ? 'Unarchive' : 'Archive'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Archiving hides an exercise from pickers without touching any '
              'workout it appears in.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      // Bottom, not an app-bar action: the app is used one-handed, so primary
      // actions belong in the thumb zone (docs/23-NAVIGATION.md).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: FilledButton(
            onPressed: _name.text.trim().isEmpty || _saving
                ? null
                : () => unawaited(_save()),
            child: Text(widget.isNew ? 'Create exercise' : 'Save'),
          ),
        ),
      ),
    );
  }
}
