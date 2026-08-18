import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Quick bodyweight entry (`F-BOD-001` §4) — reachable from the dashboard, not
/// only from a settings screen, because the whole point of unrecoverable
/// capture is that it has to be cheap enough to actually happen.
Future<void> showLogBodyweightSheet(
  BuildContext context, {
  BodyMeasurement? editing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => LogBodyweightSheet(editing: editing),
  );
}

class LogBodyweightSheet extends ConsumerStatefulWidget {
  const LogBodyweightSheet({this.editing, super.key});

  /// Null for a new entry, set to edit an existing one.
  final BodyMeasurement? editing;

  @override
  ConsumerState<LogBodyweightSheet> createState() => _LogBodyweightSheetState();
}

class _LogBodyweightSheetState extends ConsumerState<LogBodyweightSheet> {
  late final TextEditingController _value = TextEditingController(
    text: widget.editing == null
        ? ''
        : ref
              .read(quantityFormatterProvider)
              .massValueOnly(
                Mass.grams(widget.editing!.valueCanonical),
                ref.read(unitPreferencesProvider).body,
              ),
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.editing?.notes ?? '',
  );
  late DateTime _date = widget.editing == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(widget.editing!.measuredAt);
  String? _error;

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
                ? context.l10n.bodyLogBodyweight
                : context.l10n.bodyEditBodyweight,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l10n.bodyWeight,
              suffixText: prefs.body.symbol,
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.historyDate),
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
          FilledButton(
            onPressed: _submit,
            child: Text(context.l10n.catalogSave),
          ),
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
    final prefs = ref.read(unitPreferencesProvider);
    final mass = ref
        .read(quantityParserProvider)
        .parseMass(_value.text, prefs.body);
    if (mass == null || mass.grams <= 0) {
      setState(() => _error = context.l10n.bodyEnterAWeight);
      return;
    }

    final repo = ref.read(bodyMeasurementRepositoryProvider);
    final editing = widget.editing;
    if (editing == null) {
      await repo.logBodyweight(
        grams: mass.grams,
        measuredAt: _date,
        notes: _notes.text,
      );
    } else {
      await repo.updateBodyweight(
        editing.id,
        grams: mass.grams,
        measuredAt: _date,
        notes: Value(_notes.text),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
