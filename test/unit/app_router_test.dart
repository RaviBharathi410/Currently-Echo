import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echo/app/router/app_router.dart';
import 'package:echo/features/auth/application/auth_provider.dart';
import 'package:echo/features/onboarding/application/onboarding_provider.dart';

void main() {
  group('AppRouter 36-Route Canonical Inventory Tests', () {
    test('Router contains exactly 36 registered route entries across all branches', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier()),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      final routes = router.configuration.routes;

      int countRoutes(List<RouteBase> routeList) {
        int count = 0;
        for (final route in routeList) {
          if (route is GoRoute) {
            count++;
          } else if (route is StatefulShellRoute) {
            for (final branch in route.branches) {
              count += countRoutes(branch.routes);
            }
          } else if (route is ShellRoute) {
            count += countRoutes(route.routes);
          }
        }
        return count;
      }

      final totalRouteCount = countRoutes(routes);
      expect(totalRouteCount, equals(36), reason: 'Canonical route table must have exactly 36 routes');
    });

    test('Initial location is /dashboard when user is authenticated and onboarded', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier(initialAuthenticated: true)),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: true)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router.routeInformationProvider.value.uri.path, equals('/dashboard'));
    });

    test('Initial location is /welcome when user is not yet onboarded', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier()..signOut()),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: false)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router.routeInformationProvider.value.uri.path, equals('/welcome'));
    });

    test('History routes precedence: compare and reminders exist ahead of :testId', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier()),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: true)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      final routes = router.configuration.routes.whereType<GoRoute>().toList();

      final compareIndex = routes.indexWhere((r) => r.path == '/history/compare');
      final remindersIndex = routes.indexWhere((r) => r.path == '/history/reminders');
      final detailIndex = routes.indexWhere((r) => r.path == '/history/:testId');

      expect(compareIndex, isNot(equals(-1)));
      expect(remindersIndex, isNot(equals(-1)));
      expect(detailIndex, isNot(equals(-1)));
      expect(compareIndex, lessThan(detailIndex), reason: '/history/compare must precede /history/:testId');
      expect(remindersIndex, lessThan(detailIndex), reason: '/history/reminders must precede /history/:testId');
    });

    test('Test modals (/test/in-progress, /test/paused, /test/results) use rootNavigatorKey', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier()),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(initialComplete: true)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      final routes = router.configuration.routes.whereType<GoRoute>().toList();

      final inProgressRoute = routes.firstWhere((r) => r.path == '/test/in-progress');
      final pausedRoute = routes.firstWhere((r) => r.path == '/test/paused');
      final resultsRoute = routes.firstWhere((r) => r.path == '/test/results');

      expect(inProgressRoute.parentNavigatorKey, equals(rootNavigatorKey));
      expect(pausedRoute.parentNavigatorKey, equals(rootNavigatorKey));
      expect(resultsRoute.parentNavigatorKey, equals(rootNavigatorKey));
    });

    test('Redirect Loop Prevention: unauthenticated user accessing /auth stays on /auth', () {
      final redirect = appRouterRedirect(
        path: '/auth',
        isAuthenticated: false,
        isOnboardingComplete: false,
      );
      expect(redirect, isNull, reason: 'Unauthenticated user on /auth must not be redirected (avoids loop)');
    });

    test('Redirect Loop Prevention: unauthenticated user accessing protected route is routed to /auth', () {
      final redirect = appRouterRedirect(
        path: '/dashboard',
        isAuthenticated: false,
        isOnboardingComplete: false,
      );
      expect(redirect, equals('/auth'), reason: 'Protected routes require authentication and route to /auth');

      // Unauthenticated user on /welcome stays on /welcome without redirect
      final welcomeRedirect = appRouterRedirect(
        path: '/welcome',
        isAuthenticated: false,
        isOnboardingComplete: false,
      );
      expect(welcomeRedirect, isNull, reason: 'First-launch /welcome entry route must not redirect');
    });

    test('Redirect Loop Prevention: complete results -> onboarding complete -> /dashboard cleanly without loop', () {
      // 1. When completing onboarding and on /dashboard, redirect returns null (allowed)
      final dashboardRedirect = appRouterRedirect(
        path: '/dashboard',
        isAuthenticated: true,
        isOnboardingComplete: true,
      );
      expect(dashboardRedirect, isNull);

      // 2. If user tries to visit /welcome when onboarded, redirects to /dashboard
      final welcomeRedirect = appRouterRedirect(
        path: '/welcome',
        isAuthenticated: true,
        isOnboardingComplete: true,
      );
      expect(welcomeRedirect, equals('/dashboard'));

      // 3. If user is authenticated but not onboarded, visiting /welcome goes to /profile-setup
      final incompleteRedirect = appRouterRedirect(
        path: '/welcome',
        isAuthenticated: true,
        isOnboardingComplete: false,
      );
      expect(incompleteRedirect, equals('/profile-setup'));
    });

    test('RouterRefreshListenable notifies on auth and onboarding state changes while preserving GoRouter instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final routerInitial = container.read(appRouterProvider);
      final refreshListenable = container.read(routerRefreshListenableProvider);

      int notifyCount = 0;
      refreshListenable.addListener(() {
        notifyCount++;
      });

      // Trigger auth state change
      container.read(authProvider.notifier).signIn();
      expect(notifyCount, equals(1), reason: 'RouterRefreshListenable must notify on auth change');

      // Trigger onboarding state change
      container.read(onboardingProvider.notifier).completeOnboarding();
      expect(notifyCount, equals(2), reason: 'RouterRefreshListenable must notify on onboarding change');

      // GoRouter instance remains stable (not recreated)
      final routerAfter = container.read(appRouterProvider);
      expect(identical(routerInitial, routerAfter), isTrue, reason: 'appRouterProvider must not recreate GoRouter on state changes');
    });
  });
}
