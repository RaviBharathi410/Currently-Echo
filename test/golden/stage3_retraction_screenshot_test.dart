import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/layout/echo_responsive_frame.dart';
import 'package:echo/core/widgets/layout/echo_backdrop.dart';
import 'package:echo/core/widgets/navigation/echo_bottom_nav.dart';
import 'package:echo/core/widgets/splash/split_horizon_layer.dart';
import 'package:echo/features/test/presentation/hearing_test_intro_screen.dart';

Future<void> _loadTestFonts() async {
  final dmSansLoader = FontLoader('DMSans');
  for (final file in [
    'assets/fonts/DMSans-Regular.ttf',
    'assets/fonts/DMSans-Medium.ttf',
    'assets/fonts/DMSans-SemiBold.ttf',
    'assets/fonts/DMSans-Bold.ttf',
  ]) {
    if (File(file).existsSync()) {
      final bytes = File(file).readAsBytesSync();
      dmSansLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
  }
  await dmSansLoader.load();

  const iconPath = r'C:\development\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf';
  if (File(iconPath).existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    final iconBytes = File(iconPath).readAsBytesSync();
    iconLoader.addFont(Future.value(ByteData.view(iconBytes.buffer)));
    await iconLoader.load();
  }
}

Widget _buildIntegratedFrame({
  required double progress,
  required bool isReduceMotion,
}) {
  // Compute backdrop opacity matching EchoSplashGate:
  // Fades in over 400ms during the blue half retraction (0.8462 to 1.0)
  final double backdropOpacity;
  if (isReduceMotion || progress >= 1.0) {
    backdropOpacity = 1.0;
  } else if (progress >= 0.8462) {
    final tRetract = ((progress - 0.8462) / (1.0 - 0.8462)).clamp(0.0, 1.0);
    backdropOpacity = Curves.easeOut.transform(tRetract);
  } else {
    backdropOpacity = 0.0;
  }

  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: SizedBox(
        width: 390.0,
        height: 844.0,
        child: EchoResponsiveFrame(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: EchoBackdrop (fading in over ~400ms during retraction)
              Opacity(
                opacity: backdropOpacity,
                child: const EchoBackdrop(enableDrift: false),
              ),

              // Layer 2: App Content (HearingTestIntroScreen with bottom navigation)
              Scaffold(
                backgroundColor: Colors.transparent,
                body: const HearingTestIntroScreen(),
                bottomNavigationBar: EchoBottomNav(
                  currentIndex: 0,
                  onTap: (_) {},
                ),
              ),

              // Layer 3: EchoSplashGate overlay (retracting blue half & fading white half)
              if (progress < 1.0 && !isReduceMotion)
                SplitHorizonLayer(
                  animationValue: progress,
                  readinessProgress: 1.0,
                  isReduceMotion: false,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadTestFonts();
  });

  testWidgets('Generate Stage 3 Retraction Reveal Frames Landing on Tinted App', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    final retractionFrames = <String, double>{
      'stage3_retraction_t2_2s.png': 0.8462, // Start of retraction: settled wordmark
      'stage3_retraction_t2_3s.png': 0.8846, // Blue half retracts to ~38%, backdrop 25% opacity
      'stage3_retraction_t2_4s.png': 0.9231, // Blue half at ~25%, backdrop 50% opacity
      'stage3_retraction_t2_5s.png': 0.9615, // Blue half at ~12%, backdrop 75% opacity
      'stage3_retraction_t2_6s.png': 1.0000, // Complete reveal: fully landed on tinted app
    };

    for (final entry in retractionFrames.entries) {
      final fileName = entry.key;
      final progress = entry.value;
      final key = GlobalKey();

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: _buildIntegratedFrame(
            progress: progress,
            isReduceMotion: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$artifactDir/$fileName').writeAsBytesSync(byteData!.buffer.asUint8List());
      });
    }

    // Capture Reduce Motion revealed state (instant cut, no fade)
    final rmKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rmKey,
        child: _buildIntegratedFrame(
          progress: 1.0,
          isReduceMotion: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = rmKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/stage3_retraction_reduce_motion.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
