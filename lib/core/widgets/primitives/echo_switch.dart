import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';

/// Production accessible toggle switch component strictly bound to ECHO design tokens.
/// Guarantees a minimum 48x48dp interactive hit area, accessible semantics,
/// and monochromatic light-blue active styling.
class EchoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  const EchoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onChanged != null;

    return Semantics(
      toggled: value,
      enabled: isInteractive,
      label: semanticLabel,
      child: InkWell(
        onTap: isInteractive ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48.0,
              height: 28.0,
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                color: value ? AppColors.blue500 : AppColors.surfaceSubtle,
                border: Border.all(
                  color: value ? AppColors.blue500 : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
