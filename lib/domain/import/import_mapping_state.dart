import 'exercise_resolution.dart';

/// Tracks a resolution decision per unmatched exercise name across one
/// import session (`F-DAT-007`: *"remembers decisions... so a 400-row
/// import isn't 400 prompts"*).
///
/// Pure Dart, unit-tested independently of the screen that renders it — the
/// "remember decisions" rule is the one piece of real logic this feature
/// has; the screen itself is a thin list over this state.
class ImportMappingState {
  const ImportMappingState({this.resolutions = const {}});

  final Map<String, ExerciseResolution> resolutions;

  ImportMappingState resolve(
    String exerciseName,
    ExerciseResolution resolution,
  ) {
    return ImportMappingState(
      resolutions: {...resolutions, exerciseName: resolution},
    );
  }

  /// Every name in [unmatchedNames] still without a decision.
  List<String> unresolved(List<String> unmatchedNames) => [
    for (final name in unmatchedNames)
      if (!resolutions.containsKey(name)) name,
  ];

  bool get isComplete => resolutions.isNotEmpty;

  bool isFullyResolved(List<String> unmatchedNames) =>
      unresolved(unmatchedNames).isEmpty;
}
