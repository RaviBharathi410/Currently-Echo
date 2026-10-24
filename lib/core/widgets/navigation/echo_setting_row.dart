import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Standardized setting list row matching Board 1 Screen 15 (Profile & Settings).
/// Provides a consistent 48dp touch target, leading icon container, title,
/// optional subtitle, and trailing widget (switch, chevron, or custom).
class EchoSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const EchoSettingRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56.0),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
                vertical: AppSpacing.p12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: AppColors.blue100,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.blue500,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            subtitle!,
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.p12),
                    trailing!,
                  ] else if (onTap != null) ...[
                    const SizedBox(width: AppSpacing.p12),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 22.0,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 72.0, right: AppSpacing.p16),
            child: Divider(
              height: 1.0,
              thickness: 1.0,
              color: AppColors.border,
            ),
          ),
      ],
    );
  }
}
