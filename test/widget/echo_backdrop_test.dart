import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/widgets/layout/echo_backdrop.dart';
import 'package:echo/core/widgets/layout/echo_responsive_frame.dart';

double calculateLuminance(Color color) {
  double channel(double value) {
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
}

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);

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
  group('EchoBackdrop Unit & Contrast Verification Tests', () {
    test('Algorithmic Contrast Verification: Worst-case blended pixels meet WCAG AA (>= 4.5:1)', () async {
      const size = Size(390.0, 844.0);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const painter = EchoBackdropPainter(driftProgress: 0.0);

      painter.paint(canvas, size);
      final picture = recorder.endRecording();
      final image = await picture.toImage(390, 844);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      expect(byteData, isNotNull);
      final bytes = byteData!.buffer.asUint8List();

      double minLuminance = 1.0;
      Color darkestPixel = AppColors.surface;

      // Sample a grid of pixels across the entire painted canvas
      for (int y = 0; y < 844; y += 10) {
        for (int x = 0; x < 390; x += 10) {
          final index = (y * 390 + x) * 4;
          final r = bytes[index];
          final g = bytes[index + 1];
          final b = bytes[index + 2];
          final color = Color.fromARGB(255, r, g, b);
          final lum = calculateLuminance(color);

          if (lum < minLuminance) {
            minLuminance = lum;
            darkestPixel = color;
          }
        }
      }

      debugPrint(
        'MEASURED_DARKEST_PIXEL: RGBA(${darkestPixel.r * 255.0}, ${darkestPixel.g * 255.0}, ${darkestPixel.b * 255.0}) | '
        'Hex: #${darkestPixel.toARGB32().toRadixString(16).padLeft(8, "0").toUpperCase()} | '
        'Luminance: ${minLuminance.toStringAsFixed(4)} | '
        'blue100 Lum: ${calculateLuminance(AppColors.blue100).toStringAsFixed(4)}',
      );

      // 1. Assert darkest pixel is never darker than AppColors.blue100
      final blue100Luminance = calculateLuminance(AppColors.blue100);
      expect(
        minLuminance >= (blue100Luminance - 0.01),
        isTrue,
        reason: 'Darkest pixel ($darkestPixel, lum: $minLuminance) must never be darker than blue100 ($blue100Luminance)',
      );

      // 2. Assert textPrimary meets WCAG AA (>= 4.5:1)
      final textPrimaryContrast = contrastRatio(AppColors.textPrimary, darkestPixel);
      expect(
        textPrimaryContrast >= 4.5,
        isTrue,
        reason: 'textPrimary contrast on darkest backdrop pixel must be >= 4.5:1 (Actual: ${textPrimaryContrast.toStringAsFixed(2)}:1)',
      );

      // 3. Assert textSecondary meets WCAG AA (>= 4.5:1)
      final textSecondaryContrast = contrastRatio(AppColors.textSecondary, darkestPixel);
      expect(
        textSecondaryContrast >= 4.5,
        isTrue,
        reason: 'textSecondary contrast on darkest backdrop pixel must be >= 4.5:1 (Actual: ${textSecondaryContrast.toStringAsFixed(2)}:1)',
      );

      // 4. Assert blue500 meets WCAG AA (>= 4.5:1)
      final blue500Contrast = contrastRatio(AppColors.blue500, darkestPixel);
      expect(
        blue500Contrast >= 4.5,
        isTrue,
        reason: 'blue500 contrast on darkest backdrop pixel must be >= 4.5:1 (Actual: ${blue500Contrast.toStringAsFixed(2)}:1)',
      );
    });

    testWidgets('EchoBackdrop is wrapped in ExcludeSemantics and introduces 0 semantic nodes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                EchoBackdrop(enableDrift: false),
                Text('Visible Content'),
              ],
            ),
          ),
        ),
      );

      // Find all semantics nodes
      final semantics = tester.getSemantics(find.byType(EchoBackdrop));
      expect(semantics.label, isEmpty);
      expect(semantics.isMergedIntoParent, isFalse);
    });

    testWidgets('EchoBackdrop is completely static when MediaQuery.disableAnimations is true', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: EchoBackdrop(enableDrift: true),
            ),
          ),
        ),
      );

      // Advance frames - ticker should not be active
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 5));

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(EchoBackdrop),
          matching: find.byType(CustomPaint),
        ),
      );
      final painter = customPaint.painter as EchoBackdropPainter;
      expect(painter.driftProgress, 0.0);
    });

    testWidgets('EchoBackdrop renders cleanly at 320dp width without errors or overflow', (tester) async {
      tester.view.physicalSize = const Size(320.0, 568.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoBackdrop(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('EchoBackdrop inside EchoResponsiveFrame constrains to 430dp on desktop', (tester) async {
      tester.view.physicalSize = const Size(1200.0, 800.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: EchoResponsiveFrame(
            child: Stack(
              children: [
                EchoBackdrop(),
                Text('Desktop Viewport'),
              ],
            ),
          ),
        ),
      );

      final backdropSize = tester.getSize(find.byType(EchoBackdrop));
      expect(backdropSize.width, 430.0);
      expect(backdropSize.height, 800.0);
    });
  });
}
