import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../data/repositories/personal_record_repository.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/pr_timeline_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../l10n/app_localizations.dart';

/// PR timeline (`F-ANA-007`) — "the app's highlight reel": every personal
/// record, newest first, filterable by exercise and kind.
class PrTimelineScreen extends ConsumerStatefulWidget {
  const PrTimelineScreen({super.key});

  @override
  ConsumerState<PrTimelineScreen> createState() => _PrTimelineScreenState();
}

class _PrTimelineScreenState extends ConsumerState<PrTimelineScreen> {
  String? _exerciseFilter;
  PrKind? _kindFilter;

  @override
  Widget build(BuildContext context) {
    final timeline = ref.watch(prTimelineProvider);
    final formatter = ref.watch(quantityFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.analyticsPrTimeline)),
      body: timeline.view((entries) {
        if (entries.isEmpty) {
          return EmptyState(
            icon: Icons.emoji_events_outlined,
            title: context.l10n.analyticsNoRecordsYet,
            message: context.l10n.analyticsEveryPersonalRecordYouSet,
          );
        }

        final exerciseNames =
            entries.map((e) => e.exerciseName).toSet().toList()..sort();
        final filtered = entries.where((entry) {
          if (_exerciseFilter != null &&
              entry.exerciseName != _exerciseFilter) {
            return false;
          }
          if (_kindFilter != null && entry.kind != _kindFilter) return false;
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: _exerciseFilter,
                      hint: Text(context.l10n.analyticsAllExercises),
                      onChanged: (value) =>
                          setState(() => _exerciseFilter = value),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(context.l10n.analyticsAllExercises),
                        ),
                        for (final name in exerciseNames)
                          DropdownMenuItem(value: name, child: Text(name)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButton<PrKind?>(
                      isExpanded: true,
                      value: _kindFilter,
                      hint: Text(context.l10n.analyticsAllKinds),
                      onChanged: (value) => setState(() => _kindFilter = value),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(context.l10n.analyticsAllKinds),
                        ),
                        for (final kind in PrKind.values)
                          DropdownMenuItem(
                            value: kind,
                            child: Text(_kindLabel(kind, context.l10n)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.filter_alt_off_outlined,
                      title: context.l10n.analyticsNoMatches,
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final entry = filtered[i];
                        return ListTile(
                          leading: const Icon(Icons.emoji_events_outlined),
                          title: Text(entry.exerciseName),
                          subtitle: Text(
                            _describe(entry, formatter, context.l10n),
                          ),
                          trailing: Text(
                            DateFormat.yMMMd().format(
                              DateTime.fromMillisecondsSinceEpoch(
                                entry.achievedAt,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  /// Mirrors `SessionSummaryScreen._describe` — same four kinds, same
  /// wording, so a record reads identically whether it's celebrated in the
  /// moment or found later here.
  String _describe(
    PrTimelineEntry entry,
    QuantityFormatter formatter,
    AppLocalizations l10n,
  ) {
    return switch (entry.kind) {
      PrKind.maxWeight =>
        'Heaviest set: ${formatter.setWeight(Mass.grams(entry.valueGrams), showUnit: true)}',
      PrKind.bestE1rm =>
        'Best estimated 1RM: ${formatter.e1rm(Mass.grams(entry.valueGrams))}',
      PrKind.maxRepsAtWeight =>
        '${entry.valueGrams} reps at '
            '${formatter.setWeight(Mass.grams(entry.qualifierGrams!), showUnit: true)}',
      PrKind.maxSessionVolume =>
        'Most volume in a session: ${formatter.volume(Mass.grams(entry.valueGrams))}',
    };
  }

  static String _kindLabel(PrKind kind, AppLocalizations l10n) =>
      switch (kind) {
        PrKind.maxWeight => l10n.analyticsHeaviestSet,
        PrKind.bestE1rm => l10n.analyticsBestE1rm,
        PrKind.maxRepsAtWeight => l10n.analyticsMostRepsAtAWeight,
        PrKind.maxSessionVolume => l10n.analyticsMostSessionVolume,
      };
}
