import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/units/mass.dart';
import '../../../domain/history/workout_history.dart';
import '../../body/application/body_providers.dart';
import '../../body/presentation/log_bodyweight_sheet.dart';
import '../../history/application/history_providers.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../logging/presentation/active_workout_screen.dart'
    show formatElapsed;
import '../../logging/presentation/start_workout_screen.dart';
import '../../routines/application/routine_providers.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../widgets/async_view.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/weekly_insights_section.dart';
import '../../../core/l10n/l10n.dart';

/// The home tab (`F-NAV-004`): resume or start a workout first, then recent
/// activity, then everywhere else in the app.
///
/// Streaks and recent PRs depend on features that don't exist yet — they
/// arrive with those, not as placeholders here. Today's scheduled day
/// (`F-ROU-012`) landed in batch 3.5; weekly insight cards (`F-ANA-013`)
/// landed in Phase 4's closing pass.
///
/// No app bar: a large inline title reads as more Home-like than chrome, per
/// the Apple-style pass, so Settings moves to a flush row at the foot of the
/// screen (`_SettingsRow`) instead of an app-bar action.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final recent = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            _Header(colors: colors),
            const SizedBox(height: AppSpacing.xl),
            const _ResumeOrStartCard(),
            const SizedBox(height: AppSpacing.xl),
            const _TodaysScheduleCard(),
            const WeeklyInsightsSection(),
            const SizedBox(height: AppSpacing.xl),
            const _BodyweightCard(),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(context.l10n.shellRecentWorkouts),
            const SizedBox(height: AppSpacing.sm),
            recent.view(
              (entries) => entries.isEmpty
                  ? EmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: context.l10n.shellNoWorkoutsYet,
                      message: context.l10n.shellYourFinishedSessionsWillShow,
                      actionLabel: context.l10n.shellStartAWorkout,
                      onAction: () => unawaited(showStartWorkoutSheet(context)),
                    )
                  : _FlushList(
                      rows: [
                        for (final entry in entries)
                          _RecentWorkoutRow(entry: entry),
                      ],
                    ),
              errorTitle: context.l10n.shellRecentWorkoutsCouldNotBe,
            ),
            const SizedBox(height: AppSpacing.xl),
            // The exercise catalogue has no tab of its own (unlike History,
            // which does) — a flush row here is its only way in now that the
            // old `OutlinedButton` pair is gone.
            _FlushList(
              rows: [
                _FlushRow(
                  title: context.l10n.historyExercises,
                  onTap: () => context.push(AppRoutes.exercises),
                ),
                _SettingsRow(colors: colors),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: TextStyle(fontSize: 13, color: colors.labelSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          context.l10n.shellHomeTitle,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.02,
            height: 1.1,
            color: colors.label,
          ),
        ),
      ],
    );
  }
}

/// The primary action (`F-NAV-004` §1) — deliberately the first thing on the
/// screen and sized to be unmissable, per the design brief's "primary actions
/// in the bottom half" reachability rule as far as a scrolling list allows.
class _ResumeOrStartCard extends ConsumerWidget {
  const _ResumeOrStartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final active = ref.watch(activeWorkoutProvider).value;

    if (active == null) {
      return _GroupedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.shellReadyToTrain,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.17,
                color: colors.label,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _TintPillButton(
              onPressed: () => unawaited(showStartWorkoutSheet(context)),
              icon: Icons.add,
              label: context.l10n.loggingStartAWorkout,
            ),
          ],
        ),
      );
    }

    final elapsed = ref.watch(elapsedProvider);
    return _GroupedCard(
      onTap: () => context.push(AppRoutes.activeWorkout),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.17,
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.shellInProgressElapsed(formatElapsed(elapsed)),
                  style: TextStyle(fontSize: 13, color: colors.labelSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 19, color: colors.labelTertiary),
        ],
      ),
    );
  }
}

