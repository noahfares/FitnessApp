import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_router.dart';
import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';

import '../../support/harness.dart';

/// Batch 2.2 — folders and archive/restore on the routine list
/// (`F-ROU-007`, `F-ROU-009`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<ProviderContainer> openRoutines(WidgetTester tester) async {
    final container = await pumpApp(tester, db: db);
    container.read(routerProvider).go(AppRoutes.routines);
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> saveDialog(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).last, text);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
  }

  Future<void> createRoutine(WidgetTester tester, String name) async {
    await tester.tap(find.byTooltip('New routine'));
    await tester.pumpAndSettle();
    await saveDialog(tester, name);
    // Back to the list.
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  testWidgets('a routine moved into a folder is grouped under it', (
    tester,
  ) async {
    await openRoutines(tester);
    await createRoutine(tester, 'PPL');

    await tester.tap(find.byTooltip('New folder'));
    await tester.pumpAndSettle();
    await saveDialog(tester, 'Current block');

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Current block'));
    await tester.pumpAndSettle();

    expect(find.text('Current block'), findsOneWidget);
    expect(find.text('PPL'), findsOneWidget);
  });

  testWidgets('archiving hides a routine, the archive list restores it', (
    tester,
  ) async {
    await openRoutines(tester);
    await createRoutine(tester, 'Old block');

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Old block'), findsNothing);

    await tester.tap(find.byTooltip('Archived routines'));
    await tester.pumpAndSettle();

    expect(find.text('Old block'), findsOneWidget);
    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Old block'), findsNothing);

    await tester.tap(find.byTooltip('Active routines'));
    await tester.pumpAndSettle();

    expect(find.text('Old block'), findsOneWidget);
  });
}
