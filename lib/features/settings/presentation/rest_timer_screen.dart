import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../../../domain/timing/rest_settings.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/rest_timer_settings_provider.dart';

/// The "automatic" choice, as a radio value. Zero is the same sentinel the
/// stored preference uses, so the screen and the notifier agree without a
/// nullable type parameter on `RadioGroup`.
const int _automaticRest = 0;

/// Settings › Rest timer (`F-SET-003`).
///
/// Only the global settings live here. Per-exercise and per-routine overrides
/// belong with those entities — a settings screen listing every exercise's rest
/// duration would be a worse exercise editor.
class RestTimerScreen extends ConsumerWidget {
  const RestTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(restTimerSettingsProvider);
    final notifier = ref.read(restTimerSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.restTimerTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          SwitchListTile(
            title: Text(l10n.restTimerAutoStartLabel),
            subtitle: Text(l10n.restTimerAutoStartDescription),
            value: settings.autoStart,
            onChanged: (value) =>
                unawaited(notifier.setAutoStart(enabled: value)),
          ),
          const Divider(),
          _SectionHeading(l10n.restTimerDefaultRestHeading),
          RadioGroup<int>(
            groupValue: settings.defaultSeconds ?? _automaticRest,
            onChanged: (value) => unawaited(
              notifier.setDefaultSeconds(
                value == null || value == _automaticRest ? null : value,
              ),
            ),
            child: Column(
              children: [
                RadioListTile<int>(
                  value: _automaticRest,
                  title: Text(l10n.restTimerAutomaticLabel),
                  subtitle: Text(l10n.restTimerAutomaticDescription),
                ),
                for (final seconds in restDurationChoices)
                  RadioListTile<int>(
                    value: seconds,
                    title: Text(formatRestDuration(seconds)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: Text(
              l10n.restTimerExerciseOverrideNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(),
          _SectionHeading(l10n.restTimerAlertHeading),
          RadioGroup<RestAlertStyle>(
            groupValue: settings.alertStyle,
            onChanged: (value) {
              if (value != null) unawaited(notifier.setAlertStyle(value));
            },
            child: Column(
              children: [
                for (final style in RestAlertStyle.values)
                  RadioListTile<RestAlertStyle>(
                    value: style,
                    title: Text(style.label),
                  ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l10n.restTimerWarnBeforeEndLabel),
            subtitle: Text(
              l10n.restTimerWarnBeforeEndDescription(restPreWarningSeconds),
            ),
            value: settings.preWarning,
            onChanged: (value) =>
                unawaited(notifier.setPreWarning(enabled: value)),
          ),
          // The one platform limitation worth stating in the UI rather than
          // only in the code (`F-TIM-003` edge cases).
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Text(
              l10n.restTimerNotificationLimitationNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screen,
      AppSpacing.md,
      AppSpacing.screen,
      AppSpacing.sm,
    ),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
