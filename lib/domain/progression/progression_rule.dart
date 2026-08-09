/// Progression rule union, stored as `routine_exercises.progression_rule`
/// (`F-PRG-001`, `F-PRG-007`).
///
/// JSON by hand, not `json_serializable` — two small variants, and this
/// mirrors `domain/history/workout_history.dart`'s existing pattern for a
/// small stored union rather than adding a build-time dependency for it.
library;

import 'dart:convert';

enum ProgressionRuleType {
  manualCarryForward,
  linear,
  doubleProgression,
  rpeAutoregulation,
}

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

/// Per-exercise double-progression parameters (`F-PRG-003`).
class DoubleProgressionConfig {
  const DoubleProgressionConfig({
    required this.incrementGrams,
    this.floorMissThreshold = 3,
    this.deloadFraction = 0.10,
  });

  /// Added to the weight once every set reaches the top of the rep range.
  final int incrementGrams;

  /// Consecutive sessions with every set below the bottom of the rep range
  /// before a deload triggers (§3).
  final int floorMissThreshold;

  /// Fraction of the current weight cut on deload, e.g. `0.10` = 10%.
  final double deloadFraction;
}

/// Per-exercise RPE-autoregulation parameters (`F-PRG-005`). The
/// `failureThreshold`/`deloadFraction` pair is only used when the rule
/// degrades to linear progression — no RPE logged for the last session.
class RpeAutoregulationConfig {
  const RpeAutoregulationConfig({
    required this.incrementGrams,
    this.backoffFraction = 0.10,
    this.failureThreshold = 3,
    this.deloadFraction = 0.10,
  });

  final int incrementGrams;

  /// Fraction of the current weight cut when the logged RPE came in well
  /// over target.
  final double backoffFraction;
  final int failureThreshold;
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
      'doubleProgression' => DoubleProgressionRule(
        config: DoubleProgressionConfig(
          incrementGrams: map['incrementGrams'] as int,
          floorMissThreshold: map['floorMissThreshold'] as int? ?? 3,
          deloadFraction: (map['deloadFraction'] as num?)?.toDouble() ?? 0.10,
        ),
      ),
      'rpeAutoregulation' => RpeAutoregulationRule(
        config: RpeAutoregulationConfig(
          incrementGrams: map['incrementGrams'] as int,
          backoffFraction: (map['backoffFraction'] as num?)?.toDouble() ?? 0.10,
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

/// Fixed weight, working up a rep range across sessions (`F-PRG-003`).
class DoubleProgressionRule extends ProgressionRule {
  const DoubleProgressionRule({required this.config});

  final DoubleProgressionConfig config;

  @override
  ProgressionRuleType get type => ProgressionRuleType.doubleProgression;

  @override
  String toJson() => jsonEncode({
    'type': 'doubleProgression',
    'incrementGrams': config.incrementGrams,
    'floorMissThreshold': config.floorMissThreshold,
    'deloadFraction': config.deloadFraction,
  });
}

/// Adjusts load from the gap between the last session's logged RPE and the
/// exercise's target RPE (`F-PRG-005`). Degrades to linear progression when
/// no RPE was logged for the last session.
class RpeAutoregulationRule extends ProgressionRule {
  const RpeAutoregulationRule({required this.config});

  final RpeAutoregulationConfig config;

  @override
  ProgressionRuleType get type => ProgressionRuleType.rpeAutoregulation;

  @override
  String toJson() => jsonEncode({
    'type': 'rpeAutoregulation',
    'incrementGrams': config.incrementGrams,
    'backoffFraction': config.backoffFraction,
    'failureThreshold': config.failureThreshold,
    'deloadFraction': config.deloadFraction,
  });
}