/// "Today: Push" — the day(s) scheduled for today (`F-ROU-012`), or nothing
/// at all when no day is scheduled or a workout is already in progress
/// (`_ResumeOrStartCard` already covers that case).
class _TodaysScheduleCard extends ConsumerWidget {
  const _TodaysScheduleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeWorkoutProvider).value;
    if (active != null) return const SizedBox.shrink();

    final scheduled = ref.watch(todaysScheduledDaysProvider).value ?? const [];
    // A routine on fixed weekdays answers "what today" by the calendar; one on
    // a rolling rotation answers it by what was last trained (`F-ROU-012`).
    // Both end up in the same card, because the question is the same.
    final rotation = ref.watch(rotationDaysProvider).value ?? const [];
    final days = [...scheduled, ...rotation];
    if (days.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          for (final day in days)
            Padding(
              padding: EdgeInsets.only(
                bottom: day == days.last ? 0 : AppSpacing.md,
              ),
              child: _GroupedCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 18,
                ),
                onTap: () => context.push(
                  AppRoutes.routineDay(day.routineId, day.dayId),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scheduled.contains(day)
                                ? context.l10n.shellTodaysDay(day.dayName)
                                : context.l10n.shellNextUpDay(day.dayName),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.17,
                              color: colors.label,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            day.routineName,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 19,
                      color: colors.labelTertiary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Quick bodyweight entry (`F-BOD-001` §4) — cheap enough to actually happen,
/// which is the whole point of capturing something unrecoverable.
class _BodyweightCard extends ConsumerWidget {
  const _BodyweightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final latest = ref.watch(latestBodyweightProvider).value;
    final formatter = ref.watch(quantityFormatterProvider);

    return _GroupedCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 18,
      ),
      onTap: () => context.push(AppRoutes.body),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latest == null
                      ? context.l10n.shellNoBodyweightLoggedYet
                      : formatter.bodyweight(Mass.grams(latest.valueCanonical)),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.17,
                    color: colors.label,
                    fontFeatures: AppTheme.tabularFigures,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  latest == null
                      ? context.l10n.shellLogItToTrackAlongside
                      : DateFormat.yMMMd().format(
                          DateTime.fromMillisecondsSinceEpoch(
                            latest.measuredAt,
                          ),
                        ),
                  style: TextStyle(fontSize: 13, color: colors.labelSecondary),
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            tooltip: context.l10n.bodyLogBodyweight,
            onPressed: () => unawaited(showLogBodyweightSheet(context)),
          ),
        ],
      ),
    );
  }
}

/// A flush, card-less row list — dividers between rows, none after the last.
class _FlushList extends StatelessWidget {
  const _FlushList({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(children: rows);
  }
}

class _RecentWorkoutRow extends ConsumerWidget {
  const _RecentWorkoutRow({required this.entry});

  final WorkoutHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    return _FlushRow(
      title: entry.name,
      subtitle:
          '${entry.exerciseCount} '
          '${entry.exerciseCount == 1 ? 'exercise' : 'exercises'} · '
          '${formatter.volume(Mass.grams(entry.totalVolumeGrams))}',
      onTap: () => context.push(AppRoutes.historyWorkout(entry.id)),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _FlushRow(
      title: context.l10n.shellSettings,
      onTap: () => context.push(AppRoutes.settings),
    );
  }
}

/// One row of the flush list at the foot of Home: 11 dp vertical padding, a
/// hairline `separator` beneath, name + optional subtitle, trailing chevron.
/// Press dims to 60% opacity rather than tinting the background — chrome
/// recedes here, matching the handoff's one deliberate exception to tinted
/// grouped surfaces.
class _FlushRow extends StatefulWidget {
  const _FlushRow({required this.title, this.subtitle, required this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  State<_FlushRow> createState() => _FlushRowState();
}

class _FlushRowState extends State<_FlushRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.separator)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: -0.16,
                        color: colors.label,
                      ),
                    ),
                    if (widget.subtitle case final subtitle?) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.labelSecondary,
                          fontFeatures: AppTheme.tabularFigures,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 19, color: colors.labelTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// A grouped `surface` card: radius 20, 20 dp padding by default, optional tap
/// target with `surfaceHover` feedback.
class _GroupedCard extends StatefulWidget {
  const _GroupedCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<_GroupedCard> createState() => _GroupedCardState();
}

class _GroupedCardState extends State<_GroupedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _hovered ? colors.surfaceHover : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: widget.child,
    );
    if (widget.onTap == null) return card;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapCancel: () => setState(() => _hovered = false),
      onTapUp: (_) => setState(() => _hovered = false),
      child: card,
    );
  }
}

class _TintPillButton extends StatefulWidget {
  const _TintPillButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  State<_TintPillButton> createState() => _TintPillButtonState();
}

class _TintPillButtonState extends State<_TintPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _pressed ? colors.tintHover : colors.tint,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.17,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 19, color: colors.tint),
        ),
      ),
    );
  }
}
