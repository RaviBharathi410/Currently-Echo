import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

/// Production accessible checkbox component strictly bound to ECHO design tokens.
/// Guarantees a minimum 48x48dp interactive hit area, accessible semantics,
/// and monochromatic light-blue active styling.
class EchoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final String? semanticLabel;

  const EchoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onChanged != null;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: value ? AppColors.blue500 : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.sm / 2),
        border: Border.all(
          color: value ? AppColors.blue500 : AppColors.border,
          width: 2.0,
        ),
      ),
      child: value
          ? const Icon(
              Icons.check,
              size: 16.0,
              color: AppColors.white,
            )
          : null,
    );

    return Semantics(
      checked: value,
      enabled: isInteractive,
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: isInteractive ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p4,
              vertical: AppSpacing.p12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                box,
                if (label != null) ...[
                  const SizedBox(width: AppSpacing.p12),
                  Flexible(child: label!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
