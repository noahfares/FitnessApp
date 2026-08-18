import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/routines/rotation.dart';

/// `F-ROU-012`'s open question — fixed weekdays *or* a rolling rotation —
/// answered as both, with the rotation derived rather than stored.
void main() {
  const days = ['a', 'b', 'c'];

  test('the first day is next when nothing has been trained yet', () {
    expect(nextRotationDayId(orderedDayIds: days), 'a');
  });

  test('the day after the last one trained', () {
    expect(nextRotationDayId(orderedDayIds: days, lastTrainedDayId: 'a'), 'b');
    expect(nextRotationDayId(orderedDayIds: days, lastTrainedDayId: 'b'), 'c');
  });

  test('it wraps, because that is what a rotation is', () {
    expect(nextRotationDayId(orderedDayIds: days, lastTrainedDayId: 'c'), 'a');
  });

  test('a day deleted since it was trained restarts the rotation visibly', () {
    // Guessing which neighbour the deleted day sat between would be a silent
    // decision about someone's programme.
    expect(
      nextRotationDayId(orderedDayIds: days, lastTrainedDayId: 'gone'),
      'a',
    );
  });

  test('a routine with no days has no next day', () {
    expect(nextRotationDayId(orderedDayIds: const []), isNull);
  });

  test('position is 1-based, for reading out as "day 2 of 3"', () {
    expect(rotationPosition(orderedDayIds: days, dayId: 'b'), (
      position: 2,
      total: 3,
    ));
    expect(rotationPosition(orderedDayIds: days, dayId: 'gone'), isNull);
  });
}
