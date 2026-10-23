import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/core/theme/app_colors.dart';
import 'package:echo/core/theme/app_theme.dart';
import 'package:echo/core/widgets/primitives/echo_text_field.dart';

void main() {
  group('EchoTextField Widget & Accessibility Tests', () {
    testWidgets('enforces 48dp minimum tap target and renders label and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: EchoTextField(
                label: 'Full Name',
                hintText: 'Enter your name',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);

      final box = tester.renderObject<RenderBox>(find.byType(TextField));
      expect(box.size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('error state renders Icon(Icons.error_outline) and Error: prefix in blue500', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: EchoTextField(
                label: 'Email',
                errorText: 'Please enter a valid email address',
              ),
            ),
          ),
        ),
      );

      // Icon + "Error: " label check
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error: Please enter a valid email address'), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, equals(AppColors.blue500));
    });
  });
}
