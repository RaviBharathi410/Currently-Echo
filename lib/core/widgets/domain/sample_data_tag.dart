import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class SampleDataTag extends StatelessWidget {
  const SampleDataTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sample data: simulated non-clinical screening metric',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p8,
          vertical: AppSpacing.p4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: AppRadii.roundedSm,
          border: Border.all(color: AppColors.blue400, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14.0, color: AppColors.blue500),
            const SizedBox(width: AppSpacing.p4),
            Text(
              'Sample data',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
