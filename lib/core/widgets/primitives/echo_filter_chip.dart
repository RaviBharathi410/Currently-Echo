import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Selectable filter chip pill matching Board 1 Screen 16.
/// Features a full 48dp touch target and clear semantic states.
/// Fully resilient to 200% accessibility font scale.
class EchoFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const EchoFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.roundedPill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 48.0),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue500 : AppColors.white,
            borderRadius: AppRadii.roundedPill,
            border: Border.all(
              color: isSelected ? AppColors.blue500 : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16.0,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.p6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelBold.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
