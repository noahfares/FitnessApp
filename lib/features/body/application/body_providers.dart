import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';

/// Every bodyweight entry, most recent first (`F-BOD-001`).
final bodyweightHistoryProvider = StreamProvider<List<BodyMeasurement>>(
  (ref) =>
      ref.watch(bodyMeasurementRepositoryProvider).watchBodyweightHistory(),
);

/// The most recent entry, for the dashboard's quick-entry card.
final latestBodyweightProvider = StreamProvider<BodyMeasurement?>(
  (ref) => ref.watch(bodyMeasurementRepositoryProvider).watchLatestBodyweight(),
);
