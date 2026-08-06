/// Route paths, in one place (F-NAV-002).
///
/// Constants rather than string literals at call sites, because deep links are
/// load-bearing here: home-screen widgets (`F-NAV-007`), app shortcuts
/// (`F-NAV-008`) and rest-timer notification taps (`F-TIM-003`) all route by
/// URI, so a typo is a silently dead entry point rather than a compile error.
///
/// The full map lives in docs/23-NAVIGATION.md. Only the routes Phase 0 needs
/// are defined; the rest arrive with the features that own them.
abstract final class AppRoutes {
  // Shell branches.
  static const String home = '/';
  static const String routines = '/routines';
  static const String start = '/start';
  static const String history = '/history';
  static const String insights = '/insights';

  // Catalogue. Pushed over the shell rather than owning a tab: it is reached
  // from Home now and from the exercise picker once F-LOG-002 lands.
  static const String exercises = '/exercises';
  static const String exerciseNew = '/exercises/new';

  /// `/exercises/:exerciseId/edit`.
  static String exerciseEdit(String exerciseId) =>
      '$exercises/$exerciseId/edit';

  // Pushed over the shell — low-frequency, so they do not dilute the five tabs.
  static const String settings = '/settings';
  static const String settingsUnits = '/settings/units';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsAbout = '/settings/about';
}
