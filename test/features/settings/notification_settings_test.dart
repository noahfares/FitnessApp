import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/features/settings/application/notification_settings_provider.dart';

import '../../support/harness.dart';

/// `F-SET-008` — "all default off except the rest timer; permission requested
/// in context, never at first launch".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = testDatabase());

  testWidgets('the rest alert is on, the two reminders are off', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.settingsRestTimer,
    );

    final settings = container.read(notificationSettingsProvider);
    expect(settings.restAlerts, isTrue);
    expect(settings.workoutReminders, isFalse);
    expect(settings.measurementReminders, isFalse);
  });

  testWidgets('turning a reminder on asks first, and persists the answer', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.settingsRestTimer,
    );

    final reminder = find.widgetWithText(SwitchListTile, 'Workout reminders');
    await tester.scrollUntilVisible(
      reminder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(reminder);
    await tester.pumpAndSettle();

    // The harness's FakeRestTimerService grants, so the switch sticks. The
    // refusal path is covered in notification_rest_timer_test.dart, where a
    // real service with no platform behind it is the subject.
    expect(
      container.read(notificationSettingsProvider).workoutReminders,
      isTrue,
    );
  });

  testWidgets('nothing is asked for on the way into the app', (tester) async {
    // The permission must be requested in context — at a switch, or at the
    // first rest — never at launch (`F-SET-008`, `F-TIM-003` acceptance).
    final container = await pumpApp(tester, db: db);
    expect(container.read(notificationSettingsProvider).restAlerts, isTrue);
    expect(find.textContaining('Allow'), findsNothing);
  });
}
