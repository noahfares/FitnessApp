import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

/// Writing finished sessions to the platform health store, and reading
/// bodyweight back (`F-HLT-001`, `F-HLT-002`).
///
/// An interface in `data/platform/` for the same reason [RestTimerService] is
/// one: Health Connect and HealthKit are different enough that neither
/// platform's answer may leak into `features/` or `domain/`
/// (docs/20-ARCHITECTURE.md §cross-platform-discipline).
///
/// **Every method here is allowed to fail and must never throw.** A health
/// store that is missing, out of date, or has had its permission revoked is a
/// normal state, not an error — `F-HLT-001` §3 is explicit that a write
/// failure never blocks finishing a workout, because the local record is the
/// authoritative one and always was.
abstract interface class HealthService {
  /// Whether the platform has a health store this app can talk to at all.
  Future<bool> isAvailable();

  /// Asks for permission, in context — never at launch (`F-HLT-001` §2).
  ///
  /// False is a working state: nothing is written, and the app is otherwise
  /// unchanged.
  Future<bool> requestPermissions({required bool read});

  /// Whether permission is currently granted. Revocation happens outside the
  /// app, so this is asked rather than remembered.
  Future<bool> hasPermissions({required bool read});

  /// Writes one finished session as a strength-training workout.
  ///
  /// Deliberately no energy figure: `F-HLT-001`'s open question settles on
  /// omitting it, because a fabricated calorie number in someone's health
  /// record is worse than no number at all.
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    String? title,
  });

  /// Removes whatever this app wrote for that exact window (`F-HLT-001`
  /// acceptance: deleting locally offers to remove the health record too).
  Future<bool> deleteWorkout({required DateTime start, required DateTime end});

  /// Bodyweight entries between [from] and [to], newest first (`F-HLT-002`).
  Future<List<({DateTime measuredAt, int grams})>> readBodyweight({
    required DateTime from,
    required DateTime to,
  });
}

/// The real implementation, on top of the `health` plugin.
class PlatformHealthService implements HealthService {
  PlatformHealthService([Health? health]) : _health = health ?? Health();

  final Health _health;

  /// Exactly two types, and each for a stated reason: workouts are what this
  /// app produces, bodyweight is what it can usefully consume. Asking for more
  /// than is used is how a permission prompt stops being trustworthy.
  static const _writeTypes = [HealthDataType.WORKOUT];
  static const _readTypes = [HealthDataType.WEIGHT];

  List<HealthDataType> _types({required bool read}) => [
    ..._writeTypes,
    if (read) ..._readTypes,
  ];

  List<HealthDataAccess> _access({required bool read}) => [
    HealthDataAccess.WRITE,
    if (read) HealthDataAccess.READ,
  ];

  @override
  Future<bool> isAvailable() async {
    try {
      await _health.configure();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions({required bool read}) async {
    try {
      await _health.configure();
      return await _health.requestAuthorization(
        _types(read: read),
        permissions: _access(read: read),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPermissions({required bool read}) async {
    try {
      await _health.configure();
      return await _health.hasPermissions(
            _types(read: read),
            permissions: _access(read: read),
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    String? title,
  }) async {
    try {
      await _health.configure();
      return await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.STRENGTH_TRAINING,
        start: start,
        end: end,
        title: title,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteWorkout({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await _health.configure();
      return await _health.delete(
        type: HealthDataType.WORKOUT,
        startTime: start,
        endTime: end,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<({DateTime measuredAt, int grams})>> readBodyweight({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      await _health.configure();
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WEIGHT],
        startTime: from,
        endTime: to,
      );
      final entries = <({DateTime measuredAt, int grams})>[];
      for (final point in points) {
        final value = point.value;
        if (value is! NumericHealthValue) continue;
        // The plugin reports weight in kilograms; storage is grams
        // (docs/22-UNITS.md — canonical units, always).
        entries.add((
          measuredAt: point.dateFrom,
          grams: (value.numericValue.toDouble() * 1000).round(),
        ));
      }
      entries.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
      return entries;
    } catch (_) {
      return const [];
    }
  }
}

/// Does nothing, successfully.
///
/// The default in tests, and the honest implementation for any platform with
/// no health store. Every caller already treats "false" as a working state, so
/// nothing needs to know which one it has.
class NoopHealthService implements HealthService {
  const NoopHealthService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> requestPermissions({required bool read}) async => false;

  @override
  Future<bool> hasPermissions({required bool read}) async => false;

  @override
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    String? title,
  }) async => false;

  @override
  Future<bool> deleteWorkout({
    required DateTime start,
    required DateTime end,
  }) async => false;

  @override
  Future<List<({DateTime measuredAt, int grams})>> readBodyweight({
    required DateTime from,
    required DateTime to,
  }) async => const [];
}

final healthServiceProvider = Provider<HealthService>(
  (ref) => PlatformHealthService(),
);
