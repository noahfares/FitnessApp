import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database_provider.dart';
import '../../../domain/analytics/analytics_set_record.dart';

/// Every counted-or-not set across the whole catalogue (`F-ANA-004`'s
/// muscle-group/overall volume, `F-ANA-005`'s sets-per-muscle-per-week).
///
/// One provider rather than per-screen queries — the Insights screen's
/// several charts all read the same underlying stream.
final analyticsSetRecordsProvider = StreamProvider<List<AnalyticsSetRecord>>(
  (ref) => ref.watch(setRepositoryProvider).watchAllAnalyticsSets(),
);
