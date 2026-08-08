import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/features/shell/presentation/dashboard_screen.dart';

import '../../support/harness.dart';

/// `F-ROU-012` §"today: Push".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  // A fixed Wednesday (ISO weekday 3).
  final wednesday = DateTime(2026, 8, 5);

  testWidgets('shows a card for a day scheduled today', (tester) async {
    final repo = RoutineRepository(db);
    final routine = await repo.create(name: 'Push Pull Legs');
    final day = await repo.addDay(routine.id, name: 'Push');
    await repo.setScheduledWeekdays(day.id, [3]);

    await pumpScreen(tester, const DashboardScreen(), db: db, now: wednesday);

    expect(find.text('Today: Push'), findsOneWidget);
    expect(find.text('Push Pull Legs'), findsOneWidget);
  });

  testWidgets('shows nothing when no day is scheduled today', (tester) async {
    final repo = RoutineRepository(db);
    final routine = await repo.create(name: 'Push Pull Legs');
    final day = await repo.addDay(routine.id, name: 'Push');
    // Scheduled for Monday, not the pinned Wednesday.
    await repo.setScheduledWeekdays(day.id, [1]);

    await pumpScreen(tester, const DashboardScreen(), db: db, now: wednesday);

    expect(find.textContaining('Today:'), findsNothing);
  });
}
