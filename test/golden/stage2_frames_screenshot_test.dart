import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/splash/split_horizon_layer.dart';

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
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadTestFonts();
  });

  testWidgets('Generate Stage 2 Split Horizon Frame Visualizations', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    final frames = <String, double>{
      'stage2_frame_t0_0s.png': 0.0 / 2.6,
      'stage2_frame_t0_5s.png': 0.5 / 2.6,
      'stage2_frame_t1_0s.png': 1.0 / 2.6,
      'stage2_frame_t1_5s.png': 1.5 / 2.6,
      'stage2_frame_t2_0s.png': 2.0 / 2.6,
      'stage2_frame_t2_5s.png': 2.5 / 2.6,
    };

    // 1. Capture dynamic frames
    for (final entry in frames.entries) {
      final fileName = entry.key;
      final t = entry.value;
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 390.0,
                height: 844.0,
                child: SplitHorizonLayer(
                  animationValue: t,
                  readinessProgress: t.clamp(0.0, 1.0),
                ),
              ),
            ),
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

    // 2. Capture Reduce Motion static frame
    final reduceMotionKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: RepaintBoundary(
            key: reduceMotionKey,
            child: const SizedBox(
              width: 390.0,
              height: 844.0,
              child: SplitHorizonLayer(
                animationValue: 1.0,
                isReduceMotion: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = reduceMotionKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/stage2_frame_reduce_motion.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
