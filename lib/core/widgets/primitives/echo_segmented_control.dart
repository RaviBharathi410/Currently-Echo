import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';

class EchoSegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const EchoSegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Generic pill segmented control matching Board 1 & 2.
/// Used in Sound Monitoring (Daily/Weekly/Monthly), Listening Reports, and History.
/// Fully resilient to 200% font scale.
class EchoSegmentedControl<T> extends StatelessWidget {
  final List<EchoSegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  const EchoSegmentedControl({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppRadii.roundedPill,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == selectedValue;

          return Expanded(
            child: Semantics(
              selected: isSelected,
              button: true,
              label: option.label,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44.0),
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: AppRadii.roundedPill,
                  child: AnimatedContainer(
                    duration: disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p8,
                      vertical: AppSpacing.p8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.white : AppColors.transparent,
                      borderRadius: AppRadii.roundedPill,
                      boxShadow: isSelected ? AppShadows.soft : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (option.icon != null) ...[
                            Icon(
                              option.icon,
                              size: 16.0,
                              color: isSelected
                                  ? AppColors.blue500
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.p4),
                          ],
                          Flexible(
                            child: Text(
                              option.label,
                              style: AppTypography.labelBold.copyWith(
                                color: isSelected
                                    ? AppColors.blue500
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
