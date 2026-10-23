import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/widgets/domain/sound_wave_hero.dart';

void main() {
  group('SoundWaveHero Widget Tests', () {
    testWidgets('renders 7 harmonic acoustic bars and excludes animation ticks from semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundWaveHero(),
            ),
          ),
        ),
      );

      // Verify Semantics wrapper
      final semanticsFinder = find.byType(SoundWaveHero);
      expect(semanticsFinder, findsOneWidget);

      final semantics = tester.getSemantics(semanticsFinder);
      final data = semantics.getSemanticsData();
      expect(data.label, equals('Acoustic sound wave visualization'));

      // Verify row of 7 bars
      final containers = find.descendant(
        of: find.byType(SoundWaveHero),
        matching: find.byType(Container),
      );
      expect(containers, findsNWidgets(7));
    });

    testWidgets('animates and updates heights over time when animations are enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundWaveHero(animateInTest: true),
            ),
          ),
        ),
      );

      // Capture initial heights of middle bar
      final containers = find.descendant(
        of: find.byType(SoundWaveHero),
        matching: find.byType(Container),
      );
      final initialSize = tester.getSize(containers.at(3));

      // Advance clock by 350ms (quarter cycle)
      await tester.pump(const Duration(milliseconds: 350));
      final nextSize = tester.getSize(containers.at(3));

      expect(initialSize.height != nextSize.height, isTrue,
          reason: 'SoundWaveHero middle bar must animate height over time');
    });

    testWidgets('Reduce Motion (disableAnimations: true) freezes bars at static harmonic heights', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SoundWaveHero(),
              ),
            ),
          ),
        ),
      );

      final containers = find.descendant(
        of: find.byType(SoundWaveHero),
        matching: find.byType(Container),
      );
      final initialSize = tester.getSize(containers.at(3));

      // Advance clock
      await tester.pump(const Duration(milliseconds: 500));
      final nextSize = tester.getSize(containers.at(3));

      // Height must be unchanged under Reduce Motion
      expect(initialSize.height, equals(nextSize.height));
      expect(initialSize.height, equals((48.0 + 76.0) * 0.5)); // Static balanced midpoint
    });

    testWidgets('resilient to 200% text scale without overflow', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SoundWaveHero(),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
