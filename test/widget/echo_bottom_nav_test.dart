import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/widgets/navigation/echo_bottom_nav.dart';

void main() {
  group('EchoBottomNav Widget Tests', () {
    const items = [
      EchoNavItem(icon: Icons.hearing, label: 'Test', fullLabel: 'Hearing Test'),
      EchoNavItem(icon: Icons.dashboard, label: 'Home', fullLabel: 'Home Dashboard'),
      EchoNavItem(icon: Icons.graphic_eq, label: 'Monitor', fullLabel: 'Sound Exposure Monitoring'),
      EchoNavItem(icon: Icons.insert_chart_outlined, label: 'Reports', fullLabel: 'Weekly Reports'),
      EchoNavItem(icon: Icons.person_outline, label: 'Profile', fullLabel: 'Profile & Settings'),
    ];

    testWidgets('exposes selected state and tab semantics with clamped scaling', (tester) async {
      int selectedIndex = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EchoBottomNav(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
              items: items,
            ),
          ),
        ),
      );

      // Verify Tab 2 (Home Dashboard) semantics
      final dashboardFinder = find.bySemanticsLabel('Home Dashboard, Tab 2 of 5');
      expect(dashboardFinder, findsOneWidget);

      final semantics = tester.getSemantics(dashboardFinder);
      final data = semantics.getSemanticsData();
      expect(data.label, equals('Home Dashboard, Tab 2 of 5'));
      expect(data.flagsCollection.isSelected.name, equals('isTrue'));
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      // Tap Tab 0 (Hearing Test)
      final testTabFinder = find.bySemanticsLabel('Hearing Test, Tab 1 of 5');
      expect(testTabFinder, findsOneWidget);
      await tester.tap(testTabFinder);
      expect(selectedIndex, equals(0));
    });

    testWidgets('resilient to 200% system text scaling without overflow (clamped scaler)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              bottomNavigationBar: EchoBottomNav(
                currentIndex: 0,
                onTap: (_) {},
                items: items,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Phase 3: sliding nav pill alignment updates smoothly with currentIndex', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EchoBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: items,
            ),
          ),
        ),
      );

      // Tab 0 -> alignment (-1.0, 0.0)
      var alignWidget = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(alignWidget.alignment, equals(const Alignment(-1.0, 0.0)));
      expect(alignWidget.duration, equals(const Duration(milliseconds: 250)));

      // Re-pump with Tab 2 (center)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EchoBottomNav(
              currentIndex: 2,
              onTap: (_) {},
              items: items,
            ),
          ),
        ),
      );
      await tester.pump();

      alignWidget = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(alignWidget.alignment, equals(const Alignment(0.0, 0.0)));

      // Re-pump with Tab 4 (far right)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EchoBottomNav(
              currentIndex: 4,
              onTap: (_) {},
              items: items,
            ),
          ),
        ),
      );
      await tester.pump();

      alignWidget = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(alignWidget.alignment, equals(const Alignment(1.0, 0.0)));
    });

    testWidgets('Phase 3: Reduce Motion (disableAnimations: true) sets sliding pill duration to Duration.zero', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: EchoBottomNav(
                currentIndex: 1,
                onTap: (_) {},
                items: items,
              ),
            ),
          ),
        ),
      );

      final alignWidget = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(alignWidget.duration, equals(Duration.zero));
    });
  });
}
