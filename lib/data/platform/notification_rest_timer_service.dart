import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/timing/rest_settings.dart';
import 'rest_timer_service.dart';

/// The OS-delivered rest alert (`F-TIM-003`), and the actions on it
/// (`F-TIM-004`).
///
/// This is the implementation `rest_timer_service.dart`'s own doc has
/// described since batch 1.5, finally written. It **wraps**
/// [InAppRestTimerService] rather than replacing it: the in-app timer is the
/// floor, correct whenever the process is alive and needing no permission, and
/// the notification is what survives the process being killed. Running both is
/// deliberate — an alert that fires twice is a non-event, an alert that does
/// not fire is the failure this feature exists to prevent.
///
/// Nothing here throws. A missing permission, a manufacturer that refuses
/// exact alarms, an unsupported platform: all of them degrade to the in-app
/// timer, which is a working state and not an error (`F-TIM-003` edge cases).
class NotificationRestTimerService implements RestTimerService {
  NotificationRestTimerService({
    FlutterLocalNotificationsPlugin? plugin,
    InAppRestTimerService? inApp,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _inApp = inApp ?? InAppRestTimerService();

  final FlutterLocalNotificationsPlugin _plugin;
  final InAppRestTimerService _inApp;

  /// One id, reused: completing another set restarts the rest rather than
  /// stacking a second alert (`F-TIM-002` §4), and a fixed id makes that a
  /// property of the platform call instead of bookkeeping here.
  static const int alertId = 1001;
  static const int _ongoingId = 1002;

  static const String channelId = 'rest_timer';
  static const String channelName = 'Rest timer';

  /// What the tap and the action buttons hand back. The route is
  /// `AppRoutes.activeWorkout`'s literal value — this file is in `data/` and
  /// may not import `core/routing/`, so the constant is duplicated here and
  /// asserted equal in the test rather than silently drifting.
  static const String openActivePayload = '/workout/active';
  static const String skipActionId = 'rest_skip';
  static const String extendActionId = 'rest_extend';

  bool _initialised = false;
  bool _available = false;

  /// Called when a notification action arrives — set by whoever wires the
  /// plugin up at startup, so the platform layer stays ignorant of routing and
  /// of the timer's own state (`F-TIM-004`).
  static void Function(String actionId)? onAction;

  Future<void> _ensureInitialised() async {
    if (_initialised) return;
    _initialised = true;
    // Only Android and iOS have anything to deliver; on a desktop or test
    // host the in-app timer is the whole implementation.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    try {
      tz_data.initializeTimeZones();
      _available =
          await _plugin.initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings(
                // The launcher icon's monochrome layer (`F-THM-006`) —
                // Android tints the status-bar icon itself, so a colour icon
                // would come out as a white blob.
                '@drawable/ic_launcher_foreground',
              ),
              iOS: DarwinInitializationSettings(
                requestAlertPermission: false,
                requestSoundPermission: false,
                requestBadgePermission: false,
              ),
            ),
            onDidReceiveNotificationResponse: _handleResponse,
          ) ??
          false;
    } catch (_) {
      _available = false;
    }
  }

  static void _handleResponse(NotificationResponse response) {
    final actionId = response.actionId;
    if (actionId != null && actionId.isNotEmpty) {
      onAction?.call(actionId);
      return;
    }
    // A tap with no action is the notification body itself: go to the session
    // (`F-TIM-003` §4).
    if (response.payload == openActivePayload) {
      onOpenRoute?.call(openActivePayload);
    }
  }

  /// Where a tap should take the app — set by whoever owns routing, for the
  /// same reason [onAction] is: `data/` may not import `core/routing/`.
  static void Function(String route)? onOpenRoute;

  /// Whether the app was launched *by* a notification tap, and where it should
  /// go if so. Read once at startup (`F-TIM-003` §4): the deep link has to
  /// survive the process being dead, which is the whole point of the alert.
  Future<String?> launchRoute() async {
    await _ensureInitialised();
    if (!_available) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return null;
      return details?.notificationResponse?.payload;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> schedule({
    required DateTime firesAt,
    required RestAlertStyle style,
    Duration preWarning = Duration.zero,
    void Function()? onFired,
    void Function()? onWarning,
  }) async {
    // The in-app alert goes first and unconditionally: it is the one that
    // works with no permission at all.
    await _inApp.schedule(
      firesAt: firesAt,
      style: style,
      preWarning: preWarning,
      onFired: onFired,
      onWarning: onWarning,
    );

    await _ensureInitialised();
    if (!_available) return;

    try {
      await _plugin.cancel(id: alertId);
      await _plugin.zonedSchedule(
        id: alertId,
        scheduledDate: tz.TZDateTime.from(firesAt, tz.local),
        title: 'Rest finished',
        body: 'Back to it.',
        payload: openActivePayload,
        // Exact where allowed, inexact where not: a rest that fires a minute
        // late is useless, but refusing to schedule at all is worse than
        // approximate (`F-TIM-003` edge cases — battery optimisation).
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Fires when a rest period ends.',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            playSound: style.playsSound,
            enableVibration: style.vibrates,
            // Full-screen intent is deliberately not used: this is a gym
            // timer, not an alarm clock, and hijacking the whole screen
            // mid-set would be worse than a heads-up notification.
            actions: const [
              AndroidNotificationAction(skipActionId, 'Skip'),
              AndroidNotificationAction(extendActionId, '+15s'),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentSound: style.playsSound,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
      );
    } catch (_) {
      // Scheduling refused — the in-app timer above still stands.
    }
  }

  /// The live countdown notification (`F-TIM-003` §3).
  ///
  /// Rewritten on each tick by whoever owns the countdown; this class only
  /// knows how to draw one. Ongoing and silent: it is a status display, and a
  /// sound every second would be intolerable.
  Future<void> showOngoing({
    required String title,
    required String body,
  }) async {
    await _ensureInitialised();
    if (!_available) return;
    try {
      await _plugin.show(
        id: _ongoingId,
        title: title,
        body: body,
        payload: openActivePayload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            ongoing: true,
            silent: true,
            autoCancel: false,
            onlyAlertOnce: true,
            importance: Importance.low,
            priority: Priority.low,
            actions: [
              AndroidNotificationAction(skipActionId, 'Skip'),
              AndroidNotificationAction(extendActionId, '+15s'),
            ],
          ),
        ),
      );
    } catch (_) {
      // A status display that cannot be drawn changes nothing about the rest.
    }
  }

  @override
  Future<void> cancel() async {
    await _inApp.cancel();
    await _ensureInitialised();
    if (!_available) return;
    try {
      await _plugin.cancel(id: alertId);
      await _plugin.cancel(id: _ongoingId);
    } catch (_) {
      // Nothing to cancel is not a failure.
    }
  }

  /// Asked at the first rest, never at launch (`F-TIM-003` acceptance).
  @override
  Future<bool> requestPermission() async {
    await _ensureInitialised();
    if (!_available) return true; // in-app only, which is a working state

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final granted = await android.requestNotificationsPermission() ?? false;
        // Asked separately and *after*, because it is a different, heavier
        // question — Android sends the user to a settings screen for it. A
        // refusal here still leaves a working inexact alarm.
        if (granted) {
          await android.requestExactAlarmsPermission();
        }
        return granted;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
