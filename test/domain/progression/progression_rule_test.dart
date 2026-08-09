import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/progression/progression_rule.dart';

void main() {
  test('null stored value falls back to manual carry-forward', () {
    final rule = ProgressionRule.fromJson(null);
    expect(rule, isA<ManualCarryForwardRule>());
  });

  test('an unrecognised stored type falls back to manual carry-forward', () {
    final rule = ProgressionRule.fromJson('{"type": "somethingFuture"}');
    expect(rule, isA<ManualCarryForwardRule>());
  });

  test('manual carry-forward round-trips through JSON', () {
    const rule = ManualCarryForwardRule();
    final decoded = ProgressionRule.fromJson(rule.toJson());
    expect(decoded, isA<ManualCarryForwardRule>());
  });

  test('linear progression round-trips its config through JSON', () {
    const rule = LinearProgressionRule(
      config: LinearProgressionConfig(
        incrementGrams: 5000,
        failureThreshold: 2,
        deloadFraction: 0.15,
      ),
    );
    final decoded = ProgressionRule.fromJson(rule.toJson());
    expect(decoded, isA<LinearProgressionRule>());
    final config = (decoded as LinearProgressionRule).config;
    expect(config.incrementGrams, 5000);
    expect(config.failureThreshold, 2);
    expect(config.deloadFraction, 0.15);
  });

  test('linear progression defaults the failure threshold and deload '
      'fraction when omitted from stored JSON', () {
    final decoded = ProgressionRule.fromJson(
      '{"type": "linear", "incrementGrams": 2500}',
    );
    final config = (decoded as LinearProgressionRule).config;
    expect(config.failureThreshold, 3);
    expect(config.deloadFraction, 0.10);
  });

  test('double progression round-trips its config through JSON', () {
    const rule = DoubleProgressionRule(
      config: DoubleProgressionConfig(
        incrementGrams: 2500,
        floorMissThreshold: 2,
        deloadFraction: 0.15,
      ),
    );
    final decoded = ProgressionRule.fromJson(rule.toJson());
    expect(decoded, isA<DoubleProgressionRule>());
    final config = (decoded as DoubleProgressionRule).config;
    expect(config.incrementGrams, 2500);
    expect(config.floorMissThreshold, 2);
    expect(config.deloadFraction, 0.15);
  });

  test('double progression defaults the floor-miss threshold and deload '
      'fraction when omitted from stored JSON', () {
    final decoded = ProgressionRule.fromJson(
      '{"type": "doubleProgression", "incrementGrams": 2500}',
    );
    final config = (decoded as DoubleProgressionRule).config;
    expect(config.floorMissThreshold, 3);
    expect(config.deloadFraction, 0.10);
  });
}
