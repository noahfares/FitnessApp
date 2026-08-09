import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/ids/uuid.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../application/plate_providers.dart';
import '../application/unit_preferences_provider.dart';

/// Settings › Bars & plates (`F-PLT-002`).
///
/// Configures what `F-PLT-001`'s calculator and `F-PRG-012`'s plate-aware
/// rounding are allowed to propose — never anything the user hasn't told the
/// app they actually own.
class PlateSettingsScreen extends ConsumerWidget {
  const PlateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bars = ref.watch(barsProvider);
    final plates = ref.watch(platesProvider);
    final unit = ref.watch(unitPreferencesProvider).load;
    final formatter = ref.watch(quantityFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bars & plates')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          _SectionHeading(
            'Bars',
            onAdd: () => _showBarSheet(context, ref, unit: unit),
          ),
          bars.view(
            (rows) => rows.isEmpty
                ? const _EmptyRow('No bars configured yet.')
                : Column(
                    children: [
                      for (final bar in rows)
                        ListTile(
                          leading: Icon(
                            bar.isDefault ? Icons.star : Icons.star_border,
                          ),
                          title: Text(bar.name),
                          subtitle: Text(
                            formatter.massValueOnly(
                              Mass.grams(bar.weightGrams),
                              unit,
                            ),
                          ),
                          onTap: () =>
                              _showBarSheet(context, ref, unit: unit, bar: bar),
                        ),
                    ],
                  ),
          ),
          const Divider(),
          _SectionHeading(
            'Plates',
            onAdd: () => _showPlateSheet(context, ref, unit: unit),
          ),
          plates.view(
            (rows) => rows.isEmpty
                ? const _EmptyRow('No plates configured yet.')
                : Column(
                    children: [
                      for (final plate in rows)
                        _PlateRow(plate: plate, unit: unit, formatter: formatter),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showBarSheet(
  BuildContext context,
  WidgetRef ref, {
  required MassUnit unit,
  Bar? bar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BarEditSheet(unit: unit, bar: bar),
  );
}

Future<void> _showPlateSheet(
  BuildContext context,
  WidgetRef ref, {
  required MassUnit unit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PlateAddSheet(unit: unit),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text, {required this.onAdd});

  final String text;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screen,
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.sm,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.titleSmall),
        ),
        IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
      ],
    ),
  );
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _PlateRow extends ConsumerWidget {
  const _PlateRow({
    required this.plate,
    required this.unit,
    required this.formatter,
  });

  final Plate plate;
  final MassUnit unit;
  final QuantityFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(plateRepositoryProvider);
    return ListTile(
      title: Text(formatter.massValueOnly(Mass.grams(plate.weightGrams), unit)),
      subtitle: Text('${plate.countAvailable} pair(s) available'),
      leading: Switch(
        value: plate.isEnabled,
        onChanged: (value) => unawaited(
          repo.setPlateEnabled(plate.id, isEnabled: value),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Fewer pairs',
            icon: const Icon(Icons.remove),
            onPressed: plate.countAvailable <= 0
                ? null
                : () => unawaited(
                    repo.setPlateCount(plate.id, plate.countAvailable - 1),
                  ),
          ),
          Text('${plate.countAvailable}'),
          IconButton(
            tooltip: 'More pairs',
            icon: const Icon(Icons.add),
            onPressed: () => unawaited(
              repo.setPlateCount(plate.id, plate.countAvailable + 1),
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showConfirmSheet(
                context,
                title: 'Remove this plate?',
                message: 'The calculator will stop proposing it.',
              );
              if (confirmed) await repo.deletePlate(plate.id);
            },
          ),
        ],
      ),
    );
  }
}

class _BarEditSheet extends ConsumerStatefulWidget {
  const _BarEditSheet({required this.unit, this.bar});

  final MassUnit unit;
  final Bar? bar;

  @override
  ConsumerState<_BarEditSheet> createState() => _BarEditSheetState();
}

class _BarEditSheetState extends ConsumerState<_BarEditSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.bar?.name ?? '',
  );
  late final TextEditingController _weight = TextEditingController(
    text: widget.bar == null
        ? ''
        : Mass.grams(widget.bar!.weightGrams).toUnit(widget.unit).toString(),
  );
  late bool _isDefault = widget.bar?.isDefault ?? false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(plateRepositoryProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.screen + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.bar == null ? 'New bar' : 'Edit bar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Weight (${widget.unit.symbol})',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Default bar'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () async {
                final name = _name.text.trim();
                final value = double.tryParse(_weight.text.trim());
                if (name.isEmpty || value == null) return;
                final weightGrams = Mass.inUnit(value, widget.unit).grams;
                if (widget.bar == null) {
                  await repo.createBar(
                    id: newUuidV4(),
                    name: name,
                    weightGrams: weightGrams,
                    isDefault: _isDefault,
                  );
                } else {
                  await repo.updateBar(
                    widget.bar!.id,
                    name: name,
                    weightGrams: weightGrams,
                    isDefault: _isDefault,
                  );
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateAddSheet extends ConsumerStatefulWidget {
  const _PlateAddSheet({required this.unit});

  final MassUnit unit;

  @override
  ConsumerState<_PlateAddSheet> createState() => _PlateAddSheetState();
}

class _PlateAddSheetState extends ConsumerState<_PlateAddSheet> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _pairs = TextEditingController(text: '1');

  @override
  void dispose() {
    _weight.dispose();
    _pairs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(plateRepositoryProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.screen + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New plate', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Weight (${widget.unit.symbol})',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _pairs,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pairs available'),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(_weight.text.trim());
                final pairs = int.tryParse(_pairs.text.trim());
                if (value == null || pairs == null) return;
                await repo.createPlate(
                  id: newUuidV4(),
                  weightGrams: Mass.inUnit(value, widget.unit).grams,
                  countAvailable: pairs,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
