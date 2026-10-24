import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/main.dart';

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

  testWidgets('Generate Component Gallery Screenshots at 1.0x and 2.0x', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['ARTIFACT_DIR'];
    const reviewDir = 'build/review';

    Directory(reviewDir).createSync(recursive: true);
    if (artifactDir != null) {
      Directory(artifactDir).createSync(recursive: true);
    }

    Future<void> saveScreenshot(GlobalKey key, String filename) async {
      await tester.runAsync(() async {
        final RenderRepaintBoundary boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        File('$reviewDir/$filename').writeAsBytesSync(bytes);
        if (artifactDir != null) {
          File('$artifactDir/$filename').writeAsBytesSync(bytes);
        }
      });
    }

    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    // -------------------------------------------------------------
    // 1. Capture at 1.0x text scale (Top, Middle, Bottom)
    // -------------------------------------------------------------
    final key1 = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key1,
        child: const EchoApp(showGallery: true, initialTextScale: 1.0),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await saveScreenshot(key1, 'gallery_1_0x_top.png');
    // Also save legacy default name for compatibility
    await saveScreenshot(key1, 'gallery_1_0x.png');

    // Scroll down to middle section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -680));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await saveScreenshot(key1, 'gallery_1_0x_mid.png');

    // Scroll down to bottom section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -780));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await saveScreenshot(key1, 'gallery_1_0x_bottom.png');

    // Scroll down to end section (settings, buttons, typography)
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -780));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await saveScreenshot(key1, 'gallery_1_0x_end.png');

    // -------------------------------------------------------------
    // 2. Capture at 2.0x text scale (Top, Middle, Bottom, End)
    // -------------------------------------------------------------
    final key2 = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key2,
        child: const EchoApp(showGallery: true, initialTextScale: 2.0),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await saveScreenshot(key2, 'gallery_2_0x_top.png');
    // Also save legacy default name for compatibility
    await saveScreenshot(key2, 'gallery_2_0x.png');

    // Scroll down to middle section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -850));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await saveScreenshot(key2, 'gallery_2_0x_mid.png');

    // Scroll down to bottom section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await saveScreenshot(key2, 'gallery_2_0x_bottom.png');

    // Scroll down to end section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await saveScreenshot(key2, 'gallery_2_0x_end.png');

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
