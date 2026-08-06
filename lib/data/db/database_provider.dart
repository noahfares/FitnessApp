import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/exercise_repository.dart';
import 'app_database.dart';

/// The single database instance.
///
/// Overridden in tests with an in-memory executor; features never construct
/// their own.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The only route features have to the exercise catalogue. Screens depend on
/// this, never on `AppDatabase` directly — that seam is what keeps them
/// testable and lets storage change without rewriting them
/// (docs/20-ARCHITECTURE.md).
final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(databaseProvider)),
);
