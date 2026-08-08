import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database_provider.dart';
import '../../../data/repositories/personal_record_repository.dart';

/// Every personal record, newest first (`F-ANA-007`).
final prTimelineProvider = StreamProvider<List<PrTimelineEntry>>(
  (ref) => ref.watch(personalRecordRepositoryProvider).watchTimeline(),
);
