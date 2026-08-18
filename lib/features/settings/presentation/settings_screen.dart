import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/week_start.dart';
import '../../../domain/logging/rpe.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../shell/widgets/apple_list.dart';
import '../application/rest_timer_settings_provider.dart';
import '../application/rpe_settings_provider.dart';
import '../application/theme_provider.dart';
import '../application/unit_preferences_provider.dart';
import '../application/week_start_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Settings root.
///
/// Reached from Home rather than owning a tab — low-frequency screens would
/// dilute the five slots (docs/23-NAVIGATION.md).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final units = ref.watch(unitPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final restTimer = ref.watch(restTimerSettingsProvider);
    final rpe = ref.watch(rpeSettingsProvider);
    final rpeNotifier = ref.read(rpeSettingsProvider.notifier);
    final weekStart = ref.watch(weekStartProvider);
    final weekStartNotifier = ref.read(weekStartProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(context.l10n.shellSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          // Two settings, a bool and a two-value scale, so they live inline
          // rather than behind their own route (`F-LOG-014` §3, `F-SET-005`).
          AppleListSection(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppleSwitchRow(
                      icon: Icons.speed_outlined,
                      title: context.l10n.settingsRpe,
                      subtitle: context.l10n.settingsRateOfPerceivedExertionPer,
                      value: rpe.enabled,
                      onChanged: (value) =>
                          unawaited(rpeNotifier.setEnabled(enabled: value)),
                    ),
                    if (rpe.enabled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        child: SegmentedTrack<RpeDisplayMode>(
                          selected: rpe.displayMode,
                          segments: [
                            for (final mode in RpeDisplayMode.values)
                              (
                                value: mode,
                                label: mode == RpeDisplayMode.rpe
                                    ? 'RPE'
                                    : 'RIR',
                              ),
                          ],
                          onChanged: (mode) =>
                              unawaited(rpeNotifier.setDisplayMode(mode)),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppleListRow(
                      icon: Icons.calendar_view_week_outlined,
                      title: context.l10n.settingsWeekStartsOn,
                      subtitle: context.l10n.settingsAppliesToWeeklyVolumeSets,
                      showChevron: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: SegmentedTrack<WeekStart>(
                        selected: weekStart,
                        segments: [
                          for (final option in [
                            WeekStart.monday,
                            WeekStart.saturday,
                            WeekStart.sunday,
                          ])
                            (value: option, label: _weekdayLabel(option)),
                        ],
                        onChanged: (value) =>
                            unawaited(weekStartNotifier.set(value)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppleListSection(
            children: [
              AppleListRow(
                icon: Icons.straighten,
                title: context.l10n.settingsUnits,
                subtitle:
                    '${units.load.symbol} · ${units.length.symbol} · '
                    '${units.distance.symbol}',
                onTap: () => context.push(AppRoutes.settingsUnits),
              ),
              AppleListRow(
                icon: Icons.palette_outlined,
                title: context.l10n.settingsAppearance,
                subtitle: themeMode.label(context.l10n),
                onTap: () => context.push(AppRoutes.settingsAppearance),
              ),
              AppleListRow(
                icon: Icons.timer_outlined,
                title: context.l10n.catalogRestTimer,
                subtitle:
                    '${restTimer.autoStart ? context.l10n.settingsStartsAutomatically : context.l10n.settingsManualStart}'
                    ' · '
                    '${restTimer.defaultSeconds == null ? context.l10n.settingsAutomaticLength : formatRestDuration(restTimer.defaultSeconds!)}',
                onTap: () => context.push(AppRoutes.settingsRestTimer),
              ),
              AppleListRow(
                icon: Icons.monitor_weight_outlined,
                title: context.l10n.settingsBodyweight,
                onTap: () => context.push(AppRoutes.body),
              ),
              AppleListRow(
                icon: Icons.import_export,
                title: context.l10n.settingsData,
                onTap: () => context.push(AppRoutes.settingsData),
              ),
              AppleListRow(
                icon: Icons.fitness_center,
                title: context.l10n.settingsBarsPlates,
                onTap: () => context.push(AppRoutes.settingsPlates),
              ),
              AppleListRow(
                icon: Icons.favorite_outline,
                title: context.l10n.settingsHealthConnect,
                subtitle: context.l10n.settingsHealthConnectSubtitle,
                onTap: () => context.push(AppRoutes.settingsHealth),
              ),
              AppleListRow(
                icon: Icons.lock_outline,
                title: context.l10n.settingsAppLock,
                onTap: () => context.push(AppRoutes.settingsAppLock),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppleListSection(
            children: [
              AppleListRow(
                icon: Icons.info_outline,
                title: context.l10n.settingsAbout,
                onTap: () => context.push(AppRoutes.settingsAbout),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(WeekStart weekStart) =>
      switch (weekStart.weekday) {
        DateTime.monday => 'Mon',
        DateTime.saturday => 'Sat',
        DateTime.sunday => 'Sun',
        _ => 'Mon',
      };
}
