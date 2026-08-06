import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/timing/rest_settings.dart';

/// Making the end of a rest audible (`F-TIM-003`, `F-TIM-006`).
///
/// An interface in `data/platform/` rather than a plugin call from a widget,
/// because this is **the largest known Android/iOS behavioural divergence in
/// the project** (`F-TIM-003` open questions) and neither platform's answer may
/// leak into `features/` or `domain/`
/// (docs/20-ARCHITECTURE.md §cross-platform-discipline).
///
/// ## The two platform approaches
///
/// **Android.** A notification scheduled through `AlarmManager`
/// (`setExactAndAllowWhileIdle`) so it survives doze, plus a low-priority
/// ongoing notification carrying the live countdown (`F-TIM-003` §3). Needs
/// `POST_NOTIFICATIONS` from API 33 and `SCHEDULE_EXACT_ALARM` /
/// `USE_EXACT_ALARM` from API 31, and aggressive OEM battery managers
/// (Samsung, Xiaomi) can still kill the process — which is why the fallback
/// below is not optional. The notification's tap action deep-links to
/// `AppRoutes.activeWorkout` (`F-TIM-003` §4, `F-NAV-002`).
///
/// **iOS.** No equivalent. Background execution is measured in seconds, and
/// there is no ongoing-notification analogue, so a *live* countdown outside the
/// app is not achievable. The approach is a single `UNTimeIntervalNotification`
/// scheduled at start time and cancelled if the timer is skipped or adjusted —
/// meaning every adjustment reschedules, and the "remaining time" notification
/// of §3 becomes a static one that only fires at zero. This is a documented gap
/// rather than a bug to be fixed.
///
/// Both are notification-shaped, which is why [schedule] takes a target time
/// rather than being driven by ticks: the implementation decides whether that
/// target is honoured by a timer, an alarm, or the OS.
abstract interface class RestTimerService {
  /// Arranges for the alert to happen at [firesAt].
  ///
  /// Replaces any previously scheduled alert — completing another set restarts
  /// the rest rather than stacking a second one (`F-TIM-002` §4).
  ///
  /// [onFired] and [onWarning] are how the in-process implementation reports
  /// back; an implementation whose alert is delivered by the OS while the app
  /// is dead simply never calls them, and the UI recovers from the timestamp
  /// on the next frame instead.
  Future<void> schedule({
    required DateTime firesAt,
    required RestAlertStyle style,
    Duration preWarning = Duration.zero,
    void Function()? onFired,
    void Function()? onWarning,
  });

  /// Drops any scheduled alert. Safe to call when nothing is scheduled.
  Future<void> cancel();

  /// Asks for whatever permission the alert needs, **in context** — at the
  /// first rest, not at first launch (`F-TIM-003` acceptance).
  ///
  /// False means the alert will be in-app only, which callers must treat as a
  /// working state rather than a failure (`F-TIM-003` edge cases).
  Future<bool> requestPermission();
}

/// The in-app implementation: a Dart timer, a system sound, and a buzz.
///
/// This is the floor, not the ceiling. It is correct whenever the process is
/// alive, it needs no permission and no plugin, and it is what the app falls
/// back to when notification permission is denied. What it does **not** do is
/// survive the process being killed by a battery manager, which is exactly the
/// case the Android approach documented above exists for.
///
/// It never counts down: it schedules against a wall-clock target and lets the
/// `RestTimer` value answer questions about time. Nothing here can drift.
class InAppRestTimerService implements RestTimerService {
  Timer? _fire;
  Timer? _warn;

  @override
  Future<void> schedule({
    required DateTime firesAt,
    required RestAlertStyle style,
    Duration preWarning = Duration.zero,
    void Function()? onFired,
    void Function()? onWarning,
  }) async {
    await cancel();

    final untilFire = firesAt.difference(DateTime.now());
    // A target already in the past fires on the next microtask rather than
    // never: a zero-second rest is still a completed rest.
    _fire = Timer(untilFire.isNegative ? Duration.zero : untilFire, () {
      _fire = null;
      unawaited(_alert(style));
      onFired?.call();
    });

    if (preWarning > Duration.zero) {
      final untilWarning = untilFire - preWarning;
      if (untilWarning > Duration.zero) {
        _warn = Timer(untilWarning, () {
          _warn = null;
          // The warning is always a buzz, never the alert sound: two identical
          // sounds ten seconds apart is indistinguishable from the timer
          // having fired early.
          if (style != RestAlertStyle.silent) {
            unawaited(HapticFeedback.mediumImpact());
          }
          onWarning?.call();
        });
      }
    }
  }

  @override
  Future<void> cancel() async {
    _fire?.cancel();
    _warn?.cancel();
    _fire = null;
    _warn = null;
  }

  /// Volume rides the system alert stream. `F-TIM-006` asks for a volume
  /// independent of media volume "where the platform allows"; through
  /// [SystemSound] it does not, and getting that needs the audio-focus handling
  /// that arrives with the notification implementation.
  Future<void> _alert(RestAlertStyle style) async {
    if (style.playsSound) await SystemSound.play(SystemSoundType.alert);
    if (style.vibrates) await HapticFeedback.heavyImpact();
  }

  void dispose() => unawaited(cancel());
}

final restTimerServiceProvider = Provider<RestTimerService>((ref) {
  final service = InAppRestTimerService();
  ref.onDispose(service.dispose);
  return service;
});
