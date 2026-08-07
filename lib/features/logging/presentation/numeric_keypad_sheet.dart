import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/logging/duration_entry.dart';
import '../../../domain/logging/set_fields.dart';
import '../../../domain/logging/weight_steps.dart';
import '../../settings/application/unit_preferences_provider.dart';
import 'set_value_format.dart';

/// Opens the keypad for one set, focused on [initialField] (`F-LOG-006`).
///
/// The sheet is deliberately not full height: the set list has to stay visible
/// above it (§6), because the number being typed only means anything next to
/// the ones above it.
Future<void> showSetKeypad(
  BuildContext context, {
  required WorkoutSet set,
  required List<SetField> fields,
  required SetField initialField,
  required String equipment,
  int? incrementGrams,
  bool perSide = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Nothing behind it is dimmed to the point of being unreadable — the point
    // is that the rest of the session stays legible while typing.
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.2),
    builder: (context) => NumericKeypadSheet(
      set: set,
      fields: fields,
      initialField: initialField,
      equipment: equipment,
      incrementGrams: incrementGrams,
      perSide: perSide,
    ),
  );
}

/// The purpose-built keypad (`F-LOG-006`).
///
/// Never the system keyboard: its targets are small, its layout shifts between
/// devices, and it covers the set list. This one has big keys in fixed
/// positions and a known height.
///
/// **Writes through on every keystroke** (`F-LOG-003` §7). Buffering until the
/// sheet closes would mean a kill mid-entry loses the number, and this sheet is
/// open for most of the time the app is in the foreground.
class NumericKeypadSheet extends ConsumerStatefulWidget {
  const NumericKeypadSheet({
    super.key,
    required this.set,
    required this.fields,
    required this.initialField,
    required this.equipment,
    this.perSide = false,
    this.incrementGrams,
  });

  final WorkoutSet set;
  final List<SetField> fields;
  final SetField initialField;

  /// Stored enum name, for the default step (`F-LOG-006` §2).
  final String equipment;

  /// Per-exercise override in canonical grams (`F-SET-007`).
  final int? incrementGrams;

  /// The exercise's weight entry mode (`F-LOG-017` §2). Every weight number
  /// this sheet shows, steps or parses is in the per-side domain when true —
  /// only [_write] converts back to the total that is actually stored.
  final bool perSide;

  @override
  ConsumerState<NumericKeypadSheet> createState() => _NumericKeypadSheetState();
}

class _NumericKeypadSheetState extends ConsumerState<NumericKeypadSheet> {
  late SetField _field = widget.initialField;

  /// Text as typed, per field. Kept as text rather than as a parsed number so
  /// that a half-typed `102.` survives the next keystroke — reparsing and
  /// reformatting between keys is what makes home-made keypads eat digits.
  final Map<SetField, String> _text = {};

