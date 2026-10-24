import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/widgets/domain/echo_headphone_hero.dart';
import 'package:echo/core/widgets/domain/echo_wave_backdrop.dart';
import 'package:echo/core/widgets/domain/echo_glow_rings.dart';
import 'package:echo/core/widgets/domain/echo_check_circle_hero.dart';
import 'package:echo/core/widgets/domain/echo_ring_gauge.dart';
import 'package:echo/core/widgets/primitives/echo_segmented_control.dart';
import 'package:echo/core/widgets/primitives/echo_feature_tile.dart';
import 'package:echo/core/widgets/primitives/echo_section_card.dart';
import 'package:echo/core/widgets/primitives/echo_filter_chip.dart';
import 'package:echo/core/widgets/primitives/echo_stat_tile.dart';
import 'package:echo/core/widgets/navigation/echo_setting_row.dart';

void main() {
  group('EchoHeadphoneHero Widget Tests', () {
    testWidgets('renders properly with semantics and custom sizes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoHeadphoneHero(
              size: 200.0,
              activeEar: EchoEarTarget.left,
              semanticLabel: 'Testing left ear',
            ),
          ),
        ),
      );

      expect(find.byType(EchoHeadphoneHero), findsOneWidget);
      expect(find.bySemanticsLabel('Testing left ear'), findsOneWidget);
    });

    testWidgets('renders all active ear variations without errors', (tester) async {
      for (final ear in EchoEarTarget.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EchoHeadphoneHero(activeEar: ear),
            ),
          ),
        );
        expect(find.byType(EchoHeadphoneHero), findsOneWidget);
      }
    });
  });

  group('EchoWaveBackdrop Widget Tests', () {
    testWidgets('renders layered wave with child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoWaveBackdrop(
              height: 120.0,
              child: Text('Wave Content'),
            ),
          ),
        ),
      );

      expect(find.text('Wave Content'), findsOneWidget);
      expect(find.byType(EchoWaveBackdrop), findsOneWidget);
    });
  });

  group('EchoGlowRings Widget Tests', () {
    testWidgets('renders concentric rings and child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoGlowRings(
              size: 200.0,
              isPulsing: false,
              child: Icon(Icons.hearing),
            ),
          ),
        ),
      );

      expect(find.byType(EchoGlowRings), findsOneWidget);
      expect(find.byIcon(Icons.hearing), findsOneWidget);
    });

    testWidgets('animates properly when pulsing is enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoGlowRings(
              isPulsing: true,
              child: Text('Center'),
            ),
          ),
        ),
      );

      expect(find.text('Center'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('EchoCheckCircleHero Widget Tests', () {
    testWidgets('renders check icon, tonal confetti, and semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoCheckCircleHero(
              size: 150.0,
              semanticLabel: 'Section complete',
            ),
          ),
        ),
      );

      expect(find.byType(EchoCheckCircleHero), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('Section complete'), findsOneWidget);
    });
  });

  group('EchoRingGauge Widget Tests', () {
    testWidgets('renders arc gauge with level and status labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoRingGauge(
              value: 0.65,
              levelLabel: 'Level 3 of 5',
              statusLabel: 'Moderate, sample',
            ),
          ),
        ),
      );

      expect(find.text('Level 3 of 5'), findsOneWidget);
      expect(find.text('Moderate, sample'), findsOneWidget);
      expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
    });
  });

  group('EchoSegmentedControl Widget Tests', () {
    testWidgets('renders all options and fires onChanged when tapped', (tester) async {
      String selected = 'Daily';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: EchoSegmentedControl<String>(
                  options: const [
                    EchoSegmentOption(value: 'Daily', label: 'Daily'),
                    EchoSegmentOption(value: 'Weekly', label: 'Weekly'),
                    EchoSegmentOption(value: 'Monthly', label: 'Monthly'),
                  ],
                  selectedValue: selected,
                  onChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(selected, 'Weekly');
    });
  });

  group('EchoFeatureTile Widget Tests', () {
    testWidgets('renders icon, title, subtitle, and fires onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EchoFeatureTile(
              icon: Icons.mic_rounded,
              title: 'Microphone Access',
              subtitle: 'Calibrate environmental sound monitoring',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.text('Microphone Access'), findsOneWidget);
      expect(find.text('Calibrate environmental sound monitoring'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Microphone Access'));
      expect(tapped, isTrue);
    });
  });

  group('EchoSectionCard Widget Tests', () {
    testWidgets('renders title, subtitle, trailing, and child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoSectionCard(
              title: 'Summary Stats',
              subtitle: 'Past 7 days',
              trailing: Text('More'),
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Summary Stats'), findsOneWidget);
      expect(find.text('Past 7 days'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });
  });

  group('EchoFilterChip Widget Tests', () {
    testWidgets('renders label and toggles on tap', (tester) async {
      bool selected = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: EchoFilterChip(
                  label: 'Routine Check',
                  isSelected: selected,
                  onTap: () => setState(() => selected = !selected),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Routine Check'), findsOneWidget);
      await tester.tap(find.text('Routine Check'));
      await tester.pumpAndSettle();

      expect(selected, isTrue);
    });
  });

  group('EchoStatTile Widget Tests', () {
    testWidgets('renders icon, value, label, and badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EchoStatTile(
              icon: Icons.timer_outlined,
              value: '2h 15m',
              label: 'Daily Exposure',
              badgeText: 'Optimal',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);
      expect(find.text('Daily Exposure'), findsOneWidget);
      expect(find.text('Optimal'), findsOneWidget);
    });
  });

  group('EchoSettingRow Widget Tests', () {
    testWidgets('renders setting row with 48dp minimum touch target', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EchoSettingRow(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Daily hearing health reminders',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Daily hearing health reminders'), findsOneWidget);

      final rowBox = tester.getRect(find.byType(EchoSettingRow));
      expect(rowBox.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.text('Notifications'));
      expect(tapped, isTrue);
    });
  });
}
