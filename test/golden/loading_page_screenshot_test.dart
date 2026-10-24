import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/theme/app_typography.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/theme/app_shadows.dart';
import 'package:echo/core/widgets/splash/split_horizon_layer.dart';
import 'package:echo/core/widgets/layout/echo_responsive_frame.dart';
import 'package:echo/core/widgets/layout/echo_backdrop.dart';
import 'package:echo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:echo/features/dashboard/application/dashboard_provider.dart';

Future<void> _loadTestFonts() async {
  // Load DM Sans fonts for the golden test (PlusJakartaSans removed)
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

  testWidgets('Generate Loading Page & App Theme Visualizations', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['ARTIFACT_DIR'] ?? 'build/review';

    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    Future<void> saveScreenshot(GlobalKey key, String name) async {
      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        File('build/review/$name')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(pngBytes);

        File('$artifactDir/$name')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(pngBytes);
      });
    }

    // 1. Row 1 Frames (Intro sequence)
    final introFrames = <String, double>{
      'loading_frame_1_start.png': 0.0,
      'loading_frame_2_top_fill.png': 0.3 / 2.6,
      'loading_frame_3_wordmark.png': 0.85 / 2.6,
      'loading_frame_4_echo.png': 1.6 / 2.6,
      'loading_frame_5_tagline.png': 2.2 / 2.6,
    };

    for (final entry in introFrames.entries) {
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
                  animationValue: entry.value,
                  readinessProgress: 0.0,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(key, entry.key);
    }

    // Frame 6: Reveal with app dashboard underneath
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) => DashboardNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 390.0,
                  height: 844.0,
                  child: EchoResponsiveFrame(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const Opacity(
                          opacity: 0.8,
                          child: EchoBackdrop(enableDrift: false),
                        ),
                        const DashboardScreen(),
                        SplitHorizonLayer(
                          animationValue: 2.45 / 2.6, // in upward retraction
                          readinessProgress: 1.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(key, 'loading_frame_6_reveal.png');
    }

    // 2. Row 2 Frames (Real loading behavior with progress percentage)
    final progressFrames = <String, double>{
      'loading_progress_10.png': 0.10,
      'loading_progress_35.png': 0.35,
      'loading_progress_70.png': 0.70,
      'loading_progress_100.png': 1.00,
    };

    for (final entry in progressFrames.entries) {
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
                  animationValue: 0.25,
                  readinessProgress: entry.value,
                  showProgressText: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(key, entry.key);
    }

    // Frame: Blocking modal ("Launching... Please wait")
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) => DashboardNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 390.0,
                  height: 844.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const EchoBackdrop(enableDrift: false),
                      const DashboardScreen(),
                      // Modal overlay card
                      Container(
                        color: AppColors.splashOverlay,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: AppShadows.modal,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 36.0, color: AppColors.blue500),
                                SizedBox(height: 12.0),
                                Text(
                                  'Launching...',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Please wait',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
      await saveScreenshot(key, 'loading_blocking_modal.png');
    }

    // Frame: App Dashboard with new Electric Royal Blue & Plus Jakarta Sans
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) => DashboardNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(
                key: key,
                child: const SizedBox(
                  width: 390.0,
                  height: 844.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      EchoBackdrop(enableDrift: false),
                      DashboardScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(key, 'app_dashboard_electric_blue.png');
    }
  });
}
