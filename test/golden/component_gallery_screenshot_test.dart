import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/main.dart';

void main() {
  testWidgets('Generate Component Gallery Screenshots at 1.0x and 2.0x', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // 1. Capture at 1.0x text scale
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    final key1 = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key1,
        child: const EchoApp(showGallery: true, initialTextScale: 1.0),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary1 =
          key1.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image1 = await boundary1.toImage(pixelRatio: 1.0);
      final byteData1 = await image1.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/gallery_1_0x.png').writeAsBytesSync(byteData1!.buffer.asUint8List());
    });

    // 2. Capture at 2.0x text scale
    final key2 = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key2,
        child: const EchoApp(showGallery: true, initialTextScale: 2.0),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary2 =
          key2.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image2 = await boundary2.toImage(pixelRatio: 1.0);
      final byteData2 = await image2.toByteData(format: ui.ImageByteFormat.png);
      File('$artifactDir/gallery_2_0x.png').writeAsBytesSync(byteData2!.buffer.asUint8List());
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
