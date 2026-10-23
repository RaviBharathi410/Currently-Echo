import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// Responsive container that constrains the mobile application to a centered
/// 430dp column on wide desktop viewports with elegant outer subtle framing.
class EchoResponsiveFrame extends StatelessWidget {
  final Widget child;

  const EchoResponsiveFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 430.0) {
          return ColoredBox(
            color: AppColors.surfaceSubtle,
            child: Center(
              child: SizedBox(
                width: 430.0,
                height: double.infinity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: AppShadows.soft,
                  ),
                  child: ClipRect(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(430.0, MediaQuery.of(context).size.height),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
