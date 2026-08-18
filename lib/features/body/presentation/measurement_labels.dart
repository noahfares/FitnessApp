/// Human-readable names for `MeasurementType` (`F-BOD-002`).
///
/// Display only, and deliberately not stored — same reasoning as
/// `exercise_labels.dart`.
library;

import '../../../data/db/tables/enums.dart';
import '../../../l10n/app_localizations.dart';

extension MeasurementTypeLabel on MeasurementType {
  String label(AppLocalizations l10n) => switch (this) {
    MeasurementType.bodyweight => l10n.measurementBodyweight,
    MeasurementType.waist => l10n.measurementWaist,
    MeasurementType.chest => l10n.measurementChest,
    MeasurementType.hips => l10n.measurementHips,
    MeasurementType.neck => l10n.measurementNeck,
    MeasurementType.leftArm => l10n.measurementLeftArm,
    MeasurementType.rightArm => l10n.measurementRightArm,
    MeasurementType.leftThigh => l10n.measurementLeftThigh,
    MeasurementType.rightThigh => l10n.measurementRightThigh,
    MeasurementType.leftCalf => l10n.measurementLeftCalf,
    MeasurementType.rightCalf => l10n.measurementRightCalf,
    MeasurementType.shoulders => l10n.measurementShoulders,
    MeasurementType.bodyFatPercent => l10n.measurementBodyFatPercent,
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
