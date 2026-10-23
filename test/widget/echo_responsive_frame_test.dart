import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/widgets/layout/echo_responsive_frame.dart';
import 'package:echo/main.dart';

void main() {
  group('EchoResponsiveFrame Widget Tests', () {
    testWidgets('Constrains wide viewport to centered 430dp column', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late Size measuredChildSize;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => EchoResponsiveFrame(child: child!),
          home: Builder(
            builder: (context) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  measuredChildSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return const Scaffold(
                    body: Text('Responsive Child Content'),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(measuredChildSize.width, 430.0, reason: 'Child should receive maxWidth 430.0 on wide screens');
      expect(find.text('Responsive Child Content'), findsOneWidget);
    });

    testWidgets('Preserves full width on narrow viewports (<= 430dp)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late Size measuredChildSize;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => EchoResponsiveFrame(child: child!),
          home: Builder(
            builder: (context) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  measuredChildSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return const Scaffold(
                    body: Text('Mobile Child Content'),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(measuredChildSize.width, 390.0, reason: 'Child should receive full width on narrow screens');
      expect(find.text('Mobile Child Content'), findsOneWidget);
    });

    testWidgets('Constrains full app with GoRouter on wide viewports (1200x800)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: EchoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the inner SizedBox of EchoResponsiveFrame
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 430.0,
      );
      expect(sizedBoxFinder, findsOneWidget, reason: 'EchoResponsiveFrame should render a 430dp wide container');

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);
      final firstScaffoldSize = tester.getSize(scaffoldFinder.first);
      debugPrint('TEST firstScaffoldSize: $firstScaffoldSize');
      expect(firstScaffoldSize.width, 430.0);
    });
  });
}
