import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/timing/rest_settings.dart';
import 'package:fitness_app/features/settings/application/rest_timer_settings_provider.dart';

import '../../support/harness.dart';

/// Rest-timer preferences (`F-SET-003`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to automatic everything', () async {
    final container = await testContainer(db: testDatabase());

    final settings = container.read(restTimerSettingsProvider);
    expect(settings.autoStart, isTrue);
    // Null is "automatic" — the per-exercise built-ins (`F-TIM-005`).
    expect(settings.defaultSeconds, isNull);
    expect(settings.alertStyle, RestAlertStyle.both);
    expect(settings.preWarning, isFalse);
  });

  test('reads what was stored', () async {
    final container = await testContainer(
      db: testDatabase(),
      prefs: {
        'rest.autoStart': false,
        'rest.defaultSeconds': 90,
        'rest.alertStyle': 'vibration',
        'rest.preWarning': true,
      },
    );

    final settings = container.read(restTimerSettingsProvider);
    expect(settings.autoStart, isFalse);
    expect(settings.defaultSeconds, 90);
    expect(settings.alertStyle, RestAlertStyle.vibration);
    expect(settings.preWarning, isTrue);
  });

  test('a stored zero means automatic, not a zero-second rest', () async {
    final container = await testContainer(
      db: testDatabase(),
      prefs: {'rest.defaultSeconds': 0},
    );

    expect(container.read(restTimerSettingsProvider).defaultSeconds, isNull);
  });

  test('an unrecognised alert style falls back rather than throwing', () async {
    // A downgrade or a corrupt write. No preference is worth failing to start
    // over.
    final container = await testContainer(
      db: testDatabase(),
      prefs: {'rest.alertStyle': 'fanfare'},
    );

    expect(
      container.read(restTimerSettingsProvider).alertStyle,
      RestAlertStyle.both,
    );
  });

  test('setting the default writes through and rebuilds', () async {
    final container = await testContainer(db: testDatabase());
    final notifier = container.read(restTimerSettingsProvider.notifier);

    await notifier.setDefaultSeconds(120);
    expect(container.read(restTimerSettingsProvider).defaultSeconds, 120);

    await notifier.setDefaultSeconds(null);
    expect(container.read(restTimerSettingsProvider).defaultSeconds, isNull);
  });
}
