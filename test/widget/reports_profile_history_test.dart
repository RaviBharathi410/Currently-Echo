import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/domain/sample_data_tag.dart';
import 'package:echo/core/widgets/navigation/echo_setting_row.dart';
import 'package:echo/core/widgets/primitives/echo_filter_chip.dart';
import 'package:echo/core/widgets/primitives/echo_segmented_control.dart';
import 'package:echo/core/widgets/primitives/echo_stat_tile.dart';
import 'package:echo/features/reports/presentation/reports_screens.dart';
import 'package:echo/features/profile/presentation/profile_screens.dart';
import 'package:echo/features/history/presentation/history_screens.dart';

void main() {
  group('Phase 5: Reports, Profile, and History Widget & Parity Tests', () {
    testWidgets('1. ReportsScreen renders Board 1 Screen 14 components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const ReportsScreen(),
        ),
      );

      // Verify Header and Sample data tags
      expect(find.text('Listening Reports'), findsOneWidget);
      expect(find.byType(SampleDataTag), findsWidgets);

      // Verify Period Segmented Control
      expect(find.byType(EchoSegmentedControl<String>), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);

      // Verify Dual Stat Tiles
      expect(find.byType(EchoStatTile), findsNWidgets(2));
      expect(find.text('Daily Avg Exposure'), findsOneWidget);
      expect(find.text('Weekly Total'), findsOneWidget);

      // Verify Weekly Distribution Chart and Acoustic Breakdown
      expect(find.text('Listening Duration Distribution'), findsOneWidget);
      expect(find.text('Acoustic Range Breakdown'), findsOneWidget);
      expect(find.text('Quiet (< Level 2)'), findsOneWidget);
      expect(find.text('Moderate (Level 2–4)'), findsOneWidget);
      expect(find.text('High (Level 5+)'), findsOneWidget);

      // Verify sub-route buttons
      expect(find.text('Exposure Trends'), findsOneWidget);
      expect(find.text('Insights & Tips'), findsOneWidget);
      expect(find.text('Historical Data'), findsOneWidget);

      // Non-negotiable: strictly zero 'dB' references
      expect(find.textContaining('dB'), findsNothing);
    });

    testWidgets('2. ReportsScreen timeframe toggle updates stat tiles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const ReportsScreen(),
        ),
      );

      // Initial Weekly state
      expect(find.text('Weekly Summary'), findsOneWidget);
      expect(find.text('12h 15m'), findsOneWidget);

      // Toggle to Daily
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Summary'), findsOneWidget);
      expect(find.text('Today Exposure'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);

      // Toggle to Monthly
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Summary'), findsOneWidget);
      expect(find.text('Monthly Total'), findsOneWidget);
      expect(find.text('54h 20m'), findsOneWidget);
    });

    testWidgets('3. ReportsScreen 200% accessibility font scale renders without overflow', (tester) async {
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
          home: const ReportsScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. ProfileScreen renders Board 1 Screen 15 components and EchoSettingRows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const ProfileScreen(),
        ),
      );

      // Verify Header & Profile Card
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Alex Parker'), findsOneWidget);
      expect(find.text('Active Profile'), findsOneWidget);

      // Verify Section Headers
      expect(find.text('Devices & Audio Output'), findsOneWidget);
      expect(find.text('Alerts & Monitoring'), findsOneWidget);
      expect(find.text('Privacy & Data'), findsOneWidget);
      expect(find.text('About & Support'), findsOneWidget);

      // Verify EchoSettingRows
      expect(find.byType(EchoSettingRow), findsNWidgets(9));
      expect(find.text('Connected Devices'), findsOneWidget);
      expect(find.text('Screening Reminders'), findsOneWidget);
      expect(find.text('Sound Exposure Alerts'), findsOneWidget);
      expect(find.text('Privacy & Data Protection'), findsOneWidget);
      expect(find.text('Export Screening Data'), findsOneWidget);
      expect(find.text('About ECHO'), findsOneWidget);

      // Verify Switches
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('5. ProfileScreen 200% accessibility font scale renders without overflow', (tester) async {
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
          home: const ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('6. HearingHistoryScreen renders Board 1 Screen 16 filter chips and timeline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const HearingHistoryScreen(),
        ),
      );

      // Verify Header & Sample Tag
      expect(find.text('Screening History'), findsOneWidget);
      expect(find.byType(SampleDataTag), findsWidgets);

      // Verify Filter Chips
      expect(find.byType(EchoFilterChip), findsNWidgets(4));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Left Ear'), findsOneWidget);
      expect(find.text('Right Ear'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);

      // Verify Stat Tiles
      expect(find.byType(EchoStatTile), findsNWidgets(2));
      expect(find.text('4 Checks'), findsOneWidget);
      expect(find.text('Level 3 Avg'), findsOneWidget);

      // Verify Timeline Records
      expect(find.text('Recorded Screening Sessions'), findsOneWidget);
      expect(find.text('Screening #4 • Balanced'), findsOneWidget);
      expect(find.text('Screening #1 • Initial Calibration'), findsOneWidget);

      // Tap a filter chip
      await tester.tap(find.text('Left Ear'));
      await tester.pumpAndSettle();

      // Verify sub-route buttons
      expect(find.text('Compare Screenings'), findsOneWidget);
      expect(find.text('Screening Reminders'), findsOneWidget);
    });

    testWidgets('7. HearingHistoryScreen 200% accessibility font scale renders without overflow', (tester) async {
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
          home: const HearingHistoryScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
