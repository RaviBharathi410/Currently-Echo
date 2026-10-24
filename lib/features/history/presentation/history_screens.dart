import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/navigation/echo_app_bar.dart';
import '../../../core/widgets/primitives/echo_button.dart';
import '../../../core/widgets/primitives/echo_card.dart';
import '../../../core/widgets/primitives/echo_filter_chip.dart';
import '../../../core/widgets/primitives/echo_stat_tile.dart';
import '../../../core/widgets/primitives/echo_text.dart';
import '../../../core/widgets/domain/sample_data_tag.dart';

/// Screen 16: Hearing Screening History Screen matching Board 1 Screen 16.
/// Features filter chips for session filtering, aggregate summary stat tiles,
/// and a chronological timeline of completed screening check records.
class HearingHistoryScreen extends StatefulWidget {
  const HearingHistoryScreen({super.key});

  @override
  State<HearingHistoryScreen> createState() => _HearingHistoryScreenState();
}

class _HearingHistoryScreenState extends State<HearingHistoryScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Left Ear', 'Right Ear', 'Recent'];

  static const _historyRecords = [
    (
      id: 'test-104',
      date: 'Today, 10:30 AM',
      title: 'Screening #4 • Balanced',
      summary: 'All 6 frequencies detected within standard range.',
      badge: 'Balanced',
      leftLevel: 'Level 3',
      rightLevel: 'Level 3',
    ),
    (
      id: 'test-103',
      date: 'Oct 10, 2026',
      title: 'Screening #3 • Consistent',
      summary: 'Consistent tone response matching previous baseline.',
      badge: 'Consistent',
      leftLevel: 'Level 3',
      rightLevel: 'Level 4',
    ),
    (
      id: 'test-102',
      date: 'Sep 24, 2026',
      title: 'Screening #2 • Regular Check',
      summary: 'Monthly routine auditory screening session.',
      badge: 'Stable',
      leftLevel: 'Level 3',
      rightLevel: 'Level 3',
    ),
    (
      id: 'test-101',
      date: 'Sep 01, 2026',
      title: 'Screening #1 • Initial Calibration',
      summary: 'Initial baseline screening established on first onboarding.',
      badge: 'Baseline',
      leftLevel: 'Level 4',
      rightLevel: 'Level 4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(
        title: 'Screening History',
        showBackButton: true,
        actions: [
          SampleDataTag(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.p8),
                      child: EchoFilterChip(
                        label: filter,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // 2. Summary Metric Tiles with responsive LayoutBuilder
              LayoutBuilder(
                builder: (context, constraints) {
                  const tileA = EchoStatTile(
                    icon: Icons.history,
                    value: '4 Checks',
                    label: 'Screening Sessions',
                    badgeText: 'Complete',
                  );
                  const tileB = EchoStatTile(
                    icon: Icons.tune,
                    value: 'Level 3 Avg',
                    label: 'Response Average',
                    badgeText: 'Consistent',
                  );

                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  if (constraints.maxWidth < 340 || textScale > 1.3) {
                    return const Column(
                      children: [
                        tileA,
                        SizedBox(height: AppSpacing.p12),
                        tileB,
                      ],
                    );
                  }
                  return const Row(
                    children: [
                      Expanded(child: tileA),
                      SizedBox(width: AppSpacing.p12),
                      Expanded(child: tileB),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.p20),

              // 3. Chronological Records Timeline
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.p8,
                runSpacing: AppSpacing.p4,
                children: [
                  EchoText('Recorded Screening Sessions', variant: EchoTextStyleVariant.labelBold),
                  SampleDataTag(),
                ],
              ),
              const SizedBox(height: AppSpacing.p12),

              ..._historyRecords.map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.p12),
                  child: EchoCard(
                    onTap: () => context.push('/history/${rec.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.p8,
                          runSpacing: AppSpacing.p4,
                          children: [
                            EchoText(rec.date, variant: EchoTextStyleVariant.caption),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.p8,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue100,
                                borderRadius: AppRadii.roundedPill,
                                border: Border.all(color: AppColors.blue400, width: 1.0),
                              ),
                              child: Text(
                                rec.badge,
                                style: AppTypography.captionBold.copyWith(
                                  color: AppColors.blue500,
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.p6),
                        EchoText(rec.title, variant: EchoTextStyleVariant.titleMedium),
                        const SizedBox(height: AppSpacing.p4),
                        EchoText(
                          rec.summary,
                          variant: EchoTextStyleVariant.bodyMedium,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.p12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.p12,
                            runSpacing: AppSpacing.p4,
                            children: [
                              Text(
                                'Left: ${rec.leftLevel}',
                                style: AppTypography.captionBold.copyWith(color: AppColors.blue500),
                              ),
                              Text(
                                'Right: ${rec.rightLevel}',
                                style: AppTypography.captionBold.copyWith(color: AppColors.blue500),
                              ),
                              const Icon(Icons.chevron_right, size: 16.0, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.p12),

              // 4. Sub-Navigation Actions
              EchoButton(
                label: 'Compare Screenings',
                icon: Icons.compare_arrows,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/history/compare'),
              ),
              const SizedBox(height: AppSpacing.p12),
              EchoButton(
                label: 'Screening Reminders',
                icon: Icons.alarm,
                variant: EchoButtonVariant.secondary,
                onPressed: () => context.push('/history/reminders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestComparisonScreen extends StatelessWidget {
  const TestComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Compare Screenings', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Response Comparison', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Compare tone responses between October and September.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TestRemindersScreen extends StatelessWidget {
  const TestRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoAppBar(title: 'Screening Reminders', showBackButton: true),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Reminder Frequency', variant: EchoTextStyleVariant.titleMedium),
                SizedBox(height: AppSpacing.p8),
                EchoText('Monthly recurring prompt active.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TestDetailScreen extends StatelessWidget {
  final String testId;

  const TestDetailScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EchoAppBar(title: 'Test Record $testId', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: EchoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EchoText('Record Identifier: $testId', variant: EchoTextStyleVariant.titleMedium),
                const SizedBox(height: AppSpacing.p8),
                const EchoText('Detailed frequency responses for Left and Right ear.', variant: EchoTextStyleVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
