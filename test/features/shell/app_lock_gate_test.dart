import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/security/pin_hasher.dart';
import 'package:fitness_app/data/db/app_database.dart';

import '../../support/harness.dart';

/// Batch 5.4 — `F-SET-010`. The gate itself, not the settings screen that
/// configures it — `AppLockScreen`'s PIN prompts are plain dialogs, no new
/// interaction logic beyond what this widget already needs proven.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('no PIN configured — the app opens straight through', (
    tester,
  ) async {
    await pumpApp(tester, db: db);

    expect(find.text('Enter PIN'), findsNothing);
  });

  testWidgets('a configured PIN locks the app at launch', (tester) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash('1234', salt);

    await pumpApp(
      tester,
      db: db,
      prefs: {'security.pinSalt': salt, 'security.pinHash': hash},
    );

    expect(find.text('Enter PIN'), findsOneWidget);
  });

  testWidgets('the correct PIN unlocks the app', (tester) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash('1234', salt);

    await pumpApp(
      tester,
      db: db,
      prefs: {'security.pinSalt': salt, 'security.pinHash': hash},
    );

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Enter PIN'), findsNothing);
  });

  testWidgets('the wrong PIN stays locked and shows an error', (tester) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash('1234', salt);

    await pumpApp(
      tester,
      db: db,
      prefs: {'security.pinSalt': salt, 'security.pinHash': hash},
    );

    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Enter PIN'), findsOneWidget);
    expect(find.text('Wrong PIN'), findsOneWidget);
  });
}
