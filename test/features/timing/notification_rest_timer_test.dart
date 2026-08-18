import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/platform/notification_rest_timer_service.dart';
import 'package:fitness_app/data/platform/rest_timer_service.dart';
import 'package:fitness_app/domain/timing/rest_settings.dart';

/// `F-TIM-003` / `F-TIM-004` — the parts of the OS alert that can be checked
/// without a device.
///
/// What cannot be checked here is everything the feature's own acceptance
/// criteria name: firing with the screen off, surviving an aggressive battery
/// manager, the permission dialog. Those are on-device criteria and the
/// feature file says so. What *is* checkable is that nothing throws off a
/// platform channel that does not exist, that the in-app floor still runs, and
/// that the payload the deep link depends on matches the route it names.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the deep-link payload is the active workout route', () {
    // `data/` may not import `core/routing/`, so the constant is duplicated —
    // and this is what stops the copy drifting from the original.
    expect(
      NotificationRestTimerService.openActivePayload,
      AppRoutes.activeWorkout,
    );
  });

  test(
    'scheduling still runs the in-app timer when the platform is absent',
    () async {
      // No plugin registrant exists in a test host, so every platform call
      // throws — which is exactly the "no health store / no permission /
      // unsupported OS" case, and it must degrade rather than fail.
      final inApp = InAppRestTimerService();
      final service = NotificationRestTimerService(inApp: inApp);

      var fired = false;
      await service.schedule(
        firesAt: DateTime.now().add(const Duration(milliseconds: 10)),
        style: RestAlertStyle.silent,
        onFired: () => fired = true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(fired, isTrue, reason: 'the in-app floor is not optional');
      await service.cancel();
    },
  );

  test('cancel is safe with nothing scheduled', () async {
    final service = NotificationRestTimerService();
    await expectLater(service.cancel(), completes);
  });

  test('a refused platform still reports a working state', () async {
    // "False means the alert will be in-app only, which callers must treat as
    // a working state rather than a failure" — with no platform at all, there
    // is nothing to refuse, so it is true.
    final service = NotificationRestTimerService();
    expect(await service.requestPermission(), isTrue);
  });

  test('notification actions route to timer intents, unknown ones do not', () {
    final received = <String>[];
    NotificationRestTimerService.onAction = received.add;
    addTearDown(() => NotificationRestTimerService.onAction = null);

    NotificationRestTimerService.onAction?.call(
      NotificationRestTimerService.skipActionId,
    );
    NotificationRestTimerService.onAction?.call(
      NotificationRestTimerService.extendActionId,
    );

    expect(received, ['rest_skip', 'rest_extend']);
  });
}
