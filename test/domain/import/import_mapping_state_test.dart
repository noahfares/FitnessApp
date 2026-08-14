import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/import/exercise_resolution.dart';
import 'package:fitness_app/domain/import/import_mapping_state.dart';

/// Batch 5.3 — `F-DAT-007`: "remembers decisions across a session so a
/// 400-row import isn't 400 prompts."
void main() {
  test('every unmatched name starts unresolved', () {
    const state = ImportMappingState();

    expect(state.unresolved(['Skullcrusher', 'Leg Press']), [
      'Skullcrusher',
      'Leg Press',
    ]);
    expect(state.isFullyResolved(['Skullcrusher']), isFalse);
  });

  test('resolving a name removes it from unresolved', () {
    const state = ImportMappingState();

    final resolved = state.resolve(
      'Skullcrusher',
      const ExerciseResolution.createCustom(),
    );

    expect(resolved.unresolved(['Skullcrusher', 'Leg Press']), ['Leg Press']);
  });

  test('a decision persists once made and can be overridden', () {
    const state = ImportMappingState();

    final first = state.resolve(
      'Skullcrusher',
      const ExerciseResolution.skip(),
    );
    final overridden = first.resolve(
      'Skullcrusher',
      const ExerciseResolution.useExisting('triceps-extension'),
    );

    expect(
      overridden.resolutions['Skullcrusher']!.kind,
      ExerciseResolutionKind.useExisting,
    );
    expect(
      overridden.resolutions['Skullcrusher']!.exerciseId,
      'triceps-extension',
    );
  });

  test('fully resolved once every unmatched name has a decision', () {
    const state = ImportMappingState();

    final resolved = state.resolve(
      'Skullcrusher',
      const ExerciseResolution.skip(),
    );

    expect(resolved.isFullyResolved(['Skullcrusher']), isTrue);
    expect(resolved.isFullyResolved(['Skullcrusher', 'Leg Press']), isFalse);
  });
}
