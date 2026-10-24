import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Clean card container with subtle border matching the board style.
/// Used extensively across Dashboard, Reports, History, and Settings.
/// Resilient to 200% accessibility font scale.
class EchoSectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const EchoSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.p16),
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.p16,
                right: AppSpacing.p16,
                top: AppSpacing.p16,
                bottom: AppSpacing.p8,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.p8,
                runSpacing: AppSpacing.p4,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        style: AppTypography.cardTitle,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.p4),
                        Text(
                          subtitle!,
                          style: AppTypography.caption,
                        ),
                      ],
                    ],
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
