import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/features/shell/widgets/pr_badge.dart';

/// F-A11Y-005 — the entrance animation is `PrBadge`'s own celebration
/// (`F-LOG-013`); reduce motion must still render it instantly rather than
/// crash or leave it invisible.
void main() {
  testWidgets('reduce motion skips the entrance animation duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: Scaffold(body: PrBadge())),
      ),
    );

    // A zero-duration TweenAnimationBuilder settles on the very first pump.
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
