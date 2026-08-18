import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/platform/rest_timer_service.dart';
import '../../../domain/timing/rest_settings.dart';
import '../../../domain/timing/rest_timer.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../../data/platform/notification_rest_timer_service.dart';
import '../../settings/application/notification_settings_provider.dart';
import '../../settings/application/rest_timer_settings_provider.dart';

/// The clock the timer starts from.
///
/// Separate from [clockTickProvider], which is the once-a-second *display*
/// tick: a rest must target a precise instant, not the last tick, or every rest
/// is up to a second short. Overridable so that a widget test can pin both to
/// the same moment — a timer started from the wall clock and rendered against a
/// pinned one disagrees by however long ago the test's fixture date was.
final restClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The rest timer (`F-TIM-001`, `F-TIM-002`).
///
/// [Ref.keepAlive] because the timer outlives the screen that shows it:
/// switching to the History tab mid-rest must not silently cancel the rest. It
/// is *not* persisted — a timer is worth nothing after a relaunch, and
/// `F-TIM-001` says so explicitly. Starting idle after a kill is the
/// specification, not a shortcut.
final restTimerProvider = NotifierProvider<RestTimerController, RestTimer>(
  RestTimerController.new,
);

class RestTimerController extends Notifier<RestTimer> {
  @override
  RestTimer build() {
    ref.keepAlive();
    // Skip and +15 s from the notification itself (`F-TIM-004`), so the phone
    // never has to be unlocked between sets. Registered here rather than at
    // startup because this is the object that owns what those words mean; the
    // platform layer only knows the action fired.
    NotificationRestTimerService.onAction = (actionId) => switch (actionId) {
      NotificationRestTimerService.skipActionId => skip(),
      NotificationRestTimerService.extendActionId => adjust(15),
      _ => null,
    };
    ref.onDispose(() => NotificationRestTimerService.onAction = null);
    // Captured rather than read on dispose: by then the service provider may
    // already have gone, and a leaked platform alert outlives the app.
    final service = ref.read(restTimerServiceProvider);
    ref.onDispose(() => unawaited(service.cancel()));
    return RestTimer.idle;
  }

  int get _nowMs => ref.read(restClockProvider)().millisecondsSinceEpoch;

  /// Starts a rest of [seconds], replacing any rest already running.
  ///
  /// Replacing rather than stacking is `F-TIM-002` §4: two overlapping rests
  /// have no meaning, and the second alert would fire against the first set.
  void start(int seconds, {String? setId}) {
    state = RestTimer.start(seconds: seconds, nowMs: _nowMs, setId: setId);
    _reschedule();
  }

  /// Auto-start on completion, honouring the global toggle (`F-TIM-002` §3).
  ///
  /// The toggle is checked here rather than at the call site so that every
  /// completion path gets it — one that forgot would be a timer that starts
  /// when it was turned off, which reads as a bug in the setting.
  void startForSet({required String setId, required int seconds}) {
    if (!ref.read(restTimerSettingsProvider).autoStart) return;
    start(seconds, setId: setId);
  }

  /// Cancels a rest **only if this set started it** (`F-TIM-002` §5).
  ///
  /// Un-ticking a set two exercises up must not kill the rest belonging to the
  /// set just completed.
  void cancelForSet(String setId) {
    if (state.startedBySetId != setId) return;
    skip();
  }

  void pause() {
    if (!state.isRunning) return;
    state = state.pausedAt(_nowMs);
    _reschedule();
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.resumedAt(_nowMs);
    _reschedule();
  }

  /// Back to the full duration (`F-TIM-001` §2 "reset").
  void restart() {
    if (state.isIdle) return;
    state = state.restartedAt(_nowMs);
    _reschedule();
  }

  /// Ends the rest now, without an alert — the alert is for a rest that ran
  /// out, and skipping means it did not.
  void skip() {
    state = RestTimer.idle;
    _reschedule();
  }

  /// ±15 s (`F-TIM-001` §2). Adjusting to zero ends the rest rather than
  /// leaving a timer sitting at `0:00`.
  void adjust(int deltaSeconds) {
    if (state.isIdle) return;
    final next = state.adjusted(deltaSeconds, nowMs: _nowMs);
    if (next.isRunning && next.hasFiredAt(_nowMs)) {
      skip();
      return;
    }
    state = next;
    _reschedule();
  }

  /// Pushes the current target down to the platform.
  ///
  /// Called after every state change rather than only on start, because
  /// `RestTimerService` is target-based: an adjustment or a pause is nothing
  /// more than a different target, and rescheduling is how iOS is able to
  /// implement this at all (see `RestTimerService`).
  void _reschedule() {
    final service = ref.read(restTimerServiceProvider);
    final endsAtMs = state.isRunning ? state.endsAtMs : null;
    if (endsAtMs == null) {
      unawaited(service.cancel());
      return;
    }

    final settings = ref.read(restTimerSettingsProvider);
    // The alert is a preference (`F-SET-008`), and one that can be refused at
    // the OS level; the countdown itself is not, so this gates only the
    // scheduling below and never the state above.
    if (!ref.read(notificationSettingsProvider).restAlerts) {
      unawaited(service.cancel());
      return;
    }
    unawaited(
      service.schedule(
        firesAt: DateTime.fromMillisecondsSinceEpoch(endsAtMs),
        style: settings.alertStyle,
        preWarning: settings.preWarning
            ? const Duration(seconds: restPreWarningSeconds)
            : Duration.zero,
        // The bar hides itself once the target has passed, so firing only has
        // to drop the state — there is no "finished" screen to show.
        onFired: () {
          if (state.isRunning) state = RestTimer.idle;
        },
      ),
    );

    // The live countdown (`F-TIM-003` §3). Written once per reschedule rather
    // than once per second: Android redraws an ongoing notification from the
    // chronometer itself, and a per-second platform call for a number nobody
    // is watching is exactly the kind of battery cost a rest timer must not
    // have.
    if (service case final NotificationRestTimerService notifications) {
      unawaited(
        notifications.showOngoing(
          title: 'Resting',
          body: formatCountdown(state.remainingAt(_nowMs)),
        ),
      );
    }
  }
}

/// What the bar renders, recomputed on each tick of [clockTickProvider].
///
/// Derived rather than stored: the timer value itself never changes between
/// start and finish, which is what makes it immune to a missed tick
/// (`F-TIM-001` §4).
final restRemainingProvider = Provider<Duration>((ref) {
  final timer = ref.watch(restTimerProvider);
  final now = ref.watch(clockTickProvider).value ?? DateTime.now();
  return timer.remainingAt(now.millisecondsSinceEpoch);
});

/// Whether the rest bar belongs on screen.
final restTimerVisibleProvider = Provider<bool>((ref) {
  final timer = ref.watch(restTimerProvider);
  final now = ref.watch(clockTickProvider).value ?? DateTime.now();
  return timer.isVisibleAt(now.millisecondsSinceEpoch);
});
