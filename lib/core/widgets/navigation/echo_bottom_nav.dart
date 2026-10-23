import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class EchoNavItem {
  final IconData icon;
  final String label; // Short display label: 'Test', 'Home', 'Monitor', 'Reports', 'Profile'
  final String? fullLabel; // Full name for accessibility and tooltip

  const EchoNavItem({
    required this.icon,
    required this.label,
    this.fullLabel,
  });

  String get effectiveFullLabel => fullLabel ?? label;
}

const List<EchoNavItem> kEchoDefaultNavItems = [
  EchoNavItem(icon: Icons.hearing, label: 'Test', fullLabel: 'Hearing Test'),
  EchoNavItem(icon: Icons.dashboard, label: 'Home', fullLabel: 'Home Dashboard'),
  EchoNavItem(icon: Icons.graphic_eq, label: 'Monitor', fullLabel: 'Sound Exposure Monitoring'),
  EchoNavItem(icon: Icons.insert_chart_outlined, label: 'Reports', fullLabel: 'Weekly Reports'),
  EchoNavItem(icon: Icons.person_outline, label: 'Profile', fullLabel: 'Profile & Settings'),
];

class EchoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EchoNavItem> items;

  const EchoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = kEchoDefaultNavItems,
  }) : assert(items.length == 5, 'ECHO Bottom Nav must contain exactly 5 items.');

  @override
  Widget build(BuildContext context) {
    // Clamp bottom nav text scaling between 1.0 and 1.3 to avoid clipping while preserving readable labels
    final clampedScaler = MediaQuery.textScalerOf(context).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p8,
              vertical: AppSpacing.p8,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double tabWidth = constraints.maxWidth / items.length;
                final double alignX = items.length > 1
                    ? (currentIndex * 2.0 / (items.length - 1)) - 1.0
                    : 0.0;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Sliding Nav Pill
                    Positioned.fill(
                      child: AnimatedAlign(
                        alignment: Alignment(alignX, 0.0),
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                        child: SizedBox(
                          width: tabWidth,
                          height: 48.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.blue100,
                                borderRadius: AppRadii.roundedPill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Foreground Tab Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: Semantics(
                            selected: isSelected,
                            label: '${item.effectiveFullLabel}, Tab ${index + 1} of 5',
                            button: true,
                            child: Tooltip(
                              message: item.effectiveFullLabel,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 48.0),
                                child: InkWell(
                                  onTap: () => onTap(index),
                                  borderRadius: AppRadii.roundedPill,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.p8,
                                      horizontal: AppSpacing.p4,
                                    ),
                                    child: ExcludeSemantics(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            item.icon,
                                            size: 22.0,
                                            color: isSelected ? AppColors.blue500 : AppColors.textSecondary,
                                          ),
                                          const SizedBox(height: AppSpacing.p4),
                                          Text(
                                            item.label,
                                            style: AppTypography.caption.copyWith(
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                              color: isSelected ? AppColors.blue500 : AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
