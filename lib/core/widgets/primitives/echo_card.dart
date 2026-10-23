import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';

class EchoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const EchoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.p16),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.roundedLg,
          splashColor: onTap != null ? AppColors.splashOverlay : Colors.transparent,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        container: true,
        button: onTap != null,
        label: semanticLabel,
        excludeSemantics: true,
        child: cardWidget,
      );
    }

    if (onTap != null) {
      return MergeSemantics(
        child: Semantics(
          button: true,
          child: cardWidget,
        ),
      );
    }

    return MergeSemantics(child: cardWidget);
  }
}
