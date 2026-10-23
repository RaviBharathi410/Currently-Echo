import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primitives/echo_card.dart';
import '../../../../core/widgets/primitives/echo_text.dart';

class ReadinessItemData {
  final String title;
  final String description;

  const ReadinessItemData({
    required this.title,
    required this.description,
  });
}

const List<ReadinessItemData> kDefaultReadinessItems = [
  ReadinessItemData(
    title: 'Find a quiet space',
    description: 'Minimize ambient room noise and background chatter.',
  ),
  ReadinessItemData(
    title: 'Wear headphones',
    description: 'Ensure both left and right earcups fit securely.',
  ),
  ReadinessItemData(
    title: 'Set device volume to moderate level',
    description: 'Keep comfort levels balanced throughout.',
  ),
];

/// An interactive readiness checklist for hearing screening.
/// Guarantees:
/// - 48dp minimum touch target per checklist row
/// - Explicit Semantics(checked: ...) on each row
/// - Circular progress ring in blue100/blue400/blue500
/// - Live-region announcement of completion ratio ("X of 3 checks complete")
/// - Animation skip when disableAnimations is enabled
class HearingReadinessChecklist extends StatelessWidget {
  final Set<int> checkedIndices;
  final ValueChanged<int> onToggle;
  final List<ReadinessItemData> items;

  const HearingReadinessChecklist({
    super.key,
    required this.checkedIndices,
    required this.onToggle,
    this.items = kDefaultReadinessItems,
  });

  @override
  Widget build(BuildContext context) {
    final int totalCount = items.length;
    final int checkedCount = checkedIndices.length;
    final double progress = totalCount > 0 ? (checkedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

    return EchoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Live Progress Ring
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EchoText(
                      'Before You Begin',
                      variant: EchoTextStyleVariant.cardTitle,
                    ),
                    const SizedBox(height: 2.0),
                    EchoText(
                      checkedCount == totalCount
                          ? 'All readiness checks complete.'
                          : 'Complete all checks to start.',
                      variant: EchoTextStyleVariant.caption,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.p12),

              // Circular Progress Ring with Live-Region Semantics
              Semantics(
                liveRegion: true,
                label: '$checkedCount of $totalCount checks complete',
                child: SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring Animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 4.0,
                            backgroundColor: AppColors.blue100,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.blue500,
                            ),
                          );
                        },
                      ),
                      // Text in Ring Center
                      EchoText(
                        '$checkedCount/$totalCount',
                        variant: EchoTextStyleVariant.labelMedium,
                        color: AppColors.blue500,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p16),

          // Tappable Checklist Rows
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.p8),
            _ChecklistRow(
              item: items[i],
              index: i,
              isChecked: checkedIndices.contains(i),
              onTap: () => onToggle(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final ReadinessItemData item;
  final int index;
  final bool isChecked;
  final VoidCallback onTap;

  const _ChecklistRow({
    required this.item,
    required this.index,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: isChecked,
      label: '${item.title}. ${item.description}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          splashColor: AppColors.splashOverlay,
          highlightColor: AppColors.highlightOverlay,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.p8,
                horizontal: AppSpacing.p4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accessible Checkbox Box (24x24 inside 48dp touch row)
                  Container(
                    width: 24.0,
                    height: 24.0,
                    margin: const EdgeInsets.only(top: 2.0),
                    decoration: BoxDecoration(
                      color: isChecked ? AppColors.blue500 : AppColors.white,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: isChecked ? AppColors.blue500 : AppColors.blue400,
                        width: 1.5,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check,
                            size: 16.0,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.p12),
                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EchoText(
                          item.title,
                          variant: EchoTextStyleVariant.labelLarge,
                        ),
                        const SizedBox(height: 2.0),
                        EchoText(
                          item.description,
                          variant: EchoTextStyleVariant.caption,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
