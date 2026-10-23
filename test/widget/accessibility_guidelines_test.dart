import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/widgets/primitives/echo_button.dart';
import 'package:echo/core/widgets/navigation/echo_bottom_nav.dart';

void main() {
  group('Flutter Accessibility Guidelines (Phase 1)', () {
    testWidgets('EchoButton meets androidTapTargetGuideline and iOSTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EchoButton(
                label: 'Confirm Tone',
                onPressed: () {},
                semanticHint: 'Proceed to next tone step',
              ),
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('EchoBottomNav meets accessibility tap target and label guidelines', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EchoBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                EchoNavItem(icon: Icons.hearing, label: 'Test', fullLabel: 'Hearing Test'),
                EchoNavItem(icon: Icons.dashboard, label: 'Home', fullLabel: 'Home Dashboard'),
                EchoNavItem(icon: Icons.graphic_eq, label: 'Monitor', fullLabel: 'Sound Exposure Monitoring'),
                EchoNavItem(icon: Icons.insert_chart_outlined, label: 'Reports', fullLabel: 'Weekly Reports'),
                EchoNavItem(icon: Icons.person_outline, label: 'Profile', fullLabel: 'Profile & Settings'),
              ],
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}
