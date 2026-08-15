import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

/// One bodyweight reading read back from Health Connect (`F-HLT-002`).
///
/// [id] is the reading's own UUID — stored as
/// `body_measurements.health_connect_record_id` so the same reading is never
/// imported twice, and so an imported row can be told apart from one the
/// user typed in by hand (`domain/health/health_connect_import.dart`'s
/// conflict rule reads exactly that distinction).
class HealthConnectWeightReading {
  const HealthConnectWeightReading({
    required this.id,
    required this.grams,
    required this.measuredAt,
  });

  final String id;
  final int grams;
  final DateTime measuredAt;
}

/// Writing completed workouts to, and reading bodyweight from, Health
/// Connect (`F-HLT-001`, `F-HLT-002`).
///
/// An interface in `data/platform/` rather than a plugin call from a widget
/// or a repository, per docs/20-ARCHITECTURE.md#cross-platform-discipline —
/// no Android-only package is called directly from `features/` or `domain/`.
///
/// **Android only.** Health Connect has no iOS equivalent; the closest
/// analogue there is Apple HealthKit, which the `health` package this
/// implementation wraps also supports, but no `IosHealthKitService` exists
/// yet — this app is Android-only for now (`10-VISION.md`), and building an
/// iOS implementation against a store this session cannot submit to or
/// verify on real hardware would be exactly the kind of unverified platform
/// work this codebase has consistently deferred elsewhere (`F-TIM-003`,
/// `F-THM-006`). [isAvailable] returning `false` on any platform without a
/// working implementation is the documented gap, not a bug.
abstract interface class HealthConnectService {
  /// Whether Health Connect itself is installed and usable on this device.
  /// False here means every other method is a safe no-op — callers never
  /// need their own platform check.
  Future<bool> isAvailable();

  /// Whether the app currently holds the permissions it needs (write
  /// exercise sessions, read weight). Re-checked before every write and
  /// read rather than cached, since revocation happens entirely outside the
  /// app, in Health Connect's own settings (`F-HLT-001` acceptance:
  /// "revoking permission degrades gracefully").
  Future<bool> hasPermissions();

  /// Asks for exactly the two permissions this app uses — never a broader
  /// set "for later". Returns whether they were granted.
  Future<bool> requestPermissions();

  /// Revokes every permission this app holds in Health Connect — the
  /// explicit in-app path for "revocable" (`F-HLT-001` spec §2), on top of
  /// the settings toggle that stops the app from ever asking again.
  Future<void> revokePermissions();

  /// Writes [start]–[end] as a strength-training session (`F-HLT-001` §1).
  ///
  /// Deliberately carries no energy-expenditure figure — a resistance
  /// session's calorie burn is a guess, and the feature's own open question
  /// says a fabricated number is worse than none (`F-HLT-001`).
  ///
  /// Returns whether the write succeeded. A failure here must never block
  /// finishing a workout (`F-HLT-001` §3) — callers are expected to catch
  /// their own errors around this call and treat it as best-effort.
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    required String title,
  });

  /// Removes whatever strength-training session occupies exactly
  /// [start]–[end] — the same window [writeWorkout] was called with, since
  /// that pair is the only identifier this API gives back (`writeWorkout`
  /// returns success/failure, never the written record's own id).
  Future<void> deleteWorkout({required DateTime start, required DateTime end});

  /// Every weight reading Health Connect has from [since] onward.
  Future<List<HealthConnectWeightReading>> readWeightReadings({
    required DateTime since,
  });
}

class AndroidHealthConnectService implements HealthConnectService {
  AndroidHealthConnectService() : _health = Health() {
    // Resolves the device id used to tag written records — every other
    // method here works without it, so this is fire-and-forget rather than
    // something callers need to wait on.
    unawaited(_health.configure());
  }

  final Health _health;

  static const _types = [HealthDataType.WORKOUT];
  static const _writePermissions = [HealthDataAccess.WRITE];
  static const _readTypes = [HealthDataType.WEIGHT];
  static const _readPermissions = [HealthDataAccess.READ];

  @override
  Future<bool> isAvailable() => _health.isHealthConnectAvailable();

  @override
  Future<bool> hasPermissions() async {
    final workout = await _health.hasPermissions(
      _types,
      permissions: _writePermissions,
    );
    final weight = await _health.hasPermissions(
      _readTypes,
      permissions: _readPermissions,
    );
    return (workout ?? false) && (weight ?? false);
  }

  @override
  Future<bool> requestPermissions() async {
    final workout = await _health.requestAuthorization(
      _types,
      permissions: _writePermissions,
    );
    final weight = await _health.requestAuthorization(
      _readTypes,
      permissions: _readPermissions,
    );
    return workout && weight;
  }

  @override
  Future<void> revokePermissions() => _health.revokePermissions();

  @override
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    required String title,
  }) {
    return _health.writeWorkoutData(
      activityType: HealthWorkoutActivityType.STRENGTH_TRAINING,
      start: start,
      end: end,
      title: title,
    );
  }

  @override
  Future<void> deleteWorkout({required DateTime start, required DateTime end}) {
    return _health.delete(
      type: HealthDataType.WORKOUT,
      startTime: start,
      endTime: end,
    );
  }

  @override
  Future<List<HealthConnectWeightReading>> readWeightReadings({
    required DateTime since,
  }) async {
    final points = await _health.getHealthDataFromTypes(
      types: _readTypes,
      startTime: since,
      endTime: DateTime.now(),
      preferredUnits: {HealthDataType.WEIGHT: HealthDataUnit.KILOGRAM},
    );
    return [
      for (final point in points)
        if (point.value case final NumericHealthValue value)
          HealthConnectWeightReading(
            id: point.uuid,
            grams: (value.numericValue * 1000).round(),
            measuredAt: point.dateFrom,
          ),
    ];
  }
}

/// The documented iOS/desktop/web gap, made concrete rather than left as a
/// null check every call site would otherwise need to repeat: every method
/// is a safe no-op, and [isAvailable] is always false, exactly what the
/// interface's own contract promises for a platform with no working
/// implementation.
class UnsupportedHealthConnectService implements HealthConnectService {
  const UnsupportedHealthConnectService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> hasPermissions() async => false;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<void> revokePermissions() async {}

  @override
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    required String title,
  }) async => false;

  @override
  Future<void> deleteWorkout({
    required DateTime start,
    required DateTime end,
  }) async {}

  @override
  Future<List<HealthConnectWeightReading>> readWeightReadings({
    required DateTime since,
  }) async => const [];
}

/// Never constructs the real, platform-channel-backed implementation off
/// Android — the `health` plugin has no Windows/web native side registered,
/// so calling into it there would throw `MissingPluginException` on the
/// first real use instead of degrading the way [UnsupportedHealthConnectService]
/// does.
final healthConnectServiceProvider = Provider<HealthConnectService>(
  (ref) => Platform.isAndroid
      ? AndroidHealthConnectService()
      : const UnsupportedHealthConnectService(),
);
