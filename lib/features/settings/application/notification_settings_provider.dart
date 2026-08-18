/// Notification preferences (`F-SET-008`).
///
/// Three switches, and the spec's own default rule: **all off except the rest
/// timer**. Permission is requested in context — at the first rest, or when a
/// reminder switch is turned on — never at first launch, which is the one
/// thing an app with nothing to sell should never do.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_preferences_provider.dart' show sharedPreferencesProvider;

const String restAlertsKey = 'notifications.restAlerts';
const String workoutRemindersKey = 'notifications.workoutReminders';
const String measurementRemindersKey = 'notifications.measurementReminders';

class NotificationSettings {
  const NotificationSettings({
    required this.restAlerts,
    required this.workoutReminders,
    required this.measurementReminders,
  });

  /// On by default: it is the alert the app exists to deliver, and someone
  /// who does not want it turns it off here or lets the permission lapse.
  final bool restAlerts;

  /// Off by default. A reminder to train is a notification nobody asked for
  /// until they ask for it.
  final bool workoutReminders;

  /// Off by default, same reasoning.
  final bool measurementReminders;

  NotificationSettings copyWith({
    bool? restAlerts,
    bool? workoutReminders,
    bool? measurementReminders,
  }) => NotificationSettings(
    restAlerts: restAlerts ?? this.restAlerts,
    workoutReminders: workoutReminders ?? this.workoutReminders,
    measurementReminders: measurementReminders ?? this.measurementReminders,
  );
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationSettings(
      restAlerts: prefs.getBool(restAlertsKey) ?? true,
      workoutReminders: prefs.getBool(workoutRemindersKey) ?? false,
      measurementReminders: prefs.getBool(measurementRemindersKey) ?? false,
    );
  }

  Future<void> setRestAlerts(bool enabled) =>
      _write(restAlertsKey, enabled, (s) => s.copyWith(restAlerts: enabled));

  Future<void> setWorkoutReminders(bool enabled) => _write(
    workoutRemindersKey,
    enabled,
    (s) => s.copyWith(workoutReminders: enabled),
  );

  Future<void> setMeasurementReminders(bool enabled) => _write(
    measurementRemindersKey,
    enabled,
    (s) => s.copyWith(measurementReminders: enabled),
  );

  Future<void> _write(
    String key,
    bool value,
    NotificationSettings Function(NotificationSettings) update,
  ) async {
    state = update(state);
    await ref.read(sharedPreferencesProvider).setBool(key, value);
  }
}
