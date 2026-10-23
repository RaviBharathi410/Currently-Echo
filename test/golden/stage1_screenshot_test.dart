import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/layout/echo_backdrop.dart';
import 'package:echo/core/widgets/layout/echo_responsive_frame.dart';
import 'package:echo/core/widgets/navigation/echo_bottom_nav.dart';
import 'package:echo/features/test/presentation/hearing_test_intro_screen.dart';
import 'package:echo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:echo/features/profile/presentation/profile_screens.dart';

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

Widget _buildScreenContainer({
  required Widget screen,
  required int navIndex,
  required bool hasBackdrop,
  required double width,
  required double height,
}) {
  final shellChild = Scaffold(
    backgroundColor: AppColors.transparent,
    body: screen,
    bottomNavigationBar: EchoBottomNav(
      currentIndex: navIndex,
      onTap: (_) {},
    ),
  );

  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: SizedBox(
        width: width,
        height: height,
        child: EchoResponsiveFrame(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasBackdrop)
                const EchoBackdrop(enableDrift: false)
              else
                const ColoredBox(color: AppColors.surface),
              shellChild,
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

  testWidgets('Generate Stage 1 UI Screenshots (Test, Dashboard, Profile at 390dp and 1200dp Before/After)', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final screens = <String, Map<String, dynamic>>{
      'test': {
        'navIndex': 0,
        'widget': const HearingTestIntroScreen(),
      },
      'dashboard': {
        'navIndex': 1,
        'widget': const DashboardScreen(),
      },
      'profile': {
        'navIndex': 4,
        'widget': const ProfileScreen(),
      },
    };

    final viewports = <String, Size>{
      '390dp': const Size(390.0, 844.0),
      '1200dp': const Size(1200.0, 800.0),
    };

    for (final screenEntry in screens.entries) {
      final screenName = screenEntry.key;
      final navIndex = screenEntry.value['navIndex'] as int;
      final screenWidget = screenEntry.value['widget'] as Widget;

      for (final viewportEntry in viewports.entries) {
        final viewportName = viewportEntry.key;
        final size = viewportEntry.value;

        for (final hasBackdrop in [false, true]) {
          final stateName = hasBackdrop ? 'after' : 'before';
          final fileName = 'stage1_${screenName}_${viewportName}_$stateName.png';
          final repaintKey = GlobalKey();

          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            RepaintBoundary(
              key: repaintKey,
              child: _buildScreenContainer(
                screen: screenWidget,
                navIndex: navIndex,
                hasBackdrop: hasBackdrop,
                width: size.width,
                height: size.height,
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.runAsync(() async {
            final boundary = repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            File('$artifactDir/$fileName').writeAsBytesSync(byteData!.buffer.asUint8List());
          });
        }
      }
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
