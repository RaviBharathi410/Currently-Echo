import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

enum EchoButtonVariant { primary, secondary, ghost }

class EchoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final EchoButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final String? semanticHint;

  const EchoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = EchoButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.semanticHint,
  });

  @override
  State<EchoButton> createState() => _EchoButtonState();
}

class _EchoButtonState extends State<EchoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final double targetScale = (!disableAnimations && isEnabled && _isPressed) ? 0.97 : 1.0;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case EchoButtonVariant.primary:
        backgroundColor = isEnabled ? AppColors.blue500 : AppColors.surfaceSubtle;
        foregroundColor = isEnabled ? AppColors.white : AppColors.textDisabled;
        if (!isEnabled) borderSide = const BorderSide(color: AppColors.border);
        break;
      case EchoButtonVariant.secondary:
        backgroundColor = isEnabled ? AppColors.blue100 : AppColors.surfaceSubtle;
        foregroundColor = isEnabled ? AppColors.blue500 : AppColors.textDisabled;
        borderSide = BorderSide(color: isEnabled ? AppColors.blue400 : AppColors.border);
        break;
      case EchoButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.blue500 : AppColors.textDisabled;
        break;
    }

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      hint: widget.semanticHint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
        child: AnimatedScale(
          scale: targetScale,
          duration: disableAnimations ? Duration.zero : const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Material(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.roundedLg,
              side: borderSide,
            ),
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              onHighlightChanged: isEnabled
                  ? (highlighted) {
                      if (_isPressed != highlighted) {
                        setState(() => _isPressed = highlighted);
                      }
                    }
                  : null,
              borderRadius: AppRadii.roundedLg,
              splashColor: AppColors.splashOverlay,
              highlightColor: AppColors.highlightOverlay,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                  vertical: AppSpacing.p12,
                ),
                child: Center(
                  child: ExcludeSemantics(
                    child: widget.isLoading
                        ? SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon, size: 20.0, color: foregroundColor),
                                const SizedBox(width: AppSpacing.p8),
                              ],
                              Flexible(
                                child: Text(
                                  widget.label,
                                  style: AppTypography.labelLarge.copyWith(color: foregroundColor),
                                  maxLines: 2,
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
        ),
      ),
    );
  }
}
