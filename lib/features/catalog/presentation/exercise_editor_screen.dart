import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ids/uuid.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/weight_steps.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../settings/application/plate_providers.dart';
import '../../settings/application/unit_preferences_provider.dart';
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
  final TextEditingController _increment = TextEditingController();
  final TextEditingController _fixedIncrements = TextEditingController();
  final TextEditingController _stackBase = TextEditingController();
  final TextEditingController _stackStep = TextEditingController();
  final TextEditingController _stackHalfStep = TextEditingController();
  final TextEditingController _bodyweightCoefficient = TextEditingController();

  List<String> _aliases = <String>[];

  Muscle _primaryMuscle = Muscle.chest;
  Set<Muscle> _secondaryMuscles = <Muscle>{};
  Equipment _equipment = Equipment.barbell;
  TrackingType _trackingType = TrackingType.weightReps;

  /// Null until the equipment picks a sensible default (`F-PLT-005`),
  /// resolved in [_save] the same way [_weightEntryMode] is.
  WeightSource? _weightSource;

  /// Null for a new exercise until the equipment picks a sensible default
  /// (`F-LOG-017` §2) — resolved in [_save], not here, so changing equipment
  /// before saving keeps proposing the right default rather than freezing
  /// whatever [_equipment] happened to be on first build.
  WeightEntryMode? _weightEntryMode;

  /// Null means "use the global setting, then the built-in for this kind of
  /// exercise" (`F-TIM-005`).
  int? _defaultRestSeconds;

  /// Null means "use the inventory's own default bar" (`F-PLT-002` §4).
  String? _defaultBarId;

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
    _increment.dispose();
    _fixedIncrements.dispose();
    _stackBase.dispose();
    _stackStep.dispose();
    _stackHalfStep.dispose();
    _bodyweightCoefficient.dispose();
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
        _defaultBarId = row.defaultBarId;
        _weightEntryMode = row.weightEntryMode;
        _weightSource = row.weightSource;
        _notes.text = row.notes ?? '';
        _aliases = List<String>.of(row.aliases);
        final unit = ref.read(unitPreferencesProvider).load;
        final formatter = ref.read(quantityFormatterProvider);
        if (row.incrementGrams case final grams?) {
          _increment.text = formatter.massValueOnly(Mass.grams(grams), unit);
        }
        if (row.fixedIncrementsGrams.isNotEmpty) {
          _fixedIncrements.text = row.fixedIncrementsGrams
              .map((g) => formatter.massValueOnly(Mass.grams(g), unit))
              .join(', ');
        }
        if (row.stackBaseGrams case final grams?) {
          _stackBase.text = formatter.massValueOnly(Mass.grams(grams), unit);
        }
        if (row.stackStepGrams case final grams?) {
          _stackStep.text = formatter.massValueOnly(Mass.grams(grams), unit);
        }
        if (row.stackHalfStepGrams case final grams?) {
          _stackHalfStep.text = formatter.massValueOnly(
            Mass.grams(grams),
            unit,
          );
        }
        if (row.bodyweightCoefficient case final coefficient?) {
          _bodyweightCoefficient.text = (coefficient * 100).round().toString();
        }
      }
    });
  }

  /// Parses a comma-separated list of weights in the display unit into
  /// sorted, de-duplicated canonical grams. Blank entries are ignored rather
  /// than rejected — a trailing comma while typing shouldn't error.
  List<int> _parseFixedIncrements() {
    final unit = ref.read(unitPreferencesProvider).load;
    final parser = ref.read(quantityParserProvider);
    final grams = <int>{
      for (final part in _fixedIncrements.text.split(','))
        if (parser.parseMass(part.trim(), unit) case final mass?) mass.grams,
    }.toList();
    grams.sort();
    return grams;
  }

  int? _parseMassField(TextEditingController controller) {
    final unit = ref.read(unitPreferencesProvider).load;
    return ref
        .read(quantityParserProvider)
        .parseMass(controller.text, unit)
        ?.grams;
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
    // A blank or unparseable field falls through to the equipment default
    // rather than being treated as an error — this override is optional
    // (`F-SET-007`).
    final incrementGrams = ref
        .read(quantityParserProvider)
        .parseMass(_increment.text, ref.read(unitPreferencesProvider).load)
        ?.grams;
    final weightSource = _weightSource ?? defaultWeightSourceFor(_equipment);
    final fixedIncrementsGrams = weightSource == WeightSource.fixedIncrement
        ? _parseFixedIncrements()
        : const <int>[];
    final stackBaseGrams = weightSource == WeightSource.stack
        ? _parseMassField(_stackBase)
        : null;
    final stackStepGrams = weightSource == WeightSource.stack
        ? _parseMassField(_stackStep)
        : null;
    final stackHalfStepGrams = weightSource == WeightSource.stack
        ? _parseMassField(_stackHalfStep)
        : null;
    // A blank or unparseable field means "full bodyweight" (`F-LOG-019` §3),
    // the same "no override" reading `_defaultRestSeconds` uses.
    double? bodyweightCoefficient;
    if (_trackingType == TrackingType.bodyweightReps) {
      final percent = int.tryParse(_bodyweightCoefficient.text.trim());
      if (percent != null) bodyweightCoefficient = percent / 100;
    }

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
        defaultBarId: _defaultBarId,
        weightEntryMode: weightEntryMode,
        incrementGrams: incrementGrams,
        weightSource: weightSource,
        fixedIncrementsGrams: fixedIncrementsGrams,
        stackBaseGrams: stackBaseGrams,
        stackStepGrams: stackStepGrams,
        stackHalfStepGrams: stackHalfStepGrams,
        bodyweightCoefficient: bodyweightCoefficient,
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
          defaultBarId: Value(_defaultBarId),
          weightEntryMode: Value(weightEntryMode),
          incrementGrams: Value(incrementGrams),
          weightSource: Value(weightSource),
          fixedIncrementsGrams: Value(fixedIncrementsGrams),
          stackBaseGrams: Value(stackBaseGrams),
          stackStepGrams: Value(stackStepGrams),
          stackHalfStepGrams: Value(stackHalfStepGrams),
          bodyweightCoefficient: Value(bodyweightCoefficient),
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
          if (_trackingType == TrackingType.bodyweightReps) ...[
            const SizedBox(height: AppSpacing.lg),
            // Full bodyweight by default — a ring dip loads all of it, an
            // assisted-pulldown machine loads a fraction (`F-LOG-019` §3).
            // The set row still logs *added* weight only; this is the rest
            // of the effective load, resolved at analytics time.
            TextField(
              controller: _bodyweightCoefficient,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bodyweight loaded',
                border: OutlineInputBorder(),
                suffixText: '%',
                helperText: 'Blank uses 100% — the full bodyweight.',
              ),
            ),
          ],
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
          if (setFieldsFor(_trackingType.name).contains(SetField.weight)) ...[
            const SizedBox(height: AppSpacing.lg),
            // Decides what the plate calculator shows and what the
            // progression engine's plate-aware rounding snaps a proposed
            // weight to (`F-PLT-005`).
            DropdownButtonFormField<WeightSource>(
              initialValue: _weightSource ?? defaultWeightSourceFor(_equipment),
              decoration: const InputDecoration(
                labelText: 'Weight source',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: WeightSource.plateLoaded,
                  child: Text('Plate-loaded'),
                ),
                DropdownMenuItem(
                  value: WeightSource.fixedIncrement,
                  child: Text('Fixed dumbbells'),
                ),
                DropdownMenuItem(
                  value: WeightSource.stack,
                  child: Text('Weight stack'),
                ),
              ],
              onChanged: (source) => setState(() => _weightSource = source),
            ),
          ],
          if ((_weightSource ?? defaultWeightSourceFor(_equipment)) ==
              WeightSource.plateLoaded) ...[
            const SizedBox(height: AppSpacing.lg),
            // The plate calculator and plate-aware rounding load this
            // exercise on whichever bar is picked here, falling back to the
            // inventory's own default bar when left unset (`F-PLT-002` §4).
            Builder(
              builder: (context) {
                final bars = ref.watch(barsProvider).value ?? const [];
                return DropdownButtonFormField<String?>(
                  initialValue: bars.any((b) => b.id == _defaultBarId)
                      ? _defaultBarId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Bar',
                    border: OutlineInputBorder(),
                    helperText:
                        "Left as Default, uses the inventory's own "
                        'default bar (Settings › Bars & plates).',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Default')),
                    for (final bar in bars)
                      DropdownMenuItem(value: bar.id, child: Text(bar.name)),
                  ],
                  onChanged: (id) => setState(() => _defaultBarId = id),
                );
              },
            ),
          ] else if ((_weightSource ?? defaultWeightSourceFor(_equipment)) ==
              WeightSource.fixedIncrement) ...[
            const SizedBox(height: AppSpacing.lg),
            Builder(
              builder: (context) {
                final unit = ref.watch(unitPreferencesProvider).load;
                return TextField(
                  controller: _fixedIncrements,
                  decoration: InputDecoration(
                    labelText: 'Available weights',
                    border: const OutlineInputBorder(),
                    suffixText: unit.symbol,
                    helperText:
                        'Comma-separated, e.g. "5, 10, 15, 20" — '
                        'exactly what the rack stocks.',
                    helperMaxLines: 2,
                  ),
                );
              },
            ),
          ] else if ((_weightSource ?? defaultWeightSourceFor(_equipment)) ==
              WeightSource.stack) ...[
            const SizedBox(height: AppSpacing.lg),
            Builder(
              builder: (context) {
                final unit = ref.watch(unitPreferencesProvider).load;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _stackBase,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Base',
                          border: const OutlineInputBorder(),
                          suffixText: unit.symbol,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _stackStep,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Step',
                          border: const OutlineInputBorder(),
                          suffixText: unit.symbol,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _stackHalfStep,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Half step',
                          border: const OutlineInputBorder(),
                          suffixText: unit.symbol,
                          helperText: 'Optional',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          if (setFieldsFor(_trackingType.name).contains(SetField.weight)) ...[
            const SizedBox(height: AppSpacing.lg),
            // Overrides `defaultStep`'s per-equipment default
            // (`domain/logging/weight_steps.dart`) for this exercise only
            // (`F-SET-007`). Left blank, the stepper falls through to that
            // default — never to zero.
            Builder(
              builder: (context) {
                final unit = ref.watch(unitPreferencesProvider).load;
                final defaultLabel = ref
                    .watch(quantityFormatterProvider)
                    .setWeight(
                      defaultStep(equipment: _equipment.name, unit: unit),
                      showUnit: true,
                    );
                return TextField(
                  controller: _increment,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Stepper increment',
                    border: const OutlineInputBorder(),
                    suffixText: unit.symbol,
                    helperText: 'Blank uses the default, $defaultLabel.',
                  ),
                );
              },
            ),
          ],
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
