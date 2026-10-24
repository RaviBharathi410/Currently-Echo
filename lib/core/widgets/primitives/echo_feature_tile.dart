import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Standard feature tile with light-blue icon tile, title, multi-line subtitle,
/// and optional trailing action.
/// Matches Board 2 Screens 1 & 5 and Board 1 Screen 7.
class EchoFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool hasBorder;

  const EchoFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.p16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon square
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: AppRadii.roundedMd,
            ),
            child: Icon(
              icon,
              color: AppColors.blue500,
              size: 22.0,
            ),
          ),
          const SizedBox(width: AppSpacing.p16),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.p4),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Trailing widget (if any)
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.p12),
            trailing!,
          ],
        ],
      ),
    );

    if (!hasBorder && onTap == null) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.roundedLg,
        border: hasBorder ? Border.all(color: AppColors.border, width: 1.0) : null,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.roundedLg,
          child: content,
        ),
      ),
    );
  }
}
