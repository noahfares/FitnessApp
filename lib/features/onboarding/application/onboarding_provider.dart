import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/unit_preferences_provider.dart'
    show sharedPreferencesProvider;

/// Whether first-run onboarding (`F-SET-011`) has been completed *or*
/// explicitly skipped — the two collapse to the same state, since every
/// choice `OnboardingScreen` offers is changeable later in Settings anyway
/// (`F-SET-011` §2).
final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );

class OnboardingCompletedNotifier extends Notifier<bool> {
  /// Also read directly (not through this provider) in `main()`, before the
  /// `ProviderScope` exists — resolving the startup location has to happen
  /// synchronously ahead of the first frame, the same reason `main()` reads
  /// `units.load` directly rather than through `unitPreferencesProvider`.
  static const key = 'onboarding.completed';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(key) ?? false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(key, true);
  }
}
