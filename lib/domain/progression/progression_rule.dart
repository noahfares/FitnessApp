/// Progression rule union, stored as `routine_exercises.progression_rule`
/// (`F-PRG-001`, `F-PRG-007`).
///
/// JSON by hand, not `json_serializable` — two small variants, and this
/// mirrors `domain/history/workout_history.dart`'s existing pattern for a
/// small stored union rather than adding a build-time dependency for it.
library;

import 'dart:convert';

enum ProgressionRuleType { manualCarryForward, linear }

/// Per-exercise linear-progression parameters (`F-PRG-002` §3).
class LinearProgressionConfig {
  const LinearProgressionConfig({
    required this.incrementGrams,
    this.failureThreshold = 3,
    this.deloadFraction = 0.10,
  });

  /// Added to the weight on a successful session.
  final int incrementGrams;

  /// Consecutive failed sessions before a deload triggers (§2, §3).
  final int failureThreshold;

  /// Fraction of the current weight cut on deload, e.g. `0.10` = 10%.
  final double deloadFraction;
}

sealed class ProgressionRule {
  const ProgressionRule();

  ProgressionRuleType get type;

  String toJson();

  /// `null` input (no rule ever assigned) and any unrecognised stored value
  /// both fall back to the manual rule — the default, never an error
  /// (`F-PRG-006`).
  static ProgressionRule fromJson(String? json) {
    if (json == null) return const ManualCarryForwardRule();
    final map = jsonDecode(json) as Map<String, dynamic>;
    return switch (map['type'] as String?) {
      'linear' => LinearProgressionRule(
        config: LinearProgressionConfig(
          incrementGrams: map['incrementGrams'] as int,
          failureThreshold: map['failureThreshold'] as int? ?? 3,
          deloadFraction: (map['deloadFraction'] as num?)?.toDouble() ?? 0.10,
        ),
      ),
      _ => const ManualCarryForwardRule(),
    };
  }
}

/// The default, opinion-free rule (`F-PRG-006`): next session's targets are
/// exactly what was actually logged last time, no evaluation at all.
class ManualCarryForwardRule extends ProgressionRule {
  const ManualCarryForwardRule();

  @override
  ProgressionRuleType get type => ProgressionRuleType.manualCarryForward;

  @override
  String toJson() => jsonEncode({'type': 'manualCarryForward'});
}

class LinearProgressionRule extends ProgressionRule {
  const LinearProgressionRule({required this.config});

  final LinearProgressionConfig config;

  @override
  ProgressionRuleType get type => ProgressionRuleType.linear;

  @override
  String toJson() => jsonEncode({
    'type': 'linear',
    'incrementGrams': config.incrementGrams,
    'failureThreshold': config.failureThreshold,
    'deloadFraction': config.deloadFraction,
  });
}
