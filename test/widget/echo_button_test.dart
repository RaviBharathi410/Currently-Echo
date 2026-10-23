import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/widgets/primitives/echo_button.dart';

void main() {
  group('EchoButton Widget & Accessibility Tests', () {
    testWidgets('enforces 48dp minimum tap target and exposes Semantics', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EchoButton(
                label: 'Confirm Tone',
                onPressed: () => tapped = true,
                semanticHint: 'Proceed to next tone step',
              ),
            ),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(EchoButton));
      expect(buttonSize.width >= 48.0, isTrue);
      expect(buttonSize.height >= 48.0, isTrue);

      final semantics = tester.getSemantics(find.byType(EchoButton));
      final data = semantics.getSemanticsData();
      expect(data.label, equals('Confirm Tone'));
      expect(data.hint, equals('Proceed to next tone step'));
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled.name, equals('isTrue'));
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await tester.tap(find.byType(EchoButton));
      expect(tapped, isTrue);
    });

    testWidgets('resilient to 200% system text scale without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Center(
                child: SizedBox(
                  width: 200.0,
                  child: EchoButton(
                    label: 'Very Long Button Label Designed for Scale',
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled button does not trigger callback and has disabled semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: EchoButton(
                label: 'Disabled Action',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(EchoButton));
      final data = semantics.getSemanticsData();
      expect(data.label, equals('Disabled Action'));
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled.name, equals('isFalse'));
      expect(data.hasAction(SemanticsAction.tap), isFalse);
    });

    testWidgets('Phase 3: press-down triggers AnimatedScale to 0.97 and release restores 1.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EchoButton(
                label: 'Press Scale Action',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, equals(1.0));

      final gesture = await tester.startGesture(tester.getCenter(find.byType(EchoButton)));
      await tester.pump(const Duration(milliseconds: 120));

      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, equals(0.97));

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 120));

      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, equals(1.0));
    });

    testWidgets('Phase 3: Reduce Motion (disableAnimations: true) skips press-scale animation', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: EchoButton(
                  label: 'Motion Reduced',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(tester.getCenter(find.byType(EchoButton)));
      await tester.pump(const Duration(milliseconds: 120));

      // Scale must stay strictly 1.0 when disableAnimations is enabled
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, equals(1.0));

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, equals(1.0));
    });

    testWidgets('Phase 3: Disabled button never compresses on touch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: EchoButton(
                label: 'Disabled No Scale',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, equals(1.0));
    });
  });
}