  /// Repeats a stepper while it is held (`F-LOG-006` §2).
  Timer? _repeat;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(unitPreferencesProvider);
    final formatter = ref.read(quantityFormatterProvider);
    for (final field in widget.fields) {
      _text[field] = switch (field) {
        SetField.duration =>
          widget.set.durationSeconds == null
              ? ''
              : digitsFromSeconds(widget.set.durationSeconds!),
        _ =>
          formatSetField(
                widget.set,
                field,
                formatter,
                prefs,
                perSide: widget.perSide,
              ) ??
              '',
      };
    }
  }

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  Mass get _step {
    final override = widget.incrementGrams;
    if (override != null) return Mass.grams(override);
    return defaultStep(
      equipment: widget.equipment,
      unit: ref.read(unitPreferencesProvider).load,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (final field in widget.fields) ...[
                  // Switching field never closes the sheet (`F-LOG-006` §4).
                  Expanded(
                    child: _FieldTab(
                      label: fieldHeader(
                        field,
                        prefs,
                        perSide: field == SetField.weight && widget.perSide,
                      ),
                      value: _display(field),
                      selected: field == _field,
                      onTap: () => setState(() => _field = field),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                IconButton(
                  tooltip: 'Done',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.keyboard_hide_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  semanticLabel: 'Decrease',
                  onPressed: () => _stepBy(-1),
                  onHold: () => _startRepeat(-1),
                  onRelease: _stopRepeat,
                ),
                Expanded(
                  child: Text(
                    _display(_field).isEmpty ? '—' : _display(_field),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  semanticLabel: 'Increase',
                  onPressed: () => _stepBy(1),
                  onHold: () => _startRepeat(1),
                  onRelease: _stopRepeat,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _Keys(
              decimalSeparator: _allowsDecimal ? _decimalSeparator : null,
              onDigit: _append,
              onDecimal: () => _append(_decimalSeparator),
              onBackspace: _backspace,
              onClear: _clear,
            ),
          ],
        ),
      ),
    );
  }

  /// Reps and durations are whole numbers; a decimal point on them can only
  /// produce a value the app then has to reject.
  bool get _allowsDecimal =>
      _field == SetField.weight || _field == SetField.distance;

  String get _decimalSeparator =>
      ref
          .read(quantityFormatterProvider)
          .setWeight(const Mass.grams(1500))
          .contains(',')
      ? ','
      : '.';

  String _display(SetField field) {
    final raw = _text[field] ?? '';
    // Durations are typed as digits and read back as a clock, so what the tab
    // shows is not what the buffer holds.
    if (field == SetField.duration) {
      final seconds = secondsFromDigits(raw);
      return seconds == null ? '' : formatDurationSeconds(seconds);
    }
    return raw;
  }

  void _append(String character) {
    final current = _text[_field] ?? '';
    if (character == _decimalSeparator && current.contains(character)) return;
    // Ten digits is a 1000 kg lift with three decimals — beyond that it is a
    // stuck key, and letting it grow makes the row unreadable.
    if (current.length >= 10) return;
    _write(current + character);
  }

  void _backspace() {
    final current = _text[_field] ?? '';
    if (current.isEmpty) return;
    _write(current.substring(0, current.length - 1));
  }

  void _clear() => _write('');

  /// Steps by the exercise's increment, in the display unit (`F-LOG-006` §3).
  ///
  /// Weight goes through canonical grams so that hundreds of repeats cannot
  /// drift (docs/22-UNITS.md); reps step by one and durations by five seconds,
  /// which are exact by construction.
  void _stepBy(int direction) {
    switch (_field) {
      case SetField.weight:
        final current = _parseGrams() ?? 0;
        final stepped = steppedGrams(current, _step, direction);
        _write(
          ref.read(quantityFormatterProvider).setWeight(Mass.grams(stepped)),
        );
      case SetField.reps:
        final current = int.tryParse(_text[_field] ?? '') ?? 0;
        final next = current + direction;
        _write(next < 0 ? '0' : '$next');
      case SetField.duration:
        final current = secondsFromDigits(_text[_field] ?? '') ?? 0;
        final next = current + 5 * direction;
        _write(digitsFromSeconds(next < 0 ? 0 : next));
      case SetField.distance:
        final metres = _parseMetres() ?? 0;
        final step = ref.read(unitPreferencesProvider).distance;
        final next = metres + Distance.inUnit(0.1, step).metres * direction;
        _write(
          ref
              .read(quantityFormatterProvider)
              .distance(Distance.metres(next < 0 ? 0 : next), showUnit: false),
        );
    }
  }

  void _startRepeat(int direction) {
    _repeat?.cancel();
    _repeat = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => _stepBy(direction),
    );
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  int? _parseGrams() {
    final text = _text[SetField.weight] ?? '';
    if (text.isEmpty) return null;
    final parser = ref.read(quantityParserProvider);
    return parser
        .parseMass(text, ref.read(unitPreferencesProvider).load)
        ?.grams;
  }

  int? _parseMetres() {
    final text = _text[SetField.distance] ?? '';
    if (text.isEmpty) return null;
    final parser = ref.read(quantityParserProvider);
    final value = parser.parseNumber(text);
    if (value == null) return null;
    return Distance.inUnit(
      value,
      ref.read(unitPreferencesProvider).distance,
    ).metres;
  }

  /// Sets the buffer and writes it through immediately.
  ///
  /// Unparseable input — `102.` mid-typing — leaves the stored value alone
  /// rather than clearing it. Clearing is what the clear key is for.
  void _write(String text) {
    setState(() => _text[_field] = text);
    HapticFeedback.selectionClick();
    final repo = ref.read(setRepositoryProvider);

    switch (_field) {
      case SetField.weight:
        if (text.isEmpty) {
          unawaited(
            repo.updateValues(widget.set.id, weightGrams: const Value(null)),
          );
          return;
        }
        final grams = _parseGrams();
        if (grams != null) {
          // The buffer is always in the display domain — per-side when
          // `perSide`, exactly the total otherwise — and only this write
          // converts back to what `sets.weight_grams` actually stores
          // (`F-LOG-017` §1, §3).
          final total = widget.perSide ? (Mass.grams(grams) * 2).grams : grams;
          unawaited(
            repo.updateValues(widget.set.id, weightGrams: Value(total)),
          );
        }
      case SetField.reps:
        final reps = text.isEmpty ? null : int.tryParse(text);
        if (text.isEmpty || reps != null) {
          unawaited(repo.updateValues(widget.set.id, reps: Value(reps)));
        }
      case SetField.distance:
        if (text.isEmpty) {
          unawaited(
            repo.updateValues(widget.set.id, distanceMetres: const Value(null)),
          );
          return;
        }
        final metres = _parseMetres();
        if (metres != null) {
          unawaited(
            repo.updateValues(widget.set.id, distanceMetres: Value(metres)),
          );
        }
      case SetField.duration:
        final seconds = text.isEmpty ? null : secondsFromDigits(text);
        if (text.isEmpty || seconds != null) {
          unawaited(
            repo.updateValues(widget.set.id, durationSeconds: Value(seconds)),
          );
        }
    }
  }
}

class _FieldTab extends StatelessWidget {
  const _FieldTab({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stepper key: one tap steps once, holding repeats (`F-LOG-006` §2).
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    required this.onHold,
    required this.onRelease,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final VoidCallback onHold;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onHold,
      onLongPressEnd: (_) => onRelease(),
      onLongPressCancel: onRelease,
      child: SizedBox(
        // Bigger than the 48 dp minimum: hit mid-set with imprecise aim
        // (docs/24-DESIGN-SYSTEM.md §spacing).
        width: AppSpacing.setRowTouchTarget,
        height: AppSpacing.setRowTouchTarget,
        child: IconButton.filledTonal(
          tooltip: semanticLabel,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _Keys extends StatelessWidget {
  const _Keys({
    required this.decimalSeparator,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
  });

  /// Null when the field takes whole numbers only, which disables the key.
  final String? decimalSeparator;
  final void Function(String digit) onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback? onTap, {String? semantics}) =>
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: SizedBox(
              height: AppSpacing.setRowTouchTarget,
              child: FilledButton.tonal(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
                child: semantics == null
                    ? child
                    : Semantics(label: semantics, child: child),
              ),
            ),
          ),
        );

    Widget digit(String value) =>
        key(Text(value, textAlign: TextAlign.center), () => onDigit(value));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [digit('1'), digit('2'), digit('3')]),
        Row(children: [digit('4'), digit('5'), digit('6')]),
        Row(children: [digit('7'), digit('8'), digit('9')]),
        Row(
          children: [
            key(
              Text(decimalSeparator ?? '.'),
              decimalSeparator == null ? null : onDecimal,
              semantics: 'Decimal point',
            ),
            digit('0'),
            key(
              const Icon(Icons.backspace_outlined),
              onBackspace,
              semantics: 'Backspace',
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: onClear, child: const Text('Clear')),
        ),
      ],
    );
  }
}
