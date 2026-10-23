import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/domain/sound_wave_hero.dart';
import 'package:echo/core/widgets/navigation/echo_bottom_nav.dart';
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

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadTestFonts();
  });

  testWidgets('Generate Phase 3 UI Screenshots', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(430 * 2.0, 932 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    // 1. Capture SoundWaveHero Card
    final heroKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: const Color(0xFFF7FAFC),
          body: Center(
            child: RepaintBoundary(
              key: heroKey,
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFD2E3FC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SoundWaveHero(animate: false),
                    SizedBox(height: 16),
                    Text(
                      'Preliminary Sound Screening',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D233A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Harmonic acoustic wave visualization with 7 tonal steps',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        color: Color(0xFF4A6B8A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary =
          heroKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/phase3_sound_wave_hero.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    // 2. Capture Sliding Nav Pill (Comparison: Index 0 Test vs Index 1 Home)
    final navKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: const Color(0xFFF7FAFC),
          body: Center(
            child: RepaintBoundary(
              key: navKey,
              child: Container(
                width: 430,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Tab 0: Test Screen Active (Sliding Pill at Index 0)',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A6B8A),
                        ),
                      ),
                    ),
                    EchoBottomNav(
                      currentIndex: 0,
                      onTap: (_) {},
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Tab 1: Home Dashboard Active (Sliding Pill at Index 1)',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A6B8A),
                        ),
                      ),
                    ),
                    EchoBottomNav(
                      currentIndex: 1,
                      onTap: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary =
          navKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/phase3_sliding_nav.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    // 3. Capture Full Screen Integration of HearingTestIntroScreen
    final fullScreenKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Center(
            child: RepaintBoundary(
              key: fullScreenKey,
              child: SizedBox(
                width: 430,
                height: 932,
                child: HearingTestIntroScreen(
                  bottomNavigationBar: EchoBottomNav(
                    currentIndex: 0,
                    onTap: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verification of bottom nav layout bounds

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary =
          fullScreenKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/phase3_screen_integration.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
