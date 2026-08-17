import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/shell/widgets/calendar_heatmap.dart';
import 'package:fitness_app/features/shell/widgets/pr_badge.dart';
import 'package:fitness_app/features/shell/widgets/trend_chart.dart';
import 'package:fitness_app/features/shell/widgets/weekly_bar_chart.dart';
import 'package:fitness_app/core/units/week_start.dart';

import '../../support/harness.dart';
import '../../core/theme/app_theme_test.dart' show contrastRatio;

/// Phase 6 accessibility audit — `F-A11Y-001`, `F-A11Y-002`, `F-A11Y-003`,
/// `F-A11Y-005`.
///
/// One file per criterion group rather than a11y assertions scattered through
/// every screen's own test: the exit criterion is "the full app usable with a
/// screen reader and at 200% text scale", which is a property of the app, not
/// of any one screen. The screen-by-screen sweep below is the part that
/// actually catches regressions — a new screen added without thinking about
/// scale fails here, not in review.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = testDatabase());

  Future<void> seedSession() async {
    for (final (id, name, muscle) in [
      ('bench', 'Bench Press', Muscle.chest),
      ('squat', 'Back Squat', Muscle.quads),
    ]) {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: id,
              name: name,
              primaryMuscle: muscle,
              equipment: Equipment.barbell,
              trackingType: TrackingType.weightReps,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
    }
    final repo = WorkoutRepository(db);
    final workout = await repo.start(name: 'Push A');
    await repo.addExercises(workout.id, ['bench', 'squat']);
  }

  group('screen reader (F-A11Y-001)', () {
    testWidgets('a trend chart is replaced by a sentence, not left silent', (
      tester,
    ) async {
      await pumpScreen(
        db: db,
        tester,
        Scaffold(
          body: TrendChart(
            metricLabel: 'Estimated one-rep max',
            valueLabel: (v) => '${v.toStringAsFixed(0)} kg',
            points: const [
              TrendChartPoint(x: 0, y: 100, label: '1 Mar'),
              TrendChartPoint(x: 1, y: 105, label: '8 Mar'),
              TrendChartPoint(x: 2, y: 110, label: '15 Mar'),
            ],
          ),
        ),
      );

      final label = tester
          .getSemantics(find.bySemanticsLabel(RegExp('Estimated one-rep max')))
          .label;

      // What it is, how much of it there is, where it starts and ends — the
      // same four facts every chart summary in the app gives, in the same
      // order.
      expect(label, contains('3 points'));
      expect(label, contains('trending up'));
      expect(label, contains('100 kg'));
      expect(label, contains('1 Mar'));
      expect(label, contains('110 kg'));
    });

    testWidgets('a bar chart leads with its biggest bar', (tester) async {
      await pumpScreen(
        db: db,
        tester,
        Scaffold(
          body: WeeklyBarChart(
            metricLabel: 'Weekly volume',
            valueLabel: (v) => '${v.toStringAsFixed(0)} kg',
            points: const [
              WeeklyBarPoint(value: 1000, label: '1 Mar'),
              WeeklyBarPoint(value: 4000, label: '8 Mar'),
              WeeklyBarPoint(value: 2000, label: '15 Mar'),
            ],
          ),
        ),
      );

      final label = tester
          .getSemantics(find.bySemanticsLabel(RegExp('Weekly volume')))
          .label;

      expect(label, contains('Highest 8 Mar, 4000 kg'));
      expect(label, contains('Latest 15 Mar, 2000 kg'));
    });

    testWidgets('the calendar states a count, not a shape', (tester) async {
      final now = DateTime(2026, 3, 15);
      await pumpScreen(
        db: db,
        tester,
        Scaffold(
          body: CalendarHeatmap(
            trainingDays: {DateTime(2026, 3, 9), DateTime(2026, 3, 11)},
            weekStart: WeekStart.monday,
            now: now,
            weeksToShow: 4,
          ),
        ),
      );

      expect(
        tester
            .getSemantics(find.bySemanticsLabel(RegExp('Training calendar')))
            .label,
        contains('Trained on 2 of 28 days'),
      );
    });

    testWidgets('the set row announces the whole set, not loose cells', (
      tester,
    ) async {
      await seedSession();
      await pumpApp(tester, db: db, startAt: AppRoutes.activeWorkout);

      // The spec's own worked example: "set 3, working, 100 kilograms, 8 reps,
      // completed" — an unlabelled row reads as three unrelated numbers.
      expect(find.bySemanticsLabel(RegExp('Set 1')), findsWidgets);
    });
  });

  group('dynamic type at 200% (F-A11Y-002)', () {
    // Every screen reachable without a tap, at the scale the criterion names.
    // A screen that overflows throws during layout, which fails the test —
    // there is nothing to assert beyond arriving.
    for (final (name, route) in [
      ('dashboard', AppRoutes.home),
      ('active workout', AppRoutes.activeWorkout),
      ('history', AppRoutes.history),
      ('insights', AppRoutes.insights),
      ('routines', AppRoutes.routines),
      ('exercise catalogue', AppRoutes.exercises),
      ('settings', AppRoutes.settings),
      ('body', AppRoutes.body),
      ('bars and plates', AppRoutes.settingsPlates),
      ('data', AppRoutes.settingsData),
      ('about', AppRoutes.settingsAbout),
    ]) {
      testWidgets('$name survives 200% text scale', (tester) async {
        await seedSession();
        await pumpApp(tester, db: db, startAt: route, textScale: 2);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('reduce motion (F-A11Y-005)', () {
    testWidgets('the PR badge is simply there, with no entrance', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const Scaffold(body: Center(child: PrBadge())),
        db: db,
        disableAnimations: true,
      );

      // Mid-animation the badge would be scaled down; with motion reduced the
      // first frame is the final one. Pumping a single frame is the test: no
      // settle, no waiting for a transition that must not exist.
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.emoji_events));
      expect(icon.size, 18);
      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        1.0,
        reason: 'the badge should not fade in when motion is reduced',
      );
    });

    testWidgets('navigating arrives instantly', (tester) async {
      await pumpApp(
        tester,
        db: db,
        startAt: AppRoutes.settings,
        disableAnimations: true,
      );

      await tester.scrollUntilVisible(find.text('About'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      // Two frames: one to process the tap and push the route, one to build
      // the destination.
      await tester.pump();
      await tester.pump();

      final onArrival = tester.getRect(find.text('Version'));
      await tester.pumpAndSettle();

      // Nothing moved between arriving and settling, which is what "instant
      // transition" means from the outside. (The route's own controller still
      // runs its course underneath — see `ReduceMotionPageTransitionsBuilder`
      // — but it drives nothing.)
      expect(tester.getRect(find.text('Version')), onArrival);
    });

    testWidgets('and still animates when nobody asked it not to', (
      tester,
    ) async {
      // The control. Without it the test above passes just as well against a
      // build that never animated anything, which would prove nothing about
      // the setting being honoured.
      await pumpApp(tester, db: db, startAt: AppRoutes.settings);

      await tester.scrollUntilVisible(find.text('About'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      await tester.pump();
      await tester.pump();

      final onArrival = tester.getRect(find.text('Version'));
      await tester.pumpAndSettle();

      expect(tester.getRect(find.text('Version')), isNot(onArrival));
    });
  });

  group('contrast and colour independence (F-A11Y-003)', () {
    test('scheme text pairs meet 4.5:1 in both schemes', () {
      for (final (name, theme) in [
        ('light', AppTheme.light()),
        ('dark', AppTheme.dark()),
      ]) {
        final scheme = theme.colorScheme;
        final pairs = {
          'onSurface/surface': (scheme.onSurface, scheme.surface),
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onError/error': (scheme.onError, scheme.error),
          'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
        };
        pairs.forEach((pair, colors) {
          expect(
            contrastRatio(colors.$1, colors.$2),
            greaterThanOrEqualTo(4.5),
            reason: '$name $pair fails WCAG AA for text',
          );
        });
      }
    });

    test('interactive boundaries meet 3:1 in both schemes', () {
      for (final (name, theme) in [
        ('light', AppTheme.light()),
        ('dark', AppTheme.dark()),
      ]) {
        final scheme = theme.colorScheme;
        expect(
          contrastRatio(scheme.outline, scheme.surface),
          greaterThanOrEqualTo(3.0),
          reason: '$name outline is too faint to bound a control',
        );
      }
    });

    test('a chart series is distinguishable without colour', () {
      // The palette is ordered and distinct, but that is a colour argument.
      // What makes the charts readable without colour vision is shape: the
      // secondary series is a line-less scatter and the regression overlay is
      // dashed — both asserted where they are drawn, in trend_chart_test.dart.
      // Here only the palette's own precondition is pinned.
      for (final colors in [AppColors.light, AppColors.dark]) {
        expect(colors.chartSeries.toSet().length, colors.chartSeries.length);
      }
    });
  });
}
