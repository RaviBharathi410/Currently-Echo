import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/domain/sample_data_tag.dart';
import 'package:echo/core/widgets/primitives/echo_button.dart';
import 'package:echo/core/widgets/primitives/echo_checkbox.dart';
import 'package:echo/core/widgets/primitives/echo_switch.dart';
import 'package:echo/features/auth/application/auth_provider.dart';
import 'package:echo/features/onboarding/presentation/onboarding_screens.dart';
import 'package:echo/features/test/domain/models/hearing_threshold_result.dart';

void main() {
  group('Onboarding Flow (7 Screens) Production Widget Tests', () {
    testWidgets('1. WelcomeScreen renders value propositions and navigation actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Welcome to ECHO'), findsOneWidget);
      expect(find.text('Preliminary Sound Screening'), findsOneWidget);
      expect(find.text('Acoustic Monitoring'), findsOneWidget);
      expect(find.text('Sound Personalization'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('I Already Have an Account'), findsOneWidget);
    });

    testWidgets('2. AuthScreen validates empty fields with Icon + Error prefix', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('Sign In'), findsWidgets);

      // Attempt to submit with empty fields (bottom CTA button)
      await tester.tap(find.widgetWithText(EchoButton, 'Sign In').last);
      await tester.pumpAndSettle();

      // Error rows must render icon + "Error: " prefix
      expect(find.byIcon(Icons.error_outline), findsWidgets);
      expect(find.text('Error: Please enter your email address'), findsOneWidget);
      expect(find.text('Error: Please enter your password'), findsOneWidget);
    });

    testWidgets('2b. AuthScreen Continue as Guest sets isAuthenticated: true and isGuest: true', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier()..signOut()),
        ],
      );
      addTearDown(container.dispose);

      // Verify initially unauthenticated
      expect(container.read(authProvider).isAuthenticated, isFalse);

      final router = GoRouter(
        initialLocation: '/auth',
        routes: [
          GoRoute(path: '/auth', builder: (c, s) => const AuthScreen()),
          GoRoute(path: '/profile-setup', builder: (c, s) => const Scaffold(body: Text('Profile Setup Route'))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Continue as Guest'), findsOneWidget);
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Verify guest state is set allowing navigation guard to pass
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, isTrue, reason: 'Guest mode must set isAuthenticated to pass router guard');
      expect(authState.isGuest, isTrue);
      expect(find.text('Profile Setup Route'), findsOneWidget);
    });

    testWidgets('3. ProfileSetupScreen renders name, age bracket, and language without listening level', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileSetupScreen(),
        ),
      );

      expect(find.text('Preferred Name'), findsOneWidget);
      expect(find.text('Age Range'), findsOneWidget);
      expect(find.text('18–35'), findsOneWidget);
      expect(find.text('Preferred Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Continue to Disclaimer'), findsOneWidget);

      // Verify health-adjacent daily listening level is not present
      expect(find.textContaining('daily listening', findRichText: true), findsNothing);
    });

    testWidgets('4. DisclaimerScreen enforces exact scope wording and mandatory checkbox gate', (tester) async {
      final router = GoRouter(
        initialLocation: '/disclaimer',
        routes: [
          GoRoute(path: '/disclaimer', builder: (c, s) => const DisclaimerScreen()),
          GoRoute(path: '/permissions', builder: (c, s) => const Scaffold(body: Text('Permissions Route'))),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Exact scope wording verification
      expect(
        find.text('ECHO provides a preliminary screening, not a substitute for professional audiological assessment.'),
        findsOneWidget,
      );

      // "Accept & Continue" button must be disabled initially
      final continueButtonFinder = find.widgetWithText(EchoButton, 'Accept & Continue');
      final initialButton = tester.widget<EchoButton>(continueButtonFinder);
      expect(initialButton.onPressed, isNull, reason: 'Accept & Continue must be disabled until checkbox is checked');

      // Tap checkbox to acknowledge
      await tester.tap(find.byType(EchoCheckbox));
      await tester.pumpAndSettle();

      final enabledButton = tester.widget<EchoButton>(continueButtonFinder);
      expect(enabledButton.onPressed, isNotNull, reason: 'Accept & Continue must be enabled once checked');

      // Tap to navigate
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text('Permissions Route'), findsOneWidget);
    });

    testWidgets('5. PermissionsScreen displays simulated notice, 3 permission cards with switches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PermissionsScreen(),
        ),
      );

      expect(find.text('Simulated permissions for UI demonstration. No actual system permissions are requested.'), findsOneWidget);
      expect(find.text('Microphone Permission'), findsOneWidget);
      expect(find.text('Notifications Permission'), findsOneWidget);
      expect(find.text('Bluetooth Permission'), findsOneWidget);
      expect(find.byType(EchoSwitch), findsNWidgets(3));
      expect(find.text('Continue to Device Setup'), findsOneWidget);
    });

    testWidgets('6. DeviceSetupScreen renders Sample tag, and handles Connected, Disconnected, and Permission Denied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeviceSetupScreen(),
        ),
      );

      // Sample Data tag must be visibly present
      expect(find.byType(SampleDataTag), findsWidgets);

      // Initial state: Connected
      expect(find.text('Headphones Connected'), findsOneWidget);
      expect(find.text('Bluetooth Audio Active (Simulated)'), findsOneWidget);
      final continueButtonFinder = find.widgetWithText(EchoButton, 'Continue to Screening Briefing');
      expect(tester.widget<EchoButton>(continueButtonFinder).onPressed, isNotNull);

      // Switch to Disconnected
      await tester.tap(find.text('Disconnected'));
      await tester.pumpAndSettle();
      expect(find.text('No Headphones Detected'), findsOneWidget);
      expect(tester.widget<EchoButton>(continueButtonFinder).onPressed, isNull,
          reason: 'Cannot continue when headphones are disconnected');

      // Switch to Permission Denied
      await tester.tap(find.text('Permission Denied'));
      await tester.pumpAndSettle();
      expect(find.text('Bluetooth Permission Unavailable'), findsOneWidget);
      expect(tester.widget<EchoButton>(continueButtonFinder).onPressed, isNull,
          reason: 'Cannot continue when permission is denied');
    });

    testWidgets('7. OnboardingTestIntroScreen dynamically references kScreeningFrequencies', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/onboarding/test-intro',
        routes: [
          GoRoute(path: '/onboarding/test-intro', builder: (c, s) => const OnboardingTestIntroScreen()),
          GoRoute(path: '/test/in-progress', builder: (c, s) => const Scaffold(body: Text('In Progress Route'))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Dynamic frequency count and list check
      final sortedFreqs = [...kScreeningFrequencies]..sort();
      expect(find.textContaining('${kScreeningFrequencies.length} test frequencies'), findsOneWidget);
      expect(find.textContaining(sortedFreqs.join(', ')), findsOneWidget);
      expect(find.textContaining('beginning at reference ${kScreeningFrequencies.first} Hz'), findsOneWidget);

      // Start screening
      await tester.tap(find.text('Begin Initial Screening'));
      await tester.pumpAndSettle();
      expect(find.text('In Progress Route'), findsOneWidget);
    });

    testWidgets('8. 200% Font Scale with Keyboard Inset (viewInsets 300dp) renders without overflow across all 7 screens', (tester) async {
      final screens = <Widget>[
        const WelcomeScreen(),
        const AuthScreen(),
        const ProfileSetupScreen(),
        const DisclaimerScreen(),
        const PermissionsScreen(),
        const DeviceSetupScreen(),
        const OnboardingTestIntroScreen(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(390, 844),
                  textScaler: TextScaler.linear(2.0),
                  viewInsets: EdgeInsets.only(bottom: 300.0), // Keyboard open!
                ),
                child: screen,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${screen.runtimeType} must not overflow at 200% scale with keyboard open');
      }
    });
  });
}
