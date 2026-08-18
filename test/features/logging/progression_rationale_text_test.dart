import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/formatting/quantity_formatter.dart';
import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/core/units/unit_preferences.dart';
import 'package:fitness_app/domain/progression/progression_rationale.dart';
import 'package:fitness_app/features/logging/presentation/progression_rationale_text.dart';

import '../../support/l10n.dart';

/// `F-PRG-008` §1: "You hit 3×5 at 100 kg last time, so this is +2.5 kg."
void main() {
  const formatter = QuantityFormatter(prefs: UnitPreferences.metric);

  test('firstRun explains there is no history yet', () {
    const rationale = ProgressionRationale(
      outcome: ProgressionOutcome.firstRun,
    );
    expect(
      progressionRationaleText(rationale, formatter, MassUnit.kg, testL10n()),
      contains('No history'),
    );
  });

  test('success names the previous weight and the increment', () {
    const rationale = ProgressionRationale(
      outcome: ProgressionOutcome.success,
      previousWeightGrams: 100000,
      previousReps: 5,
      deltaGrams: 2500,
    );
    final text = progressionRationaleText(
      rationale,
      formatter,
      MassUnit.kg,
      testL10n(),
    );
    expect(text, contains('100 kg'));
    expect(text, contains('+2.5 kg'));
  });

  test('deload names the resulting weight and the streak length', () {
    const rationale = ProgressionRationale(
      outcome: ProgressionOutcome.deload,
      previousWeightGrams: 100000,
      deltaGrams: -10000,
      consecutiveFailures: 3,
    );
    final text = progressionRationaleText(
      rationale,
      formatter,
      MassUnit.kg,
      testL10n(),
    );
    expect(text, contains('3 sessions'));
    expect(text, contains('90 kg'));
  });

  test('failure below threshold repeats the same weight', () {
    const rationale = ProgressionRationale(
      outcome: ProgressionOutcome.failure,
      previousWeightGrams: 100000,
      consecutiveFailures: 1,
    );
    final text = progressionRationaleText(
      rationale,
      formatter,
      MassUnit.kg,
      testL10n(),
    );
    expect(text, contains('repeating the same weight'));
  });

  test('repRangeTopMet names the previous weight and the increment', () {
    const rationale = ProgressionRationale(
      outcome: ProgressionOutcome.repRangeTopMet,
      previousWeightGrams: 20000,
      previousReps: 12,
      targetReps: 8,
      deltaGrams: 2500,
    );
    final text = progressionRationaleText(
      rationale,
      formatter,
      MassUnit.kg,
      testL10n(),
    );
    expect(text, contains('20 kg'));
    expect(text, contains('+2.5 kg'));
  });

  test('manual carry-forward names what was actually carried forward', () {
    const rationale = ProgressionRationale(
      outcome: ProgressionOutcome.manualCarryForward,
      previousWeightGrams: 105000,
      previousReps: 5,
    );
    final text = progressionRationaleText(
      rationale,
      formatter,
      MassUnit.kg,
      testL10n(),
    );
    expect(text, contains('105 kg'));
  });
}
