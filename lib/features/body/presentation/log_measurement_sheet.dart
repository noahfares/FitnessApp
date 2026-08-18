import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/length.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../settings/application/unit_preferences_provider.dart';
import 'measurement_labels.dart';
import '../../../core/l10n/l10n.dart';

/// Log or edit a non-bodyweight measurement entry (`F-BOD-002`).
///
/// One sheet for every tracked type — a circumference reads and writes
/// through [Length] in the configured [LengthUnit], body fat through a bare
/// percentage — same "one screen, dispatch on shape" reasoning as the
/// exercise editor's weight-source fields.
Future<void> showLogMeasurementSheet(
  BuildContext context, {
  required MeasurementType type,
  BodyMeasurement? editing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => LogMeasurementSheet(type: type, editing: editing),
  );
}

class LogMeasurementSheet extends ConsumerStatefulWidget {
  const LogMeasurementSheet({required this.type, this.editing, super.key});

  final MeasurementType type;

  /// Null for a new entry, set to edit an existing one.
  final BodyMeasurement? editing;

  @override
  ConsumerState<LogMeasurementSheet> createState() =>
      _LogMeasurementSheetState();
}

class _LogMeasurementSheetState extends ConsumerState<LogMeasurementSheet> {
  late final TextEditingController _value = TextEditingController(
    text: widget.editing == null ? '' : _initialValueText(),
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.editing?.notes ?? '',
  );
  late DateTime _date = widget.editing == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(widget.editing!.measuredAt);
  String? _error;

  String _initialValueText() {
    final grams = widget.editing!.valueCanonical;
    if (widget.type.isPercent) return (grams / 100).toString();
    final unit = ref.read(unitPreferencesProvider).length;
    return Length.millimetres(grams).toUnit(unit).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);
    final label = widget.type.label(context.l10n);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screen,
        right: AppSpacing.screen,
        top: AppSpacing.screen,
        bottom: AppSpacing.screen + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.editing == null
                ? context.l10n.bodyLogMeasurement(label)
                : context.l10n.bodyEditMeasurement(label),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              suffixText: widget.type.isPercent ? '%' : prefs.length.symbol,
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat.yMMMd().format(_date)),
            onTap: _pickDate,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notes,
            decoration: InputDecoration(
              labelText: context.l10n.bodyNoteOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: _submit, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final parser = ref.read(quantityParserProvider);
    final int? canonical;
    if (widget.type.isPercent) {
      canonical = parser.parsePercentBasisPoints(_value.text);
    } else {
      canonical = parser
          .parseLength(_value.text, ref.read(unitPreferencesProvider).length)
          ?.millimetres;
    }
    if (canonical == null || canonical < 0) {
      setState(() => _error = context.l10n.bodyEnterAValue);
      return;
    }

    final repo = ref.read(bodyMeasurementRepositoryProvider);
    final editing = widget.editing;
    if (editing == null) {
      await repo.logMeasurement(
        type: widget.type,
        valueCanonical: canonical,
        measuredAt: _date,
        notes: _notes.text,
      );
    } else {
      await repo.updateMeasurement(
        editing.id,
        valueCanonical: canonical,
        measuredAt: _date,
        notes: Value(_notes.text),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
