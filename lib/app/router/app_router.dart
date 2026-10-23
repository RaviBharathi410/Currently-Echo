import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/navigation/echo_bottom_nav.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/onboarding/application/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../features/test/presentation/hearing_test_intro_screen.dart';
import '../../features/test/presentation/hearing_test_in_progress_screen.dart';
import '../../features/test/presentation/hearing_test_paused_screen.dart';
import '../../features/test/presentation/hearing_test_results_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/monitoring/presentation/monitoring_screens.dart';
import '../../features/reports/presentation/reports_screens.dart';
import '../../features/profile/presentation/profile_screens.dart';
import '../../features/history/presentation/history_screens.dart';
import '../../features/personalization/presentation/personalization_screens.dart';

String? appRouterRedirect({
  required String path,
  required bool isAuthenticated,
  required bool isOnboardingComplete,
}) {
  // 1. Unauthenticated users attempting to access protected routes redirect to /auth
  // (/welcome and /auth are public entry routes)
  if (!isAuthenticated && path != '/welcome' && path != '/auth') {
    return '/auth';
  }

  // 2. Authenticated users attempting to view welcome/auth
  if (isAuthenticated && (path == '/welcome' || path == '/auth')) {
    return isOnboardingComplete ? '/dashboard' : '/profile-setup';
  }

  return null;
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

/// Listenable bridge that notifies GoRouter when auth or onboarding state updates
/// without destroying or recreating the GoRouter instance.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(onboardingProvider, (_, __) => notifyListeners());
  }
}

final routerRefreshListenableProvider = Provider<RouterRefreshListenable>((ref) {
  return RouterRefreshListenable(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshListenable,
    initialLocation: ref.read(onboardingProvider).isOnboardingComplete ? '/dashboard' : '/welcome',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final onboardingState = ref.read(onboardingProvider);
      return appRouterRedirect(
        path: state.uri.path,
        isAuthenticated: authState.isAuthenticated,
        isOnboardingComplete: onboardingState.isOnboardingComplete,
      );
    },
    routes: [
      // ---------------------------------------------------------
      // 1-7: Onboarding Routes (Top-level)
      // ---------------------------------------------------------
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/disclaimer',
        name: 'disclaimer',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: '/permissions',
        name: 'permissions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(
        path: '/device-setup',
        name: 'deviceSetup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DeviceSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/test-intro',
        name: 'onboardingTestIntro',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingTestIntroScreen(),
      ),

      // ---------------------------------------------------------
      // 9-11: Top-Level Modal Test Routes (Hide bottom navigation)
      // ---------------------------------------------------------
      GoRoute(
        path: '/test/in-progress',
        name: 'testProgress',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HearingTestInProgressScreen(),
      ),
      GoRoute(
        path: '/test/paused',
        name: 'testPaused',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HearingTestPausedScreen(),
      ),
      GoRoute(
        path: '/test/results',
        name: 'testResults',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HearingTestResultsScreen(),
      ),

      // ---------------------------------------------------------
      // 5 Primary Shell Tabs (StatefulShellRoute.indexedStack)
      // ---------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: EchoBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          );
        },
        branches: [
          // Branch 0: Test Intro (Tab 0) - Route 8
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/test',
                name: 'testIntro',
                builder: (context, state) => const HearingTestIntroScreen(),
              ),
            ],
          ),

          // Branch 1: Home Dashboard (Tab 1) - Route 12
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 2: Monitoring (Tab 2) - Route 13
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/monitoring',
                name: 'monitoring',
                builder: (context, state) => const MonitoringScreen(),
              ),
            ],
          ),

          // Branch 3: Reports (Tab 3) - Route 17
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Branch 4: Profile (Tab 4) - Route 22
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ---------------------------------------------------------
      // Sub-Routes (Pushed with Back button)
      // ---------------------------------------------------------
      // Monitoring Sub-routes (14-16)
      GoRoute(
        path: '/monitoring/history',
        name: 'monitoringHistory',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MonitoringHistoryScreen(),
      ),
      GoRoute(
        path: '/monitoring/exposure',
        name: 'exposureDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ExposureDetailScreen(),
      ),
      GoRoute(
        path: '/monitoring/settings',
        name: 'monitoringSettings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MonitoringSettingsScreen(),
      ),

      // Reports Sub-routes (18-21)
      GoRoute(
        path: '/reports/weekly',
        name: 'reportsWeekly',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReportsWeeklyScreen(),
      ),
      GoRoute(
        path: '/reports/exposure',
        name: 'reportsExposure',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReportsExposureScreen(),
      ),
      GoRoute(
        path: '/reports/insights',
        name: 'reportsInsights',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReportsInsightsScreen(),
      ),
      GoRoute(
        path: '/reports/historical',
        name: 'reportsHistorical',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReportsHistoricalScreen(),
      ),

      // Profile Sub-routes (23-28)
      GoRoute(
        path: '/profile/devices',
        name: 'profileDevices',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DeviceManagementScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        name: 'profileNotif',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        name: 'profilePrivacy',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/profile/export',
        name: 'profileExport',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DataExportScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        name: 'profileAbout',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/profile/help',
        name: 'profileHelp',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HelpFaqScreen(),
      ),

      // History Sub-routes (29-32)
      // NOTE: Static routes /history/compare and /history/reminders are declared
      // BEFORE parameterized /history/:testId to avoid greedy segment collisions.
      GoRoute(
        path: '/history',
        name: 'history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HearingHistoryScreen(),
      ),
      GoRoute(
        path: '/history/compare',
        name: 'historyCompare',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TestComparisonScreen(),
      ),
      GoRoute(
        path: '/history/reminders',
        name: 'historyReminders',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TestRemindersScreen(),
      ),
      GoRoute(
        path: '/history/:testId',
        name: 'historyDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => TestDetailScreen(
          testId: state.pathParameters['testId'] ?? 'unknown',
        ),
      ),

      // Audio Personalization Sub-routes (33-36)
      GoRoute(
        path: '/personalization',
        name: 'personalization',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AudioPersonalizationScreen(),
      ),
      GoRoute(
        path: '/personalization/equalizer',
        name: 'personalizationEq',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EqualizerScreen(),
      ),
      GoRoute(
        path: '/personalization/enhancement',
        name: 'personalizationEnhance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HearingEnhancementScreen(),
      ),
      GoRoute(
        path: '/personalization/profiles',
        name: 'personalizationProfiles',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SavedProfilesScreen(),
      ),
    ],
  );
});
