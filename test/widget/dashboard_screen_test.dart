import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/features/dashboard/application/dashboard_provider.dart';
import 'package:echo/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget & Multi-State Tests', () {
    testWidgets('Dashboard renders loaded state with illustrative estimate metrics and sample data tags', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      // Verify Connected Device (Generic, no brand/battery)
      expect(find.text('Headphones Connected'), findsOneWidget);

      // Verify Illustrative-estimate sound dose section (Plain durations & relative levels)
      expect(find.text('Daily Sound Exposure'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);
      expect(find.text('Moderate (Level 2 of 5)'), findsOneWidget);
      expect(find.text('45m'), findsOneWidget);

      // Verify Tone Response Profile
      expect(find.text('Tone Response Profile'), findsOneWidget);
      expect(find.text('Sample data'), findsWidgets);
      expect(find.text('Check Response Again'), findsOneWidget);

      // Verify Quick Access
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Equalizer'), findsOneWidget);
    });

    testWidgets('Dashboard renders loading state with progress indicator and explanatory copy', (tester) async {
      final container = ProviderContainer(
        overrides: [
          dashboardProvider.overrideWith((ref) => DashboardNotifier(initialStatus: DashboardStatus.loading)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading illustrative estimates...'), findsOneWidget);
    });

    testWidgets('Dashboard renders empty state with icon, explanatory guidance, and CTA to screen', (tester) async {
      final container = ProviderContainer(
        overrides: [
          dashboardProvider.overrideWith((ref) => DashboardNotifier(initialStatus: DashboardStatus.empty)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.hearing_outlined), findsOneWidget);
      expect(find.text('No Listening Estimates Yet'), findsOneWidget);
      expect(find.text('Start Preliminary Screening'), findsOneWidget);
    });

    testWidgets('Dashboard renders error state with tonal styling (no red) and retry action', (tester) async {
      final container = ProviderContainer(
        overrides: [
          dashboardProvider.overrideWith((ref) {
            final notifier = DashboardNotifier();
            notifier.setStatus(DashboardStatus.error);
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, equals(AppColors.blue500)); // Strict tonal error styling

      expect(find.text('Unable to Load Dashboard Data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Verify zero red colors
      final allTexts = tester.widgetList<Text>(find.byType(Text));
      for (final text in allTexts) {
        final color = text.style?.color;
        if (color != null) {
          expect(color.toARGB32() != 0xFFFF0000, isTrue);
          expect(color.toARGB32() != 0xFFB00020, isTrue);
          expect(color.toARGB32() != 0xFFBA1A1A, isTrue);
        }
      }
    });

    testWidgets('200% text scale resilience: Dashboard loaded state handles 2.0x scale without overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const DashboardScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Headphones Connected'), findsOneWidget);
      expect(find.text('Daily Sound Exposure'), findsOneWidget);
      expect(tester.takeException(), isNull); // Zero overflows!
    });
  });
}
