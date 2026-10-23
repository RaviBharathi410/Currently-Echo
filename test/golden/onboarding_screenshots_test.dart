import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/primitives/echo_button.dart';
import 'package:echo/features/onboarding/presentation/onboarding_screens.dart';

void main() {
  testWidgets('Generate Onboarding Flow UI Screenshots', tags: ['screenshot'], (tester) async {
    final artifactDir = Platform.environment['REVIEW_DIR'] ?? 'build/review';
    final dir = Directory(artifactDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    Future<void> captureScreen(Widget widget, String filename, {Future<void> Function(WidgetTester)? onPumped}) async {
      final repaintKey = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: RepaintBoundary(
              key: repaintKey,
              child: widget,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (onPumped != null) {
        await onPumped(tester);
        await tester.pumpAndSettle();
      }

      await tester.runAsync(() async {
        final RenderRepaintBoundary boundary =
            repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$artifactDir/$filename').writeAsBytesSync(byteData!.buffer.asUint8List());
      });
    }

    // 1. Welcome Screen
    await captureScreen(const WelcomeScreen(), 'onboarding_welcome.png');

    // 2. Auth Screen with Error validation triggered
    await captureScreen(
      const AuthScreen(),
      'onboarding_auth_error.png',
      onPumped: (t) async {
        await t.tap(find.widgetWithText(EchoButton, 'Sign In').last);
      },
    );

    // 3. Profile Setup Screen
    await captureScreen(const ProfileSetupScreen(), 'onboarding_profile.png');

    // 4. Disclaimer Screen
    await captureScreen(const DisclaimerScreen(), 'onboarding_disclaimer.png');

    // 5. Permissions Screen
    await captureScreen(const PermissionsScreen(), 'onboarding_permissions.png');

    // 6. Device Setup Screen (with Sample tag & variants)
    await captureScreen(const DeviceSetupScreen(), 'onboarding_device_setup.png');

    // 7. Onboarding Test Intro Screen
    await captureScreen(const OnboardingTestIntroScreen(), 'onboarding_test_intro.png');

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
