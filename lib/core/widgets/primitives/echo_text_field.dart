import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import 'echo_text.dart';

/// Production text field component bound strictly to ECHO design tokens.
/// Satisfies WCAG 48dp touch targets, uses DM Sans typography, and formats
/// errors with an explicit [Icons.error_outline] and "Error: " prefix.
class EchoTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;

  const EchoTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          EchoText(
            label!,
            variant: EchoTextStyleVariant.labelLarge,
            color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.p6),
        ],
        Semantics(
          label: label,
          hint: hintText,
          textField: true,
          enabled: enabled,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              enabled: enabled,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.blue500,
              decoration: InputDecoration(
                filled: true,
                fillColor: enabled ? AppColors.white : AppColors.surfaceSubtle,
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDisabled,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                  vertical: AppSpacing.p12,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                // Suppress standard Material error display (custom icon+label row used below)
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.blue500 : AppColors.border,
                    width: hasError ? 2.0 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: const BorderSide(
                    color: AppColors.borderFunctional,
                    width: 2.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.p6),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16.0,
                  color: AppColors.blue500,
                ),
                const SizedBox(width: AppSpacing.p6),
                Expanded(
                  child: EchoText(
                    'Error: $errorText',
                    variant: EchoTextStyleVariant.caption,
                    color: AppColors.blue500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
