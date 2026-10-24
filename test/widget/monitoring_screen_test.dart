import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/domain/echo_ring_gauge.dart';
import 'package:echo/core/widgets/domain/echo_wave_backdrop.dart';
import 'package:echo/core/widgets/domain/sample_data_tag.dart';
import 'package:echo/core/widgets/primitives/echo_button.dart';
import 'package:echo/core/widgets/primitives/echo_segmented_control.dart';
import 'package:echo/core/widgets/primitives/echo_stat_tile.dart';
import 'package:echo/features/monitoring/presentation/monitoring_screens.dart';

void main() {
  group('Screen 8: Sound Monitoring Widget Tests (Board 1 Parity)', () {
    testWidgets('1. MonitoringScreen renders Board 1 centerpiece components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const MonitoringScreen(),
        ),
      );

      // Verify header and sample tags
      expect(find.text('Sound Monitoring'), findsOneWidget);
      expect(find.byType(SampleDataTag), findsWidgets);

      // Verify Segmented Control with Daily & Weekly
      expect(find.byType(EchoSegmentedControl<String>), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);

      // Verify Wave Backdrop & 270-degree Ring Gauge
      expect(find.byType(EchoWaveBackdrop), findsOneWidget);
      expect(find.byType(EchoRingGauge), findsOneWidget);
      expect(find.text('Level 3 of 5'), findsOneWidget);
      expect(find.text('Moderate, sample'), findsOneWidget);

      // Verify Dual Stat Tiles
      expect(find.byType(EchoStatTile), findsNWidgets(2));
      expect(find.text('Ambient Sound'), findsOneWidget);
      expect(find.text('Headset Exposure'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);

      // Verify Non-Negotiable rule: strictly zero 'dB' references
      expect(find.textContaining('dB'), findsNothing);
      expect(find.textContaining('decibel', skipOffstage: false), findsNothing);
    });

    testWidgets('2. Segmented control toggles between Daily and Weekly state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const MonitoringScreen(),
        ),
      );

      // Initial daily state
      expect(find.text('Level 3 of 5'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);

      // Tap Weekly
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      // Updated weekly state
      expect(find.text('Level 2 of 5'), findsOneWidget);
      expect(find.text('14h 40m'), findsOneWidget);

      // Tap Daily again
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      expect(find.text('Level 3 of 5'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);
    });

    testWidgets('3. Navigation actions push sub-routes', (tester) async {
      final router = GoRouter(
        initialLocation: '/monitoring',
        routes: [
          GoRoute(path: '/monitoring', builder: (c, s) => const MonitoringScreen()),
          GoRoute(path: '/monitoring/history', builder: (c, s) => const MonitoringHistoryScreen()),
          GoRoute(path: '/monitoring/exposure', builder: (c, s) => const ExposureDetailScreen()),
          GoRoute(path: '/monitoring/settings', builder: (c, s) => const MonitoringSettingsScreen()),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );

      // Scroll until View Exposure History is visible, then tap
      await tester.scrollUntilVisible(find.widgetWithText(EchoButton, 'View Exposure History'), 100);
      await tester.tap(find.widgetWithText(EchoButton, 'View Exposure History'));
      await tester.pumpAndSettle();

      expect(find.text('Historical Sound Levels'), findsOneWidget);
      expect(find.byType(EchoSegmentedControl<String>), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('4. 200% Accessibility Font Scale renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2.0),
              viewInsets: const EdgeInsets.only(bottom: 300.0),
            ),
            child: child!,
          ),
          home: const MonitoringScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
