import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/widgets/rolling_number.dart';

/// `F-LOG-024` — the odometer-style roller used for the live volume cell.
///
/// Every digit 0-9 lives in the tree for a mid-roll column regardless of
/// where the animation currently sits (it's a clipped, translated strip), so
/// these tests key off `rolling-digit-strip` to tell "still rolling" from
/// "settled" rather than counting which glyphs are present.
void main() {
  const style = TextStyle(fontSize: 16);
  final rollingStrip = find.byKey(const ValueKey('rolling-digit-strip'));

  Future<void> pump(
    WidgetTester tester,
    int value, {
    bool reduceMotion = false,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        home: Scaffold(
          body: RollingNumber(value: value, style: style),
        ),
      ),
    ),
  );

  /// The settled digits read left to right, once nothing is still rolling.
  String settledDigits(WidgetTester tester) =>
      tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).join();

  testWidgets('renders the initial value with nothing to roll', (tester) async {
    await pump(tester, 200);
    await tester.pump();

    expect(rollingStrip, findsNothing);
    expect(settledDigits(tester), '200');
  });

  testWidgets('changing the value starts a roll on the differing digit only', (
    tester,
  ) async {
    await pump(tester, 200);
    await tester.pump();
    await pump(tester, 202);
    await tester.pump();

    // Only the ones place changed (0 -> 2); the hundreds and tens digits
    // never enter a rolling state.
    expect(rollingStrip, findsOneWidget);
  });

  testWidgets('the roll lands on the target and then settles', (tester) async {
    await pump(tester, 200);
    await tester.pump();
    await pump(tester, 202);
    await tester.pumpAndSettle();

    expect(rollingStrip, findsNothing);
    expect(settledDigits(tester), '202');
  });

  testWidgets('a digit count that grows fades the new leading digit in', (
    tester,
  ) async {
    await pump(tester, 9);
    await tester.pump();
    await pump(tester, 10);
    await tester.pumpAndSettle();

    // The new leading digit had no prior value to roll from, so it fades
    // rather than rolling through a strip.
    expect(rollingStrip, findsNothing);
    expect(settledDigits(tester), '10');
  });

  testWidgets('negative values show a static leading minus sign', (
    tester,
  ) async {
    await pump(tester, -5);
    await tester.pump();

    expect(find.text('-'), findsOneWidget);
    expect(settledDigits(tester), '-5');
  });

  testWidgets('under reduce motion the new value appears with no roll', (
    tester,
  ) async {
    await pump(tester, 200, reduceMotion: true);
    await tester.pump();
    await pump(tester, 202, reduceMotion: true);
    // No settle needed — reduce motion means arriving instantly, never a
    // rolling strip at all (`core/a11y/motion.dart`).
    await tester.pump();

    expect(rollingStrip, findsNothing);
    expect(settledDigits(tester), '202');
  });
}
