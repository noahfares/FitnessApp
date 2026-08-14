import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/units/week_start.dart';
import '../../../domain/logging/rpe.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/rest_timer_settings_provider.dart';
import '../application/rpe_settings_provider.dart';
import '../application/theme_provider.dart';
import '../application/unit_preferences_provider.dart';
import '../application/week_start_provider.dart';

/// Settings root.
///
/// Reached from Home rather than owning a tab — low-frequency screens would
/// dilute the five slots (docs/23-NAVIGATION.md).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final units = ref.watch(unitPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final restTimer = ref.watch(restTimerSettingsProvider);
    final rpe = ref.watch(rpeSettingsProvider);
    final rpeNotifier = ref.read(rpeSettingsProvider.notifier);
    final weekStart = ref.watch(weekStartProvider);
    final weekStartNotifier = ref.read(weekStartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // Two settings, a bool and a two-value scale, so this lives inline
          // rather than behind its own route (`F-LOG-014` §3).
          SwitchListTile(
            secondary: const Icon(Icons.speed_outlined),
            title: Text(l10n.settingsRpeTitle),
            subtitle: Text(l10n.settingsRpeSubtitle),
            value: rpe.enabled,
            onChanged: (value) =>
                unawaited(rpeNotifier.setEnabled(enabled: value)),
          ),
          if (rpe.enabled)
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
              child: RadioGroup<RpeDisplayMode>(
                groupValue: rpe.displayMode,
                onChanged: (mode) {
                  if (mode != null) unawaited(rpeNotifier.setDisplayMode(mode));
                },
                child: Row(
                  children: [
                    for (final mode in RpeDisplayMode.values)
                      Expanded(
                        child: RadioListTile<RpeDisplayMode>(
                          value: mode,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            mode == RpeDisplayMode.rpe
                                ? l10n.settingsRpeModeRpe
                                : l10n.settingsRpeModeRir,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // A three-value choice, so this lives inline rather than behind its
          // own route, same reasoning as RPE above (`F-SET-005`).
          ListTile(
            leading: const Icon(Icons.calendar_view_week_outlined),
            title: Text(l10n.settingsWeekStartTitle),
            subtitle: Text(l10n.settingsWeekStartSubtitle),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
            child: RadioGroup<WeekStart>(
              groupValue: weekStart,
              onChanged: (value) {
                if (value != null) unawaited(weekStartNotifier.set(value));
              },
              child: Row(
                children: [
                  for (final option in [
                    WeekStart.monday,
                    WeekStart.saturday,
                    WeekStart.sunday,
                  ])
                    Expanded(
                      child: RadioListTile<WeekStart>(
                        value: option,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_weekdayLabel(l10n, option)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(l10n.settingsUnitsTitle),
            subtitle: Text(
              '${units.load.symbol} · ${units.length.symbol} · '
              '${units.distance.symbol}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsUnits),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsAppearanceTitle),
            subtitle: Text(themeMode.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAppearance),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.settingsRestTimerTitle),
            subtitle: Text(
              '${restTimer.autoStart ? l10n.settingsRestTimerAutoStart : l10n.settingsRestTimerManualStart}'
              ' · '
              '${restTimer.defaultSeconds == null ? l10n.settingsRestTimerAutoLength : formatRestDuration(restTimer.defaultSeconds!)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsRestTimer),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: Text(l10n.settingsBodyweightTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.body),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: Text(l10n.settingsDataTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsData),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(l10n.settingsPlatesTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsPlates),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.settingsAppLockTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAppLock),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAboutTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAbout),
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(AppLocalizations l10n, WeekStart weekStart) =>
      switch (weekStart.weekday) {
        DateTime.monday => l10n.settingsWeekdayMon,
        DateTime.saturday => l10n.settingsWeekdaySat,
        DateTime.sunday => l10n.settingsWeekdaySun,
        _ => l10n.settingsWeekdayMon,
      };
}
