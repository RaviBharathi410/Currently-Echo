import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_theme.dart';
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

  testWidgets('Generate Phase 2 Readiness Checklist UI Screenshots with Real Fonts', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(430 * 2.0, 932 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    // 1. Initial State: 0 of 3 checks ticked, Start button disabled with visible warning & hint
    final key1 = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: RepaintBoundary(
            key: key1,
            child: Scaffold(
              body: const HearingTestIntroScreen(),
              bottomNavigationBar: EchoBottomNav(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary =
          key1.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/phase2_checklist_initial.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    // 2. Completed State: 3 of 3 checks ticked, Start button enabled
    final item1 = find.text('Find a quiet space');
    final item2 = find.text('Wear headphones');
    final item3 = find.text('Set device volume to moderate level');

    await tester.ensureVisible(item1);
    await tester.tap(item1);
    await tester.pumpAndSettle();

    await tester.ensureVisible(item2);
    await tester.tap(item2);
    await tester.pumpAndSettle();

    await tester.ensureVisible(item3);
    await tester.tap(item3);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary =
          key1.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/phase2_checklist_completed.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
