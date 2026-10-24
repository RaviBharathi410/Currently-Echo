import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Metric stat tile matching Board 1 Screens 7, 8 & 14.
/// Displays an icon, large value, and caption label with tonal blue accents.
/// Resilient to 200% accessibility font scale.
class EchoStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? badgeText;

  const EchoStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.p6,
            runSpacing: AppSpacing.p4,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: AppRadii.roundedSm,
                ),
                child: Icon(
                  icon,
                  color: AppColors.blue500,
                  size: 20.0,
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p8,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue100,
                    borderRadius: AppRadii.roundedPill,
                    border: Border.all(color: AppColors.blue400, width: 1.0),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTypography.captionBold.copyWith(
                      color: AppColors.blue500,
                      fontSize: 10.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.statDisplay,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.p4),
          Text(
            label,
            style: AppTypography.statLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
