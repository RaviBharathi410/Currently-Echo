import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/theme/app_typography.dart';
import 'package:echo/core/theme/app_spacing.dart';

double calculateLuminance(Color color) {
  double channel(double value) {
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  final argb = color.toARGB32();
  final r = channel(((argb >> 16) & 0xFF) / 255.0);
  final g = channel(((argb >> 8) & 0xFF) / 255.0);
  final b = channel((argb & 0xFF) / 255.0);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color c1, Color c2) {
  final l1 = calculateLuminance(c1);
  final l2 = calculateLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('ECHO Strict Design Token Enforcement', () {
    test('Print computed luminance and contrast values for documentation', () {
      final tokens = {
        'white': AppColors.white,
        'surface': AppColors.surface,
        'surfaceSubtle': AppColors.surfaceSubtle,
        'blue100': AppColors.blue100,
        'blue200': AppColors.blue200,
        'blue300': AppColors.blue300,
        'blue400': AppColors.blue400,
        'blue500': AppColors.blue500,
        'textPrimary': AppColors.textPrimary,
        'textSecondary': AppColors.textSecondary,
        'textDisabled': AppColors.textDisabled,
        'border': AppColors.border,
      };

      for (final entry in tokens.entries) {
        final lum = calculateLuminance(entry.value);
        final vsWhite = contrastRatio(entry.value, AppColors.white);
        final vsSurface = contrastRatio(entry.value, AppColors.surface);
        debugPrint(
            'TOKEN_METRIC: ${entry.key} | Lum: ${lum.toStringAsFixed(4)} | vsWhite: ${vsWhite.toStringAsFixed(2)}:1 | vsSurface: ${vsSurface.toStringAsFixed(2)}:1');
      }

      final blue500OnBlue100 = contrastRatio(AppColors.blue500, AppColors.blue100);
      debugPrint('TOKEN_METRIC: blue500 on blue100 | Contrast: ${blue500OnBlue100.toStringAsFixed(2)}:1');
    });

    test('All AppColors must strictly belong to the light-blue and white family', () {
      final allowedColors = <Color>[
        AppColors.white,
        AppColors.surface,
        AppColors.surfaceSubtle,
        AppColors.blue100,
        AppColors.blue200,
        AppColors.blue300,
        AppColors.blue400,
        AppColors.blue500,
        AppColors.textPrimary,
        AppColors.textSecondary,
        AppColors.textDisabled,
        AppColors.border,
        AppColors.borderFunctional,
        AppColors.borderFocused,
        AppColors.focusRing,
        AppColors.splashOverlay,
        AppColors.highlightOverlay,
        AppColors.transparent,
        AppColors.backdropTintA,
        AppColors.backdropTintB,
        AppColors.backdropTintCenter,
        AppColors.backdropFade,
        AppColors.backdropWave,
        AppColors.splashGhostTop1,
        AppColors.splashGhostTop2,
        AppColors.splashGhostTop3,
        AppColors.splashGhostBottom1,
        AppColors.splashGhostBottom2,
        AppColors.splashGhostBottom3,
      ];

      for (final color in allowedColors) {
        final hsl = HSLColor.fromColor(color);
        if (hsl.saturation > 0.05) {
          expect(
            hsl.hue >= 195.0 && hsl.hue <= 225.0,
            isTrue,
            reason: 'Color $color violates monochromatic blue restriction with hue ${hsl.hue}°',
          );
        }
      }
    });

    test('Algorithmic WCAG Contrast Ratio Verification for real UI pairs', () {
      // 1. Text Primary on backgrounds (must exceed 7:1 for AAA)
      final textPrimaryWhite = contrastRatio(AppColors.textPrimary, AppColors.white);
      expect(textPrimaryWhite >= 7.0, isTrue,
          reason: 'textPrimary on white must be >= 7.0 (Actual: $textPrimaryWhite)');

      final textPrimarySurface = contrastRatio(AppColors.textPrimary, AppColors.surface);
      expect(textPrimarySurface >= 7.0, isTrue,
          reason: 'textPrimary on surface must be >= 7.0 (Actual: $textPrimarySurface)');

      // 2. Text Secondary on backgrounds (must exceed 4.5:1 for AA)
      final textSecondaryWhite = contrastRatio(AppColors.textSecondary, AppColors.white);
      expect(textSecondaryWhite >= 4.5, isTrue,
          reason: 'textSecondary on white must be >= 4.5 (Actual: $textSecondaryWhite)');

      final textSecondarySurface = contrastRatio(AppColors.textSecondary, AppColors.surface);
      expect(textSecondarySurface >= 4.5, isTrue,
          reason: 'textSecondary on surface must be >= 4.5 (Actual: $textSecondarySurface)');

      // 3. Primary button: White text on blue500 (must exceed 4.5:1 for AA)
      final whiteOnBlue500 = contrastRatio(AppColors.white, AppColors.blue500);
      expect(whiteOnBlue500 >= 4.5, isTrue,
          reason: 'white on blue500 must be >= 4.5 (Actual: $whiteOnBlue500)');

      // 4. Secondary button & Active nav: blue500 on blue100 (must exceed 4.5:1 for AA)
      final blue500OnBlue100 = contrastRatio(AppColors.blue500, AppColors.blue100);
      expect(blue500OnBlue100 >= 4.5, isTrue,
          reason: 'blue500 on blue100 must be >= 4.5 (Actual: $blue500OnBlue100)');

      // 5. Functional borders: blue400 on white & surface (must exceed 3.0:1 for WCAG 1.4.11)
      final blue400White = contrastRatio(AppColors.blue400, AppColors.white);
      expect(blue400White >= 3.0, isTrue,
          reason: 'blue400 on white must be >= 3.0 for WCAG 1.4.11 (Actual: $blue400White)');

      final blue400Surface = contrastRatio(AppColors.blue400, AppColors.surface);
      expect(blue400Surface >= 3.0, isTrue,
          reason: 'blue400 on surface must be >= 3.0 for WCAG 1.4.11 (Actual: $blue400Surface)');
    });

    test('All TextTheme styles must strictly use PlusJakartaSans with letterSpacing 0', () {
      final textTheme = AppTypography.createTextTheme();
      final styles = [
        textTheme.displayLarge,
        textTheme.titleLarge,
        textTheme.titleMedium,
        textTheme.titleSmall,
        textTheme.bodyLarge,
        textTheme.bodyMedium,
        textTheme.labelLarge,
        textTheme.labelMedium,
        textTheme.bodySmall,
      ];

      for (final style in styles) {
        expect(style, isNotNull);
        expect(style!.fontFamily, equals('PlusJakartaSans'));
        expect(style.letterSpacing, equals(0.0));
      }
    });

    test('Usage-based semantic styles strictly use PlusJakartaSans and appropriate bold weights (ADR-010)', () {
      final semanticStyles = [
        AppTypography.statDisplay,
        AppTypography.statLabel,
        AppTypography.cardTitle,
        AppTypography.sectionHeader,
        AppTypography.labelBold,
        AppTypography.bodyMediumBold,
        AppTypography.captionBold,
      ];

      for (final style in semanticStyles) {
        expect(style.fontFamily, equals('PlusJakartaSans'), reason: 'All typography styles must use PlusJakartaSans');
        expect(style.fontWeight!.value >= FontWeight.w600.value, isTrue,
            reason: 'Usage-based bold styles must be at least SemiBold w600');
      }

      // Check statDisplay tracking
      expect(AppTypography.statDisplay.letterSpacing, equals(-0.5));
      expect(AppTypography.statDisplay.fontWeight, equals(FontWeight.w700));
    });

    test('AppSpacing defines p6 = 6.0 alongside 4/8dp grid', () {
      expect(AppSpacing.p6, equals(6.0));
      expect(AppSpacing.p4, equals(4.0));
      expect(AppSpacing.p8, equals(8.0));
      expect(AppSpacing.p12, equals(12.0));
      expect(AppSpacing.p16, equals(16.0));
    });
  });
}
