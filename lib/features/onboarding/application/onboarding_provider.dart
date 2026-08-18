/// Whether first-run onboarding has been dealt with (`F-SET-011`).
///
/// One boolean, set when the flow is finished *or skipped* — skipping is a
/// complete answer, not a postponement (§2). Everything it asks about has a
/// sensible default already, so someone who skips is not left in a broken
/// state; they are left in exactly the state they would have been in before
/// this feature existed.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/unit_preferences_provider.dart'
    show sharedPreferencesProvider;

const String onboardingSeenKey = 'onboarding.seen';

final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
);

class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(onboardingSeenKey) ?? false;

  Future<void> markSeen() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(onboardingSeenKey, true);
  }
}
