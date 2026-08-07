import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';

/// A session logged from memory, after the fact (`F-LOG-009` §4).
///
/// Collects only a name and a date/time; exercises and sets are added on the
/// edit screen it opens onto, the same flow as any other past workout.
Future<void> showLogPastWorkoutSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _LogPastWorkoutSheet(),
  );
}

class _LogPastWorkoutSheet extends ConsumerStatefulWidget {
  const _LogPastWorkoutSheet();

  @override
  ConsumerState<_LogPastWorkoutSheet> createState() =>
      _LogPastWorkoutSheetState();
}

class _LogPastWorkoutSheetState extends ConsumerState<_LogPastWorkoutSheet> {
  final _name = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  Duration _duration = const Duration(hours: 1);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text('Log a past workout', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_date)),
                  onTap: _pickDate,
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start time'),
                  subtitle: Text(_startTime.format(context)),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Duration', style: theme.textTheme.bodyMedium),
              Text('${_duration.inMinutes} min'),
            ],
          ),
          Slider(
            value: _duration.inMinutes.toDouble(),
            min: 5,
            max: 240,
            divisions: 47,
            label: '${_duration.inMinutes} min',
            onChanged: (value) =>
                setState(() => _duration = Duration(minutes: value.round())),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: _submit, child: const Text('Add exercises')),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _submit() async {
    final startedAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _startTime.hour,
      _startTime.minute,
    );
    final workout = await ref
        .read(workoutRepositoryProvider)
        .createRetroactive(
          name: _name.text,
          startedAt: startedAt,
          endedAt: startedAt.add(_duration),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(context.push(AppRoutes.historyWorkoutEdit(workout.id)));
  }
}
