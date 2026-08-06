import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../domain/history/workout_history.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../application/history_providers.dart';
import 'log_past_workout_sheet.dart';

/// Past sessions, reverse-chronological, grouped by month (`F-LOG-011`).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(historySearchProvider),
  );
  late final ScrollController _scroll = ScrollController()
    ..addListener(_maybeLoadMore);

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Lazily raises the query limit near the bottom rather than paging with an
  /// offset — cheap while the table is small, and simple (`F-LOG-011` §3).
  void _maybeLoadMore() {
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 400) {
      return;
    }
    final entries = ref.read(historyProvider).value ?? const [];
    final limit = ref.read(historyPageSizeProvider);
    if (entries.length < limit) return; // fewer rows than asked for: no more.
    ref.read(historyPageSizeProvider.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final months = ref.watch(historyByMonthProvider);
    final search = ref.watch(historySearchProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by workout or exercise',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _search.clear();
                          ref.read(historySearchProvider.notifier).setQuery('');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: ref.read(historySearchProvider.notifier).setQuery,
            ),
          ),
          Expanded(
            child: history.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, _) => Center(child: Text('$error')),
              data: (entries) => entries.isEmpty
                  ? _EmptyHistory(isSearching: search.isNotEmpty)
                  : CustomScrollView(
                      controller: _scroll,
                      slivers: [
                        for (final group in months) ...[
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _MonthHeader(_monthLabel(group)),
                          ),
                          SliverList.builder(
                            itemCount: group.entries.length,
                            itemBuilder: (context, i) =>
                                _WorkoutTile(entry: group.entries[i]),
                          ),
                        ],
                        // Room for the FAB, so the last row is never trapped
                        // underneath it.
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 88),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLogPastWorkoutSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Log past workout'),
      ),
    );
  }

  static String _monthLabel(MonthGroup group) =>
      DateFormat.yMMMM().format(DateTime(group.year, group.month));
}

class _MonthHeader extends SliverPersistentHeaderDelegate {
  const _MonthHeader(this.label);

  final String label;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      color: theme.colorScheme.surface,
      child: Text(label, style: theme.textTheme.titleMedium),
    );
  }

  @override
  bool shouldRebuild(_MonthHeader oldDelegate) => oldDelegate.label != label;
}

class _WorkoutTile extends ConsumerWidget {
  const _WorkoutTile({required this.entry});

  final WorkoutHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(quantityFormatterProvider);
    final date = entry.localDate;

    return ListTile(
      title: Text(entry.name),
      subtitle: Text(
        '${DateFormat.MMMd().format(date)} · '
        '${entry.exerciseCount} '
        '${entry.exerciseCount == 1 ? 'exercise' : 'exercises'} · '
        '${formatter.volume(Mass.grams(entry.totalVolumeGrams))}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.historyWorkout(entry.id)),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.calendar_month_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isSearching ? 'No sessions match' : 'No sessions logged yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isSearching
                  ? 'Try a shorter search.'
                  : 'Finished workouts show up here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
