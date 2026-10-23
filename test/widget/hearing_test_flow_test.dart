import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/primitives/echo_button.dart';
import 'package:echo/app/router/app_router.dart';
import 'package:echo/features/auth/application/auth_provider.dart';
import 'package:echo/features/onboarding/application/onboarding_provider.dart';
import 'package:echo/features/test/domain/models/hearing_threshold_result.dart';
import 'package:echo/features/test/application/hearing_test_notifier.dart';
import 'package:echo/features/test/presentation/hearing_test_intro_screen.dart';
import 'package:echo/features/test/presentation/hearing_test_in_progress_screen.dart';
import 'package:echo/features/test/presentation/hearing_test_paused_screen.dart';
import 'package:echo/features/test/presentation/hearing_test_results_screen.dart';

void main() {
  group('Screening Test Flow & Interstitial Widget Tests', () {
    testWidgets('HearingTestIntroScreen renders guidelines, sample data tag, and start button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );

      expect(find.text('Preliminary Sound Screening'), findsOneWidget);
      expect(find.text('Sample data'), findsOneWidget);
      expect(find.text('Start Screening'), findsOneWidget);
      expect(find.byIcon(Icons.headphones), findsWidgets);
    });

    testWidgets('HearingTestInProgressScreen renders stimulus, tag row wrap, and tone response buttons', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(hearingTestProvider.notifier).startTest();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: HearingTestInProgressScreen(),
          ),
        ),
      );

      // Verify Ear pill and Sample data tag
      expect(find.text('Left Ear'), findsOneWidget);
      expect(find.text('Sample data'), findsOneWidget);

      // Verify Frequency & Relative Level
      expect(find.text('1000 Hz'), findsOneWidget);
      expect(find.text('Relative Sound Level 3 of 13'), findsOneWidget);

      // Verify Tone Response Buttons
      expect(find.text('I Hear It'), findsOneWidget);
      expect(find.text("Can't Hear It"), findsOneWidget);
      expect(find.text('Pause test'), findsOneWidget);
    });

    testWidgets('HearingTestInProgressScreen handles 200% text scale without overflow in tag row', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(hearingTestProvider.notifier).startTest();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HearingTestInProgressScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Left Ear'), findsOneWidget);
      expect(find.text('Sample data'), findsOneWidget);
      expect(tester.takeException(), isNull); // Zero layout overflows!
    });

    testWidgets('Button-driven ear interstitial appears when Left ear completes, continue switches to Right ear', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(hearingTestProvider.notifier).startTest();

      // Complete all frequencies for left ear
      final notifier = container.read(hearingTestProvider.notifier);
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: HearingTestInProgressScreen(),
          ),
        ),
      );

      // Verify interstitial card is displayed
      expect(find.text('Left Ear Screening Complete'), findsOneWidget);
      expect(find.text('Continue to Right Ear'), findsOneWidget);
      expect(find.byIcon(Icons.headphones), findsOneWidget);

      // Tap "Continue to Right Ear"
      await tester.tap(find.text('Continue to Right Ear'));
      await tester.pump();

      // Now right ear is active!
      expect(find.text('Right Ear'), findsOneWidget);
      expect(find.text('1000 Hz'), findsOneWidget);
    });

    testWidgets('HearingTestPausedScreen displays pause message and actions', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: HearingTestPausedScreen(),
          ),
        ),
      );

      expect(find.text('Screening Paused'), findsOneWidget);
      expect(find.text('Resume Screening'), findsOneWidget);
      expect(find.text('Exit Screening'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    });

    testWidgets('HearingTestResultsScreen displays tone response pattern and non-clinical Sample data tags', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: HearingTestResultsScreen(),
          ),
        ),
      );

      expect(find.text('Tone Response Pattern'), findsOneWidget);
      expect(find.text('Sample data'), findsWidgets);
      expect(find.text('Continue to Dashboard'), findsOneWidget);
    });

    testWidgets('HearingTestResultsScreen Continue button calls completeOnboarding() and navigates to /dashboard', (tester) async {
      final container = ProviderContainer(
        overrides: [
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: false)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(onboardingProvider).isOnboardingComplete, isFalse);

      final testRouter = GoRouter(
        initialLocation: '/test/results',
        routes: [
          GoRoute(
            path: '/test/results',
            builder: (context, state) => const HearingTestResultsScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(body: Text('Dashboard View')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: testRouter,
          ),
        ),
      );

      expect(find.text('Continue to Dashboard'), findsOneWidget);

      await tester.tap(find.text('Continue to Dashboard'));
      await tester.pumpAndSettle();

      expect(container.read(onboardingProvider).isOnboardingComplete, isTrue,
          reason: 'HearingTestResultsScreen must invoke completeOnboarding() when user continues');
      expect(find.text('Dashboard View'), findsOneWidget);
    });

    testWidgets('Returning to Test tab mid-session does not wipe active session state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start and advance test state mid-session
      final notifier = container.read(hearingTestProvider.notifier);
      notifier.startTest();
      notifier.recordResponse();
      notifier.recordResponse();
      expect(container.read(hearingTestProvider).leftEarResults.length, equals(2));

      // Simulate pausing / returning to HearingTestIntroScreen
      notifier.pauseTest();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // State is strictly preserved (NOT wiped out)
      final state = container.read(hearingTestProvider);
      expect(state.leftEarResults.length, equals(2), reason: 'Returning to Test tab must not wipe mid-session results');
      expect(state.phase, equals(HearingTestPhase.paused));

      // UI offers Resume Screening button
      expect(find.text('Resume Screening'), findsOneWidget);
    });

    testWidgets('Automatic navigation to /test/results upon screening completion', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier(initialAuthenticated: true)),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: true)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/test/in-progress');
      await tester.pumpAndSettle();

      final notifier = container.read(hearingTestProvider.notifier);
      notifier.startTest();
      // Complete Left ear
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }
      notifier.startRightEar();
      // Complete Right ear
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }

      await tester.pumpAndSettle();

      // Successfully navigated to /test/results
      expect(router.routeInformationProvider.value.uri.path, equals('/test/results'));
      expect(find.text('Screening Results'), findsOneWidget);
    });

    testWidgets('200% text-scale resilience: Ear Interstitial card handles 2.0x scale without overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(hearingTestProvider.notifier);
      notifier.startTest();
      for (int i = 0; i < kScreeningFrequencies.length; i++) {
        notifier.recordResponse();
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HearingTestInProgressScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Left Ear Screening Complete'), findsOneWidget);
      expect(find.text('Continue to Right Ear'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('200% text-scale resilience: HearingTestPausedScreen handles 2.0x scale without overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HearingTestPausedScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Screening Paused'), findsOneWidget);
      expect(find.text('Resume Screening'), findsOneWidget);
      expect(find.text('Exit Screening'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('200% text-scale resilience: HearingTestResultsScreen handles 2.0x scale without overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HearingTestResultsScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Tone Response Pattern'), findsOneWidget);
      expect(find.text('Continue to Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('200% text-scale resilience: HearingTestIntroScreen renders pinned action bar at 2.0x scale without overflow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HearingTestIntroScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Start Screening'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Pinned action bar must not cause layout overflow at 200% scale');
    });

    testWidgets('Phase 2: HearingTestIntroScreen displays frequencies in ascending order', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );

      // Verify ascending order (250, 500, 1000, 2000, 4000, 8000 Hz)
      expect(
        find.textContaining('250, 500, 1000, 2000, 4000, 8000 Hz'),
        findsOneWidget,
        reason: 'Intro screening frequencies must be displayed in ascending order',
      );
    });

    testWidgets('Phase 2: Readiness checklist gates Start button through 0, 1, 2, and 3 ticked items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );

      // 0 of 3 checks ticked
      expect(find.text('0/3'), findsOneWidget);
      expect(find.text('Complete all 3 checks to begin'), findsOneWidget);

      final startButtonFinder = find.widgetWithText(EchoButton, 'Start Screening');
      expect(startButtonFinder, findsOneWidget);

      // Verify button disabled initially
      expect(tester.widget<EchoButton>(startButtonFinder).onPressed, isNull);
      final initialSemantics = tester.getSemantics(startButtonFinder).getSemanticsData();
      expect(initialSemantics.hint, contains('Complete all 3 checks to begin'));

      // Check item 1: Find a quiet space
      final item1Finder = find.text('Find a quiet space');
      await tester.ensureVisible(item1Finder);
      await tester.tap(item1Finder);
      await tester.pumpAndSettle();

      // 1 of 3 checks ticked -> still disabled
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('Complete all 3 checks to begin'), findsOneWidget);
      expect(tester.widget<EchoButton>(startButtonFinder).onPressed, isNull);

      // Check item 2: Wear headphones
      final item2Finder = find.text('Wear headphones');
      await tester.ensureVisible(item2Finder);
      await tester.tap(item2Finder);
      await tester.pumpAndSettle();

      // 2 of 3 checks ticked -> still disabled
      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('Complete all 3 checks to begin'), findsOneWidget);
      expect(tester.widget<EchoButton>(startButtonFinder).onPressed, isNull);

      // Check item 3: Set device volume to moderate level
      final item3Finder = find.text('Set device volume to moderate level');
      await tester.ensureVisible(item3Finder);
      await tester.tap(item3Finder);
      await tester.pumpAndSettle();

      // 3 of 3 checks ticked -> ENABLED!
      expect(find.text('3/3'), findsOneWidget);
      expect(find.text('All readiness checks complete.'), findsOneWidget);
      expect(find.text('Complete all 3 checks to begin'), findsNothing);

      expect(tester.widget<EchoButton>(startButtonFinder).onPressed, isNotNull);
      final enabledSemantics = tester.getSemantics(startButtonFinder).getSemanticsData();
      expect(enabledSemantics.hint.isEmpty, isTrue);
    });

    testWidgets('Phase 2: Unticking an item after completing checklist immediately re-disables Start button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );

      final startButtonFinder = find.widgetWithText(EchoButton, 'Start Screening');

      // Tick all 3 items
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

      expect(tester.widget<EchoButton>(startButtonFinder).onPressed, isNotNull);

      // Untick one item (Wear headphones)
      await tester.ensureVisible(item2);
      await tester.tap(item2);
      await tester.pumpAndSettle();

      // Button must immediately re-disable
      expect(find.text('2/3'), findsOneWidget);
      expect(tester.widget<EchoButton>(startButtonFinder).onPressed, isNull);
      expect(find.text('Complete all 3 checks to begin'), findsOneWidget);
    });

    testWidgets('Phase 2: Active session Resume and Restart buttons are NOT gated by checklist', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start and pause test
      final notifier = container.read(hearingTestProvider.notifier);
      notifier.startTest();
      notifier.pauseTest();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );

      // Both Resume and Restart must be enabled without ticking checklist
      final resumeFinder = find.widgetWithText(EchoButton, 'Resume Screening');
      final restartFinder = find.widgetWithText(EchoButton, 'Restart Fresh Screening');

      expect(resumeFinder, findsOneWidget);
      expect(restartFinder, findsOneWidget);
      expect(tester.widget<EchoButton>(resumeFinder).onPressed, isNotNull);
      expect(tester.widget<EchoButton>(restartFinder).onPressed, isNotNull);
      expect(find.text('Complete all 3 checks to begin'), findsNothing);
    });

    testWidgets('Phase 2: Checklist rows enforce >= 48dp minimum tap target and expose checked semantics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HearingTestIntroScreen(),
          ),
        ),
      );

      final row1Finder = find.text('Find a quiet space');
      final inkWellFinder = find.ancestor(of: row1Finder, matching: find.byType(InkWell)).first;

      final Size rowSize = tester.getSize(inkWellFinder);
      expect(rowSize.height, greaterThanOrEqualTo(48.0), reason: 'Checklist row must have at least 48dp height');

      // Verify semantics
      final semanticsBefore = tester.getSemantics(inkWellFinder).getSemanticsData();
      expect(semanticsBefore.flagsCollection.isChecked.name, equals('isFalse'));

      await tester.ensureVisible(row1Finder);
      await tester.tap(row1Finder);
      await tester.pumpAndSettle();

      final semanticsAfter = tester.getSemantics(inkWellFinder).getSemanticsData();
      expect(semanticsAfter.flagsCollection.isChecked.name, equals('isTrue'));
    });

    testWidgets('Phase 2: 200% text scale on Readiness Checklist renders without overflow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HearingTestIntroScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Before You Begin'), findsOneWidget);
      expect(find.text('Find a quiet space'), findsOneWidget);
      expect(find.text('0/3'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Readiness checklist must not overflow at 200% text scale');
    });
  });
}
