import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/app_theme.dart';

/// Contrast ratio per WCAG 2.x. Used to hold the design system to the 4.5:1
/// figure it claims (docs/24-DESIGN-SYSTEM.md, F-A11Y-003) rather than trusting
/// the palette by eye.
double contrastRatio(Color a, Color b) {
  double luminance(Color c) => c.computeLuminance();
  final l1 = luminance(a);
  final l2 = luminance(b);
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final light = AppTheme.light();
  final dark = AppTheme.dark();

  group('schemes', () {
    test('both are built and carry the right brightness', () {
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
    });

    test('both derive from the same seed', () {
      // One accent drives the whole app; changing the seed re-tints
      // everything. The Apple-style pass re-tints it to Apple's own light
      // `tint` (`AppColors.light.tint`).
      expect(AppTheme.seed, const Color(0xFF0071E3));
    });

    test('a dynamic scheme overrides the seed when given (F-THM-003)', () {
      const dynamicScheme = ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF00FF00),
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFF00AA00),
        onSecondary: Color(0xFF000000),
        error: Color(0xFFB00020),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
      );

      final themed = AppTheme.light(dynamicScheme: dynamicScheme);

      expect(themed.colorScheme.primary, dynamicScheme.primary);
      expect(themed.colorScheme.primary, isNot(light.colorScheme.primary));
    });

    test('AppColors semantic roles are unaffected by a dynamic scheme', () {
      // "pr and danger keep their meaning regardless of the wallpaper"
      // (F-THM-003 spec) — AppColors is a fixed ThemeExtension, never derived
      // from ColorScheme, so this holds by construction; the test pins it.
      const dynamicScheme = ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFFF00FF),
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFFAA00AA),
        onSecondary: Color(0xFF000000),
        error: Color(0xFFB00020),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
      );

      final themed = AppTheme.light(dynamicScheme: dynamicScheme);

      expect(
        themed.extension<AppColors>()!.pr,
        light.extension<AppColors>()!.pr,
      );
      expect(
        themed.extension<AppColors>()!.danger,
        light.extension<AppColors>()!.danger,
      );
    });

    test('dark mode avoids pure black', () {
      // OLED smearing during scroll hurts readability, and a set list is
      // scrolled constantly.
      expect(dark.scaffoldBackgroundColor, isNot(const Color(0xFF000000)));
      expect(dark.colorScheme.surface, isNot(const Color(0xFF000000)));
    });
  });

  group('semantic colours', () {
    test('the extension is registered on both themes', () {
      expect(light.extension<AppColors>(), isNotNull);
      expect(dark.extension<AppColors>(), isNotNull);
    });

    test('light and dark carry different palettes', () {
      // Dark is designed, not derived by inversion.
      expect(
        light.extension<AppColors>()!.ghost,
        isNot(dark.extension<AppColors>()!.ghost),
      );
    });

    test('foreground on each role meets 4.5:1', () {
      for (final entry in {
        'light': AppColors.light,
        'dark': AppColors.dark,
      }.entries) {
        final colors = entry.value;
        final pairs = {
          'success': (colors.success, colors.onSuccess),
          'pr': (colors.pr, colors.onPr),
          'warning': (colors.warning, colors.onWarning),
          'danger': (colors.danger, colors.onDanger),
        };
        pairs.forEach((name, pair) {
          expect(
            contrastRatio(pair.$1, pair.$2),
            greaterThanOrEqualTo(4.5),
            reason: '${entry.key} $name fails WCAG AA',
          );
        });
      }
    });

    test('ghost is legible against its surface but clearly secondary', () {
      // Too faint and it is invisible in gym lighting; too strong and it reads
      // as entered data (F-LOG-004).
      final lightRatio = contrastRatio(
        Color.alphaBlend(AppColors.light.ghost, light.colorScheme.surface),
        light.colorScheme.surface,
      );
      final darkRatio = contrastRatio(
        Color.alphaBlend(AppColors.dark.ghost, dark.colorScheme.surface),
        dark.colorScheme.surface,
      );

      for (final ratio in [lightRatio, darkRatio]) {
        expect(ratio, greaterThanOrEqualTo(3.0), reason: 'ghost too faint');
        expect(ratio, lessThan(12.0), reason: 'ghost reads as entered data');
      }
    });

    test('chart palettes have enough distinct series', () {
      for (final colors in [AppColors.light, AppColors.dark]) {
        expect(colors.chartSeries.length, greaterThanOrEqualTo(6));
        expect(colors.chartSeries.toSet().length, colors.chartSeries.length);
      }
    });

    test('lerp does not throw between the two palettes', () {
      expect(AppColors.light.lerp(AppColors.dark, 0.5), isA<AppColors>());
    });
  });

  group('typography', () {
    test('numeric styles use tabular figures', () {
      // A column of weights must line up vertically; proportional digits read
      // slowly and look wrong in a set list.
      for (final theme in [light, dark]) {
        for (final style in [
          theme.textTheme.bodyLarge, // set-row values
          theme.textTheme.displaySmall, // rest timer
        ]) {
          expect(
            style?.fontFeatures,
            contains(const FontFeature.tabularFigures()),
          );
        }
      }
    });

    test('non-numeric styles are left alone', () {
      expect(light.textTheme.bodySmall?.fontFeatures ?? const [], isEmpty);
    });
  });

  group('touch targets', () {
    test('buttons meet the 48dp minimum', () {
      final size = light.filledButtonTheme.style?.minimumSize?.resolve({});
      expect(size?.height, greaterThanOrEqualTo(48));
    });
  });
}
