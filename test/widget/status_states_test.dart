import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/primitives/echo_card.dart';
import 'package:echo/core/widgets/primitives/echo_text.dart';

void main() {
  group('Icon-Plus-Label Status & Error Treatment Tests', () {
    testWidgets('Status and error states convey status via Icon + Label and tonal styling (no red)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Center(
              child: EchoCard(
                semanticLabel: 'Error status: Device disconnected. Please check headphone connection.',
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.blue500, // Non-hue error color: strictly blue500
                      size: 24.0,
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EchoText(
                            'Connection Unavailable',
                            variant: EchoTextStyleVariant.labelLarge,
                            color: AppColors.blue500,
                          ),
                          EchoText(
                            'Headphones disconnected. Reconnect to resume.',
                            variant: EchoTextStyleVariant.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // 1. Verify an Icon is present
      expect(find.byType(Icon), findsOneWidget);
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.icon, equals(Icons.error_outline));
      expect(iconWidget.color, equals(AppColors.blue500));

      // 2. Verify explicit Text labels are present
      expect(find.text('Connection Unavailable'), findsOneWidget);
      expect(find.text('Headphones disconnected. Reconnect to resume.'), findsOneWidget);

      // 3. Verify zero off-palette colors (specifically zero red)
      final allTextWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in allTextWidgets) {
        final color = text.style?.color;
        if (color != null) {
          expect(color.toARGB32() != 0xFFFF0000, isTrue);
          expect(color.toARGB32() != 0xFFB00020, isTrue); // Material 2 error red
          expect(color.toARGB32() != 0xFFBA1A1A, isTrue); // Material 3 error red
        }
      }

      // 4. Verify Semantics output
      final semantics = tester.getSemantics(find.byType(EchoCard));
      expect(semantics.label, contains('Error status: Device disconnected.'));
    });
  });
}
