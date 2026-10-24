import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class EchoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const EchoAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: Row(
          children: [
            if (showBackButton)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Go back',
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              )
            else
              const SizedBox(width: AppSpacing.p4),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.sectionHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (actions != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
