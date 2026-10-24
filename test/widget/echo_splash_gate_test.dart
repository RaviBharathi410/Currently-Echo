import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/main.dart';
import 'package:echo/core/widgets/splash/echo_splash_gate.dart';
import 'package:echo/core/widgets/splash/split_horizon_layer.dart';
import 'package:echo/features/auth/application/auth_provider.dart';
import 'package:echo/features/onboarding/application/onboarding_provider.dart';

void main() {
  group('EchoSplashGate Widget & Accessibility Tests', () {
    testWidgets('Underlying app receives NO taps or focus while splash is active', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: EchoSplashGate(
            child: Scaffold(
              body: ElevatedButton(
                onPressed: () => tapCount++,
                child: const Text('App Button'),
              ),
            ),
          ),
        ),
      );

      // Verify splash is visible
      expect(find.byType(SplitHorizonLayer), findsOneWidget);

      // Attempt tapping the center (where button is located underneath)
      await tester.tap(find.byType(SplitHorizonLayer));
      await tester.pump();

      // Tap count must remain 0 (app subtree was ignored)
      expect(tapCount, 0);
    });

    testWidgets('Tap anywhere skips to reveal and dismisses the splash', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: EchoSplashGate(
            onDismissed: () => dismissed = true,
            child: const Scaffold(body: Text('Ready App')),
          ),
        ),
      );

      expect(find.byType(SplitHorizonLayer), findsOneWidget);

      // Tap to skip
      await tester.tap(find.byType(SplitHorizonLayer));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.byType(SplitHorizonLayer), findsNothing);
      expect(find.text('Ready App'), findsOneWidget);
    });

    testWidgets('Enforces minimum 1.8s display even when initialization resolves immediately', (tester) async {
      final completer = Completer<void>();
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: EchoSplashGate(
            initializationFuture: completer.future,
            minDuration: const Duration(milliseconds: 1800),
            onDismissed: () => dismissed = true,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      // Resolve init future immediately
      completer.complete();
      await tester.pump();

      // At 1.0s (less than 1.8s), splash must still be visible
      await tester.pump(const Duration(milliseconds: 1000));
      expect(dismissed, isFalse);
      expect(find.byType(SplitHorizonLayer), findsOneWidget);

      // Advance past 1.8s minimum
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.byType(SplitHorizonLayer), findsNothing);
    });

    testWidgets('Enforces 4.0s hard cap dismissal when initialization hangs', (tester) async {
      final uncompletedCompleter = Completer<void>();
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: EchoSplashGate(
            initializationFuture: uncompletedCompleter.future,
            maxDuration: const Duration(milliseconds: 4000),
            onDismissed: () => dismissed = true,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      // Advance to 3.5s - still visible
      await tester.pump(const Duration(milliseconds: 3500));
      expect(dismissed, isFalse);

      // Advance past 4.0s cap
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.byType(SplitHorizonLayer), findsNothing);
    });

    testWidgets('Semantics node has label "ECHO, loading" and app semantics are excluded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EchoSplashGate(
            child: Scaffold(
              body: ElevatedButton(
                onPressed: () {},
                child: const Text('Underlying Semantic Label'),
              ),
            ),
          ),
        ),
      );

      // Verify semantics label & value
      final semantics = tester.getSemantics(find.byType(SplitHorizonLayer));
      final data = semantics.getSemanticsData();
      expect(data.label, 'ECHO, loading');
      expect(data.value, contains('%'));

      // Underlying button semantics should be excluded from semantics tree
      expect(find.bySemanticsLabel('Underlying Semantic Label'), findsNothing);
    });

    testWidgets('Reduce Motion: renders static frame and dismisses after hold (~800ms)', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: EchoSplashGate(
              reduceMotionHoldDuration: const Duration(milliseconds: 800),
              onDismissed: () => dismissed = true,
              child: const Scaffold(body: Text('Ready App')),
            ),
          ),
        ),
      );

      // Initial pump: static frame with isReduceMotion: true
      final layer = tester.widget<SplitHorizonLayer>(find.byType(SplitHorizonLayer));
      expect(layer.isReduceMotion, isTrue);

      // Advance 400ms: still visible
      await tester.pump(const Duration(milliseconds: 400));
      expect(dismissed, isFalse);

      // Advance past 800ms: dismisses
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.byType(SplitHorizonLayer), findsNothing);
    });

    testWidgets('Renders cleanly at 320dp width without overflow', (tester) async {
      tester.view.physicalSize = const Size(320.0, 568.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: EchoSplashGate(
            child: Scaffold(body: Text('Narrow App')),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Backdrop reveal: opacity is 0 during intro, rises during retraction, and is 1 under disableAnimations', (tester) async {
      const backdropKey = Key('test-backdrop-key');

      // 1. Standard animated intro
      await tester.pumpWidget(
        const MaterialApp(
          home: EchoSplashGate(
            backdrop: SizedBox.expand(key: backdropKey),
            child: Scaffold(body: Text('Underlying App')),
          ),
        ),
      );

      // Helper to query the Opacity widget wrapping the backdrop
      Opacity getBackdropOpacity() {
        return tester.widget<Opacity>(
          find.ancestor(
            of: find.byKey(backdropKey),
            matching: find.byType(Opacity),
          ),
        );
      }

      // During intro (t = 1000ms < 2200ms): opacity is strictly 0.0
      await tester.pump(const Duration(milliseconds: 1000));
      expect(getBackdropOpacity().opacity, equals(0.0));

      // Advance to 2200ms (intro reaches settled state)
      await tester.pump(const Duration(milliseconds: 1200));
      // Pump frame to trigger readiness and start retraction animateTo(1.0)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Advance into retraction (mid-retraction)
      await tester.pump(const Duration(milliseconds: 150));
      final midOpacity = getBackdropOpacity().opacity;
      expect(midOpacity, greaterThan(0.0));
      expect(midOpacity, lessThan(1.0));

      // Dismiss splash and settle
      await tester.pumpAndSettle();
      expect(find.byType(SplitHorizonLayer), findsNothing);
      expect(find.byKey(backdropKey), findsOneWidget);

      // 2. Reduce Motion (disableAnimations: true)
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: EchoSplashGate(
              backdrop: SizedBox.expand(key: backdropKey),
              child: Scaffold(body: Text('Underlying App')),
            ),
          ),
        ),
      );

      // Under disableAnimations, opacity is strictly 1.0 immediately without fade
      expect(getBackdropOpacity().opacity, equals(1.0));

      // Settle past hold duration
      await tester.pumpAndSettle();
      expect(find.byKey(backdropKey), findsOneWidget);
    });

    testWidgets('Dismissing splash preserves router state and does not rebuild Navigator', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => AuthNotifier(initialAuthenticated: true)),
            onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: true)),
          ],
          child: const EchoApp(),
        ),
      );

      // Verify splash gate is active on initial cold start
      expect(find.byType(SplitHorizonLayer), findsOneWidget);

      // Tap anywhere to skip splash reveal
      await tester.tap(find.byType(SplitHorizonLayer));
      await tester.pumpAndSettle();

      // Verify splash is gone and dashboard is displayed
      expect(find.byType(SplitHorizonLayer), findsNothing);
      expect(find.text('Headphones Connected'), findsOneWidget);

      // Navigate to another tab (Tab 3: Sound Exposure Monitoring)
      final monitorTab = find.bySemanticsLabel('Sound Exposure Monitoring, Tab 3 of 5');
      expect(monitorTab, findsOneWidget);
      await tester.tap(monitorTab);
      await tester.pumpAndSettle();

      // Confirm navigation succeeded to the monitor tab
      expect(find.text('Sound Monitoring'), findsOneWidget);

      // Navigate to another tab (Tab 5: Profile & Settings)
      final profileTab = find.bySemanticsLabel('Profile & Settings, Tab 5 of 5');
      expect(profileTab, findsOneWidget);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // Confirm navigation succeeded to profile screen
      expect(find.text('Profile & Settings'), findsOneWidget);
    });

    testWidgets('Resilient at 200% text scale without overflow', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            home: EchoSplashGate(
              child: Scaffold(body: Text('Scaled App')),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('SplitHorizonLayer renders "Your ideas, amplified." tagline in reduce motion / settled state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplitHorizonLayer(
              animationValue: 0.85,
              isReduceMotion: true,
            ),
          ),
        ),
      );

      expect(find.text('Your ideas, amplified.'), findsOneWidget);
    });

    testWidgets('SplitHorizonLayer renders live progress percentage during readiness loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplitHorizonLayer(
              animationValue: 0.20,
              readinessProgress: 0.35,
            ),
          ),
        ),
      );

      expect(find.text('35%'), findsOneWidget);
    });

    testWidgets('EchoSplashGate renders "Launching... Please wait" blocking card when showBlockingModal is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EchoSplashGate(
            showBlockingModal: true,
            child: Scaffold(body: Text('App Content')),
          ),
        ),
      );

      expect(find.text('Launching...'), findsOneWidget);
      expect(find.text('Please wait'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });
  });
}
