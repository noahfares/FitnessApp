/// Human-readable names for `MeasurementType` (`F-BOD-002`).
///
/// Display only, and deliberately not stored — same reasoning as
/// `exercise_labels.dart`.
library;

import '../../../data/db/tables/enums.dart';

extension MeasurementTypeLabel on MeasurementType {
  String get label => switch (this) {
    MeasurementType.bodyweight => 'Bodyweight',
    MeasurementType.waist => 'Waist',
    MeasurementType.chest => 'Chest',
    MeasurementType.hips => 'Hips',
    MeasurementType.neck => 'Neck',
    MeasurementType.leftArm => 'Left arm',
    MeasurementType.rightArm => 'Right arm',
    MeasurementType.leftThigh => 'Left thigh',
    MeasurementType.rightThigh => 'Right thigh',
    MeasurementType.leftCalf => 'Left calf',
    MeasurementType.rightCalf => 'Right calf',
    MeasurementType.shoulders => 'Shoulders',
    MeasurementType.bodyFatPercent => 'Body fat',
  };

  /// Whether this type is a circumference (`Length`, millimetres) or a
  /// percentage (basis points) — the only two shapes `F-BOD-002` covers
  /// beyond bodyweight itself, which is a `Mass` and handled separately.
  bool get isPercent => this == MeasurementType.bodyFatPercent;
}

/// Every type a user can opt into tracking (`F-BOD-002` §"users choose which
/// measurements to track") — every [MeasurementType] except bodyweight,
/// which has been always-on since `F-BOD-001`.
const List<MeasurementType> trackableMeasurementTypes = [
  MeasurementType.waist,
  MeasurementType.chest,
  MeasurementType.hips,
  MeasurementType.neck,
  MeasurementType.leftArm,
  MeasurementType.rightArm,
  MeasurementType.leftThigh,
  MeasurementType.rightThigh,
  MeasurementType.leftCalf,
  MeasurementType.rightCalf,
  MeasurementType.shoulders,
  MeasurementType.bodyFatPercent,
];
