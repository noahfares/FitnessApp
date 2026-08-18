import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../../domain/timing/rest_settings.dart';
import '../../../data/platform/rest_timer_service.dart';
import '../../shell/widgets/apple_list.dart';
import '../../shell/widgets/section_header.dart';
import '../application/notification_settings_provider.dart';
import '../application/rest_timer_settings_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../timing/presentation/rest_alert_labels.dart';

/// The "automatic" choice, as a radio value. Zero is the same sentinel the
/// stored preference uses, so the screen and the notifier agree without a
/// nullable type parameter.
const int _automaticRest = 0;

/// Settings › Rest timer (`F-SET-003`).
///
/// Only the global settings live here. Per-exercise and per-routine overrides
/// belong with those entities — a settings screen listing every exercise's rest
/// duration would be a worse exercise editor.
/// Turning an alert *on* is the moment to ask for the permission it needs —
/// in context, never at first launch (`F-SET-008`, `F-TIM-003` acceptance).
/// A refusal leaves the switch off rather than pretending it is on.
Future<void> _setRestAlerts(WidgetRef ref, {required bool enabled}) async {
  final notifier = ref.read(notificationSettingsProvider.notifier);
  if (!enabled) return notifier.setRestAlerts(false);
  final granted = await ref.read(restTimerServiceProvider).requestPermission();
  return notifier.setRestAlerts(granted);
}

Future<void> _setReminder(
  WidgetRef ref, {
  required bool enabled,
  required Future<void> Function(NotificationSettingsNotifier, bool) write,
}) async {
  final notifier = ref.read(notificationSettingsProvider.notifier);
  if (!enabled) return write(notifier, false);
  final granted = await ref.read(restTimerServiceProvider).requestPermission();
  return write(notifier, granted);
}

class RestTimerScreen extends ConsumerWidget {
  const RestTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final settings = ref.watch(restTimerSettingsProvider);
    final notifier = ref.read(restTimerSettingsProvider.notifier);
    final notifications = ref.watch(notificationSettingsProvider);
    final defaultSeconds = settings.defaultSeconds ?? _automaticRest;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(context.l10n.catalogRestTimer)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          AppleListSection(
            children: [
              AppleSwitchRow(
                title: context.l10n.settingsStartAutomatically,
                subtitle: context.l10n.settingsAutoStartRestExplainer,
                value: settings.autoStart,
                onChanged: (value) =>
                    unawaited(notifier.setAutoStart(enabled: value)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.settingsDefaultRest),
          const SizedBox(height: AppSpacing.sm),
          AppleListSection(
            children: [
              AppleRadioRow(
                title: context.l10n.settingsAutomatic,
                subtitle: context.l10n.settingsRestDefaultsHint,
                selected: defaultSeconds == _automaticRest,
                onTap: () => unawaited(notifier.setDefaultSeconds(null)),
              ),
              for (final seconds in restDurationChoices)
                AppleRadioRow(
                  title: formatRestDuration(seconds),
                  selected: defaultSeconds == seconds,
                  onTap: () => unawaited(notifier.setDefaultSeconds(seconds)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              context.l10n.settingsRestDefaultOverrideNote,
              style: TextStyle(fontSize: 13, color: colors.labelSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Alert'),
          const SizedBox(height: AppSpacing.sm),
          AppleListSection(
            children: [
              for (final style in RestAlertStyle.values)
                AppleRadioRow(
                  title: style.label(context.l10n),
                  selected: settings.alertStyle == style,
                  onTap: () => unawaited(notifier.setAlertStyle(style)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppleListSection(
            children: [
              AppleSwitchRow(
                title: context.l10n.settingsWarnBeforeTheEnd,
                subtitle:
                    'A short buzz $restPreWarningSeconds seconds before zero.',
                value: settings.preWarning,
                onChanged: (value) =>
                    unawaited(notifier.setPreWarning(enabled: value)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.settingsNotifications),
          const SizedBox(height: AppSpacing.sm),
          AppleListSection(
            children: [
              AppleSwitchRow(
                title: context.l10n.settingsRestAlerts,
                subtitle: context.l10n.settingsRestAlertsExplainer,
                value: notifications.restAlerts,
                onChanged: (value) =>
                    unawaited(_setRestAlerts(ref, enabled: value)),
              ),
              AppleSwitchRow(
                title: context.l10n.settingsWorkoutReminders,
                subtitle: context.l10n.settingsWorkoutRemindersExplainer,
                value: notifications.workoutReminders,
                onChanged: (value) => unawaited(
                  _setReminder(
                    ref,
                    enabled: value,
                    write: (n, v) => n.setWorkoutReminders(v),
                  ),
                ),
              ),
              AppleSwitchRow(
                title: context.l10n.settingsMeasurementReminders,
                subtitle: context.l10n.settingsMeasurementRemindersExplainer,
                value: notifications.measurementReminders,
                onChanged: (value) => unawaited(
                  _setReminder(
                    ref,
                    enabled: value,
                    write: (n, v) => n.setMeasurementReminders(v),
                  ),
                ),
              ),
            ],
          ),
          // The one platform limitation worth stating in the UI rather than
          // only in the code (`F-TIM-003` edge cases).
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Text(
              context.l10n.settingsRestAlertLimitation,
              style: TextStyle(fontSize: 13, color: colors.labelSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
